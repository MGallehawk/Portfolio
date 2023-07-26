#script written by Mathew Gallehawk for INC0036918
#remove e3 licenses form microsoft calling 2 group
$M365_E3_Calling2 = 'C:\Users\ad-e103719\Desktop\M365_E3_Calling2.csv'
$M365_E3_Callingchecked = 'C:\Users\ad-e103719\Desktop\M365_E3_Calling2.csv'
Get-ADGroupMember -Identity "M365 E3 Calling 2" -Recursive |select name | Export-Csv -NoType $M365_E3_Calling2

$Licenses = Get-ADGroup -identity "M365 E3 Calling 2";
$Licenses | foreach-object {
$members = get-adgroupmember $_
    Remove-adgroupmember -identity "M365 E3" -members $members -Confirm:$false
    Remove-adgroupmember -identity "M365 E5" -members $members -Confirm:$false
    $members | Select-object Name -unique | select name | Export-Csv -NoType $M365_E3_Callingchecked -Append
   };