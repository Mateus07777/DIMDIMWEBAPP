. "$PSScriptRoot/common.ps1"
$state = Get-State
$root = (Resolve-Path "$PSScriptRoot/..").Path
$publish = Join-Path $root 'artifacts/publish'
$zip = Join-Path $root 'artifacts/deploy.zip'
if (Test-Path $publish) { Remove-Item $publish -Recurse -Force }
New-Item $publish -ItemType Directory -Force | Out-Null
dotnet publish "$root/src/DimDimWebApp/DimDimWebApp.csproj" --configuration Release --output $publish
if ($LASTEXITCODE -ne 0) { throw 'Publicação .NET falhou; nenhum deploy efetuado.' }
if (Test-Path $zip) { Remove-Item $zip -Force }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open(
    $zip, [System.IO.Compression.ZipArchiveMode]::Create
)
try {
    $base = (Resolve-Path $publish).Path
    Get-ChildItem $base -Recurse -File | ForEach-Object {
        $entry = $_.FullName.Substring($base.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $archive, $_.FullName, $entry
        ) | Out-Null
    }
} finally {
    $archive.Dispose()
}
Invoke-Az @('webapp','deploy','-g',$state.ResourceGroup,'-n',$state.AppName,'--src-path',$zip,'--type','zip','--clean','true','--restart','true','-o','none')
Write-Host "Deploy concluído: $($state.Url)"
Write-Host 'Abra a URL. O primeiro início cria as tabelas no Azure SQL se o banco estiver vazio.'

