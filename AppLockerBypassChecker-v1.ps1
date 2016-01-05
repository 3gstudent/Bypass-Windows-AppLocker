﻿# AppLocker Bypass Checker (Default Rules) v1.0
#
# One of the Default Rules in AppLocker allows everything in the folder C:\Windows to be executed.
# A normal user shouln't have write permission in that folder, but that is not always the case.
# This script tries to copy an executable to every folder in Windows and (if the copy succeeds)
# it will try to execute it.
# Read more at https://mssec.wordpress.com/2015/10/22/applocker-bypass-checker/
#
# // Tom Aafloen, 2015-10-22


# Cleanup if script has been run before
# Note that some folder allows adding files, but not deleting or executing
Get-ChildItem C:\Windows -Filter ABCtestfile.exe -Recurse -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue

# Loop through C:Windows, try to copy executable and - if successful - try to execute it.
# Some folders that allow copying but not executing will throw an Access Denied error
foreach($_ in (Get-ChildItem C:\Windows -recurse -ErrorAction SilentlyContinue)){
    if($_.PSIsContainer)
    {
        Set-Location $_.FullName
        Copy-Item "C:\Windows\System32\mstsc.exe" .\ABCtestfile.exe -ErrorAction SilentlyContinue
        if (Test-Path -Path .\ABCtestfile.exe)
            {
            Write-Host "Trying to execute in writable folder" $_.FullName -ForegroundColor Yellow
            Start-Process  .\ABCtestfile.exe
            }
    }
}

# List folders where the executable was copied (and you have read access)
Write-Host "The following paths allow write (and read)" -ForegroundColor Green
Get-ChildItem C:\Windows -Filter ABCtestfile.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Format-Table -AutoSize

# List path of running executables
Write-Host "The following paths allow write and execute" -ForegroundColor Green
(Get-Process ABCtestfile).MainModule | select FileName

# Cleanup by stopping all created test processes
Stop-Process -Name ABCtestfile -Force