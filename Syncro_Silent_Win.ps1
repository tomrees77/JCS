#!ps
#maxlength=50000
#timeout=900000

# Deploy Syncro via command line, originally intended for use with ScreenConnect
# Above comments are used by ScreenConnect's command processor to specify that this is a PowerShell script
# Script needs to be customized for each Syncro customer, get the information from the customer page.
# Go to New > RMM Agent Installer, and replace the specified data in the variables indicated below.
# In ScreenConnect, paste script in the right side menu, under the Commands tab (5th icon down)

$Url = "https://rmm.syncromsp.com/dl/rs/djEtMTIzNDU2NzgtMDEyMzQ1Njc4OS0xMjM0NS0xMjM0NTY3" # Replace with the download link under the "Windows (EXE)" radio button
$SavePath = "c:\Windows\Temp\SyncroSetup.exe"

$WebClient = New-Object System.Net.WebClient
$downloadResults = $WebClient.DownloadFile($Url,$SavePath)

$FileArguments = "--console --customerid 1234567 --folderid 1234567" # Replace these values with the ones under the "Command line" radio button
$runProcessResults = Start-Process -Filepath "$SavePath" -ArgumentList "$FileArguments"
