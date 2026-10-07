$ErrorActionPreference = 'Stop'
function Invoke-Az {
    param([string[]]$AzArgs)
    $result = & az @AzArgs --only-show-errors
    if ($LASTEXITCODE -ne 0) { throw 'Comando Azure CLI falhou. Resolva o erro acima antes de continuar.' }
    return $result
}
function Get-State {
    $path = Join-Path $PSScriptRoot '../.azure-state.json'
    if (!(Test-Path $path)) { throw 'Execute scripts/01-provisionar.ps1 primeiro.' }
    return Get-Content $path -Raw | ConvertFrom-Json
}
