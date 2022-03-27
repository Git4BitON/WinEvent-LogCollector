Clear-Host

    


Function LogCollector
{
<#
        .SYNOPSIS
        Copies Windows Event logs from a remote machine, specially a virutal machine.

        .DESCRIPTION
        This script can be used to copy windows Event lgs -Application, System & Security Logs from a remote machine.
        It requires remote machine should be configured to allow powershell remoting.

        .PARAMETER Name
        Destionation path where these three logs need to be copied. Default location is script root and under "LogCollectionServer" folder


        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> readEvemts.ps1 ".readEvents.ps1 C:\Users\XXXX\LogCollectorServer"
        File.txt

        .EXAMPLE
        PS> readEvemts.ps1 .readEvents.ps1
        Logs copied to ../LogCollectionServer

        .LINK
        Online version: 

    #>



    Param(
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $DestinationPath="C:\Users\prade\00.MyWorkSpace\001.Projects\004_RemoteEventsReader\08_LogCollectorServer"
    )

    BEGIN 
{ 
    $VMnames = @('DESKTOP-2CDJ7P9')    
    $LogNames = @("Application", "System", "Security")
    $sessionObj = New-PSSessionOption -SkipCACheck -SkipCNCheck
    $creds = Get-Credential
    $setupFolder = "c:\temp\LogDump\"


}
    Process
    {

        foreach($VM in $VMnames){

            $session = New-PSSession -ComputerName $VM -Credential $creds -UseSSL -SessionOption $sessionObj
            Invoke-Command -Session $Session -ScriptBlock { 


                #$fileName = "$setupFolder$log.evtx"
                Write-Host "Creating LogDump Folder in VM"
                New-Item -Path $using:setupFolder -type directory -Force 
                Write-Host "Folder creation complete"}
            foreach($log in $LogNames){
                $fileName = "$setupFolder$log.evtx"
            Invoke-Command -Session $Session  -ScriptBlock {(Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ $using:log ).BackupEventlog($using:fileName)} 
            Copy-Item "c:\temp\LogDump\$log.evtx" -Destination $DestinationPath -FromSession $session

}
$Session | Remove-PSSession

    }
}

}

Write-Host -Prompt "Script copies Windows Event logs (Application, Security & System) from a Remote Machine"
Write-Host -Prompt " "
Write-Host -Prompt "The Logs will be copied to LogCollector in your current path"
Write-Host -Prompt "You can also provide path as an Argument to script for e.g [/.readEvents.ps1 C:\Users\XXXX\LogCollectorServer]"

#$DestinationPath = "C:\Users\prade\00.MyWorkSpace\001.Projects\004_RemoteEventsReader\08_LogCollectorServer";


if (!(Test-Path $DestinationPath -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $DestinationPath
}
$DestinationPath =  Join-Path $PSScriptRoot "../LogCollectionServer"

LogCollector $DestinationPath 


