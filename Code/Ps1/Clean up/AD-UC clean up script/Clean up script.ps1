#selects all users that are disabled that are not hidden from gal
# replicated this is prod with $galUser = get-ADUser -Identity e103719 this changed me and only me
#the $GalUser decleration works and is used in my auditing

$GalUser = Get-ADUser -Filter  {(Enabled -eq $false)} -property msExchHideFromAddressLists | ? { ($_.msExchHideFromAddressLists -xor 'true') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) }
$GalUser | foreach{
Set-ADUser $_ -replace @{msExchHideFromAddressLists=$true}};

#returns disabled users that have not been moved to end dated user ou.
$endDateOU = "OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au"; # operational enviroment
$outOfEnddated = Get-ADUser -Filter  {(Enabled -eq $false)} | ? { ($_.distinguishedname -notlike '*End-dated Users*') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) }
$outOfEnddated | Move-ADObject -TargetPath $endDateOU; #tested works

#this script written by Mathew Gallehawk with the help of joel.... mostly joel on this one.... to automate anumber of queries through ad an create a report in my hdrive
#not 100% sure about this one havent tested it
$dls = get-adgroup -filter {name -like "DL -*"}
$dls | foreach-object {
    $dlmembers = get-adgroupmember $_ | ? { ($_.distinguishedname -like '*End-dated Users*') }
    Remove-adgroupmember -identity $_ -members $dlmembers -Confirm:$false
    $dlmembers | Select-object Name -unique | select name
   };


#this script shgould strip v6 and mso licenses
#defines the targeted users


$Licenses = Get-ADGroup -filter { (name -like '*V6*') -or (name -like '*365*') -or (name -like '*project*')};
$Licenses | foreach-object {
    $members = get-adgroupmember $_ | ? { ($_.distinguishedname -like '*End-dated Users*') }
    Remove-adgroupmember -identity $_ -members $members -Confirm:$false
    $members | Select-object Name -unique | select name
   };





$EnddatedUser = Get-ADUser -Filter  {(Enabled -eq $false)} | ? { ($_.distinguishedname -like '*End-dated Users*') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } | foreach-object {



$securityGroups = Get-ADPrincipalGroupMembership $EndUser;
$365Licenses = $securityGroups | ? { ($_.name -like '*365*') };
$project = $securityGroups | ? { ($_.name -like '*project*') };
$V6 = $securityGroups | ? { ($_.name -like '*V6*') };

$365Licenses | foreach-object {Remove-ADGroupMember -Identity $_ -Members $EndUser -Confirm:$false} 
$project | foreach-object {Remove-ADGroupMember -Identity $_ -Members $EndUser -Confirm:$false}  
$V6 | foreach-object {Remove-ADGroupMember -Identity $_ -Members $EndUser -Confirm:$false}  
}