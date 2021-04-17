# Symantec/VERITAS automated data restore test from Backup

The Script can be used to automate file/folder restore test from the Symantec/VERITAS backup. Restore test is to ensure that the data is recoverable from the backup.

# Pre-requisites

1.Windows PowerShell version 4.0 or above

2.Ensure that BEMCLI or Backup Exec powershell module installed in your backup server.

To ensure open an administrative powershell and run below commands.

PS C: \windows\system32> Import-Module -name BEMCLI 	
PS C: \windows\system32> Get-command -name BEMCLI

3.Ensure that the user account used to schedule the script must have necessary permissions to restore the files and folders, also should have access to Symantec/VERITAS registry locations.

4.Configure the below on Symantec/VERITAS backup exec console to get an additional alert about job restoration status.

a)Login to BE console --> click on the yellow database icon (for VERITAS – red play icon) on top left side --> Configuration and Settings --> Alerts and notifications --> Email alert and text notification

b)Under Email configuration enter the details of Email Server and Port, Sender name, Sender email address, also enter credentials if your email server requires authentication.

c)Navigate --> click on the yellow database icon (for VERITAS – red play icon) on top left side --> Configuration and Settings --> Alerts and notifications --> Notification recipient --> click add recipient and enter the recipient name and email address --> check the tick box send email notification by email.

d)Click on send test email to verify the alert notification is received to the inbox of configured email recipient.

5.Verify the name of server or servers in the Backup exec console those are selected for restore test.

6.Create a folder named “BackupTest” in the C or D drive of servers chosen for restore test and add some files into it.(Total size of all files in the folder should be greater than 1 MB)

7.By verifying the backup job report ensures that the folder is being backed up in the last backup schedule.

8.Create a folder named “BackupRestoreTest” on the D or any drive of the backup exec server.

# How to use the script & working of script

STEP 1) Download the script “BE-Restore.ps1” from the GitHub and extract it to any drive.

STEP 2) Edit the following portion in the script.

**#Edit this session**

**The folder chosen for test restore from the server**.

$Foldername = "D:\BackupTest" 

**The Server chosen for test restore**

$Server = "Server01" 

**Note**: Ensure that server name should be exact match with the name shown in the backup exec console.

Example: “Server01” or Server01.sjohnonline.in

**Data restore path**
**Note: If admin shares(d$ c$) are disabled in your machine create a share in the backup server and use the share path "\\backupexecserver\sharename\$today"**
**Enabling admin shares may increase the chances of attack surfaces**


$Restorepath = "\\backupexecserver\d$\BackupRestoreTest\$today"

**Recipient name configured in the alert notification on backup exec console**

$recipient = "Sijo John"

**Email address of sender**

$FromAddress = "BErestoretest@sjohnonline.in"

**Email address of recipient**

$ToAddress = "sjohn@sjohnonline.in"

**Subject of the email**

$Subject = "Symantec/VERITAS backup exec Monthly scheduled backup-Restore Test"

**SMTP Server responsible for email service**

$SMTPServer = "Enter SMTP server name or IP here" 

**Enter the SMTP Port number**

$SMTPPort = “Enter SMTP Port number here”

STEP 3) Open a PowerShell (Administrative PS recommended) 

STEP 4) Navigate and set path to script root folder

Example: PS D:\Symantec-VERITAS-Data-Restore>

STEP 5) Run the script --> PS D:\Symantec-VERITAS-Data-Restore> .\BE-Restore.ps1

SETP 6) Script creates a new folder named “present date” under the restore path specified and restores the files & folders into it. Also you will get an email notification from backup exec console about the restoration job status.

Example: 05-05-2019

STEP 7) upon completion of restore operation, the script verifies the file restored and notify if the folder is empty or not. If folder is empty “restore failed”.

STEP 8) Logging is enabled on the script for troubleshooting, check “logs” folder under the script root folder if you come across any errors.

Example: D:\Symantec-VERITAS-Data-Restore>\logs

STEP 9) The log will be attached and send to the recipient email address with following information

Restore test performed on Server = Server01

Restored folder = D:\BackupTest

Restore path = \\backupexecserver\d$\BackupRestoreTest\07052019

Restore start time = 05/07/2019 15:05:36

Restore end time = 05/07/2019 15:05:36

Size of data restored in MB = 9.35 MB

Restore status = Success

STEP 10) Information in the Log file helps to analyze the estimated time requirement for data restore.

STEP 11) The script can be schedule using task scheduler to perform restore tests from backup as per the requirement.

# Troubleshooting

1.Logging is enabled on the script with run time, date and year, check the folder "logs"

# Future Enhancements

1.Expand functionality for Veeam and Microsoft Azure backup.

# Backup Exec version tested

Support all versions of Symantec/VERITAS Backup-exec

1)Symantec Backup Exec 2014

2)Symantec Backup Exec 2015

3)VERITAS Backup Exec 2016

4)Symantec Backup Exec 2020
