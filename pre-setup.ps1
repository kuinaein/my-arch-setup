$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.MySetup' -ErrorAction 'Continue' 2>&1 | Out-Null;
Import-Module ($PSScriptRoot + '\ps-module\Kuina.MySetup') -Scope Local;
$MySetup.InvokeMain( {
        if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                    [Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            throw '管理者権限で実行してください';
        }

        $BIN_DIR = 'C:\bin';
        $DL_DIR = 'C:\work\dl';

        $MySetup.InvokeWithNoDebug( {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
                Install-Module -Name Set-PsEnv;
            }.GetNewClosure());
        if (!(Test-Path $BIN_DIR)) {
            mkdir $BIN_DIR;
        }
        if (!(Test-Path $DL_DIR)) {
            mkdir $DL_DIR;
        }


        $binDir = ($BIN_DIR + '\VirtualBox');
        if (!(Test-Path $binDir)) {
            $MySetup.EchoInfo('VirtualBoxをインストールします...');
            $installer = ($DL_DIR + '\VirtualBox-5.2.18-124319-Win.exe');
            Invoke-WebRequest -Uri 'https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-Win.exe' `
                -OutFile $installer;
            $tmpDir = ($env:TEMP + '\vbox_inst');
            & "$installer --extract --path $tmpDir --silent";
            $innerInstallerName = Get-ChildItem ($tmpDir + '\*amd64.msi') -Name;
            & "$tmpDir\$innerInstallerName INSTALLDIR=$binDir /passive /norestart";
        }


        $MySetup.EchoInfo('WinRMを設定します...');
        $script = ($DL_DIR + '\ConfigureRemotingForAnsible.ps1');
        Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 `
            -OutFile $script;
        $MySetup.InvokeWithNoDebug( {
                & $script;
            }.GetNewClosure());
        Set-Item -Force WSMan:\localhost\Client\TrustedHosts -Value '192.158.85.175';
    }.GetNewClosure());
