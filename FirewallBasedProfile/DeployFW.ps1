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

#---------------------------------------------------------[Initializations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sVersion = "1.5"

#$folder = "C:\Firewall" 
$folder = "C:\Firewall" 
$fwPrefix = "FW"
$debug = $true

$logName = "Application"
$logSource = "DeployFWRule"


#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Get-FwRuleByApp {
    param (
        $progPath,
        $protocol
    )
    $fwRules = @()
    $fwAppFilter = Get-NetFirewallApplicationFilter -Program $progPath -ErrorAction SilentlyContinue
    foreach($fwApp in $fwAppFilter){
        $fwRule = $fwApp | Get-NetFirewallRule 
        $fwPortFiler = $fwRule | Get-NetFirewallPortFilter
        if($fwPortFiler.Protocol -ne $protocol){
            continue
        }
        $fwRules+=[PSCustomObject]@{
            RuleApp = $progPath
            RuleId = $fwRule.ID
            RuleDisplayName = $fwRule.DisplayName
            RuleEnabled = $fwRule.Enabled
            RuleAction = $fwRule.Action
            RuleProtocol = $fwPortFiler.Protocol
            RuleDirection = $fwRule.Direction
        }
    }
    return $fwRules
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------

if(-not([System.Diagnostics.EventLog]::SourceExists($logSource))){
    New-EventLog -LogName $logName -Source $logSource
}

Write-EventLog -LogName $logName -Source $logSource -EntryType Information -EventId 1 -Message "Starting Deploy Firewall Rules based on User - $sVersion"

if($debug){
    Write-EventLog -LogName $logName -Source $logSource -EntryType Information -EventId 99 -Message "Importing JSON File"
}
try{
    $importRules = Get-Content "$folder\fwrule.json" | ConvertFrom-Json
}catch{
    Write-EventLog -LogName $logName -Source $logSource -EntryType Error -EventId 9 -Message "Failed to import the JSON File"
    exit 1
    return
}

if($debug){
    Write-EventLog -LogName $logName -Source $logSource -EntryType Information -EventId 99 -Message "Reading all users profiles from WMI"
}
try{
    $userProfiles = @()
    $userProfiles += Get-WmiObject Win32_UserProfile  | Where-Object {$_.LocalPath -notlike 'C:\Windows\*'}  | Select-Object -ExpandProperty LocalPath
}catch{
    Write-EventLog -LogName $logName -Source $logSource -EntryType Error -EventId 9 -Message "Failed to get the user profiles from WMI"
    exit 1
}

$fwRules =@()
foreach ($userProfile in $userProfiles){
    $userName  = $userProfile.Split("\")[-1]
    Write-EventLog -LogName $logName -Source $logSource -EntryType Information -EventId 99 -Message "Deploy firewall rules for the user - $userName"
    foreach($importRule in $importRules){
        $statusFwRule = $false
        $fwDisplayName = "$fwPrefix-$userName-$($importRule.app)-$($importRule.protocol)-$($importRule.action)"

        $progPath = Join-Path -Path $userProfile -ChildPath $importRule.path
        $fwRules = Get-FwRuleByApp -progPath $progPath -protocol $importRule.protocol
        
        foreach($fwRule in $fwRules){
            if( ($fwRule.RuleDisplayName -eq $fwDisplayName) `
            -and ($fwRule.RuleAction -eq $importRule.action) `
            -and ($fwRule.RuleEnabled -eq $true)`
            -and ($fwRule.RuleProtocol -eq $importRule.protocol)`
             ){
                $statusFwRule = $true
            }else{
                Remove-NetFirewallRule -ID $fwRule.RuleId
            }
        }
        if(-not($statusFwRule)){
            New-NetFirewallRule -DisplayName $fwDisplayName  -Direction Inbound -Profile Any -Program $progPath -Action $importRule.action -Protocol $importRule.protocol | Out-Null
        }
    }
}
Write-EventLog -LogName $logName -Source $logSource -EntryType Information -EventId 1 -Message "Deploy Firewall rules finished"