Function InstallWindowsEXTWDK {
    Write-Host 'Installing Windows Mode Driver 10 ...'
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
    $wdkPath = "${env:ProgramFiles(x86)}\Windows Kits\10"
    $process = Expand-Archive -Path "$wdkPath\Vsix\VS2019\WDK.vsix" -DestinationPath "C:\temp" -Force -PassThru
    $process = Copy-Item -Path 'C:\temp\$MSBuild' -Destination $vsPath\MSBuild -Force -Recurse -PassThru
    $exitCode = $process.ExitCode
    if ($exitCode -eq 0) {
      Write-Host 'Installation successful!'
            return $exitCode
        }
        else {
            Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."
            return $exitCode
        }
    }
    catch
    {
        Write-Host -Object "Failed to install the Executable $Name"
        Write-Host -Object $_.Exception.Message
        return -1
    }
}

InstallWindowsEXTWDK