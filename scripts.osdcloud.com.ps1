#Requires -RunAsAdministrator

[CmdletBinding()]
param()
$ScriptName = 'scripts.osdcloud.com'
$ScriptVersion = '23.7.16.4'
Write-Host -ForegroundColor Cyan "[i] $ScriptName version $ScriptVersion"

# OSDCloudScripts
$FileName = 'OSDCloudScripts.zip'
$Url = 'https://github.com/OSDeploy/OSDCloudScripts/archive/refs/heads/main.zip'

# OSDCloudScriptsGUI
$GUIFileName = 'OSDCloudScriptsGUI.zip'
$GUIUrl = 'https://github.com/OSDeploy/OSDCloudScriptsGUI/archive/refs/heads/main.zip'

#region OSDCloudScripts
    $OutFile = Join-Path $env:TEMP $FileName
    # Remove existing Zip file
    if (Test-Path $OutFile) {
        Remove-Item $OutFile -Force
    }

    # Download Zip file
    Invoke-WebRequest -Uri $Url -OutFile $OutFile

    if (Test-Path $OutFile) {
        Write-Host -ForegroundColor Green "[+] OSDCloudScripts downloaded to $OutFile"
    }
    else {
        Write-Host -ForegroundColor Red "[!] OSDCloudScripts could not be downloaded"
        Break
    }

    # Expand Zip file
    $CurrentFile = Get-Item -Path $OutFile
    $DestinationPath = Join-Path $CurrentFile.DirectoryName $CurrentFile.BaseName
    if (Test-Path $DestinationPath) {
        Remove-Item $DestinationPath -Force -Recurse
    }
    Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force
    if (Test-Path $DestinationPath) {
        Write-Host -ForegroundColor Green "[+] OSDCloudScripts expanded to $DestinationPath"
    }
    else {
        Write-Host -ForegroundColor Red "[!] OSDCloudScripts could not be expanded to $DestinationPath"
        Break
    }

    # Set Scripts Path
    $ScriptFiles = Get-ChildItem -Path $DestinationPath -Directory | Select-Object -First 1 -ExpandProperty FullName
    if (Test-Path $ScriptFiles) {
        Write-Host -ForegroundColor Green "[+] OSDCloudScripts is set to $ScriptFiles"
    }
    else {
        Write-Host -ForegroundColor Red "[!] OSDCloudScripts could not be created at $ScriptFiles"
        Break
    }
#endregion

#region OSDCloudScriptsGUI
    $GUIOutFile = Join-Path $env:TEMP $GUIFileName
    # Remove existing Zip file
    if (Test-Path $GUIOutFile) {
        Remove-Item $GUIOutFile -Force
    }

    # Download Zip file
    Invoke-WebRequest -Uri $GUIUrl -OutFile $GUIOutFile

    if (Test-Path $GUIOutFile) {
        Write-Host -ForegroundColor Green "[+] OSDCloudScriptsGUI downloaded to $GUIOutFile"
    }
    else {
        Write-Host -ForegroundColor Red "[!] OSDCloudScriptsGUI could not be downloaded"
        Break
    }

    # Expand Zip file
    $CurrentFile = Get-Item -Path $GUIOutFile
    $DestinationPath = Join-Path $CurrentFile.DirectoryName $CurrentFile.BaseName
    if (Test-Path $DestinationPath) {
        Remove-Item $DestinationPath -Force -Recurse
    }
    Expand-Archive -Path $GUIOutFile -DestinationPath $DestinationPath -Force
    if (Test-Path $DestinationPath) {
        Write-Host -ForegroundColor Green "[+] OSDCloudScriptsGUI expanded to $DestinationPath"
    }
    else {
        Write-Host -ForegroundColor Red "[!] OSDCloudScriptsGUI could not be expanded to $DestinationPath"
        Break
    }


    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    # PowerShell Module
    if ($isAdmin) {
        $ModulePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\OSDCloudScriptsGUI"
        if (Test-Path $ModulePath) {
            Remove-Item $ModulePath -Recurse -Force
        }
        # Copy Module
        $SourceModuleRoot = Get-ChildItem -Path $DestinationPath -Directory | Select-Object -First 1 -ExpandProperty FullName
        Copy-Item -Path $SourceModuleRoot -Destination $ModulePath -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $ModulePath) {
            Write-Host -ForegroundColor Green "[+] OSDCloudScriptsGUI Module copied to $ModulePath"
        }
        else {
            Write-Host -ForegroundColor Red "[!] OSDCloudScriptsGUI Module could not be copied to $ModulePath"
            Break
        }
        try {
            Import-Module $ModulePath -Force -ErrorAction Stop
            Write-Host -ForegroundColor Green "[+] Import-Module $ModulePath -Force"
        }
        catch {
            Write-Host -ForegroundColor Red "[!] Import-Module $ModulePath -Force"
            Write-Error $_.Exception.Message
            Break
        }
    }
    else {
        $ModulePath = "$env:TEMP\OSDCloudScriptsGUI\OSDCloudScriptsGUI-main\OSDCloudScriptsGUI.psm1"
        try {
            Import-Module $ModulePath -Force -ErrorAction Stop
            Write-Host -ForegroundColor Green "[+] Import-Module $ModulePath -Force"
        }
        catch {
            Write-Host -ForegroundColor Red "[!] Import-Module $ModulePath -Force"
            Write-Error $_.Exception.Message
            Break
        }
    }

    Write-Host -ForegroundColor Green "[+] Start-OSDCloudScriptsGUI -Path $ScriptFiles"
#endregion


if ($isAdmin) {
    Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    Write-Host -ForegroundColor Cyan "Start-OSDCloudScriptsGUI can be run in the new PowerShell window"
}

Start-OSDCloudScriptsGUI -Path $ScriptFiles