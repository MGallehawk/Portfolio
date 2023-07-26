$FileLocation = $PSScriptRoot
#feilds indicate the defult location of the Intun, Sophos,output folders
$JabraInportLocation =  $FileLocation+'\jabra'
$HPInportLocation = $FileLocation+'\HPImport'
$OutputLocation =  $FileLocation+'\Output'

$JabraCsvFiles = Get-ChildItem -Path $JabraInportLocation -Filter *.csv 
$HpCsvFiles = Get-ChildItem -Path $HPInportLocation -Filter *.csv 
$outCsvFiles = $OutputLocation+ '\Device_test_Upload.csv'
$ModelCsvFiles = $OutputLocation+ '\Snow_Model_test_Update.csv'

Add-Type -AssemblyName PresentationCore,PresentationFramework
$date = Get-Date -Format "dd/MM/yyyy"
#Builds object array for devices 
$AssetObjects =@() 
#Builds object array for devices 
$ModelObjects =@() 
#Creates an object out of each device in the intune export
try {
    $JabraInport = Import-Csv -Path $JabraCsvFiles.FullName
  }
  catch {
    #error message for intune no csv
    $JabraImportError = [System.Windows.MessageBox]::Show('No Jabra Import file detected, please input the required csv file','Jabra Import error','OK','Error') 
    switch  ($msgBoxInput) { 'OK' {Exit}}
    $JabraImportError
    #Disconnect-AzureAD
    Exit;
  
  }  
     
  
  #Creates an object out of each device in the export
  try {
  $HPInport = Import-Csv -Path $HPCsvFiles.FullName  
  }
  catch {
    #error message for intune no csv
    $HpImportError = [System.Windows.MessageBox]::Show('No HP Import file detected, please input the required csv file','HP Import error','OK','Error') 
    switch  ($msgBoxInput) { 'OK' { Exit;}}
    $HPImportError
    #Disconnect-AzureAD
    Exit
  }

$JabraInport | foreach-object {
#jabra variables 
#Jabra field for asset model
$DevModel = $_.'Device'
#Jabra feild for serial number
$DevSerial = $_.'ESN'
$fullName = Get-ADUser -Identity $_.'User' -Properties DisplayName | select-object DisplayName -ErrorAction Stop;
#jabra Feild for Device name
$DevName = $DevSerial
#Jabra ownership field corp or personal
$DevOwnership = $fullName.DisplayName
#dveice Manufatcurer 
$AssignedTo = $fullName.DisplayName
$DevManMU = 'Jabra'

#defult settings asset
$state = 'In use'
$Dep = 'AUD0.00'
$PreAllocated = 'FALSE'
$Quantity = 1
$resale = 'AUD0.00'
$SalVal = 'AUD0.00'
$SupGroup = 'ICT - Service Desk'
$stateMU = 'In Production'
$expenMU = 'Capex'
$Track = 'Leave to category'
$TrackUnit = 'Individual Unit'
$ClassMU = 'cmdb_hardware_product_model'
$ManBy = 'Ross Lennox'
$OwnBy = 'Ross Lennox'
$Comp = 'G James Glass & Aluminium (Qld) Pty Ltd'
$ModelCatMU = 'Headset'
#Magic Variables 
#string builder for Snow comments to track phone number carrier and IMEI
$DevComments = ('Imported from intune' )
$DevOwnership = 'Ross Lennox'

#Device Object builder model
$ModelObject = New-Object -TypeName psobject
#Device Object builder asset
$AssetObject = New-Object -TypeName psobject

#Assigning Variables to Object   
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Model categories' -Value $ModelCatMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Class' -Value $ClassMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Manufacturer' -Value $DevManMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Model number' -Value $DevModel
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $DevModel
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Owner' -Value $DevOwnership
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Status' -Value $stateMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Expenditure type' -Value $expenMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking strategy' -Value $Track
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking unit' -Value $TrackUnit

#Assigning Variables to Object asset
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Serial number' -Value $DevSerial
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Asset tag' -Value $DevName
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model name' -Value $DevModel
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model Display name' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Assigned to' -Value $AssignedTo
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Company' -Value $comp
$AssetObject | Add-Member -MemberType NoteProperty -Name 'State' -Value $state
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Owned By' -Value $OwnBy
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Managed by' -Value $ManBy
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Support group' -Value $SupGroup
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Comments' -Value $DevComments
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Depreciated amount' -Value $Dep
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Pre-allocated' -Value $PreAllocated
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Quantity' -Value $Quantity
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Resale price' -Value $resale
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Salvage value' -Value $SalVal
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Last logged in' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Date last logged on' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model category' -Value $ModelCatMU

#sets asset Model catagory
$AssetObject.'Model category' = $ModelObject.'Model categories'  

#creates displayname
$AssetObject.'Model Display name' =  $ModelObject.'Manufacturer' + ' ' + $AssetObject.'Model name' 
$ModelObjects += $ModelObject
$AssetObjects += $AssetObject
}

$HPInport | foreach-object {

$fullName = Get-ADUser -Identity $_.'UserName' -Properties DisplayName | select-object DisplayName -ErrorAction Stop;
#jabra Feild for Device name
$DevName = $DevSerial
#Jabra ownership field corp or personal
$DevOwnership = $fullName.DisplayName
#dveice Manufatcurer 
$AssignedTo = $fullName.DisplayName

#jabra variables 
#Jabra field for asset model
$DevModel = $_.'ModelNumber'
$DevSerial = $_.'SerialNumber'

#jabra Feild for Device name
$DevName = $DevSerial
#Jabra feild for serial number

#dveice Manufatcurer 
$DevManMU = $_.'Manufacturer'

#defult settings asset
$state = 'In use'
$Dep = 'AUD0.00'
$PreAllocated = 'FALSE'
$Quantity = 1
$resale = 'AUD0.00'
$SalVal = 'AUD0.00'
$SupGroup = 'ICT - Service Desk'
$stateMU = 'In Production'
$expenMU = 'Capex'
$Track = 'Leave to category'
$TrackUnit = 'Individual Unit'
$ClassMU = 'cmdb_hardware_product_model'
$ManBy = 'Ross Lennox'
$OwnBy = 'Ross Lennox'
$Comp = 'G James Glass & Aluminium (Qld) Pty Ltd'
$ModelCatMU = 'Monitor'
#Magic Variables 
#string builder for Snow comments to track phone number carrier and IMEI
$DevComments = ('Imported from HP' )
$DevOwnership = 'Ross Lennox'

if($DevManMU -eq 'SAM'){$DevManMU = 'Samsung'}
if($DevManMU -eq 'HPN'){$DevManMU = 'Hewlett-Packard'}

#Device Object builder model
$ModelObject = New-Object -TypeName psobject
#Device Object builder asset
$AssetObject = New-Object -TypeName psobject

#Assigning Variables to Object
    
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Model categories' -Value $ModelCatMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Class' -Value $ClassMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Manufacturer' -Value $DevManMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Model number' -Value $DevModel
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $DevModel
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Owner' -Value $DevOwnership
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Status' -Value $stateMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Expenditure type' -Value $expenMU
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking strategy' -Value $Track
$ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking unit' -Value $TrackUnit

#Assigning Variables to Object asset
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Serial number' -Value $DevSerial
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Asset tag' -Value $DevName
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model name' -Value $DevModel
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model Display name' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Assigned to' -Value $AssignedTo
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Company' -Value $comp
$AssetObject | Add-Member -MemberType NoteProperty -Name 'State' -Value $state
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Owned By' -Value $OwnBy
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Managed by' -Value $ManBy
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Support group' -Value $SupGroup
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Comments' -Value $DevComments
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Depreciated amount' -Value $Dep
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Pre-allocated' -Value $PreAllocated
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Quantity' -Value $Quantity
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Resale price' -Value $resale
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Salvage value' -Value $SalVal
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Last logged in' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Date last logged on' -Value ''
$AssetObject | Add-Member -MemberType NoteProperty -Name 'Model category' -Value $ModelCatMU

#sets asset Model catagory
$AssetObject.'Model category' = $ModelObject.'Model categories'  

#creates displayname
$AssetObject.'Model Display name' =  $ModelObject.'Manufacturer' + ' ' + $AssetObject.'Model name' 

if ($DevManMU -eq 'Samsung' -or $DevManMU -eq 'Hewlett-Packard' ) {
$ModelObjects += $ModelObject
$AssetObjects += $AssetObject
}
}
#Export for asset models
$ModelObjects | Sort-Object -Property Name -Unique | Select-Object * | Export-Csv -Path $ModelCsvFiles -Append -NoTypeInformation

#Final loop that outputs the Asset obects to csv file 
foreach($AssetObject in $AssetObjects) {$AssetObject |  Select-Object * | Export-Csv -Path $outCsvFiles -Append -NoTypeInformation}
