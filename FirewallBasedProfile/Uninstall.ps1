$folder = "C:\Firewall"
#Creating the fodler with only system can access
Remove-Item -Path $folder -Force -Recurse

#TaskScheduler
Unregister-ScheduledTask -TaskName "Deploy-FW" -Confirm:$false