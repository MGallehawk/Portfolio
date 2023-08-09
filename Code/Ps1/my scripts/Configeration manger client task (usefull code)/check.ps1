#file path list is currently located
$filePath = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\Devices.csv';

Import-Csv $filePath | ForEach-Object {
#outputs the host name for sanity check
$A = $_.DeviceName;
$A
$hostEntry= [System.Net.Dns]::GetHostByName($A)
$hostEntry.AddressList[0].IPAddressToString
#Sanity check for IP conversion
$B = $hostEntry.AddressList[0].IPAddressToString
#code to affect

Wmic /node:$B product get name,version

}