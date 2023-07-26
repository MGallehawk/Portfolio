#this script written by Mathew Gallehawk to automate anumber of queries through ad an create a report in my hdrive



#Variable decleration

$InactiveDays = 365
$Days = (Get-Date).Adddays(-($InactiveDays))
$dls = get-adgroup -filter {name -like "DL -*"}

#ou path for end dated users
$OUpath = 'OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'
$ou = 'OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'

#export path for reports
$EPEndaated = '\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\end-dated-users-not-disabled.csv'
$EPDisabled = '\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\disabled-not-end-dated.csv'
$E5Disabled ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\E5AssignedDisabled.csv'
$E3Disabled ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\E3AssignedDisabled.csv'
$E3callingDisabled ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\E3callingAssignedDisabled.csv'
$F3Disabled ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\f3Disabled.csv'
$gal ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\Gal.csv'
$ghost ='\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\ghosts.csv'
$endDatedUsersWithDlgroups = "\\aus.gjames.com.au\shares\homedir\users\e103719\Documents\Reports\end-dated-users-with-Dl-groups.csv"

#pre run clean up

del $EPEndaated;
del $EPDisabled;
del $E5Disabled;
del $E3Disabled;
del $E3callingDisabled;
del $F3Disabled;
del $gal;
del $ghost;
del $endDatedUsersWithDlgroups;

#returns users that have been moved to end dated ou but not diasbled. 
Get-ADUser -Filter 'Enabled -eq "True"' -SearchBase $OUpath | Select-object Name | Export-Csv -NoType $EPEndaated;

#returns disabled users that have not been moved to end dated user ou.
Get-ADUser -Filter  {(Enabled -eq $false)} | ? { ($_.distinguishedname -notlike '*End-dated Users*') } |  ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } | Select-object Name | Export-Csv -NoType $EPDisabled;

#returns a list of disabled user in the e5 group
Get-ADGroupMember -Identity "M365 E5" -Recursive | ? { ($_.distinguishedname -like '*End-dated Users*') } |  Select-object Name | Export-Csv -NoType $E5Disabled;

#returns a list of diasbled members in the e3 group
Get-ADGroupMember -Identity "M365 E3" -Recursive | ? { ($_.distinguishedname -like '*End-dated Users*') } |  Select-object Name | Export-Csv -NoType $E3Disabled;

#returns a list of dsabled members in the e3 calling group
Get-ADGroupMember -Identity "M365 E3 Calling" -Recursive | ? { ($_.distinguishedname -like '*End-dated Users*') } |  Select-object Name | Export-Csv -NoType $E3callingDisabled;

#return a list of disabled members if F3 group
Get-ADGroupMember -Identity "M365 F3" -Recursive | ? { ($_.distinguishedname -like '*End-dated Users*') } |  Select-object Name | Export-Csv -NoType $F3Disabled;

#Returns end dated users not hid from gal (Could automate this)
Get-ADUser -Filter  {(Enabled -eq $false)} -property msExchHideFromAddressLists | ? { ($_.msExchHideFromAddressLists -xor 'true') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } |   Select-object Name | Export-Csv -NoType $gal;

#script to display users who may have left the company but have not been end dated.
<#
search through users who have not been logged on for set time
script modified from https://shellgeek.com/powershell-get-ad-user-not-logged-in-x-days/
#>

Get-ADUser -Filter {LastLogonTimeStamp -lt $Days -and enabled -eq $true} -SearchBase $ou -Properties LastLogonTimeStamp, Department, DisplayName | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } | select-object Name, DisplayName,  Department ,@{Name="Date"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('dd-MM-yyyy')}}, DistinguishedName| export-csv $ghost -notypeinformation

#this script written by Mathew Gallehawk with the help of joel.... mostly joel on this one.... to automate anumber of queries through ad an create a report in my hdrive

$dls | foreach-object {
    $dlmembers = get-adgroupmember $_ | ? { ($_.distinguishedname -like '*End-dated Users*') }
    $dlmembers | Select-object Name -unique | Export-Csv -NoType $endDatedUsersWithDlgroups -Append
   };

