#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
using namespace System.Security.AccessControl;
using namespace System.Security.Principal;

[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath;
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    function Set-KNDirectoryStatus ([string] $Path) {
        if (!(Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory >$null;
        }

        [string] $username = [WindowsIdentity]::GetCurrent().Name;
        [DirectorySecurity] $acl = Get-Acl -Path $Path;
        [FileSystemAccessRule] $perm = $acl.GetAccessRules($true, $true, [NTAccount]) | `
            Where-Object {$username -eq $_.IdentityReference.Value} | Select-Object -First 1;
        if ($null -eq $perm) {
            [FileSystemAccessRule] $rule = New-Object FileSystemAccessRule @(
                $username,
                [FileSystemRights]::FullControl,
                @([InheritanceFlags]::ContainerInherit, [InheritanceFlags]::ObjectInherit),
                [PropagationFlags]::None,
                [AccessControlType]::Allow
            );
            $acl.AddAccessRule($rule);
            Set-Acl -Path $Path -AclObject $acl;
        }
    }

    Set-KNDirectoryStatus -Path $KN_BIN_DIR;
    Set-KNDirectoryStatus -Path 'C:\work';
    Set-KNDirectoryStatus -Path $KN_DL_DIR;

    Invoke-WithNoDebug -Block {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    }
    if ($null -eq (Get-Command Set-PsEnv -ErrorAction SilentlyContinue)) {
        Invoke-WithNoDebug -Block {
            Install-Module -Name Set-PsEnv;
        }
    }

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


    # TODO VirtualBoxもscoopでいける
    # $binDir = Join-Path -Path $BIN_DIR -ChildPath 'VirtualBox';
    # if (!(Test-Path $binDir)) {
    #     Write-KNNotice -Message 'VirtualBoxをインストールします...';
    #     $installer = Join-Path -Path $DL_DIR -ChildPath '\VirtualBox-5.2.18-124319-Win.exe';
    #     Invoke-WebRequest -Uri 'https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-Win.exe' `
    #         -OutFile $installer;
    #     $tmpDir = Join-Path -Path $env:TEMP -ChildPath 'vbox_inst';
    #     & $installer --extract --path $tmpDir --silent;
    #     $installerPathPattern = Join-Path -Path $tmpDir -ChildPath '*amd64.msi';
    #     $installer = Get-ChildItem -Path $installerPathPattern | ForEach-Object {$_.FullName};
    #     & $installer INSTALLDIR=$binDir /passive /norestart;
    # }


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
