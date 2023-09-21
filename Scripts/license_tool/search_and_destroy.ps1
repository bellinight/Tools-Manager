#VERIFICA ULTIMO DIA VALIDADE DA LICENÇA DE USO
#SE FOR MAIS QUE LIMITE DE DIAS, O SERVIÇO E DESISTALADO AUTOMATICAMENTE

$fileCreator = (Get-ChildItem -Path C:\Mercadologic\NfceToolkit\Host.txt).CreationTime
$file = Get-Item C:\Mercadologic\NfceToolkit\Host.txt
$dataUltimaEdicao =  $file.LastWriteTime
$serv = "NfceToolkit"
#$LimitePDVs = 15
$limiteDias = 30

#Obter data atual
$dataAtualMes = "{0:MM}" -F  (Get-Date)
$dataAtualDia = "{0:dd}" -F  (Get-Date)

#Obter data da última modificação do arquivo
$convertDataEdicaoDia = "{0:dd}" -F  ($file.LastWriteTime)
$convertDataEdicaoMes = "{0:MM}" -F  ($file.LastWriteTime)

#Calcular a diferença em dias
$diferencaDias = $dataAtualDia - $convertDataEdicaoDia
$diferencaMes = $dataAtualMes - $convertDataEdicaoMes
$diferencaReal = $diferencaDias + ($diferencaMes * 30)

#Visualizar dados#
Write-Host "Arquivo Criado em: " $fileCreator
Write-Host "Utlima Utilização: " $dataUltimaEdicao
Write-Host "Ultima Edicao dia: " $convertDataEdicaoDia
Write-Host "Ultima Edicao mes: " $convertDataEdicaoMes
Write-Host "Dia Atual"$dataAtualDia
Write-Host "MÊs Atual"$dataAtualMes
Write-Host "DIF Mes"$diferencaMes
Write-Host "DIF Dias"$diferencaDias
Write-Host "DIF REAL" $diferencaReal
Write-Host "Limite" $limiteDias "dias"
#Write-Host "Licença" $licenca

#Verificar se a diferença é maior que o limite
if ($diferencaReal -gt $limiteDias) {
Write-Host "O arquivo de licença $file venceu a $diferencaReal dias. A licença venceu em $dataUltimaEdicao."
Write-Host "[INFO] Parando o serviço $serv..."
Stop-Service $serv
Write-Host "[INFO] Removendo registro do serviço $serv..."
Sc Delete $serv
} else {
Write-Host "A Licença $file está dentro do limite de $limiteDias dias. Ultima utilização: $dataUltimaEdicao ."
}
Exit-PSHostProcess