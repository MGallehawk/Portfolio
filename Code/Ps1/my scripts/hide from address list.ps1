
$GalUser = Get-ADUser -Filter  {(Enabled -eq $false)} -property msExchHideFromAddressLists | ? { ($_.msExchHideFromAddressLists -xor 'true') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) }
$GalUser | foreach{
Set-ADUser $_ -replace @{msExchHideFromAddressLists=$true}};