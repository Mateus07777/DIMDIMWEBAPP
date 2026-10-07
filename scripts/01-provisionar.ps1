param(
    [Parameter(Mandatory=$true)][ValidatePattern('^[a-z][a-z0-9-]{5,30}$')][string]$Prefixo,
    [string]$Regiao = 'brazilsouth',
    [string]$RegiaoSql = '',
    [string]$RegiaoMonitor = ''
)
. "$PSScriptRoot/common.ps1"
Get-Command az -ErrorAction Stop | Out-Null
Get-Command dotnet -ErrorAction Stop | Out-Null
& "$PSScriptRoot/00-validar.ps1"
if (!$RegiaoSql) { $RegiaoSql = $Regiao }
if (!$RegiaoMonitor) { $RegiaoMonitor = $Regiao }
Invoke-Az @('account','show','-o','none')
$rg = "$Prefixo-rg"; $plan = "$Prefixo-plan"; $app = "$Prefixo-web"
$server = "$Prefixo-sql"; $database = 'dimdimdb'; $workspace = "$Prefixo-logs"; $insights = "$Prefixo-insights"
$statePath = Join-Path $PSScriptRoot '../.azure-state.json'
if (Test-Path $statePath) { throw 'Já existe .azure-state.json. Para republicar, use 02-deploy.ps1; para novo ambiente, use outra cópia da pasta.' }
Write-Host 'Será criado App Service B1 + Azure SQL Basic + monitoramento. Esses recursos consomem créditos/cobrança da assinatura.'
$sqlUser = Read-Host 'Defina o usuário administrador SQL (letras e números; não use admin)'
if ($sqlUser -notmatch '^[a-zA-Z][a-zA-Z0-9]{3,25}$' -or $sqlUser -in @('admin','administrator','sa','root')) { throw 'Nome de usuário inválido.' }
$secure = Read-Host 'Defina a senha SQL (mín. 12 caracteres; maiúscula, minúscula, número e símbolo; sem ponto e vírgula ou aspas)' -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
if ($password.Length -lt 12 -or $password -notmatch '[A-Z]' -or $password -notmatch '[a-z]' -or $password -notmatch '[0-9]' -or $password -notmatch '[!@#$%^&*()_+=?-]' -or $password -match '[;"''\s]') { throw 'Senha fora do padrão solicitado.' }
try {
    # Registro de provedores é idempotente.
    foreach ($provider in @('Microsoft.Web','Microsoft.Sql','Microsoft.Insights','Microsoft.OperationalInsights')) {
        Invoke-Az @('provider','register','--namespace',$provider,'--wait','-o','none')
    }
    Invoke-Az @('group','create','-n',$rg,'-l',$Regiao,'-o','none')
    # Não cria máquinas virtuais nem containers: apenas serviços PaaS.
    Invoke-Az @('appservice','plan','create','-g',$rg,'-n',$plan,'-l',$Regiao,'--is-linux','--sku','B1','-o','none')
    Invoke-Az @('webapp','create','-g',$rg,'-p',$plan,'-n',$app,'--runtime','DOTNETCORE:8.0','-o','none')
    Invoke-Az @('webapp','update','-g',$rg,'-n',$app,'--https-only','true','-o','none')
    Invoke-Az @('webapp','config','set','-g',$rg,'-n',$app,'--always-on','true','--min-tls-version','1.2','-o','none')
    Invoke-Az @('sql','server','create','-g',$rg,'-n',$server,'-l',$RegiaoSql,'-u',$sqlUser,'-p',$password,'-o','none')
    Invoke-Az @('sql','db','create','-g',$rg,'-s',$server,'-n',$database,'--service-objective','Basic','--backup-storage-redundancy','Local','-o','none')
    # Libera só IPs de saída possíveis deste App Service, sem abrir para toda a Azure.
    $ips = (Invoke-Az @('webapp','show','-g',$rg,'-n',$app,'--query','possibleOutboundIpAddresses','-o','tsv')).Trim().Split(',') | Select-Object -Unique
    $i = 0
    foreach ($ip in $ips) {
        if ($ip) { $i++; Invoke-Az @('sql','server','firewall-rule','create','-g',$rg,'-s',$server,'-n',"app-$i",'--start-ip-address',$ip,'--end-ip-address',$ip,'-o','none') }
    }
    Invoke-Az @('monitor','log-analytics','workspace','create','-g',$rg,'-n',$workspace,'-l',$RegiaoMonitor,'--retention-time','30','-o','none')
    $wsId = (Invoke-Az @('monitor','log-analytics','workspace','show','-g',$rg,'-n',$workspace,'--query','id','-o','tsv')).Trim()
    # ARM evita depender da instalação da extensão app-insights.
    $props = @{Application_Type='web'; WorkspaceResourceId=$wsId; IngestionMode='LogAnalytics'} | ConvertTo-Json -Compress
    $propsFile = [IO.Path]::GetTempFileName()
    try {
        $props | Set-Content $propsFile -Encoding UTF8
        Invoke-Az @('resource','create','-g',$rg,'-n',$insights,'--resource-type','Microsoft.Insights/components','--api-version','2020-02-02','-l',$RegiaoMonitor,'--properties',"@$propsFile",'-o','none')
    } finally { Remove-Item $propsFile -Force -ErrorAction SilentlyContinue }
    $ai = (Invoke-Az @('resource','show','-g',$rg,'-n',$insights,'--resource-type','Microsoft.Insights/components','--api-version','2020-02-02','--query','properties.ConnectionString','-o','tsv')).Trim()
    $connection = "Server=tcp:$server.database.windows.net,1433;Initial Catalog=$database;User ID=$sqlUser;Password=$password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    # Segredos fora do código e sem saída no console. Arquivo temporário removido no finally.
    $temp = [IO.Path]::GetTempFileName()
    try {
        @{ConnectionStrings__DefaultConnection=$connection; APPLICATIONINSIGHTS_CONNECTION_STRING=$ai; ASPNETCORE_ENVIRONMENT='Production'; Logging__ApplicationInsights__LogLevel__Default='Information'; SCM_DO_BUILD_DURING_DEPLOYMENT='false'} | ConvertTo-Json | Set-Content $temp -Encoding UTF8
        Invoke-Az @('webapp','config','appsettings','set','-g',$rg,'-n',$app,'--settings',"@$temp",'-o','none')
    } finally { Remove-Item $temp -Force -ErrorAction SilentlyContinue }
    $hostname = (Invoke-Az @('webapp','show','-g',$rg,'-n',$app,'--query','defaultHostName','-o','tsv')).Trim()
    @{ResourceGroup=$rg; AppName=$app; Server=$server; Database=$database; Insights=$insights; Workspace=$workspace; Url="https://$hostname"} | ConvertTo-Json | Set-Content $statePath -Encoding UTF8
    Write-Host 'Recursos criados. Execute ./scripts/02-deploy.ps1'
} finally { $password = $null; $connection = $null; $secure.Dispose() }
