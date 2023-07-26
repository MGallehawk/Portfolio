#INC0035262 
#require a script to deploy Wmic /node: "gjlt-0803" product where name="Configuration Manager Client" call uninstall to a whole bunch of pcs

#test for each loop
<#
#file path list is currently located
$filePath = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\Devices.csv';

#test for each logic if Devices = devices test the logic worked
$filePathB = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\DevicesTest.csv';

Import-Csv $filePath | ForEach-Object {
$A = $_;
Write-Output $A | Export-Csv -NoType -Append $filePathB
}
#>
# For loop successfully appended the A variable onto the new csv file confirming for each loop functionality

<# convert host name to ip
#
$A = "GJlt-1411";
$hostEntry= [System.Net.Dns]::GetHostByName($A)
$B = $hostEntry.AddressList[0].IPAddressToString
$B
#$hostEntry

#>

#Wmic logic
<#
# couldnt get this to work with domain name but had success with ip address
#test Wmic logic
#variable decleration
#$A = "10.54.5.75";

#return list of installed services
#Wmic /node:$A product get name,version
#>

#sanity check for ip converter
<#
$A = "GJlt-0971";
$hostEntry= [System.Net.Dns]::GetHostByName($A)
$B = $hostEntry.AddressList[2].IPAddressToString
$A
$B
$hostEntry
#>




#file path list is currently located
$filePath = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\Devices.csv';

#test for each logic if Devices = devices test the logic worked
$filePathB = 'C:\Users\e103719\OneDrive - G.James Australia Pty Ltd\Desktop\the thing\DevicesTest.csv';

Import-Csv $filePath | ForEach-Object {
#outputs the host name for sanity check
$A = $_.DeviceName;
$A
$hostEntry= [System.Net.Dns]::GetHostByName($A)
$hostEntry.AddressList[0].IPAddressToString
#Sanity check for IP conversion
$B = $hostEntry.AddressList[0].IPAddressToString
#code to affect
#Wmic /node:$B product get name,version
Wmic /node:$B product where name="Configuration Manager Client" call forceduninstall
#Wmic /node:$A product where name="Configuration Manager Client" call uninstall /nointeractive
}

<#
all individual parts seem to work how ever there is an issue with the ipconverter function and the variable passed out in the for loop $_


#>