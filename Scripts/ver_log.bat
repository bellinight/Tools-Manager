echo off
:: Acessa o LOG do TOOLS para verificação
cls
powershell Get-Content $env:APPDATA\Processa\ToolsManager\log\tkcheck.log

pause