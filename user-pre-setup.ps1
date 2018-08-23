#!/usr/bin/env pwsh
$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.PSMySetup' -ErrorAction Continue 2>&1 | Out-Null;
$private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
$MySetup = Import-Module $myModulePath -Scope Local -AsCustomObject;
Invoke-KNMain {
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
}.GetNewClosure();
