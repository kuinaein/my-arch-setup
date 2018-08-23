#!/usr/bin/env pwsh
Param([switch]$noHalt);
$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.PSMySetup' -ErrorAction Continue 2>&1 | Out-Null;
$private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath -Scope Local -AsCustomObject;
Invoke-KNMain {
    Set-PSEnv;
    $user = $env:ANSIBLE_WINRM_USER;
    $pass = $env:ANSIBLE_WINRM_PASS;
    if (! $pass) {
        $cred = Get-Credential;
        $user = $cred.UserName;
        $pass = $cred.GetNetworkCredential().Password;
        $dotEnv = Join-Path -Path $PSScriptRoot -ChildPath '.env'
        Set-Content $dotEnv -Encoding ASCII `
            "ANSIBLE_WINRM_USER=$user`r`nANSIBLE_WINRM_PASS=$pass";
    }

    Push-Location (Join-Path -Path $PSScriptRoot -ChildPath 'win-vagrant');
    try {
        vagrant up;
        $ansible = 'ansible-playbook -v -l win -i /mnt/ansible/hosts.yml -u {0} -e ansible_ssh_pass={1} ' `
            -f $user, $pass;

        $setupLog = Join-Path -Path $PSScriptRoot -ChildPath 'setup.log';
        Get-Date | Add-Content -Path $setupLog;
        vagrant ssh -c ($ansible + '/mnt/ansible/win-setup.yml') | `
            Add-Content -PassThru -Path $setupLog;

        $userPrefsLog = Join-Path -Path $PSScriptRoot -ChildPath 'userPrefs.log';
        Get-Date | Add-Content -Path $userPrefsLog;
        vagrant ssh -c ($ansible + '/mnt/ansible/win-user-prefs.yml') | `
            Add-Content -PassThru -Path $userPrefsLog;

        if (! $noHalt) {
            vagrant halt;
        }
    }
    finally {
        Pop-Location;
    }
}.GetNewClosure();
