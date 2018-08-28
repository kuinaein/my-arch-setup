# メモ
#
# Import-Module -Scope Local
# => ScriptBlock::GetNewClosure()するとその外側でインポートした関数を呼べなくなる
# using moudle ...
# => やはりクロージャ内でインポートしたはずのクラスが使えない
# Import-Module -AsCustomObject
# => メソッドとして呼び出そうとするとコマンドレットでなくなるので名前付き引数が使えなくなる
#    またカスタムオブジェクトからはaliasが取れない. スクリプトでは必要ないだろうが

$script:ErrorActionPreference = 'Stop';
Set-StrictMode -Version Latest;


Set-Variable -Scope Script -Option ReadOnly `
    -Name ARCH_EXE -Value (Join-Path -Path $env:USERPROFILE -ChildPath 'scoop\shims\arch.ps1');
Set-Variable -Scope Script -Option ReadOnly `
    -Name KN_BIN_DIR -Value 'C:\bin';
Set-Variable -Scope Script -Option ReadOnly `
    -Name KN_DL_DIR -Value 'C:\work\dl';

function Write-KNNotice {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Message
    );
    process { Write-Host -Object $Message -ForegroundColor Green; }
}

function Set-KNDebugMode {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([switch]$Off);
    process {
        if ($Off) {
            Set-PSDebug -Off;
        }
        else {
            if ('Continue' -eq $VerbosePreference) {
                Set-PSDebug -Trace 1;
            }
        }
    }
}

function Invoke-WithNoDebug {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$Block
    );
    process {
        Set-KNDebugMode -Off;
        try {
            $LASTEXITCODE = 0;
            & $Block | Out-Host;
            if (($null -ne $LASTEXITCODE) -and (0 -ne $LASTEXITCODE)) {
                throw '外部プログラムがエラーコード {0}を返しました: {1}' -f $LASTEXITCODE, $Block;
            }
        }
        finally {
            Set-KNDebugMode;
        }
    }
}


function ConvertTo-ArchPath {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WinPath
    );

    process {
        return '/mnt/{0}/{1}' -f $winPath.Substring(0, 1).ToLower(), `
        ($winPath.Substring(3) -replace '\\', '/');
    }
}

function Invoke-KNMain {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$Block
    );
    process {
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
}


Export-ModuleMember -Function * -Variable *;
