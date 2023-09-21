#==========================================================================================================================#
#Parametros de Conexão do Postgresql (Dados Sensiveis)
#==========================================================================================================================#

# Defina o caminho do arquivo que guarda os dados sensiveis
$arquivo = "$env:APPDATA\Processa\ToolsManager\guard_alert\datasense.config"

# Defina os padrões de pesquisa e as variáveis correspondentes
$padroes = @{
    "database" = "database="
    "port" = "port="
    "server" = "server="
    "user" = "user="
    "password" = "password="
    "username" = "username="
    "password_email" = "password_email="
    "smtp_server" = "smtp_server="
}

# Cria uma hash table para armazenar os resultados
$resultados = @{}

# Le o conteúdo do arquivo
$linhas = Get-Content -Path $arquivo

# Percorra cada linha do arquivo
foreach ($linha in $linhas) {
    # Percorra cada padrão de pesquisa
    foreach ($padrao in $padroes.GetEnumerator()) {
        # Verifique se a linha contém o padrão
        if ($linha -like "*$($padrao.Value)*") {
            # Extrai o valor correspondente ao padrão
            $valor = $linha -replace ".*$($padrao.Value)"

            # Verifique se a variável já existe no hash table
            if (-not $resultados.ContainsKey($padrao.Name)) {
                # Cria uma nova variável no hash table
                $resultados[$padrao.Name] = $valor
            }
        }
    }
}

#==========================================================================================================================#
#Caminho Path Base
#==========================================================================================================================#
#$path_atual = "C:\Mercadologic"
#==========================================================================================================================#
#Conexão 
#==========================================================================================================================#
# Use os valores armazenados na hash table para construir a string de conexão
$cnString = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$($resultados['database']);SERVER=$($resultados['server']);PORT=$($resultados['port']);UID=$($resultados['user']);PWD=$($resultados['password']);Timeout=2;"
$conn_con = New-Object -comobject ADODB.Connection
$conn_con.Open($cnString, $resultados['user'], $resultados['password'])

#==========================================================================================================================#
# Controle de PDVs
#==========================================================================================================================#
$query_seek = $conn_con.Execute("UPDATE controlpdv AS cp1
SET addpdv = 1
WHERE cp1.totalpdvs <> (
    SELECT cp2.totalpdvs
    FROM controlpdv AS cp2
    WHERE cp2.id = cp1.id - 1
)
AND cp1.registro = CURRENT_DATE;")

$query_check = $conn_con.Execute("SELECT totalpdvs FROM controlpdv where addpdv notnull")
$totalpdvs = $query_check.Fields["totalpdvs"].Value



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
Write-Host "Qtda de Pdvs " $totalpdvs 
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