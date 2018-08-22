$script:ErrorActionPreference = 'Stop';
Remove-Module 'Kuina.MySetup' -ErrorAction 'Continue' 2>&1 | Out-Null;
Import-Module ($PSScriptRoot + '\ps-module\Kuina.MySetup') -Scope Local;
$MySetup.InvokeMain( {
        if (!(cmd /c where scoop)) {
            $MySetup.EchoInfo('scoopをインストールします...');
            $MySetup.InvokeWithNoDebug( {
                    Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh');
                }.GetNewClosure());
        }

        if (!(cmd /c where vagrant)) {
            $MySetup.EchoInfo('Vagrantをインストールします...');
            $MySetup.InvokeWithNoDebug( {
                    scoop install vagrant;
                }.GetNewClosure());
        }
    }.GetNewClosure());
