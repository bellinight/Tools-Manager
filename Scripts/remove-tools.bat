@echo off
:: REMOVENDO INSTALAÇÃO DO TOOLS MANAGER
setlocal

set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%

echo.[INFO] %DATE% %TIME% Deletando Agenda do ProcessaGuard >> "C:\Mercadologic\log\tkcheck.log"
schtasks /delete /tn ProcessaGuard /f >> "C:\Mercadologic\log\tkcheck.log"