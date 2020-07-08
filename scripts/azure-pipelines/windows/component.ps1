#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;[Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

Write-Host "Installing Windows SDK 2004 (10.0.19041.0)..." -ForegroundColor Cyan
Write-Host "Downloading..."
$exePath = "$env:temp\winsdksetup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/p/?linkid=2120843', $exePath)
Write-Host "Installing..."
cmd /c start /wait $exePath /features + /quiet
Remove-Item $exePath
Write-Host "Installed" -ForegroundColor Green


Write-Host "Installing WDK 2004 (10.0.19041.0)..." -ForegroundColor Cyan
Write-Host "Downloading..."
$exePath = "$env:temp\wdksetup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/?linkid=2128854', $exePath)
Write-Host "Installing..."
cmd /c start /wait $exePath /features + /quiet
Remove-Item $exePath -Force -ErrorAction Ignore
$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
#if (-not (Test-Path $vsPath)) {
#    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community"
#}
#if (-not (Test-Path $vsPath)) {
#  return
#}
Write-Host "Installing Visual Studio 2019 WDK extension..."
Start-Process "$vsPath\Common7\IDE\VSIXInstaller.exe" "/a /q /f /sp `"${env:ProgramFiles(x86)}\Windows Kits\10\Vsix\VS2019\WDK.vsix`"" -Wait
Write-Host "Installed" -ForegroundColor Green


$vsixPath = "$env:TEMP\llvm.vsix"
Write-Host "Downloading llvm.vsix..."
(New-Object Net.WebClient).DownloadFile('https://llvmextensions.gallerycdn.vsassets.io/extensions/llvmextensions/llvm-toolchain/1.0.359557/1556628491732/llvm.vsix', $vsixPath)
$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
#if (-not (Test-Path $vsPath)) {
#    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community"
#}
#if (-not (Test-Path $vsPath)) {
#  return
#}
Write-Host "Installing LLVM extension..."
Start-Process "$vsPath\Common7\IDE\VSIXInstaller.exe" "/a /q /f /sp $vsixPath" -Wait
Remove-Item $vsixPath -Force -ErrorAction Ignore
Write-Host "Installed" -ForegroundColor Green

exit 0