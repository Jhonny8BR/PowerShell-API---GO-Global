# --- CONFIGURAÇÕES ---
# Plataformas proibidas
$blockedPlatforms = @(4,5,6)     # iOS, Android, HTML5

# Aguarda alguns milissegundos para garantir que o GO-Global já criou o cliente
Start-Sleep -Milliseconds 300

try {
    $client = Get-GGClients | Sort-Object SessionID -Descending | Select-Object -First 1
}
catch {
    Write-Host "ERRO: Não foi possível obter os clientes GO-Global."
    exit
}

if (-not $client) {
    Write-Host "Nenhum cliente encontrado no logon."
    exit
}

Write-Host "Cliente detectado:"
Write-Host "  SessionID: $($client.SessionID)"
Write-Host "  Platform:  $($client.ClientPlatform)"
Write-Host "  Name:      $($client.ClientComputerName)"

# Verifica se a plataforma é proibida
if ($blockedPlatforms -contains $client.ClientPlatform) {

    Write-Host "Plataforma BLOQUEADA detectada ($($client.ClientPlatform)). Encerrando sessão..."

    try {
        Invoke-GGSessionLogoff -ServerId 0 -SessionID $client.SessionID 
        Write-Host "Sessão finalizada."
    }
    catch {
        Write-Host "Erro ao tentar derrubar a sessão: $_"
    }

    exit
}

Write-Host "Plataforma permitida. Logon autorizado."
exit 0
