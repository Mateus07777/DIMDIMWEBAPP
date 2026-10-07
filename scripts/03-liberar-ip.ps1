param([Parameter(Mandatory=$true)][string]$Ip)
. "$PSScriptRoot/common.ps1"
$parsed = $null
if (![Net.IPAddress]::TryParse($Ip, [ref]$parsed) -or $parsed.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetwork) { throw 'Informe seu IPv4 público.' }
$state = Get-State
Invoke-Az @('sql','server','firewall-rule','create','-g',$state.ResourceGroup,'-s',$state.Server,'-n','evidencia-local','--start-ip-address',$Ip,'--end-ip-address',$Ip,'-o','none')
Write-Host 'IP liberado para consulta SQL. No editor de consultas do portal você também pode usar a opção de liberar o IP detectado.'
