#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.PSMySetup' -ErrorAction Continue 2>&1 | Out-Null;
$private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
$MySetup = Import-Module $myModulePath -Scope Local -AsCustomObject;
Invoke-KNMain {
    $BIN_DIR = 'C:\bin';
    $DL_DIR = 'C:\work\dl';

    & $MySetup.'Invoke-WithNoDebug'.Script {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
        Install-Module -Name Set-PsEnv;
    }.GetNewClosure();
    if (!(Test-Path $BIN_DIR)) {
        New-Item -Path $BIN_DIR -ItemType 'directory' >$null;
    }
    if (!(Test-Path $DL_DIR)) {
        New-Item -Path $DL_DIR -ItemType 'directory' >$null;
    }


    $binDir = Join-Path -Path $BIN_DIR -ChildPath 'VirtualBox';
    if (!(Test-Path $binDir)) {
        & $MySetup.'Write-KNNotice'.Script 'VirtualBoxをインストールします...';
        $installer = Join-Path -Path $DL_DIR -ChildPath '\VirtualBox-5.2.18-124319-Win.exe';
        Invoke-WebRequest -Uri 'https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-Win.exe' `
            -OutFile $installer;
        $tmpDir = Join-Path -Path $env:TEMP -ChildPath 'vbox_inst';
        & $installer --extract --path $tmpDir --silent;
        $installerPathPattern = Join-Path -Path $tmpDir -ChildPath '*amd64.msi';
        $installer = Get-ChildItem -Path $installerPathPattern | ForEach-Object {$_.FullName};
        & $installer INSTALLDIR=$binDir /passive /norestart;
    }


    & $MySetup.'Write-KNNotice'.Script 'WinRMを設定します...';
    $script = Join-Path -Path $DL_DIR -ChildPath 'ConfigureRemotingForAnsible.ps1';
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 `
        -OutFile $script;
    & $MySetup.'Invoke-WithNoDebug'.Script {
        & $script;
    }.GetNewClosure();
    Set-Item -Force WSMan:\localhost\Client\TrustedHosts -Value '192.158.85.175';
}.GetNewClosure();
