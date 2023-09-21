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
# Nome da Empresa
#==========================================================================================================================#
$query_set = $conn_con.Execute("SELECT razaosocial FROM public.empresa limit 1;")
$empresa_nome = $query_set.Fields['razaosocial'].value
#$empresa_nome | Out-File $path_atual\empresa.txt -Append
#$Stamp + $_ | Out-File $path_atual\empresa.txt -Append
#==========================================================================================================================#
# Parametros para envio de email ao suporte
#==========================================================================================================================#
$EmailFrom = "processaguard_alerta@processasistemas.com.br"                
$EmailTo = "leonardo.belini@processasistemas.com.br"         
$EmailSubject = "PDV ADICIONADO - SETOR SUPORTE." 
$EmailBody = "<Body>
Prezados colaboradores a empresa <B>$empresa_nome</B>, adicinou um novo PDV no sistema. Favor verificar se a adicao esta liberada.
<p> 
Em caso de nao LIBERACAO, favor acessar o cliente e efetuar o bloqueio do PDV e troca de senhas.
<p>
<B>Tenha um otimo dia.</B>
<p>
<h4>Atenciosamente, ProcessaGuard</h4>
</body>
" 

#==========================================================================================================================#
#Parametros do Servidor de Email(Dados Sensiveis)
#==========================================================================================================================#
$SMTPserver= $($resultados['smtp_server'])
$username= $($resultados['username']) 
$password = $($resultados['password_email']) | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
#==========================================================================================================================#
#Comando para envio do email
#==========================================================================================================================#
Send-MailMessage -ErrorAction Stop  -from "$EmailFrom" -to "$EmailTo" -subject "$EmailSubject" -BodyAsHtml  "$EmailBody"  -DeliveryNotificationOption OnSuccess  -SmtpServer "$SMTPserver"  -Priority  "Normal" -Credential $credential -Port 587
exit 