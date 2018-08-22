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
            $ansible = "ansible-playbook -v -l win -i /mnt/ansible/hosts.yml -u {0} -e 'ansible_ssh_pass={1}' " `
                -f $user, $pass;

            Get-Date | Add-Content -Path ($PSScriptRoot + '\setup.log');
            vagrant ssh -c ($ansible + '/mnt/ansible/win-setup.yml') | `
                Add-Content -Path ($PSScriptRoot + '\setup.log') -PassThru;

            Get-Date | Add-Content -Path ($PSScriptRoot + '\user-pregs.log');
            vagrant ssh -c ($ansible + '/mnt/ansible/win-user-prefs.yml') | `
                Add-Content -Path ($PSScriptRoot + '\user-prefs.log') -PassThru;

            if (! $noHalt) {
                vagrant halt;
            }
        } finally {
            Pop-Location;
        }
    }.GetNewClosure());
