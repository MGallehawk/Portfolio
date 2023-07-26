Connect-AzureAD

#Intune Hardware assets export location
$SophosExportPath = 'C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Asset Management\platform\itteration (2)\test\Sophos\computers.csv'

#location of ouputed data - asset list transformed for snow
$OutputPath = 'C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Asset Management\platform\itteration (2)\test\Sophos\output.csv'

#cleans up the previous output
Remove-Item $OutputPath -Erroraction 'silentlycontinue'

#todays date
$date = Get-Date -Format "dd/MM/yyyy"

#Creates an object out of each device in the export
$SophosInport = Import-Csv -Path $SophosExportPath
$SophosInport | foreach-object {

#device details
$DevName = $_.'Name'

try {
  $DevLastLog = Get-ADUser -Identity $_.'Last user' -Properties DisplayName -ErrorAction Stop
  
} catch {
  $DevLastLog = ''
}

if ($DevLastLog -Like '*Operator*')
  {$DevLastLog = ''} 


$DevLastAct =([DateTime] $_.'Last active').ToString('dd/MM/yyyy') 

$Outob = New-Object -TypeName psobject

  #Device Model Catagory
  $Outob | Add-Member -MemberType NoteProperty -Name 'Last User' -Value $DevLastLog.DisplayName
  #Device serial number 
  #$Outob | Add-Member -MemberType NoteProperty -Name 'today date' -Value $date
  $Outob | Add-Member -MemberType NoteProperty -Name 'Date logged in' -Value $DevLastAct
  #Device Asset Tag
  $Outob | Add-Member -MemberType NoteProperty -Name 'Asset tag' -Value $DevName
 
#filter corperate only devices and devices named Deskop that have not enrolled properly
if ($Outob.'Asset tag' -match '\w{4}[-]\d{4}' -And $Outob.'Date logged in' -eq $date)
  {
    $Outob | Select-Object * | Export-Csv -Path $OutputPath -Append -NoTypeInformation
  }

}
Disconnect-AzureAD
;
