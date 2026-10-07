$ErrorActionPreference = 'Stop'
Get-Command dotnet -ErrorAction Stop | Out-Null
$project = Join-Path $PSScriptRoot '../src/DimDimWebApp/DimDimWebApp.csproj'
dotnet restore $project
if ($LASTEXITCODE -ne 0) { throw 'Falha no restore. Verifique SDK .NET 8 e acesso ao NuGet.' }
dotnet build $project --configuration Release --no-restore
if ($LASTEXITCODE -ne 0) { throw 'Falha de compilação. Não prossiga com a implantação.' }
Write-Host 'Compilação validada. Agora execute 01-provisionar.ps1.'
