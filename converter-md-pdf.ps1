# Script PowerShell para converter Markdown para PDF
# Uso: .\converter-md-pdf.ps1 -Arquivo "nome-do-arquivo.md"

param(
    [Parameter(Mandatory=$true)]
    [string]$Arquivo
)

# Verificar se o arquivo existe
if (!(Test-Path $Arquivo)) {
    Write-Host "Erro: Arquivo '$Arquivo' não encontrado!" -ForegroundColor Red
    exit 1
}

# Verificar extensão
if (![IO.Path]::GetExtension($Arquivo) -eq ".md") {
    Write-Host "Erro: O arquivo deve ter extensão .md" -ForegroundColor Red
    exit 1
}

# Nome do arquivo de saída
$arquivoSaida = [IO.Path]::ChangeExtension($Arquivo, ".pdf")

Write-Host "Convertendo '$Arquivo' para '$arquivoSaida'..." -ForegroundColor Green

# Usar Pandoc se disponível
try {
    & pandoc $Arquivo -o $arquivoSaida
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Conversão concluída com sucesso!" -ForegroundColor Green
        Write-Host "Arquivo criado: $arquivoSaida" -ForegroundColor Cyan
    } else {
        throw "Pandoc falhou"
    }
}
catch {
    Write-Host "Pandoc não encontrado. Tentando método alternativo..." -ForegroundColor Yellow

    # Método alternativo: abrir no navegador e imprimir como PDF
    Write-Host "Método alternativo:" -ForegroundColor Yellow
    Write-Host "1. Abra o arquivo $Arquivo no VS Code" -ForegroundColor White
    Write-Host "2. Pressione Ctrl+K V para abrir preview" -ForegroundColor White
    Write-Host "3. Clique com botão direito e selecione 'Open in Browser'" -ForegroundColor White
    Write-Host "4. No navegador, pressione Ctrl+P e salve como PDF" -ForegroundColor White
}

Write-Host "`nExemplos de uso:" -ForegroundColor Cyan
Write-Host ".\converter-md-pdf.ps1 -Arquivo 'CFW500_Modbus_Mapping.md'" -ForegroundColor White
Write-Host ".\converter-md-pdf.ps1 -Arquivo 'alarme_velocidade_torque.md'" -ForegroundColor White