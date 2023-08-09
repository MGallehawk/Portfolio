#Intune Hardware assets export location
$IntuneExportPath = 'C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Asset Management\platform\itteration (2)\etst\intune-export.csv'

#location of ouputed data - asset list transformed for snow
$SnowConversionOutpath = 'C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Asset Management\platform\itteration (2)\etst\output.csv'

#cleans up the previous output
Remove-Item $SnowConversionOutpath -Erroraction 'silentlycontinue'
 
#Creates an object out of each device in the export
$IntuneInport = Import-Csv -Path $IntuneExportPath
$IntuneInport | foreach-object {

#intune variables 
  #Intune field for asset model
  $DevModel = $_.'Model'
  #Intune Feild for Device name
  $DevName = $_.'Device name'
  #Intune feild for serial number
  $DevSerial = $_.'Serial number'
  #Intune feild for device stste
  #$DevState = $_. 'Device state'
  #Intune ownership field corp or personal
  $DevOwnership = $_.'Ownership'
  #intune feild for Imei
  $DevIMEI = $_.'IMEI'
  #intune feild for phone number
  $DevPhNumber = $_.'Phone number'
  #intune feild for mobile carrier
  $Subscriber = $_.'Subscriber carrier'
  #Intune feild for assigned user
  $AssignedTo = $_.'Primary user display name'
  #intune feild for device operating system
  $DevOS = $_.'OS'

#Magic Variables
 #string builder for Snow comments to track phone number carrier and IMEI
  $DevComments = ('Imported from intune' + "`n" + 'IMEI: ' + $DevIMEI +  "`n"+ 'Phone Number: ' + $DevPhNumber + "`n" + 'Carrier: ' + $Subscriber)
 #Logic for transforming the Intune Ownership feild into Snow feilds Managed by, Owned by, and Company
  If ($DevOwnership -eq 'Corporate') 
    {
      $ManBy = 'Ross Lenox'
      $OwnBy = 'Ross Lenox'
      $Comp = 'G James Glass & Aluminium (Qld) Pty Ltd'
    } 
  Else 
    {
      $ManBy = 'personal'
      $Ownby = 'personal'
      $Comp = 'personal'
    }

  #Logic for deciding if device is a phone or pc
    If ($DevOS -eq 'Windows' -Or $Dev -eq 'MacOS') 
      {
        $ModelCat = 'Computer'
      } 
    else 
      {
        $ModelCat = 'Mobile Handset'
      }
  
#defult settings
  $state = 'In use'
  $expen = 'Capex'
  $Dep = 'AUD0.00'
  $PreAllocated = 'FALSE'
  $Quantity = 1
  $resale = 'AUD0.00'
  $SalVal = 'AUD0.00'
  $SupGroup = 'ICT - Service Desk'

#Snow Feilds with Null Value
  
#Device Object builder 
  $Outob = New-Object -TypeName psobject

#Assigning Variables to Object
  
  #Device Model Catagory
  $Outob | Add-Member -MemberType NoteProperty -Name 'Model Catagory' -Value $ModelCat
  #Device serial number 
  $Outob | Add-Member -MemberType NoteProperty -Name 'Serial number' -Value $DevSerial
  #Device Asset Tag
  $Outob | Add-Member -MemberType NoteProperty -Name 'Asset tag' -Value $DevName
  #Device Model Display Name
  $Outob | Add-Member -MemberType NoteProperty -Name 'Model Display name' -Value $DevModel
  #Assigned to
  $Outob | Add-Member -MemberType NoteProperty -Name 'Assigned to' -Value $AssignedTo
  #Company
  $Outob | Add-Member -MemberType NoteProperty -Name 'Company' -Value $comp
  #state
  $Outob | Add-Member -MemberType NoteProperty -Name 'State' -Value $state
  #Owned by
  $Outob | Add-Member -MemberType NoteProperty -Name 'Owned By' -Value $OwnBy
  #Manged by
  $Outob | Add-Member -MemberType NoteProperty -Name 'Managed by' -Value $ManBy
  #Expenditure type
  $Outob | Add-Member -MemberType NoteProperty -Name 'Expenditure type' -Value $expen
  #Support group
  $Outob | Add-Member -MemberType NoteProperty -Name 'Support group' -Value $SupGroup
  #Comments
  $Outob | Add-Member -MemberType NoteProperty -Name 'Comments' -Value $DevComments
  #Depreciated amount
  $Outob | Add-Member -MemberType NoteProperty -Name 'Depreciated amount' -Value $Dep
  #Pre-allocated
  $Outob | Add-Member -MemberType NoteProperty -Name 'Pre-allocated' -Value $PreAllocated
  #Quantity
  $Outob | Add-Member -MemberType NoteProperty -Name 'Quantity' -Value $Quantity
  #Resale Price
  $Outob | Add-Member -MemberType NoteProperty -Name 'Resale price' -Value $resale
  #Salvage Value
  $Outob | Add-Member -MemberType NoteProperty -Name 'Salvage value' -Value $SalVal

<#output test adds all devce objects to the import file.
$Outob | Select-Object * | Out-File -FilePath $SnowConversionOutpath -Append
#>

#filter corperate only devices and devices named Deskop that have not enrolled properly
if ($Outob.'Owned By' -eq 'Ross Lenox' -And $Outob.'Asset tag' -NotLike 'DESKTOP-*')
  {
    $Outob | Select-Object * | Export-Csv -Path $SnowConversionOutpath -Append -NoTypeInformation
  }

};
