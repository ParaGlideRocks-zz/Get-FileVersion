<#
.SYNOPSIS
  Get a version number of a file given a list of servers.

.DESCRIPTION
  This script can be used to check a single file on multiple servers.
  Once collected, it returns a string in the form FileMajorPart.FileMinorPart.FileBuildPart.FilePrivatePart

.PARAMETER ComputerName
  Mandatory. A list of computers where to check the version of Filename.

.PARAMETER FileName
  Mandatory. File you are requiring version info. 

.INPUTS
  Parameters above

.OUTPUTS
  An object with the following properties ComputerName, File, LastAccessTime, FileVersion

.NOTES
  Version:        1.0
  Author:         Michele Nappa
  Creation Date:  08/28/2018
  Purpose/Change: Initial function development

.EXAMPLE
  C:\PS>Get-FileVersion.ps1 -Computername DC01RF,EX01RF -FileName C:\Windows\system32\aadauthhelper.dll

  Description

  -----------  

  This command retrives the version info for file C:\Windows\system32\aadauthhelper.dll on servers named DC01RF,EX01RF
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias("cn")]
    [string[]]$ComputerName,

    [Parameter(Mandatory = $true,
        Position = 1)]
    [ValidateNotNullOrEmpty()]
    [Alias("fn")]
    [string]$FileName
)

Begin
{
    $report=@()	
}

Process
{
    foreach ($computer in $ComputerName)
    {
        try
        {
            $file = Get-Item -Path "\\$computer\$($fileName.replace(':','$'))" -ErrorAction Stop

            $fileVersion = '{0}.{1}.{2}.{3}' -f $file.VersionInfo.FileMajorPart,
                                                $file.VersionInfo.FileMinorPart,
                                                $file.VersionInfo.FileBuildPart,
                                                $file.VersionInfo.FilePrivatePart

            $properties = @{ 'ComputerName' = $computer;
                             'FileName' = $file.FullName 
                             'LastAccessTime' = $file.LastAccessTime;
                             'FileVersion' = $fileVersion ; }
        }
        catch
        {
            $properties = @{ 'ComputerName' = $computer;
                             'FileName' = 'NOT FOUND' 
                             'LastAccessTime' = $null;
                             'FileVersion' = $null; }
        }
        finally
        {
	    $CurrObj = New-Object PSObject -Property $properties
	    $report += $CurrObj
        }
    }
}

End
{
    $report
}
