#script written by Mathew Gallehawk for INC0036918
#migrate users from teams calling to teams calling 2
#autherised by Infrastructure
$M365_E3_Calling = 'C:\Users\ad-e103719\Desktop\M365_E3_Calling.csv'
$M365_E3_Calling_MOVED= 'C:\Users\ad-e103719\Desktop\M365_E3_Calling_MOVED.csv'
Get-ADGroupMember -Identity "M365 E3 Calling" -Recursive |select name | Export-Csv -NoType $M365_E3_Calling

$Licenses = Get-ADGroup -identity "M365 E3 Calling";
$Licenses | foreach-object {
$members = get-adgroupmember $_
    Add-adgroupmember -identity "M365 E3 Calling 2" -members $members -Confirm:$false    
    Remove-adgroupmember -identity $_ -members $members -Confirm:$false
    $members | Select-object Name -unique | select name | Export-Csv -NoType $M365_E3_Calling_MOVED -Append
   };