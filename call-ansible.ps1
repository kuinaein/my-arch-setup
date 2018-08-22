Param([switch]$noHalt);

$script:ErrorActionPreference='Stop';
Remove-Module 'Kuina.MySetup' -ErrorAction 'Continue' 2>&1 | Out-Null;
Import-Module ($PSScriptRoot + '\ps-module\Kuina.MySetup') -Scope Local;
$MySetup.InvokeMain({
    Set-PSEnv;
    $user = $env:ANSIBLE_WINRM_USER;
    $pass = $env:ANSIBLE_WINRM_PASS;

    if (! $pass) {
        $cred = Get-Credential;
        $user = $cred.UserName;
        $pass = $cred.GetNetworkCredential().Password;
    }

    pushd ($PSScriptRoot + '\win-vagrant');
    try {
        vagrant up --provision;
        try {
            $ansible = "ansible-playbook -i /mnt/ansible/win-hosts.yml -u {0} -e 'ansible_ssh_pass={1}' " `
                    -f $user, $pass;
            vagrant ssh -c ($ansible + '/mnt/ansible/win-setup.yml');
            echo "ANSIBLE_WINRM_USER=$user`r`nANSIBLE_WINRM_PASS=$pass" | `
                    Out-File ($PSScriptRoot + '\.env') -Encoding ASCII;
            # vagrant ssh -i /mnt/ansible/win-hosts.yml /mnt/ansible/win-user-prefs.yml;
        } finally {
            if (! $noHalt) {
                vagrant halt;
            }
        }
    } finally {
        popd;
    }
}.GetNewClosure());
