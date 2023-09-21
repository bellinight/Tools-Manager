# Caminhos das pastas Fonte e Destino
$Fonte = "C:\xml-fonte"
$Destino = "C:\xml_teste"

# Data de ontem
$DataOntem = (Get-Date).AddDays(-3).ToString("yyyy-MM-dd")

# Deletar o conteúdo da pasta Destino
Remove-Item -Path $Destino\* -Force -Recurse

# Copiar arquivos da Fonte modificados no dia anterior
Get-ChildItem -Path $Fonte | Where-Object { $_.LastWriteTime.Date -eq $DataOntem } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $Destino
}

Write-Host "Concluído!"
exit