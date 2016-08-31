#Requires -Version 3.0

<# 
==================================================================================================
Microsoft PowerShell Source File
NAME  :     Remove-Logs
AUTHORS     :     Maarten Van Driessen, Realdolmen
CREATED :   31/08/2016
UPDATE      :     


UPDATE in V1.0
* Initial Version of the script
==================================================================================================
#>

Function Remove-Logs{ 
[Cmdletbinding()]
#Parameters
Param
(
    [string]$FilePath,
    [datetime]$Cutoff
)

    #Check if the path exists
    if(-not (Test-Path $FilePath))
    {
        throw "Invalid path! Please make sure you enter a valid path."
    }

    $LogFiles = Get-ChildItem -Path $FilePath | Where-Object{$_.LastWriteTime -lt $Cutoff}
    if($LogFiles)
    {
        foreach($LogFile in $LogFiles)
        {
            $LogFile | Remove-Item
            Write-Host "Removing file $LogFile" -ForegroundColor Green
        }
    }
    else 
    {
        Write-Host "No files were found." -ForegroundColor Red
    }

}