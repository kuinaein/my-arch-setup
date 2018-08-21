Set-PSDebug -Strict -Trace 1;
$ErrorActionPreference='Stop';
try {

. ($PSScriptRoot + '\common.ps1');


if (!(cmd /c where scoop)) {
    Echo-Info 'Install Scoop...';
    iex (new-object net.webclient).downloadstring('https://get.scoop.sh');
}

if (!(cmd /c where vagrant)) {
    Echo-Info 'Install Vagrant...';
    Set-PSDebug -Trace 0;
    scoop install vagrant;
    Set-PSDebug -Trace 1;
}


Echo-Info 'Press Enter to continue...';
Read-Host | Out-Null;

} finally {
    Set-PSDebug -Off;
}
