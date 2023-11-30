# This Sample Code is provided for the purpose of illustration only and is not intended to be
# used in a production environment. THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED
# "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We
# grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce
# and distribute the object code form of the Sample Code, provided that You agree: (i) to not use
# Our name, logo, or trademarks to market Your software product in which the Sample Code is
# embedded; (ii) to include a valid copyright notice on Your software product in which the Sample
# Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from
# and against any claims or lawsuits, including attorneys’ fees, that arise or result from the
# use or distribution of the Sample Code.



#Please note: None of the conditions outlined in the disclaimer above will supersede the terms
# and conditions contained within the Premier Customer Services Description.

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$fwFolder = "c:\Firewall"
$fwFiles = @(
            "DeployFW.ps1",
            "fwrule.json"
    )
$fwTaskName = "Deploy-FW"

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Folder Firewall
New-Item -ItemType Directory -Path $fwFolder -Force

#Protecting the folder
$acl = Get-Acl $fwFolder
$acl.SetAccessRuleProtection($true,$false)
$acl.Access | % { $acl.RemoveAccessRule($_) }
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($rule)
$acl.SetOwner((New-Object System.Security.Principal.NTAccount("NT AUTHORITY", "SYSTEM")))
Set-Acl -Path $fwFolder -AclObject $acl | Out-Null

#Copy basic files to the folder
foreach($fwFile in $fwFiles){
    
}


#Create a Task
$ac = New-ScheduledTaskAction -Execute "powershell.exe"  -Argument "-executionpolicy bypass -windowstyle hidden -noninteractive -nologo -file $fwFolder\DeployFW.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogon
$setting = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden
Register-ScheduledTask -TaskName $fwTaskName -Trigger $trigger -Action $ac -User "System" -RunLevel Highest -Settings $setting -Force

#Start the Task
Start-ScheduledTask -TaskName $fwTaskName