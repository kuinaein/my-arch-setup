#!/usr/bin/env pwsh
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

function prompt() {
    $local:ErrorActionPreference = 'SilentlyContinue';
    $branch = git rev-parse --abbrev-ref HEAD 2>/dev/null;
    if ($branch) {
        "PS {0} [$branch]>" -f (Get-Location);
    }
    else {
        "PS {0}>" -f (Get-Location);
    }
}

#
# {% if ansible_system != 'Win32NT' %}
#
Remove-Alias ls -ErrorAction SilentlyContinue;
function ls () {
    /usr/bin/ls --color=auto $args;
}

Remove-Alias grep -ErrorAction SilentlyContinue;
function grep {
    Write-Output @($input) | /usr/bin/grep --color=auto $args;
}
#
# {% endif %}
#
