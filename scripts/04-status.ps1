. "$PSScriptRoot/common.ps1"
$s = Get-State
Invoke-Az @('webapp','show','-g',$s.ResourceGroup,'-n',$s.AppName,'--query','{Nome:name,Estado:state,Host:defaultHostName}','-o','table')
Invoke-Az @('sql','db','show','-g',$s.ResourceGroup,'-s',$s.Server,'-n',$s.Database,'--query','{Nome:name,Estado:status,SKU:sku.name}','-o','table')
Invoke-Az @('resource','show','-g',$s.ResourceGroup,'-n',$s.Insights,'--resource-type','Microsoft.Insights/components','--api-version','2020-02-02','--query','{Nome:name,Regiao:location}','-o','table')
Write-Host $s.Url
