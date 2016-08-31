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
Param
(
    [string]$Path,
    [datetime]$Cutoff
)

	Get-ChildItem -Path $Path | Where-Object{$_.LastWriteTime -lt $Cutoff} | Remove-Item
}