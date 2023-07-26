#this script written by Mathew Gallehawk to check memberships of users who have been inactive for 1 year
#Variable decleration

$InactiveDays = 365
$Days = (Get-Date).Adddays(-($InactiveDays))


#ou path for end dated users
$OUpath = 'OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'
$ou = 'OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'

#export path for reports
$ghost ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\ghosts.csv'




$GhostUsers= Get-ADUser -Filter {LastLogonTimeStamp -lt $Days -and enabled -eq $true} -SearchBase $ou -Properties LastLogonTimeStamp, Department, DisplayName | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } 
$GhostUsers | foreach-object {
   $u= Get-ADUser $_ ;
   $Memership = Get-ADPrincipalGroupMembership $_ | select name;
   $delimiter = "xxxxxxxxxxxxxxxx `n";
   #$out= $u.UserPrincipalName +"`n"+ $Memership.name+"`n" +$delimiter;
   $lastLog = $_ |select-object @{Name="Date"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('dd-MM-yyyy')}};
   #$u.UserPrincipalName;
   #$Memership
   #$delimiter
   #$out
   #$lastLog
   
   $u.UserPrincipalName| Out-file $ghost -Append;
   $lastLog| Out-file $ghost -Append;
   $Memership| Out-file $ghost -Append;
   $delimiter| Out-file $ghost -Append;
   #$out| Out-file $ghost -Append
   
   
   # select-object Name, DisplayName,  Department ,@{Name="Date"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('dd-MM-yyyy')}}, DistinguishedName| export-csv $ghost -notypeinformation
};

