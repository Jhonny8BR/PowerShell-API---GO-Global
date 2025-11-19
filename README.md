# PowerShell-API---GO-Global
### Access Blocking by Platform Type - Script BAT + PowerShell

This script is intended to limit user access by platform type.
It utilizes features of the PowerShell API functionality that was implemented starting with version 6.3.x of GO-Global.

For operation, the function **_Get-GGClients_** was used, which returns some information:
```
ClientID : x
SessionID : xx
ClientIPAddress : 0.0.0.0
ClientComputerName :
ClientVersion : 6.3.3.34722
ClientPlatform : 4
```

Identification of ClientPlatform:
````
 0 = "Unknown"
 1 = "Windows"
 2 = "macOS"
 3 = "Linux"
 4 = "iOS"
 5 = "Android"
 6 = "HTLM5
````
We only need to collect the "SessionID" and "ClientPlatform" values.

Then this will be validated against the platform's information database to determine if the ClientPlatform value is authorized to access the environment.

When the identified platform is not authorized to access the environment, we will use the "Invoke-GGSessionLogoff" parameter.

This parameter requires the "SessionID" and "ServerID" values.

*Note: The serverID is checked in another function, but we can set the value to 0.


### Create a BAT file:
Create a BAT file named GG_LogonCheck.bat

Content:
````
@echo off
powershell -ExecutionPolicy Bypass -File "C:\Scripts\GG_LogonCheck.ps1"
exit /b 0
````
You need to add the .BAT script to the Admin Console panel at: Tools > Host Options > Session Startup > Logon Script - Option "Global".


### Create the PowerShell script that performs the validation.
Creat a PS1 file name GG_LogonCheck.ps1

Content:
````
# --- CONFIG ---
# Unauthorized platforms
$blockedPlatforms = @(4,5)     # iOS, Android

# Please wait a few milliseconds to ensure that GO-Global has already created the client.
Start-Sleep -Milliseconds 300

try {
    $client = Get-GGClients | Sort-Object SessionID -Descending | Select-Object -First 1
}
catch {
    Write-Host "ERROR: The GO-Global Client was not identified!"
    exit
}

if (-not $client) {
    Write-Host "No user found at Login."
    exit
}

Write-Host "Client detected:"
Write-Host "  SessionID: $($client.SessionID)"
Write-Host "  Platform:  $($client.ClientPlatform)"
Write-Host "  Name:      $($client.ClientComputerName)"

# Check the Plataform
if ($blockedPlatforms -contains $client.ClientPlatform) {

    Write-Host "Platform BLOCKED detected ($($client.ClientPlatform)). Session Shutdown..."

    try {
        Invoke-GGSessionLogoff -ServerId 0 -SessionID $client.SessionID 
        Write-Host "Session Close."
    }
    catch {
        Write-Host "Error closing session: $_"
    }

    exit
}

Write-Host "Platform permitted. Login authorized!"
exit 0
````






 

 
