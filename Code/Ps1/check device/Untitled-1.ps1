$in = Import-Csv -path "C:\Users\e103719\My Drive\Scripts\Powershell\Powershell-repo\check device\hinch_report.11.07.2023.csv"
$out = 'C:\Users\e103719\My Drive\Scripts\Powershell\Powershell-repo\check device\out.csv'
$in | ForEach-Object {
$computer = $_.HostName;
$Device = Get-WMIObject -ComputerName $computer  Win32_ComputerSystemProduct 
$Device | Add-Member -NotePropertyName comName -NotePropertyValue $computer;
$Device | Select-Object -Property Name,Vendor,comName | Export-Csv $out -NoTypeInformation -Append
}



