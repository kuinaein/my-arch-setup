#!/usr/bin/env pwsh
[CmdletBinding()] param([switch]$NoHalt);
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    Set-PSEnv;
    [string] $user = $env:ANSIBLE_WINRM_USER;
    [string] $pass = $env:ANSIBLE_WINRM_PASS;
    if (! $pass) {
        [pscredential] $cred = Get-Credential;
        [string] $user = $cred.UserName;
        [string] $pass = $cred.GetNetworkCredential().Password;
        Set-Content '.\.env' -Encoding ASCII `
            "ANSIBLE_WINRM_USER=$user`r`nANSIBLE_WINRM_PASS=$pass";
    }

    [string] $ansibleDir = ConvertTo-ArchPath `
        -WinPath (Join-Path -Path $PSScriptRoot -ChildPath '..\ansible');
    [string] $ansibleBase = 'env ANSIBLE_LOG_PATH={0} ansible-playbook -v -i {1}' `
        -f ($ansibleDir + '/ansible.log'), ($ansibleDir + '/hosts.yml');
    [string] $ansibleWin = '{0} -l win -u {1} -e ansible_ssh_pass={2}' `
        -f $ansibleBase, $user, $pass;

    & $ARCH_EXE run $ansibleWin ($ansibleDir + '/win-setup.yml');
    & $ARCH_EXE run $ansibleWin ($ansibleDir + '/win-user-prefs.yml');
};
