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
    [ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Else {$True}
        })][string]$FilePath,
    [datetime]$Cutoff,
    [ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Else {$True}
        })]
    [string]$LogPath,
    [string]$FileExtension ="*.*"
    
)

    #Check if the file & log path exist
    if(-not (Test-Path $FilePath))
    {
        throw "Invalid file path! Please make sure you enter a valid path."
    }
    elseif(-not (Test-Path $LogPath))
    {
        throw "Invalid log path! Please make sure you enter a valid path."
    }

    #Get all items inside the path
    $LogFiles = Get-ChildItem -Path $FilePath -Filter $FileExtension | Where-Object{$_.LastWriteTime -lt $Cutoff}
    $DeletedItems = @()
    if($LogFiles)
    {
        foreach($LogFile in $LogFiles)
        {
            #Remove all items
            $DeletedItems += $LogFile
            $LogFile | Remove-Item
            Write-Host "Removing file $LogFile" -ForegroundColor Green
        }
        if($LogPath)
        {
            $LogName = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $DeletedItems | select Name,creationtime,lastwritetime | Export-Csv -path "$LogPath\DeletedLogs - $logname.csv" -Delimiter ";" -NoTypeInformation
        }
    }
    else 
    {
        Write-Host "No files were found." -ForegroundColor Red
    }
}
