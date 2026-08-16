$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Output "PRAZER Web Preview server running at http://127.0.0.1:$port/"
} catch {
    Write-Output "Failed to start listener on port $port, trying 8088..."
    $port = 8088
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://127.0.0.1:$port/")
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    Write-Output "PRAZER Web Preview server running at http://127.0.0.1:$port/"
}

$htmlPath = Join-Path $PSScriptRoot "index.html"
$logoPath = Join-Path $PSScriptRoot "logo.jpeg"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.AbsolutePath

        if ($urlPath -eq "/logo.jpeg" -and (Test-Path $logoPath)) {
            $bytes = [System.IO.File]::ReadAllBytes($logoPath)
            $response.ContentType = "image/jpeg"
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $bytes = [System.IO.File]::ReadAllBytes($htmlPath)
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        $response.OutputStream.Close()
    } catch {
        # continue loop
    }
}
