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
$fwFilePath = Join-Path -Path $fwFolder -ChildPath "fwrule.json"
$fwRulesNew = @(
   @{
        app = "TEAMS";
        path = "AppData\Local\Microsoft\Teams\Current\Teams.exe";
        protocol = "TCP";
        action = "Allow"
    },
    @{
        app = "TEAMS";
        path = "AppData\Local\Microsoft\Teams\Current\Teams.exe";
        protocol = "UDP";
        action = "Allow"
    },
    @{
        app = "TEAMS2";
        path = "AppData\Local\Microsoft\Teams\Current\Teams2.exe";
        protocol = "TCP";
        action = "Allow"
    },
    @{
        app = "TEAMS2";
        path = "AppData\Local\Microsoft\Teams\Current\Teams2.exe";
        protocol = "UDP";
        action = "Allow"
    }
) | ConvertTo-Json | ConvertFrom-Json


#-----------------------------------------------------------[Execution]------------------------------------------------------------

if(-not(Test-Path($fwFilePath))){
    exit 0
}

$fwRules = Get-Content $fwFilePath | ConvertFrom-Json

if($fwRules.Count -ne $fwRulesNew.Count){
    exit 1
}

foreach($fwr in $fwRulesNew){
    if(-not($fwRules | Where-Object{
            $fwRules.app -eq $fwr.app `
            -and $fwRules.path -eq $fwr.path `
            -and $fwRules.path -eq $fwr.path `
            -and $fwRules.protocol -eq $fwr.protocol `
            -and $fwRules.action -eq $fwr.action `
        })){
            exit 1
    }
}

exit 0