$Logon ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\logon.csv'
Get-ADUser -Filter  {(Enabled -eq $true)} -property scriptPath | ? { ($_.scriptPath -xor 'LOGON.BAT') } | ? { ($_.Name -match 'e+\d{6}' ) } | ? { ($_.Name -like 'e*' ) }| Export-Csv -NoType $Logon;

