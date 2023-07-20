@echo off
::VERIFICA ULTIMO DIA DE USO DO APP TOOLKIT
::SE FOR MAIS QUE LIMITE DE DIAS, O SERVIÇO E DESISTALADO AUTOMATICAMENTE
setlocal

set "serv=NfceToolkit"
set "arquivo=C:\Mercadologic\NfceToolkit\Host.txt"
set "limite_dias=31"
set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%
::Calcula data da ultima edicao do arquivo
for %%F in ("%arquivo%") do set "ultima_edicao=%%~tF"

:: Obter data atual
for /F %%A in ('powershell -Command "Get-Date -Format dd"') do set "dia_atual=%%A"
for /F %%A in ('powershell -Command "Get-Date -Format MM"') do set "mes_atual=%%A"

:: Obter data da última modificação do arquivo
for /F "tokens=1-3 delims=/ " %%B in ("%ultima_edicao%") do (
    set "mes_edicao=%%C"
)
for /F "tokens=1-3 delims=/ " %%B in ("%ultima_edicao%") do (
    set "dia_edicao=%%B"
)

:: Calcular a diferença em dias
set /A "diferenca_dias=dia_atual - dia_edicao"
:: Calcular a diferença em mes
set /A "diferenca_mes=mes_atual - mes_edicao"
:: Calcular a diferença real
set /A "diferenca_real=diferenca_dias + (diferenca_mes * 30)"

:: Verificar se a diferença é maior que o limite
if %diferenca_real% GTR %limite_dias% (
    echo %DATE% %TIME% A ultima edicao do arquivo %arquivo% foi ha mais de %limite_dias% dias. A Ultima utilizacao foi em "%ultima_edicao%". >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    ::echo Executando o arquivo %bat_executar%...
    echo.[INFO] %DATE% %TIME% Parando o servico %serv%... >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    net stop %serv% >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
::Remove serviço do TK
    echo.[INFO] %DATE% %TIME% Removendo registro do servico %serv%... >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    sc delete %serv% >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
    ::call "%bat_executar%"
    ::echo Executando "%bat_executar%" >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
) else (
    echo  %DATE% %TIME% A última edicao do arquivo %arquivo% esta dentro do limite de %limite_dias% dias. Total de dias ociosos, %diferenca_real% dias. >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
)
endlocal
exit