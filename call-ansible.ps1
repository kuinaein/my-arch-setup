Param([switch]$noHalt);

$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.MySetup' -ErrorAction 'Continue' 2>&1 | Out-Null;
Import-Module ($PSScriptRoot + '\ps-module\Kuina.MySetup') -Scope Local;
$MySetup.InvokeMain( {
        Set-PSEnv;
        $user = $env:ANSIBLE_WINRM_USER;
        $pass = $env:ANSIBLE_WINRM_PASS;
        if (! $pass) {
            $cred = Get-Credential;
            $user = $cred.UserName;
            $pass = $cred.GetNetworkCredential().Password;
            Set-Content ($PSScriptRoot + '\.env') `
                "ANSIBLE_WINRM_USER=$user`r`nANSIBLE_WINRM_PASS=$pass" `
                -Encoding ASCII;
        }

        Push-Location ($PSScriptRoot + '\win-vagrant');
        try {
            vagrant up;
            $ansible = "ansible-playbook -v -i /mnt/ansible/win-hosts.yml -u {0} -e 'ansible_ssh_pass={1}' " `
                -f $user, $pass;
            vagrant ssh -c ($ansible + '/mnt/ansible/win-setup.yml');
            vagrant ssh -c ($ansible + '/mnt/ansible/win-user-prefs.yml');
            if (! $noHalt) {
                vagrant halt;
            }
        } finally {
            Pop-Location;
        }
    }.GetNewClosure());
