# メモ
#
# Import-Module -Scope Local
# => ScriptBlock 内ではその外側でインポートした関数を呼べなくなる
# using moudle ...
# => やはりScriptBlock 内でインポートしたはずのクラスが使えない
# Import-Module -AsCustomObject
# => aliasが取れない. コマンドレットではないので名前付き引数も使えなくなる

$script:ErrorActionPreference = 'Stop';

class MySetup {
    # コンストラクタを書き忘れると謎のエラーが発生する
    MySetup() {}

    [void] EchoInfo($msg) {
        Write-Host $msg -ForegroundColor Green;
    }

    [void] SetDebugMode([bool]$mode) {
        if ($mode) {
            Set-PSDebug -Strict -Trace 1;
        } else {
            Set-PSDebug -Off;
        }
    }

    [void] InvokeWithNoDebug ([ScriptBlock]$block) {
        $this.SetDebugMode($false);
        try {
            & $block | Out-Default;
        } finally {
            $this.SetDebugMode($true);
        }
    }

    [void] InvokeMain ([ScriptBlock]$block) {
        $this.SetDebugMode($true);
        try {
            # Out-Defaultを付けないとechoが利かなくなる
            & $block | Out-Default;
        } catch {
            # ここで表示しないと pause 後にエラーメッセージが流れることになる
            Write-Host ($_ | Out-String) -ForegroundColor Red;
        } finally {
            $this.EchoInfo('続けるにはEnterキーを入力してください...');
            Read-Host | Out-Null;
            $this.SetDebugMode($false);
        }
    }
}

$MySetup = New-Object MySetup;
Export-ModuleMember -Variable $MySetup;
