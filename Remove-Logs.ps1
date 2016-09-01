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
    #Check to see if there are any invalid characters in the path
    [ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Else {$True}
        })][string]$FilePath,
    #You can only delete logs older than 1 day
    [ValidateRange(1,365)][int]$Cutoff,
    #Check to see if there are any invalid characters in the path
    [ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Else {$True}
        })]
    [string]$LogPath,
    #you can only delete log and txt files
    [ValidateSet("*.log","*.txt")][string]$FileExtension ="*.*"
    
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

    #
    $CutOffDate = (Get-Date).AddDays(-$Cutoff)

    #Get all items inside the path
    $LogFiles = Get-ChildItem -Path $FilePath -Filter $FileExtension | Where-Object{$_.LastWriteTime -lt $CutOffDate}
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
            $LogName = Get-Date -Format "yyyy-MM-dd"          
            $DeletedItems | select Name,creationtime,lastwritetime | Export-Csv -path "$LogPath\DeletedLogs - $LogName.csv" -Delimiter ";" -NoTypeInformation -Append
        }
    }
    else 
    {
        Write-Host "No files were found." -ForegroundColor Red
    }
}
