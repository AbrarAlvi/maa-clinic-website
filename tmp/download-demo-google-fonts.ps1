$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$url = 'https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&family=Raleway:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap'
$content = Invoke-WebRequest -Uri $url -UseBasicParsing
$cssPath = Join-Path $root 'tmp\remote-fonts.css'
Set-Content -Path $cssPath -Value $content.Content -Encoding utf8
$fonts = [regex]::Matches($content.Content, 'https://fonts.gstatic.com/[^)\s"'']+') | ForEach-Object { $_.Value } | Select-Object -Unique
$out = Join-Path $root 'vendor\fonts'
New-Item -ItemType Directory -Force -Path $out | Out-Null
foreach ($u in $fonts) {
    $name = [System.IO.Path]::GetFileName($u.Split('?')[0])
    $local = Join-Path $out $name
    if (-not (Test-Path $local)) {
        Invoke-WebRequest -Uri $u -OutFile $local -UseBasicParsing
        Write-Host "DOWNLOADED $name"
    } else {
        Write-Host "EXISTS $name"
    }
}
Write-Host "Saved remote fonts CSS to $cssPath"