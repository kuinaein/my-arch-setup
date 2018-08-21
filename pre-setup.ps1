Set-PSDebug -Strict -Trace 1;
$ErrorActionPreference='Stop';
try {

. ($PSScriptRoot + '\common.ps1');
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Error -Message 'You have use an administrative shell!';
}

$BIN_DIR='C:\bin';
$DL_DIR='C:\work\dl';


if (!(Test-Path $BIN_DIR)) {
    mkdir $BIN_DIR;
}
if (!(Test-Path $DL_DIR)) {
    mkdir $DL_DIR;
}


$binDir=($BIN_DIR + '\VirtualBox');
if (!(Test-Path $binDir)) {
    Echo-Info 'Install VirtualBox...';
    $installer=($DL_DIR + '\VirtualBox-5.2.18-124319-Win.exe');
    Invoke-WebRequest -Uri 'https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-Win.exe' `
            -OutFile $installer;
    $tmpDir=($env:TEMP + '\vbox_inst');
    Start-Process -Wait $installer @('--extract', '--path', $tmpDir, '--silent');
    $innerInstallerName=ls ($tmpDir + '\*amd64.msi') -Name;
    Start-Process -Wait ($tmpDir + '\' + $innerInstallerName) `
            @(('INSTALLDIR=' + $binDir), '/passive', '/norestart');
}


Echo-Info 'Setup WinRM...';
$script=($env:TEMP + '\ConfigureRemotingForAnsible.ps1');
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 `
        -OutFile $script;
Invoke-Expression $script;
Set-Item -Force WSMan:\localhost\Client\TrustedHosts -Value '192.158.85.175';


Echo-Info 'Press Enter to continue...';
Read-Host | Out-Null;

} finally {
    Set-PSDebug -Off;
}
