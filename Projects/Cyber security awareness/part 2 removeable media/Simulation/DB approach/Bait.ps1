#This is the Bait script

#message variable
$EndUserMessage= "This has been a simulation from the IT department. `n Pluging in random USB devices can be dangerious as it may contain malware. `n Please only use Trusted devices. `n Could you please retrun this device to where you found it."

#captured variables
$time = Get-Date -UFormat %d-%m-%y-%R 
$User = whoami.exe
$Machinenumber = HOSTNAME.EXE

#login credentials
$SqlAuthLogin = "matt-test"
$SqlAuthPw = "GJames99!"
$SqlConnection= New-Object System.Data.SqlClient.SqlConnection

#connection script
$SqlConnection.ConnectionString= "Server = gjdc01sql003 ;Database=Matt-testdb; User Id=$SqlAuthLogin; Password =$SqlAuthPw"
$SqlConnection.Open()

#command creator
$SqlCommand=$SqlConnection.CreateCommand()
$SqlCommand.CommandText = "INSERT INTO dbo.FishNet (Time,UserName,MachineName) values ('$($time)','$($User)','$($Machinenumber)')"
$SqlCommand.ExecuteNonQuery()
$SqlConnection.close()
$EndUserMessage
Start-Sleep -Second 25
exit