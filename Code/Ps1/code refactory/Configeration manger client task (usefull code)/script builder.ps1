#file path list is currently located
$filePath = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\Devices.csv';

#test for each logic if Devices = devices test the logic worked
$filePathB = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\comandbuilder.csv';

Import-Csv $filePath | ForEach-Object {
#outputs the host name for sanity check
$A = $_.DeviceName;
$hostEntry= [System.Net.Dns]::GetHostByName($A)
$hostEntry.AddressList[0].IPAddressToString
#Sanity check for IP conversion
$B = $hostEntry.AddressList[0].IPAddressToString
$StringA = '/node:"';
$StringB= '" product where name="Configuration Manager Client" call uninstall';
$out= $StringA+$A+$StringB
$out
Add-Content -Path $filePathB -Value $out -Encoding UTF8
#Write-Output $out | Export-Csv -Append $filePathB -NoTypeInformation -force

}
