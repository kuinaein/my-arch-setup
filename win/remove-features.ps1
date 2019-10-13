#!/usr/bin/env pwsh
#Requires -RunAsAdministrator

[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath;
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    $featureNames = @(
        # 共有フォルダ
        'SMB1Protocol-Deprecation',
        'SMB1Protocol-Client',
        'SMB1Protocol',

        'FaxServicesClientPackage',
        'Printing-XPSServices-Features',
        'Internet-Explorer-Optional-amd64',
        'Printing-Foundation-InternetPrinting-Client',
        'WorkFolders-Client'
    );
    foreach ($featureName in $featureNames) {
        [Microsoft.Dism.Commands.BasicFeatureObject] $feature = `
            Get-WindowsOptionalFeature -Online -FeatureName $featureName;
        if ('Enabled' -eq $feature.State) {
            Write-KNNotice -Message ($feature.DisplayName + 'を無効化します...');
            $result = Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName -NoRestart
            if ($result.RestartNeeded) {
                Write-Warning 'スクリプト終了後に再起動が必要です' -ErrorAction Continue;
            }
        }
    }
}
