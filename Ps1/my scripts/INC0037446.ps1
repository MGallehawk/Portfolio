#Get-ADGroupMember -identity "DL - 1007" | select-Object | Get-ADuser | Select Name, Enabled  | Export-csv -path C:\Users\ad-e103719\Desktop\1007.csv -Notypeinformation
Get-ADGroupMember -identity "DL - 1007" | select-Object | Get-ADuser | foreach {

    Get-ADUser -Identity $_ | Select Name, Enabled | Export-csv -path C:\Users\ad-e103719\Desktop\1007.csv -Notypeinformation -append
    Get-ADPrincipalGroupMembership -Identity $_ | select name, Enabled |foreach {if ($_.name -Like 'M365*')  {$_| select-Object name, Enabled | Export-csv -path C:\Users\ad-e103719\Desktop\1007.csv -Notypeinformation -append}}
   
    }