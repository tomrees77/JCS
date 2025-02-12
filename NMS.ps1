# Add provider for HKU and add local user sid
New-PSDrive HKU Registry HKEY_USERS
$sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# Windows Updates
# Receive updates for other Microsoft products
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 0 # Enable this field if it is "managed"
$ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
$ServiceManager.ClientApplicationID = "My App"
$NewService = $ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")
# Get me up to date
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -Type DWord -Value 1
# Download over metered connections
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" -Type DWord -Value 0
# Notify when a restart is required
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Type DWord -Value 1
# Turn off delivery optimization
Set-ItemProperty -Path "HKU:\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" -Name "DownloadMode" -Type DWord -Value 0

# Location
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value Allow


# Taskbar Items: Search
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
# Taskbar Items: Task view
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
# Taskbar Items: Widgets
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
# Taskbar Items: Chat
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0
# Taskbar align: left = 0, center = 1
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0

# Annoying Windows notifications:
# Get tips and suggestions when I use Windows
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
# Show me the Windows welcome experience...
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
# Show suggestions occasionally in Start
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
# Offer suggestions on how I can set up my device; may need to create if never run before
New-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | New-ItemProperty -Name "ScoobeSystemSettingEnabled" -Value 0 -Force | Out-Null

# Power Settings
powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 833a6b62-dfa4-46d1-82f8-e09e34d029d6 0​
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 833a6b62-dfa4-46d1-82f8-e09e34d029d6 0
Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value '0'
Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

# Set time automatically
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Type String -Value NTP
# Set Time Zone and make it automatic automatically
Set-TimeZone "Eastern Standard Time"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Type DWord -Value 3
# Adjust for DST Automatically
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "DynamicDaylightTimeDisabled" -Type DWord -Value 0
# Synchronize with time servers
net start w32time
w32tm /resync /nowait /force

#Disable Game Bar
# Adapted from: https://docs.microsoft.com/en-us/answers/questions/241800/completely-disable-and-remove-xbox-apps-and-relate.html
Write-Output "Disabling Game mode..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 0
Write-Output "Disabling Game Mode Notifications..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowGameModeNotifications" -Type DWord -Value 0
Write-Output "Disabling Game Bar tips..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Type DWord -Value 0
Write-Output "Disabling Open Xbox Game Bar using Xbox button on Game Controller..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
Write-Output "Disabling Xbox Game Monitoring..."
If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\xbgm")) {
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\xbgm" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\xbgm" -Name "Start" -Type DWord -Value 4

#Disable Cursor and Audio capture
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AudioCaptureEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "CursorCaptureEnabled" -Type DWord -Value 0

# Create shortcut to Documents folder on Desktop
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut("$env:USERPROFILE\Desktop\Documents.lnk")
$shortcut.TargetPath = "$env:USERPROFILE\Documents"
$shortcut.Save()
# Create shortcut to Pictures folder on Desktop
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut("$env:USERPROFILE\Desktop\Pictures.lnk")
$shortcut.TargetPath = "$env:USERPROFILE\Pictures"
$shortcut.Save()

# Enable Storage Sense
#Set-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name '01' -Value '1'
Set-ItemProperty -Path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name '01' -Value '1'

# Enable Network Discovery and File and Printer Sharing
netsh advfirewall firewall set rule group="Network Discovery" new enable=yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
