$root = 'd:\Websites\MediTrust'
$htmlPath = Join-Path $root 'index.html'
$html = Get-Content $htmlPath -Raw
$matches = [regex]::Matches($html,"https://bootstrapmade.com[^\"\s<>]+") | ForEach-Object { $_.Value } | Sort-Object -Unique
New-Item -ItemType Directory -Force (Join-Path $root 'img') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $root 'css') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $root 'js') | Out-Null
foreach($u in $matches){
    if($u -match '\.(png|jpg|jpeg|webp|gif)$'){
        $name = [IO.Path]::GetFileName($u)
        $out = Join-Path $root ('img\' + $name)
        if(-not (Test-Path $out)){
            Invoke-WebRequest -Uri $u -OutFile $out -UseBasicParsing -ErrorAction SilentlyContinue
        }
        $html = $html -replace [regex]::Escape($u), ('img/' + $name)
    } elseif($u -match '\.css$'){
        $name = [IO.Path]::GetFileName($u)
        $out = Join-Path $root ('css\' + $name)
        if(-not (Test-Path $out)){
            Invoke-WebRequest -Uri $u -OutFile $out -UseBasicParsing -ErrorAction SilentlyContinue
        }
        $html = $html -replace [regex]::Escape($u), ('css/' + $name)
    } elseif($u -match '\.js$'){
        $name = [IO.Path]::GetFileName($u)
        $out = Join-Path $root ('js\' + $name)
        if(-not (Test-Path $out)){
            Invoke-WebRequest -Uri $u -OutFile $out -UseBasicParsing -ErrorAction SilentlyContinue
        }
        $html = $html -replace [regex]::Escape($u), ('js/' + $name)
    } else {
        $html = $html -replace [regex]::Escape($u), '#'
    }
}
# remove google fonts and preconnect entries
$html = $html -replace '<link[^>]*fonts.googleapis.com[^>]*>',''
$html = $html -replace '<link[^>]*fonts.gstatic.com[^>]*>',''
# remove analytics and cloudflare & email decode scripts
# remove analytics and cloudflare & email decode scripts
$html = $html -replace "https://www.googletagmanager.com/gtag/js[^\"\s]*",""
$html = $html -replace '<script[^>]*static.cloudflareinsights.com[^>]*</script>',''
$html = $html -replace '<script[^>]*cdn-cgi/scripts[^>]*</script>',''
# replace bootstrapmade demo page links with relative links (strip domain)
$html = $html -replace 'https://bootstrapmade.com/content/demo/MediTrust/',''
Set-Content -Path $htmlPath -Value $html -Encoding UTF8
Write-Output 'Localization complete.'
