@echo off
::VERIFICA ULTIMO DIA DE USO DO APP TOOLKIT
::SE FOR MAIS QUE LIMITE DE DIAS, O SERVIÇO E DESISTALADO AUTOMATICAMENTE
setlocal

set "serv=NfceToolkit"
set "arquivo=C:\Mercadologic\NfceToolkit\Host.txt"
set "limite_dias=31"
set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%

for %%F in ("%arquivo%") do set "ultima_edicao=%%~tF"

:: Obter data atual
for /F %%A in ('powershell -Command "Get-Date -Format yyyyMMdd"') do set "data_atual=%%A"

:: Obter data da última modificação do arquivo
for /F "tokens=1-3 delims=/ " %%B in ("%ultima_edicao%") do (
    set "ultima_data=%%D%%C%%B"
)

:: Calcular a diferença em dias
set /A "diferenca_dias=data_atual - ultima_data"

:: Verificar se a diferença é maior que o limite
if %diferenca_dias% GTR %limite_dias% (
    echo %DATE% %TIME% A última edição do arquivo %arquivo% foi há mais de %limite_dias% dias. Ultima utilização em "%ultima_edicao%". >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    ::echo Executando o arquivo %bat_executar%...
    echo.[INFO] %DATE% %TIME% Parando o servico %serv%... >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    net stop %serv% >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
::Remove serviço do TK
    echo.[INFO] %DATE% %TIME% Removendo registro do servico %serv%... >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    sc delete %serv% >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    ::call "%bat_executar%"
    ::echo Executando "%bat_executar%" >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
) else (
    echo  %DATE% %TIME% A última edição do arquivo %arquivo% está dentro do limite de %limite_dias% dias. Total de dias ociosos, %diferenca_dias% dias. >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
)
endlocal
::Limpa tela
cls
:: Efetua varedura de log
powershell Get-Content $env:APPDATA\Processa\ToolsManager\log\tkcheck.log

pause



exit