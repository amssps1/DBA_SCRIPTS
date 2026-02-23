# Limpa Conteudo de Subpastas

# Caminho para a pasta principal (altera conforme necessário)
$PastaPrincipal = "C:\Caminho\Para\Pasta"

# Verifica se a pasta existe
if (Test-Path $PastaPrincipal) {
    # Itera por cada subpasta
    Get-ChildItem -Path $PastaPrincipal -Directory | ForEach-Object {
        $SubPasta = $_.FullName

        # Apaga todos os ficheiros dentro da subpasta
        Get-ChildItem -Path $SubPasta -File -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

        # Apaga todas as sub-subpastas (sem apagar a subpasta principal)
        Get-ChildItem -Path $SubPasta -Directory -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Limpeza concluída em: $PastaPrincipal"
}
else {
    Write-Host "A pasta principal não existe: $PastaPrincipal"
}


# Copia conteudo de subpastas para outro folder mantendo as siubpastas

# Caminhos das pastas principal de origem e destino
$Origem = "h:\Backup_Dia"
$Destino = "h:\Backup_Retencao"

# Verifica se as pastas principais existem
if (-not (Test-Path $Origem)) {
    Write-Host "A pasta de origem não existe: $Origem"
    exit
}
if (-not (Test-Path $Destino)) {
    Write-Host "A pasta de destino não existe: $Destino"
    exit
}

# Obter todas as subpastas da origem
Get-ChildItem -Path $Origem -Directory | ForEach-Object {
    $SubPastaOrigem = $_.FullName
    $NomeSubpasta = $_.Name
    $SubPastaDestino = Join-Path $Destino $NomeSubpasta

    # Cria a subpasta no destino se não existir
    if (-not (Test-Path $SubPastaDestino)) {
        New-Item -Path $SubPastaDestino -ItemType Directory | Out-Null
    }

    # Mover ficheiros da subpasta origem para a subpasta destino
    Get-ChildItem -Path $SubPastaOrigem -File | ForEach-Object {
        $FicheiroDestino = Join-Path $SubPastaDestino $_.Name
        Move-Item -Path $_.FullName -Destination $FicheiroDestino -Force
    }

    Write-Host "Ficheiros movidos de $SubPastaOrigem para $SubPastaDestino"
}
