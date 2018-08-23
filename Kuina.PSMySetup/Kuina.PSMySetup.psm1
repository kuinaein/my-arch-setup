# メモ
#
# Import-Module -Scope Local
# => ScriptBlock 内ではその外側でインポートした関数を呼べなくなる
# using moudle ...
# => やはりScriptBlock 内でインポートしたはずのクラスが使えない
# Import-Module -AsCustomObject
# => そのまま呼び出そうとするとコマンドレットでなくなるので名前付き引数が使えなくなる
#    またaliasが取れない. スクリプトでは必要ないだろうが

$script:ErrorActionPreference = 'Stop';

function Write-KNNotice {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Message
    );
    process { Write-Host -Object $Message -ForegroundColor Green; }
}

function Set-KNDebugMode {
    [CmdletBinding()]
    [OutputType([void])]
    param([switch]$Off);
    process {
        if ($Off) {
            Set-PSDebug -Off;
        }
        else {
            Set-PSDebug -Trace 1;
            Set-StrictMode -Version Latest;
        }
    }
}

function Invoke-WithNoDebug (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ScriptBlock]$Block
) {
    Set-KNDebugMode -Off;
    try {
        & $Block;
        if (($null -ne $LASTEXITCODE) -and (0 -ne $LASTEXITCODE)) {
            throw '外部プログラムがエラーコード{0}を返しました: {1}' -f $LASTEXITCODE, $Block;
        }
    }
    finally {
        Set-KNDebugMode;
    }
}

function Invoke-KNMain([Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ScriptBlock]$Block
) {
    Set-KNDebugMode;
    try {
        & $Block;
    }
    catch {
        # ここで表示しないと pause 後にエラーメッセージが流れることになる
        Write-Host -Object ($_ | Out-String) -ForegroundColor Red;
    }
    finally {
        Pause;
        Set-KNDebugMode -Off;
    }
}
