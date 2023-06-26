@echo off
:: CRIA TAREFA PARA VERIFICAÇÃO DO TOOLKIT
:: AGENDA MENSAL COM PRIVLILEGIOS ALTOS
setlocal

set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%

echo.[INFO] %DATE% %TIME% Deletando Agenda do ProcessaGuard >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
schtasks /delete /tn ProcessaGuard /f >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
echo.[INFO] %DATE% %TIME% Criando Agendamento do ProcessaGuard >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"
schtasks /create /tn ProcessaGuard /tr %appdata%\Processa\ToolsManager\ver_rem_toolkit.bat /sc monthly /f /rl HIGHEST >> "%appdata%\Processa\ToolsManager\log\tkcheck.log"

exit