#==========================================================================================================================#
#Parametros de Conexão do Postgresql (Dados Sensiveis)
#==========================================================================================================================#

# Defina o caminho do arquivo que guarda os dados sensiveis
$arquivo_sense = "$env:APPDATA\Processa\ToolsManager\guard_alert\datasense.config"
$data_files = "$env:APPDATA\Processa\ToolsManager\data_files"
$PathMlogic = "C:\Mercadologic\"

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
    "pdv_database" = "pdv_database="
    "pdv_server" = "pdv_server="
}

# Cria uma hash table para armazenar os resultados
$resultados = @{}

# Le o conteúdo do arquivo
$linhas = Get-Content -Path $arquivo_sense

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
#database=DBM_H
#port=5432
#server=127.0.0.1
#user=postgres
#password=local
#username=sandbox@processasistemas.com.br
#password_email=#1qwer0987
#smtp_server=smtp.processasistemas.com.br
#pdv_database=DBPDV
#pdv_server=$ip
#==========================================================================================================================#
#Conexão 
#==========================================================================================================================#
# Use os valores armazenados na hash table para construir a string de conexão [Concentrador]
$cnString = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$($resultados['database']);SERVER=$($resultados['server']);PORT=$($resultados['port']);UID=$($resultados['user']);PWD=$($resultados['password']);Timeout=2;"
$conn_con = New-Object -comobject ADODB.Connection
$conn_con.Open($cnString, $resultados['user'], $resultados['password'])


#Conexão banco gerente
$dbgerente = 'db_gerente'
$cnString_ger = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=db_gerente;SERVER=127.0.0.1;PORT=$($resultados['port']);UID=$($resultados['user']);PWD=$($resultados['password']);Timeout=2;"
$conn_ger = New-Object -comobject ADODB.Connection
$conn_ger.Open($cnString_ger, $resultados['user'], $resultados['password'])   



#==========================================================================================================================#
# Nome da Empresa [$empresa_nome]
#==========================================================================================================================#
$query_set = $conn_con.Execute("SELECT razaosocial FROM public.empresa limit 1;")
$empresa_nome = $query_set.Fields['razaosocial'].value
#$empresa_nome | Out-File C:\Mercadologic\log\empresa.txt -Append
#$Stamp + $_ | Out-File $PathMlogic\empresa.txt -Append

#==========================================================================================================================#
# Versão concentrador [$con_ve]
#==========================================================================================================================#

$ip_pdv_conc = $conn_con.Execute("SELECT versao_sistema FROM public.versao limit 1;")
$con_ve = $ip_pdv_conc.Fields['versao_sistema'].value

#==========================================================================================================================#
# Versão concentrador
#==========================================================================================================================#


    # Atualização carga no Concentrador
  # versões superiores à 13.7.0
    $ip_pdv_carg_conc = $conn_con.Execute("SELECT id_atualizacao, CAST(dh_fim_publicacao AS text) AS dh_fim_publicacao FROM carga.semaforo_loja ORDER BY id_atualizacao DESC LIMIT 1;")
    $carg_conc_id = $ip_pdv_carg_conc.Fields['id_atualizacao'].value
    $carg_conc_pub = $ip_pdv_carg_conc.Fields['dh_fim_publicacao'].value

 #Verifica HD do concentrador
    $hd_conc = Get-CimInstance -ClassName Win32_LogicalDisk -filter "DeviceID='C:'"

    $hd_conc_list = $hd_conc | Foreach-Object {
        $hd_free = $_.FreeSpace
        $hd_size = $_.Size
    }

    # Verifica o status dos serviços no Concentrador
    $Text = Get-Content -Path $data_files\Servicos.config
$Text.GetType() | Format-Table -AutoSize

foreach ($element in $Text) 
{ 
    $variavel = ($element.Split('=') | Select-Object -first 1)
	$valor = get-service ($element.Split('=') | Select-Object -last 1)
	#New-Variable -Name $variavel -Value $valor.Status
}

################################################################
# Verifica Java Na Maquina
################################################################
$java_ver = 'Atenção'

try {
    $java_ver = (Get-Command java | Select-Object Version).Version.Major.ToString()
} catch {
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
    $mensagem_java_error = $Stamp + "Verifique o java instalado na maquina"
   <#  $mensagem | Out-File $PathMlogic\logs.txt -Append
    $Stamp + $_ | Out-File $PathMlogic\logs.txt -Append #>
    Write-Host $mensagem_java_error
}
################################################################
# Versão do Postgres
################################################################
$pgsql_ver = 'Atenção'

try {
    $pgsql_ver = (Get-Command Postgres | Select-Object Version).Version.Major.ToString()
} catch {
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
    $mensagem_postgresql = $Stamp + "Verifique o PostregSQL instalado na maquina"
   <#  $mensagem | Out-File $PathMlogic\logs.txt -Append
    $Stamp + $_ | Out-File $PathMlogic\logs.txt -Append #>
    Write-Host $mensagem_postgresql
}

#==========================================================================================================================#
# Conecta e executa scripts nos PDVS
#==========================================================================================================================#

 # Abre a Conexao com o banco de dados do PDV
 $cnString_pdv = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$($resultados['pdv_database']);SERVER=$ip;PORT=$($resultados['port']);UID=$($resultados['user']);PWD=$($resultados['password']);Timeout=2;"
 $conn_pdv = New-Object -comobject ADODB.Connection
 $conn_pdv.Open($cnString_pdv, $resultados['user'], $resultados['password'])

# Consultar os IPs no banco DBMercadologic
$query_ip = "select descricao,ip,versao_sistema from pdv where desativado is null"
$recordset = $conn_con.Execute($query_ip)

$conn_ger.Execute("TRUNCATE TABLE public.dados_json") 
# Ler os IPs retornados e executar os scripts em cada IP
while (!$recordset.EOF) {
    $ip = $recordset.Fields.Item("ip").Value
    $pdv_desc = $recordset.Fields.Item("descricao").Value 
    $pdv_vers_conc = $recordset.Fields.Item("versao_sistema").Value

    #==========================================================================================================================#
    # Lista de scripts sql para consulta de dados do PDV
    #==========================================================================================================================#

    try {
        $query_set_pdv = $conn_pdv.Execute("SELECT ean FROM ean limit 1;")
        $ean_pdv = $query_set_pdv.Fields['ean'].value
    } catch {
        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " $pdv_desc : Não foi possivel..... "
        $mensagem | Out-File $PathMlogic\logs.txt -Append
		$Stamp + $_ | Out-File $PathMlogic\logs.txt -Append
        Write-Host $mensagem
    }
    #==========================================================================================================================#
    # Busca rejeições e apresenta no painel
    #==========================================================================================================================#

    try {
		$recordset_seek = $conn_pdv.Execute("
		SELECT substring(msg_retornada, 1, 3) as numero 
		FROM cupom_fiscal_eletronico
		WHERE msg_retornada LIKE '%100%' AND dh_contingencia ::date BETWEEN CURRENT_DATE -31 AND CURRENT_DATE -1
		limit 1;")
		$pv_seek = $recordset_seek.Fields['numero'].value
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " $pdv_desc : Ocorreu um erro ao tentar pegar a 539 do concentrador"
        $mensagem | Out-File $PathMlogic\logs.txt -Append
		$Stamp + $_ | Out-File $PathMlogic\logs.txt -Append
        Write-Host $mensagem
	}
    
    #==========================================================================================================================#
    # Pega a Versão do PDV no bacnco DBPDV
    #==========================================================================================================================#

    # Versão PDV
    try {
		$pdv_ver_query = $conn_pdv.Execute("SELECT versao_sistema FROM public.versao limit 1;")
		$pdv_ver_dbpdv = $pdv_ver_query.Fields['versao_sistema'].value
    } catch {
        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " $pdv_desc : Ocorreu um erro ao verificar a versão do PDV"
        $mensagem | Out-File $PathMlogic\logs.txt -Append
		$Stamp + $_ | Out-File $PathMlogic\logs.txt -Append
        Write-Host $mensagem        
    }
         
    #Inserir dados no banco gerente
    try {
        $conn_ger.Execute("INSERT INTO public.dados_json (pdv_desc, pdv_ip, pdv_com, pdv_vers, pdv_bkp, pdv_carg, pdv_rej) 
        VALUES ('$pdv_desc', '$ip','$java_ver' , '$pdv_ver_dbpdv','$pgsql_ver' , '$ean_pdv', '$pv_seek')")
        } catch {
        $Stamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
        $mensagem = $Stamp + " $pdv_desc : Ocorreu um erro ao Inserir os dados no Banco de Dados"
        $mensagem | Out-File "$PathMlogic\logs.txt" -Append
        $Stamp + $_ | Out-File "$PathMlogic\logs.txt" -Append
        Write-Host $mensagem
    }
    
    $recordset.MoveNext()

    
}
Write-Host $pdv_desc, $ip, $pdv_ver_dbpdv, $dbgerente
# Fechar a conexão com o banco DBMercadologic
$conn_pdv.Close()
$conn_con.Close()


