#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath;
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    [Microsoft.Dism.Commands.BasicFeatureObject] $wsl = `
        Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux;
    if ('Disabled' -eq $wsl.State) {
        Write-KNNotice -Message 'Windows Subsystem for Linuxを有効化します...';
        [Microsoft.Dism.Commands.ImageObject] $wslInstallResult = `
            Enable-WindowsOptionalFeature -Online -FeatureName $wsl.FeatureName -NoRestart;
        if ($wslInstallResult.RestartNeeded) {
            Write-Warning 'スクリプト終了後に再起動が必要です' -ErrorAction Continue;
        }
    }


    if (!(Test-Path $KN_BIN_DIR)) {
        New-Item -Path $KN_BIN_DIR -ItemType 'directory' >$null;
        icacls $KN_BIN_DIR /grant "${env:USERNAME}:(OI)(CI)F" >$null;
    }
    if (!(Test-Path $KN_DL_DIR)) {
        New-Item -Path $KN_DL_DIR -ItemType 'directory' >$null;
        icacls $KN_DL_DIR /grant "${env:USERNAME}:(OI)(CI)F" >$null;
    }


    Invoke-WithNoDebug -Block {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
        Install-Module -Name Set-PsEnv;
    }.GetNewClosure();


    # TODO VirtualBoxもscoopでいける
    $binDir = Join-Path -Path $BIN_DIR -ChildPath 'VirtualBox';
    if (!(Test-Path $binDir)) {
        Write-KNNotice -Message 'VirtualBoxをインストールします...';
        $installer = Join-Path -Path $DL_DIR -ChildPath '\VirtualBox-5.2.18-124319-Win.exe';
        Invoke-WebRequest -Uri 'https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-Win.exe' `
            -OutFile $installer;
        $tmpDir = Join-Path -Path $env:TEMP -ChildPath 'vbox_inst';
        & $installer --extract --path $tmpDir --silent;
        $installerPathPattern = Join-Path -Path $tmpDir -ChildPath '*amd64.msi';
        $installer = Get-ChildItem -Path $installerPathPattern | ForEach-Object {$_.FullName};
        & $installer INSTALLDIR=$binDir /passive /norestart;
    }


    Write-KNNotice -Message 'WinRMを設定します...';
    [string] $script = Join-Path -Path $KN_DL_DIR -ChildPath 'ConfigureRemotingForAnsible.ps1';
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 `
        -OutFile $script;
    Invoke-WithNoDebug -Block {
        & $script;
    };
    Set-Item -Force WSMan:\localhost\Client\TrustedHosts -Value '127.0.0.1';

    Write-Warning -Message '続行する前に再起動することを推奨します' -ErrorAction Continue;
};
