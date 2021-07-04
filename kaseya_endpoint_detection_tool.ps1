$SoftwareKey = 'HKLM:\Software'
if ([Environment]::Is64BitOperatingSystem)
{ $SoftwareKey = 'HKLM:\Software\WOW6432Node' }
$var = 0
$RegPath = Join-Path -Path $SoftwareKey -ChildPath 'Kaseya\Agent\*'
[string[]]$FoundAgentPaths = Get-ItemProperty -Path $RegPath | Select-Object -ExpandProperty TempPath

foreach($Path in $FoundAgentPaths)
{
    $SuspiciousFile = Get-Childitem –Path $Path -Recurse -ErrorAction SilentlyContinue |  Where-Object { $_.Name -eq "agent.crt" }
    if ($null -ne $SuspiciousFile)
    {
        Write-Host "FAIL: Suspicious Certificate Found" -ForegroundColor Red
        $var = 1
    }
    else
    {
        Write-Host "PASS: Suspicious Certificate Not Found" -ForegroundColor Green
    }
}

foreach($Path in $FoundAgentPaths)
{
    $SuspiciousFile = Get-Childitem –Path $Path -Recurse -ErrorAction SilentlyContinue |  Where-Object { $_.Name -eq "agent.exe" }
    if ($null -ne $SuspiciousFile)
    {
        #Avoid false-positive
        if ((Get-FileHash -Path $($SuspiciousFile.FullName) -Algorithm MD5 | Select-Object -ExpandProperty Hash) -ine '10ec4c5b19b88a5e1b7bf1e3a9b43c12')
        {
            Write-Host "FAIL: Suspicious Executable Found" -ForegroundColor Red
            $var = 1
        } else {
            Write-Host "PASS: Huntress Executable Not Found" -ForegroundColor Green
        }
    }
    else
    {
        Write-Host "PASS: Suspicious Executable Not Found" -ForegroundColor Green
    }
}

    if ($var -gt 0 ) {
        Write-Host "RESULT: Scan Indicates Endpoint May Be Vulnerable." -ForegroundColor Red
    } else {
        Write-Host "RESULT: Scan Did Not Indicate Endpoint Is Vulnerable" -ForegroundColor Green
    }
   Read-Host -Prompt "Press Enter to exit"