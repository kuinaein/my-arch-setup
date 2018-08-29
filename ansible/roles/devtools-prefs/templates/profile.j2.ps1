#!/usr/bin/env pwsh
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

# { % if ansible_system != 'Win32NT' %}
Remove-Alias ls -ErrorAction SilentlyContinue;
function ls () {
    /usr/bin/ls --color=auto $args;
}
# { % endif %}
