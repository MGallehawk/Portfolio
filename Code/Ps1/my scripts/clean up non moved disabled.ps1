#returns disabled users that have not been moved to end dated user ou.
$cleanup= Get-ADUser -Filter  {(Enabled -eq $false)} | ? { ($_.distinguishedname -notlike '*End-dated Users*') } |  ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } ;
$endDateOU = "OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au";
$Moved = '\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\end-dated-users-Moved.csv'
$cleanup | foreach-object {
    #Get-ADUser -Identity $_ | Export-Csv -NoType $Moved -Append
    Move-ADObject -Identity $_ -TargetPath $endDateOU;
    
   };



