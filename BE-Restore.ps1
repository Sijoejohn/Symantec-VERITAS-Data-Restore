###############################################################################
# Script info     :  Symantec/VERITAS Automated Data Restore Test from Backup.
# Script          :  BERestore.ps1
# Verified on     :  Symantec 2014,2015,2020 and VERITAS 2016
# Author          :  Sijo John
# Version         :  V-1.0
# Last Modified   :  09/05/2018
# The Script can be used to automate file/folder restore test from the Symantec/VERITAS backup. 
# Restore test is to ensure that the data is recoverable from the backup..
# .SYNOPSIS
# Usage Example   : PS>.BE-Restore.ps1
################################################################################




Begin

{

# Import required PS Modules

$VerbosePreference = 'SilentlyContinue'
Import-Module -name BEMCLI

write-host ("Module imported successfully")

$ContentFolder = "$PSScriptRoot\Content"
$LogFolder = "$PSScriptRoot\logs"
$today = Get-Date -Format "ddMMyyy"
$time = Get-Date

#region generate the transcript log
    #Modifying the VerbosePreference in the Function Scope
    $Start = Get-Date
    $VerbosePreference = 'SilentlyContinue'
    $TranscriptName = '{0}_{1}.log' -f $(($MyInvocation.MyCommand.Name.split('.'))[0]), $(Get-Date -Format ddMMyyyyhhmmss)
    Start-Transcript -Path "$LogFolder\$TranscriptName"
    #endregion generate the transcript log



#Edit this session

$Foldername = "D:\BackupTest"
$Server = "Server01"
$Restorepath = "\\backupexecservername\d$\BackupRestoreTest\$today"
$recipient = "Sijo John"
$FromAddress = "BErestoretest@sjohnonline.in"
$ToAddress = "sjohn@sjohnonline.in"
$Subject = "Symantec/VERITAS backup exec Monthly scheduled backup-Restore Test"
$SMTPServer = "Enter SMTP server name or IP here"
$SMTPPort = "Enter SMTP server port number here"

     try {
      

        # create a folder for every day
        Get-Item "$Restorepath" -ErrorAction SilentlyContinue
        if (!$?) {
            New-Item "$Restorepath" -ItemType Directory
        }
    }
    Catch {
        Show-Message -Severity high -Message "Failed to create the folder. Permission!"
        Write-Verbose -ErrorInfo $PSItem
        Stop-Transcript
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

   
   Write-Host ("Starting scheduled backup-restore test")

   Write-Host ("Restoration start time $time")

   $starttime = $time

   #Restore data from backup

   Submit-BEFileSystemRestoreJob -FileSystemSelection $Foldername -AgentServer $Server -RedirectToPath $Restorepath -NotificationRecipientList $recipient

   Write-Host ("Restoration complete time $time")

   $completetime = $time

   Write-Host ("Scheduled restore job completed successfully, please check and verify the output path $Restorepath")

   Write-Host ("Verifying restored files")

   #Verify Restored data

   $Restoredfile = Get-ChildItem "$Restorepath"| Where {$_.LastWriteTime -gt (Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue
   If ($Restoredfile.Exists) {Write-Host "Restored files verified and restore task succeeded"}
   Else {Write-Host "File does not exist/ Restore failed- Check restore logs"}

   #Verify size of data restored

   $size = 0
   $size = "{0:N2} MB" -f ((gci $Restorepath -Recurse | Measure-Object -property Length -s).Sum /1MB)
   if  ($size -gt 0) {$restorestatus = "Success"; Write-Host "Success"} Else {$restorestatus = "Failed" ;Write-Host "Failed - Check logs for details"}


   $Summary = @"

   Restore test performed on Server =  $Server

   Restored folder = $Foldername

   Restore path = $Restorepath

   Restore start time = $starttime

   Restore complete time = $completetime

   Size of data restored in MB = $size

   Restore status = $restorestatus

   Please find atached log report of scheduled file restoration test.

"@

  Write-Host ("$Summary")

  Write-Host ("Gathering logs to send email")

  #Email restore report

  $Attachments = Get-ChildItem $LogFolder\*.* -include *.txt,*.log | Where{$_.LastWriteTime -gt (Get-Date).AddMinutes(-3)}
  $body = "<p>Restore test performed on Server = $Server</p>"
  $body += "<p>Restored folder = $Foldername</p>"
  $body += "<p>Restore path = $Restorepath</p>"
  $body += "<p>Restore start time = $starttime</p>"
  $body += "<p>Restore complete time = $completetime</p>"
  $body += "<p>Size of data restored in MB = $size</p>"
  $body += "<p>Restore status = $restorestatus</p>"
  $bosy += "<p>Please find atached log report of scheduled file restoration test.</p>"
  
   
  Send-Mailmessage -From $FromAddress -To $ToAddress -Subject $Subject -Attachments $Attachments -BodyAsHTML -Body $body -Priority Normal -SmtpServer $SMTPServer -Port $SMTPPort

  Write-Host "Report has been sent by E-mail to " $ToAddress " from " $FromAddress


  Stop-Transcript 

   }