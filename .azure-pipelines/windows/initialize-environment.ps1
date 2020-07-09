# Copyright (c)

[CmdletBinding()]
Param(
    [string]$ForceAllPortsToRebuildKey = ''
)

$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWORD -Force
#New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWORD -Force

# Disable UAC
Write-Host "Disabling UAC"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Force
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" -Force
Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green  
#Disable-UserAccessControl

Get-LocalUser -Name "VssAdministrator" | Enable-LocalUser

Function Get-TempFilePath {
  Param(
    [String]$Extension
  )
  if ([String]::IsNullOrWhiteSpace($Extension)) {
    throw 'Missing Extension'
  }
  $tempPath = [System.IO.Path]::GetTempPath()
  $tempName = [System.IO.Path]::GetRandomFileName() + '.' + $Extension
  return Join-Path $tempPath $tempName
}
if (-not [string]::IsNullOrEmpty($AdminUserPassword)) {
  Write-Host "AdminUser password supplied; switching to VssAdministrator"
  $PsExecPath = Get-TempFilePath -Extension 'exe'
  Write-Host "Downloading psexec to $PsExecPath"
  & curl.exe -L -o $PsExecPath -s -S https://live.sysinternals.com/PsExec64.exe
  $PsExecArgs = @(
    '-u',
    'VssAdministrator',
    '-p',
    $AdminUserPassword,
    '-accepteula',
    '-h',
    'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    '-ExecutionPolicy',
    'Unrestricted',
    '-File',
    $PSCommandPath
  )
  Write-Host "Executing $PsExecPath " + @PsExecArgs
  $proc = Start-Process -FilePath $PsExecPath -ArgumentList $PsExecArgs -Wait -PassThru
  Write-Host 'Cleaning up...'
#  Remove-Item $PsExecPath
  exit $proc.ExitCode
}

#Get-Command -Module Microsoft.PowerShell.LocalAccounts |Format-List | Out-Host
#Get-LocalUser |Format-List | Out-Host
#Get-LocalUser -Name 'VssAdministrator' | Select-Object * |Format-List | Out-Host
#Add-LocalGroupMember -Group "Administrators" -Member "Administrator" –Verbose |Format-List | Out-Host

# Set PowerShell execution policy to Bypass
Write-Host "Changing PS execution policy to Bypass"
if (-not [string]::IsNullOrEmpty($AdminUserPassword)) {
  Write-Host "AdminUser password supplied; switching to VssAdministrator"
  $PsExecPath = Get-TempFilePath -Extension 'exe'
  Write-Host "Downloading psexec to $PsExecPath"
  & curl.exe -L -o $PsExecPath -s -S https://live.sysinternals.com/PsExec64.exe
  $PsExecArgs = @(
    '-u',
    'VssAdministrator',
    '-p',
    $AdminUserPassword,
    '-accepteula',
    '-h',
    'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    '-ExecutionPolicy',
    'Bypass',
    '-Scope',
    'MachinePolicy'
  )
  Write-Host "Executing $PsExecPath " + @PsExecArgs
  $proc = Start-Process -FilePath $PsExecPath -ArgumentList $PsExecArgs -Wait -PassThru
  Write-Host 'Cleaning up...'
#  Remove-Item $PsExecPath
  exit $proc.ExitCode
}

#Add-LocalGroupMember -Group "Administrators" -Member "VssAdministrator" –Verbose |Format-List | Out-Host
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope MachinePolicy -ErrorAction Continue | Out-Null
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -ErrorAction Ignore -Scope CurrentUser
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -ErrorAction Ignore -Scope LocalMachine
#Write-Host "PS policy updated"

# fsutil behavior set SymlinkEvaluation [L2L:{0|1}] | [L2R:{0|1}] | [R2R:{0|1}] | [R2L:{0|1}]
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkLocalToLocalEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkLocalToRemoteEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkRemoteToLocalEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkRemoteToRemoteEvaluation" -Value "1" -Force

Write-Host "Enable long path behavior"
# See https://docs.microsoft.com/en-us/windows/desktop/fileio/naming-a-file#maximum-path-length-limitation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value  "1" -Force

[Environment]::SetEnvironmentVariable("VSCMD_DEBUG", "1", "Machine")
[Environment]::SetEnvironmentVariable("VSCMD_SKIP_SENDTELEMETRY", "1", "Machine")

Write-Host 'Cleaning buildtrees'
Remove-Item buildtrees\* -Recurse -Force -errorAction silentlycontinue

Write-Host 'Cleaning packages'
Remove-Item packages\* -Recurse -Force -errorAction silentlycontinue

#Write-Host "Installing PowerShell Core"
#Write-Host "=========================="

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Write-Host "Downloading..."
#$msiPath = "$env:TEMP\PowerShell-Core.msi"
#(New-Object Net.WebClient).DownloadFile('https://github.com/PowerShell/PowerShell/releases/download/v6.2.3/PowerShell-6.2.3-win-x64.msi', $msiPath)

#Write-Host "Installing..."
#cmd /c start /wait msiexec /i $msiPath /quiet REGISTER_MANIFEST=1
#del $msiPath

#pwsh --version

#Write-Host "PowerShell Core Installed"

exit 0