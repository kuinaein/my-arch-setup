Set-PSDebug -Strict -Trace 1;
$ErrorActionPreference='Stop';
try {

. ($PSScriptRoot + '\common.ps1');

$cred=Get-Credential;

pushd ($PSScriptRoot + '\win-vagrant');
try {
    vagrant up --provision;
    try {
        $ansible = "ansible-playbook -i /mnt/ansible/win-hosts.yml -u {0} -e 'ansible_ssh_pass={1}' " `
                -f $cred.UserName, $cred.GetNetworkCredential().Password;
        vagrant ssh -c ($ansible + '/mnt/ansible/win-setup.yml');
        vagrant ssh -i /mnt/ansible/win-hosts.yml /mnt/ansible/win-user-prefs.yml;
    } finally {
        vagrant halt;
    }
} finally {
    popd;
}

Echo-Info 'Press Enter to continue...';
Read-Host | Out-Null;

} finally {
    Set-PSDebug -Off;
}
