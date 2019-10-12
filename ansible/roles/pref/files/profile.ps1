#!/usr/bin/env pwsh
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

function prompt() {
    $local:ErrorActionPreference = 'SilentlyContinue';
    $branch = git rev-parse --abbrev-ref HEAD 2>$null;
    if ($null -ne $branch) {
        Write-Host "[in " -NoNewline;
        Write-Host $branch -ForegroundColor Green -NoNewline;
        Write-Host "]";
    }
    "PS {0}>" -f (Get-Location);
}
