$root = 'D:\Websites\MediTrust'
$port = 8000
$prefix = "http://127.0.0.1:$port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving $root at $prefix`nPress Ctrl+C to stop."

function Get-ContentType($ext){
 switch ($ext.ToLower()){
  '.html' { 'text/html' }
  '.htm'  { 'text/html' }
  '.css'  { 'text/css' }
  '.js'   { 'application/javascript' }
  '.json' { 'application/json' }
  '.png'  { 'image/png' }
  '.jpg'  { 'image/jpeg' }
  '.jpeg' { 'image/jpeg' }
  '.webp' { 'image/webp' }
  '.svg'  { 'image/svg+xml' }
  '.ico'  { 'image/x-icon' }
  '.woff2'{ 'font/woff2' }
  '.woff' { 'font/woff' }
  '.ttf'  { 'font/ttf' }
  default { 'application/octet-stream' }
 }
}

try{
 while ($listener.IsListening) {
  $context = $listener.GetContext()
  $req = $context.Request
  $res = $context.Response
  $urlPath = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath)
  $relativePath = $urlPath.TrimStart('/') -replace '/','\\'
  if ([string]::IsNullOrWhiteSpace($relativePath)) { $relativePath = 'index.html' }
  $filePath = Join-Path $root $relativePath
  if (-not (Test-Path $filePath)){
    $res.StatusCode = 404
    $msg = "404 Not Found"
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($msg)
    $res.ContentLength64 = $buffer.Length
    $res.OutputStream.Write($buffer,0,$buffer.Length)
    $res.OutputStream.Close()
    continue
  }
  $ext = [System.IO.Path]::GetExtension($filePath)
  $contentType = Get-ContentType $ext
  try{
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $res.ContentType = $contentType
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes,0,$bytes.Length)
  } catch {
    $res.StatusCode = 500
    $err = "500 Internal Server Error"
    $buf = [System.Text.Encoding]::UTF8.GetBytes($err)
    $res.ContentLength64 = $buf.Length
    $res.OutputStream.Write($buf,0,$buf.Length)
  }
  $res.OutputStream.Close()
 }
} finally {
 $listener.Stop()
 $listener.Close()
}
