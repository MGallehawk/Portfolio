#This is the base script that connects using defined credentials and outputs the table of data

#login credentials
$SqlAuthLogin = "matt-test"
$SqlAuthPw = "GJames99!"
$SqlConnection= New-Object System.Data.SqlClient.SqlConnection

#connection script
$SqlConnection.ConnectionString= "Server = gjdc01sql003 ;Database=Matt-testdb; User Id=$SqlAuthLogin; Password =$SqlAuthPw"
$SqlConnection.Open()

#command creator
$SqlCommand=$SqlConnection.CreateCommand()
$SqlCommand.CommandText = "Select * from dbo.FishNet"

#changes datatype
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $SqlCommand

#generates output
$dataSet = New-Object System.Data.DataSet
$sqlDataAdapter.fill($dataSet)
$dataSet.Tables

#outputs table to file
$Path= "C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Cyber security awareness\part 2 removeable media\Simulation\DB approach\results.csv"
$dataSet.Tables[0] | Out-File $Path
$SqlConnection.Close()
