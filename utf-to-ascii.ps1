# For removing BOM ...

Param(
    [Parameter(Mandatory=$true)][string]$In,
    [string]$Out
);

Set-PSDebug -Strict -Trace 1;
$ErrorActionPreference='Stop';
try {

if ('' -eq $Out) {
    $Out = $In;
}
# Get-Content works like an iterator...
$content=Get-Content $In;
echo $content | Out-File $Out -Encoding ascii;

} finally {
    Set-PSDebug -Off;
}
