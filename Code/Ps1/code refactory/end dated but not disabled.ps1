$OUpath = 'OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'
$ExportPath = 'C:\Users\ad-e103719\Desktop\end-dated-users-not-disabled.csv'
Get-ADUser -Filter 'Enabled -eq "True"' -SearchBase $OUpath | Select-object Name | Export-Csv -NoType $ExportPath