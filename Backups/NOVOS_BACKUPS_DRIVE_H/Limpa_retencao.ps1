### Limpeza de Retenção - dos Backups


# Caminho da pasta principal
$PastaPrincipal = "H:\Backup_Retencao"

# Número de dias de retenção
$DiasRetencao = 4

# Data limite para exclusão
$DataLimite = (Get-Date).AddDays(-$DiasRetencao)

# Regex para identificar nome de pasta no formato yyyyMMdd
$regexData = '^\d{8}$'

# Obter todas as subpastas imediatas
Get-ChildItem -Path $PastaPrincipal -Directory | ForEach-Object {
    $nomePasta = $_.Name

    # Verifica se o nome está no formato yyyyMMdd
    if ($nomePasta -match $regexData) {
        try {
            $dataPasta = [datetime]::ParseExact($nomePasta, 'yyyyMMdd', $null)

            if ($dataPasta -lt $DataLimite) {
                Write-Output "A eliminar: $($_.FullName) (Data: $dataPasta)"
                Remove-Item -Path $_.FullName -Recurse -Force
            } else {
                Write-Output "A manter: $($_.FullName) (Data: $dataPasta)"
            }
        } catch {
            Write-Warning "Formato de data inválido para pasta: $nomePasta"
        }
    } else {
        Write-Output "Ignorado (nome não corresponde ao padrão): $nomePasta"
    }
}