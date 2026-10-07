. "$PSScriptRoot/common.ps1"
$s = Get-State
Write-Host "Excluir o grupo $($s.ResourceGroup) remove app, banco e monitoramento, incluindo todos os dados."
$confirm = Read-Host 'Digite o nome exato do grupo para excluir (somente após a correção do professor)'
if ($confirm -cne $s.ResourceGroup) { throw 'Cancelado.' }
Invoke-Az @('group','delete','-n',$s.ResourceGroup,'--yes','-o','none')
Remove-Item "$PSScriptRoot/../.azure-state.json" -Force
