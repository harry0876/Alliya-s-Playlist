# Scan music without changing any MP3 files.
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$music = Join-Path $root 'music'
try { $shell = New-Object -ComObject Shell.Application; $folder = $shell.Namespace($music) } catch { $folder = $null }
$songs = @(Get-ChildItem -LiteralPath $music -File -Filter '*.mp3' | ForEach-Object {
    $title = ''
    if ($folder) {
        try { $item = $folder.ParseName($_.Name); $title = [string]$item.ExtendedProperty('System.Title') } catch { $title = '' }
    }
    if ([string]::IsNullOrWhiteSpace($title)) {
        $title = $_.BaseName
        # Strip track-number prefixes and long numeric IDs, preserving names like 2 BHK.
        $title = $title -replace '^\s*\d{1,3}\s*[-._)]+\s*', ''
        $title = $title -replace '[\[(]\s*\d{5,}\s*[\])]', ''
        $title = $title -replace '(?<![\p{L}\d])\d{5,}(?![\p{L}\d])', ''
        $title = $title -replace '_+', ' '
        $title = ($title -replace '\s+', ' ').Trim(' ', '-', '.', '_')
        if ([string]::IsNullOrWhiteSpace($title)) { $title = 'Untitled song' }
    }
    @{ title = $title.Trim(); file = $_.Name }
} | Sort-Object { $_.title })
$json = ConvertTo-Json -InputObject $songs -Depth 3
[System.IO.File]::WriteAllText((Join-Path $root 'songs.js'), ('window.SONGS = ' + $json + ';'), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ('Found ' + $songs.Count + ' MP3 songs.')
