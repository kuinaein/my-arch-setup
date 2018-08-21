Set-PSDebug -Strict -Trace 1;
$ErrorActionPreference='Stop';
try {

$LINUX_FILES=@(
    ($PSScriptRoot + '\ansible\win-vagrant.yml'),
    ($PSScriptRoot + '\ansible\win-hosts.yml'),
    ($PSScriptRoot + '\ansible\win-setup.yml')
);
foreach ($f in $LINUX_FILES) {
    Invoke-Expression ($PSScriptRoot + '\utf-to-ascii.ps1 ' + $f) ;
}

} finally {
    Set-PSDebug -Off;
}
