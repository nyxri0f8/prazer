$destDir = "C:\Users\nyx41\PortableGit"
$zipFile = "C:\Users\nyx41\mingit.zip"
$gitExe = "$destDir\cmd\git.exe"

if (-not (Test-Path $gitExe)) {
    Write-Output "Downloading Portable Git..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/MinGit-2.44.0-64-bit.zip" -OutFile $zipFile -UseBasicParsing
    
    Write-Output "Extracting Git..."
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Expand-Archive -Path $zipFile -DestinationPath $destDir -Force
    Remove-Item $zipFile -Force
}

Write-Output "Git installed successfully:"
& $gitExe --version

# Add to user environment PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*PortableGit\cmd*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;C:\Users\nyx41\PortableGit\cmd", "User")
    Write-Output "Added Git to User PATH!"
}

# Run Git Init and Setup
Set-Location "c:\Users\nyx41\OneDrive\Desktop\prazer"
& $gitExe init
& $gitExe config user.name "nyxri0f8"
& $gitExe config user.email "nyxri0f8@users.noreply.github.com"
& $gitExe add -A
& $gitExe commit -m "feat: complete PRAZER engine with Indian Patent Office #1 priority, cloud neural search, and automated APK build"
& $gitExe branch -M main

Write-Output "Git status:"
& $gitExe status
