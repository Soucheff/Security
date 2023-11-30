#requires -version 5
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
        @{
            file ="DeployFW.ps1";
            SHA256= "9D4B323D9B61F1B6C43D52EDF32EAB822AE36CFEA61F02CEDAAB62ACE43436F2"
        },@{
            file= "fwrule.json";
            SHA256= $null;
        }
    )
$fwTaskName = "Deploy-FW"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#check files
foreach($fwFile in $fwFiles){
    $fwFilePath = (Join-Path -Path $fwFolder -ChildPath $fwFile.file)
    if( -not(Test-Path $fwFilePath)){
        return
    }
    if($null -ne $fwFile.SHA256){
        $fwFileHash = (Get-FileHash $fwFilePath -Algorithm SHA256)
        if($fwFileHash.Hash -ne $fwFile.SHA256){
            return
        }
    }
}

#check TaskScheduler
$fwTask = Get-ScheduledTask -TaskName $fwTaskName -ErrorAction SilentlyContinue
if(-not($fwTask)){
    return
}
if($fwTask.State -eq 'Disabled' ){
    return
}

Write-Host "OK"