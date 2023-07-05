# Defina os parâmetros de conexão ao banco de dados
$server = "localhost"
$port = 5432
$database = "DBMercadologic"
$user = "postgres"
$password = "local"
$path_atual = "C:\Mercadologic"

$cnString = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$database;SERVER=$server;PORT=$port;UID=$user;PWD=$password;Timeout=2;"

$conn_con = New-Object -comobject ADODB.Connection
$conn_con.Open($cnString, $user, $pass)

# Nome da Empresa
$recordset = $conn_con.Execute("SELECT razaosocial FROM public.empresa limit 1;")
$con_ve2 = $recordset.Fields['razaosocial'].value
$con_ve2 | Out-File $path_atual\empresa.txt -Append
		$Stamp + $_ | Out-File $path_atual\empresa.txt -Append
