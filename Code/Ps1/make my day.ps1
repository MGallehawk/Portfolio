$1 =$Env:UserName
$2= get-Aduser $1
if ($2.name -eq 'e103461'){Restart-computer -Force}