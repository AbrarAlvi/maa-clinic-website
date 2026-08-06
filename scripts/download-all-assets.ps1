$root = 'd:\Websites\MediTrust'
$urls = @(
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/favicon.png',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/apple-touch-icon.png',

  'https://bootstrapmade.com/content/vendors/bootstrap/css/bootstrap.min.css',
  'https://bootstrapmade.com/content/vendors/bootstrap-icons/bootstrap-icons.css',
  'https://bootstrapmade.com/content/vendors/aos/aos.css',
  'https://bootstrapmade.com/content/vendors/fontawesome-free/css/all.min.css',
  'https://bootstrapmade.com/content/vendors/swiper/swiper-bundle.min.css',
  'https://bootstrapmade.com/content/vendors/glightbox/css/glightbox.min.css',

  'https://bootstrapmade.com/content/demo/MediTrust/assets/css/main.css',

  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/showcase-1.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/facilities-1.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/clients/clients-1.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/clients/clients-2.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/clients/clients-3.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/clients/clients-4.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/cardiology-3.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/neurology-2.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/orthopedics-4.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/pediatrics-3.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/oncology-4.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/emergency-2.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-3.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-7.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-1.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-9.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-5.webp',
  'https://bootstrapmade.com/content/demo/MediTrust/assets/img/health/staff-12.webp',

  'https://bootstrapmade.com/cdn-cgi/scripts/5c5dd728/cloudflare-static/email-decode.min.js',
  'https://bootstrapmade.com/content/vendors/bootstrap/js/bootstrap.bundle.min.js',
  'https://bootstrapmade.com/content/vendors/php-email-form/validate.js',
  'https://bootstrapmade.com/content/vendors/aos/aos.js',
  'https://bootstrapmade.com/content/vendors/purecounter/purecounter_vanilla.js',
  'https://bootstrapmade.com/content/vendors/swiper/swiper-bundle.min.js',
  'https://bootstrapmade.com/content/vendors/imagesloaded/imagesloaded.pkgd.min.js',
  'https://bootstrapmade.com/content/vendors/isotope-layout/isotope.pkgd.min.js',
  'https://bootstrapmade.com/content/vendors/glightbox/js/glightbox.min.js',

  'https://bootstrapmade.com/content/demo/MediTrust/assets/js/main.js'
)

New-Item -ItemType Directory -Force (Join-Path $root 'img') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $root 'css') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $root 'js') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $root 'vendor') | Out-Null

foreach($u in $urls){
  try{
    $uri = [Uri]$u
    $file = [IO.Path]::GetFileName($uri.LocalPath)
    if($u -match '/assets/img/'){
      $out = Join-Path $root ('img\' + $file)
      $rel = 'img/' + $file
    } elseif($u -match '/vendors/' -and $u -match '\.css$'){
      $out = Join-Path $root ('vendor\' + $file)
      $rel = 'vendor/' + $file
    } elseif($u -match '/vendors/' -and $u -match '\.js$'){
      $out = Join-Path $root ('vendor\' + $file)
      $rel = 'vendor/' + $file
    } elseif($u -match '/assets/css/' -or $u -match '/assets/.*\.css' -or $u -match '\/css\/'){
      $out = Join-Path $root ('css\' + $file)
      $rel = 'css/' + $file
    } elseif($u -match '/assets/js/' -or $u -match '\/assets\/.*\.js' -or $u -match '\/js\/'){
      $out = Join-Path $root ('js\' + $file)
      $rel = 'js/' + $file
    } else {
      $out = Join-Path $root ('vendor\' + $file)
      $rel = 'vendor/' + $file
    }
    if(-not (Test-Path $out)){
      Write-Output "Downloading $u -> $out"
      Invoke-WebRequest -Uri $u -OutFile $out -UseBasicParsing -ErrorAction Stop
    } else {
      Write-Output "Already exists: $out"
    }
    # update index.html
    $indexPath = Join-Path $root 'index.html'
    $index = Get-Content $indexPath -Raw
    $escaped = [regex]::Escape($u)
    $index = [regex]::Replace($index, $escaped, $rel)
    Set-Content -Path $indexPath -Value $index -Encoding UTF8
  } catch{
    Write-Output ("Failed: " + $u + " -> " + $_.Exception.Message)
  }
}
Write-Output 'Done.'
