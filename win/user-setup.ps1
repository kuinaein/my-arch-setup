#!/usr/bin/env pwsh
[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    [Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage] `
        $pkg = Get-AppxPackage -Name $UBUNTU_PKG_NAME;
    if ($null -eq $pkg) {
        Write-KNNotice -Message 'Ubuntu 18.04 LTSをインストールします...';
        [string] $ubuntuPkg = Join-Path -Path $KN_DL_DIR -ChildPath 'ubuntu1804lts.appx';
        Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $ubuntuPkg -UseBasicParsing;
        Add-AppxPackage -Path $ubuntuPkg;

        $pkg = Get-AppxPackage -Name $UBUNTU_PKG_NAME;
        [string]$ubuntuExe = Get-UbuntuExePath;
        & $ubuntuExe install --root;
        [string] $preSetupSh = ConvertTo-WslPath `
            -WinPath (Join-Path -Path $PSScriptRoot -ChildPath 'pre-setup-ubuntu.sh');
        & $ubuntuExe run bash $preSetupSh $env:USERNAME;
        & $ubuntuExe config --default-user $env:USERNAME;
    }
};
