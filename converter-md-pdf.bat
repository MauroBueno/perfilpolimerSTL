@echo off
REM Script Batch para converter Markdown para PDF
REM Uso: converter-md-pdf.bat "nome-do-arquivo.md"

if "%~1"=="" (
    echo Erro: Especifique o arquivo .md como parametro
    echo Exemplo: converter-md-pdf.bat "CFW500_Modbus_Mapping.md"
    pause
    exit /b 1
)

set ARQUIVO=%~1
set ARQUIVO_SAIDA=%~dpn1.pdf

echo Convertendo "%ARQUIVO%" para "%ARQUIVO_SAIDA%"...

REM Tentar Pandoc primeiro
pandoc "%ARQUIVO%" -o "%ARQUIVO_SAIDA%" 2>nul
if %errorlevel% equ 0 (
    echo Conversao concluida com sucesso!
    echo Arquivo criado: %ARQUIVO_SAIDA%
    goto :fim
)

REM Se Pandoc falhar, mostrar instrucoes alternativas
echo Pandoc nao encontrado. Use um dos metodos alternativos:
echo.
echo METODO 1 - VS Code + Extensao:
echo 1. Instale a extensao "Markdown PDF" no VS Code
echo 2. Abra o arquivo .md no VS Code
echo 3. Pressione Ctrl+Shift+P
echo 4. Digite "Markdown PDF" e selecione
echo.
echo METODO 2 - Online:
echo 1. Acesse: https://www.markdowntopdf.com/
echo 2. Cole o conteudo do arquivo .md
echo 3. Clique em "Download PDF"
echo.
echo METODO 3 - GitHub:
echo 1. Faça upload do .md para um repositorio GitHub
echo 2. Abra o arquivo no GitHub
echo 3. Adicione "?print-pdf" no final da URL
echo 4. Pressione Ctrl+P no navegador
echo.
echo METODO 4 - Typora:
echo 1. Baixe e instale o Typora
echo 2. Abra o arquivo .md
echo 3. File ^> Export ^> PDF
echo.
pause

:fim