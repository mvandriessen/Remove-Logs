#Requires -Version 3.0

Function Remove-Logs{ 

<#
.SYNOPSIS
  Delete old log files
.DESCRIPTION
  This function will delete all .log and .txt files older than a certain number of days.
  You have the ability to specify log path, extension (log or txt) and path.
.NOTES
  Author:  Maarten Van Driessen
.PARAMETER FilePath
  Specify the path where you want to delete the logs from.
.PARAMETER CutOff
  Specify how many days you want to go back.
.PARAMETER LogPath
  Where do you want to store the log file. Path must end with a \
.PARAMETER FileExtension
  Specify whether you want to delete *.log, *.etl or *.txt files. If left blank, the function will delete both.
  Must be written as *.log, *.etl or *.txt
.EXAMPLE
  Remove-Logs -FilePath C:\inetpub\ -Cutoff 30 -LogPath c:\temp\
  
  Delete all txt and log files older than 30 days from the c:\inetpub folder and write the log to c:\reports
.EXAMPLE
  Remove-Logs -FilePath C:\inetpub\ -Cutoff 20 -LogPath c:\temp\ -FileExtension *.txt
  
  Delete all txt files older than 20 days from the c:\inetpub folder and write the log to c:\reports
#>

[Cmdletbinding()]
#Parameters
Param
(
    #Check to see if there are any invalid characters in the path
    [Parameter(Mandatory=$true)][ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Else {$True}
        })][string]$FilePath,
    #You can only delete logs older than 1 day
    [Parameter(Mandatory=$true)][ValidateRange(1,365)][int]$Cutoff,
    #Check to see if there are any invalid characters in the path
    [ValidateScript({
            If ((Split-Path $_ -Leaf).IndexOfAny([io.path]::GetInvalidFileNameChars()) -ge 0) {
                Throw "$(Split-Path $_ -Leaf) contains invalid characters!"
            } Elseif(-Not ($_.EndsWith('\'))){
                Throw "Logpath must end with \ !"
            } Else {$True}
        })]$LogPath="",  
    
    #you can only delete log and txt files
    [ValidateSet("*.log","*.txt","*.etl")][string]$FileExtension ="*.*"
    
)

    #Check if the file & log path exist
    if(-not (Test-Path $FilePath))
    {
        throw "Invalid file path! Please make sure you enter a valid path."
    }
    #If statement to handle optional parameter
    elseif($LogPath -eq "") {}
    elseif(-not (Test-Path $LogPath))
    {
        throw "Log path does not exist! Please make sure you enter a valid path."
    }

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
            $DeletedItems | select FullName,creationtime,lastwritetime | Export-Csv -path "$LogPath\DeletedLogs - $LogName.csv" -Delimiter ";" -NoTypeInformation -Append
        }
    }
    else 
    {
        Write-Host "No files were found." -ForegroundColor Red
    }
}
