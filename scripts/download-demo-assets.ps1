$root = 'd:\Websites\MediTrust'
$demoUrl = 'https://bootstrapmade.com/content/demo/MediTrust/'
Write-Output "Fetching $demoUrl"
$resp = Invoke-WebRequest -Uri $demoUrl -UseBasicParsing -ErrorAction Stop
$content = $resp.Content
$pattern = 'https?://[^"\s<>]+\.(?:png|jpg|jpeg|webp|gif|svg|css|js)'
$matches = [regex]::Matches($content, $pattern) | ForEach-Object { $_.Value } | Sort-Object -Unique
Write-Output ("Found {0} assets" -f $matches.Count)
foreach($u in $matches){
    try{
        $rel = $u -replace 'https://bootstrapmade.com/content/demo/MediTrust/', ''
        if($rel -match '^assets/img/'){
            $localPath = Join-Path $root ('img\' + ($rel -replace '^assets/img/',''))
        } elseif($rel -match '^content/vendors/'){
            $localPath = Join-Path $root ('vendor\' + ($rel -replace '^content/vendors/',''))
        } elseif($rel -match '^assets/|^content/demo/MediTrust/assets/'){
            # css/js under assets
            $localPath = Join-Path $root (($rel -replace '^assets/','') -replace '/','\\')
            # fallback to css or js folders
            if($localPath -match '\.css$'){ $localPath = Join-Path $root ('css\' + [IO.Path]::GetFileName($localPath)) }
            if($localPath -match '\.js$'){ $localPath = Join-Path $root ('js\' + [IO.Path]::GetFileName($localPath)) }
        } else {
            $localPath = Join-Path $root ('assets\' + ($rel -replace '/','\\'))
        }
        $dir = Split-Path $localPath -Parent
        if(-not (Test-Path $dir)){ New-Item -ItemType Directory -Force $dir | Out-Null }
        if(-not (Test-Path $localPath)){
            Write-Output ("Downloading: $u -> $localPath")
            Invoke-WebRequest -Uri $u -OutFile $localPath -UseBasicParsing -ErrorAction SilentlyContinue
        } else {
            Write-Output ("Exists: $localPath")
        }
        # replace references in index.html
        $index = Get-Content (Join-Path $root 'index.html') -Raw
        $localRel = $localPath -replace [regex]::Escape($root + '\\'), ''
        $localRel = $localRel -replace '\\\\','/'
        $index = $index -replace [regex]::Escape($u), $localRel
        Set-Content -Path (Join-Path $root 'index.html') -Value $index -Encoding UTF8
    } catch{
        Write-Output ("Failed to download " + $u + ": " + $_.Exception.Message)
    }
}
Write-Output 'Asset download and replacement complete.'
