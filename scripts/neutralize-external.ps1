$p='d:\Websites\MediTrust\index.html'
$s=Get-Content $p -Raw
$s = $s -replace '<link[^>]*href="https://[^"]*"[^>]*>',''
$s = $s -replace '(?s)<script[^>]*src="https://[^"]*"[^>]*>.*?</script>',''
$s = $s -replace 'href="https://[^"]*"','href="#"'
$s = $s -replace 'src="https://[^"]*"','src="img/logo.png"'
Set-Content -Path $p -Value $s -Encoding UTF8
Write-Output 'External links neutralized.'
