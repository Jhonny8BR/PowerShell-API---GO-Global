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

