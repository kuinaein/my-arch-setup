#!/usr/bin/env pwsh
[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

    [string] $archBin = Join-Path -Path $KN_BIN_DIR -ChildPath 'archlinux';
    if (!(Test-Path $ARCH_EXE)) {
        Write-KNNotice -Message 'ArchWSLをインストールします...';
        # https://github.com/yuk7/ArchWSL
        [string] $installer = Join-Path -Path $KN_DL_DIR -ChildPath 'arch18081100.zip';
        if (!(Test-Path $installer)) {
            Invoke-WebRequest -Uri https://github.com/yuk7/ArchWSL/releases/download/18081100/Arch.zip `
                -OutFile $installer -UseBasicParsing;
        }
        Invoke-WithNoDebug -Block {
            Expand-Archive -Path $installer -DestinationPath $archBin;
        }
        # ここでコケる場合は C:\bin のアクセス権が足りてない
        Write-Output -InputObject "`n" | & $ARCH_EXE;
        Write-Output -InputObject "`n";

        [string] $preSetupSh = `
            ConvertTo-ArchPath -WinPath ($PSScriptRoot + 'pre-setup-arch.sh');
        & $ARCH_EXE run bash $preSetupSh $env:USERNAME;
        & $ARCH_EXE config --default-user $env:USERNAME;
    }
    # TODO ショートカット作成


    [string] $ansible = (& $ARCH_EXE run pacman -Q ansible);
    if (($null -eq $ansible) -or ('' -eq $ansible)) {
        Write-KNNotice -Message 'Ansibleをインストールします...';
        & $ARCH_EXE run sudo pacman -Syy;
        & $ARCH_EXE run sudo pacman -S --needed --noconfirm ansible python-pywinrm;
    }


    # TODO 以下ansible行き
    if (!(Get-Command scoop -ErrorAction Continue)) {
        & $MySetup.'Write-KNNotice'.Script 'scoopをインストールします...';
        & $MySetup.'Invoke-WithNoDebug'.Script {
            Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh');
        }.GetNewClosure();
    }

    if (!(Get-Command vagrant -ErrorAction Continue)) {
        & $MySetup.'Write-KNNotice'.Script 'vagrantをインストールします...';
        & $MySetup.'Invoke-WithNoDebug'.Script {
            scoop install vagrant;
        }.GetNewClosure();
    }

    Write-Warning -Message '続行する前に再起動することを推奨します' -ErrorAction Continue;
};
