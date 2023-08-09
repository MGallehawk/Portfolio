<#
script written by Mathew Gallehawk
Ticket FETR0011805
Purpose of this script is to take in Intune and convert Models into a script to upload Models into snow
#>
Connect-AzureAD

#portability block designed so that the scrip and three folders could be zipped up and dumped anywhere and just work
#Feild indicates the file that the script runs from
$FileLocation = $PSScriptRoot
#feilds indicate the defult location of the Intun, Sophos,output folders
$IntuneInportLocation =  $FileLocation+'\Intune'
$SophosInportLocation = $FileLocation+'\Sophos'
$OutputLocation =  $FileLocation+'\Output'

# Get a list of CSV files in the Intune directory 
#files can have garbage random name so this block gets around that so long as there is only one csv in the folders
$intuneCsvFiles = Get-ChildItem -Path $IntuneInportLocation -Filter *.csv 
$sophosCsvFiles = Get-ChildItem -Path $SophosInportLocation -Filter *.csv 
$outCsvFiles = $OutputLocation+ '\Device_Bulk_Upload.csv'
$ModelCsvFiles = $OutputLocation+ '\Snow_Model_Update.csv'

#cleans up the previous output
Remove-Item $outCsvFiles -Erroraction 'silentlycontinue'
#cleans up the previous output
Remove-Item $ModelCsvFiles -Erroraction 'silentlycontinue'

#todays date used later but thought this was good enough place for it 
$date = Get-Date -Format "dd/MM/yyyy"

#Builds object array for devices 
$AssetObjects =@() 
#Builds object array for devices 
$ModelObjects =@() 

#Pals Owner
$PalsMan = 'Tony Nguyen'
#Dem Optec Owner
$DemOP = 'Gary Parkes'
#Dem Lisec Owner
$DemLi = 'Julie Farrugia'
#Dem Test Owner
$DemTe = 'Garry Poon'

#Creates an object out of each device in the intune export
$IntuneInport = Import-Csv -Path $intuneCsvFiles.FullName
$IntuneInport | foreach-object {

#intune variables 
#Intune field for asset model
$DevModel = $_.'Model'
#Intune Feild for Device name
$DevName = $_.'Device name'
#Intune feild for serial number
$DevSerial = $_.'Serial number'
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

#Magic Variables 
#string builder for Snow comments to track phone number carrier and IMEI
$DevComments = ('Imported from intune' + "`n" + 'IMEI: ' + $DevIMEI +  "`n"+ 'Phone Number: ' + $DevPhNumber + "`n" + 'Carrier: ' + $Subscriber)
#Logic for transforming the Intune Ownership feild into Snow feilds Managed by, Owned by, and Company
    If ($DevOwnership -eq 'Corporate') 
      {
        $ManBy = 'Ross Lennox'
        $OwnBy = 'Ross Lennox'
        $Comp = 'G James Glass & Aluminium (Qld) Pty Ltd'
      } 
    Else 
      {
        $ManBy = 'personal'
        $Ownby = 'personal'
        $Comp = 'personal'
      }

  If ($DevOS -eq 'Windows' -Or $DevOS -eq 'MacOS') { $ModelCatMU = 'Computer'} 
  else {$ModelCatMU = 'Mobile Handset'}
  If ($DevOwnership -eq 'Corporate') {$DevOwnership = 'Ross Lennox'} 
  else {$DevOwnership = 'personal'}

 
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
 
  #transform Branding
  if($ModelObject.'Manufacturer' -Like '*HP*') {$ModelObject.'Manufacturer' = 'Hewlett-Packard'}

  #Block to transform Intune Model to snow friendly feilds for computers
  
  #Laptops-standard (Model )
  if($ModelObject.'Name' -eq '20F5A18KAU'){$ModelObject.'Name'= 'X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20F90012AU'){$ModelObject.'Name'= 'X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20F6008EAU'){$ModelObject.'Name'= 'X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20FN001CAU'){$ModelObject.'Name'= 'T460'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20HMS04600'){$ModelObject.'Name'= 'X260 c'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20J5S24500'){$ModelObject.'Name'= 'ThinkPad L470'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20LSS0DD00'){$ModelObject.'Name'= 'ThinkPad L480'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20Q5S0CN00'){$ModelObject.'Name'= 'ThinkPad L490'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -Like 'HP EliteBook *' -Or $ModelObject.'Name' -Like 'HP * Notebook *' ){$ModelObject.'Model categories' = 'Laptop - Standard'}    
 
   #Laptops-standard (Asset)
  if($AssetObject.'Model name' -eq '20F5A18KAU'){$AssetObject.'Model name'= 'X260';  }
  if($AssetObject.'Model name' -eq '20F90012AU'){$AssetObject.'Model name'= 'X260';  }
  if($AssetObject.'Model name' -eq '20F6008EAU'){$AssetObject.'Model name'= 'X260'; }
  if($AssetObject.'Model name' -eq '20FN001CAU'){$AssetObject.'Model name'= 'T460'; }
  if($AssetObject.'Model name' -eq '20HMS04600'){$AssetObject.'Model name'= 'X260 c'; }
  if($AssetObject.'Model name' -eq '20J5S24500'){$AssetObject.'Model name'= 'ThinkPad L470'; }
  if($AssetObject.'Model name' -eq '20LSS0DD00'){$AssetObject.'Model name'= 'ThinkPad L480';  }
  if($AssetObject.'Model name' -eq '20Q5S0CN00'){$AssetObject.'Model name'= 'ThinkPad L490'; }    

  #Laptops-Advanced (Model)
  if($ModelObject.'Name' -eq '20HCS0K100'){$ModelObject.'Name'= 'ThinkPad P51s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20HJS2AV00'){$ModelObject.'Name'= 'ThinkPad P52s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20LBS03V00'){$ModelObject.'Name'= 'ThinkPad P52s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20N6S04A00'){$ModelObject.'Name'= 'ThinkPad P53s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -Like 'HP ZBook *'){$ModelObject.'Model categories' = 'Laptop - Advanced'}

  #Laptops-Advanced (Asset)
  if($AssetObject.'Model name' -eq '20HCS0K100'){$AssetObject.'Model name'= 'ThinkPad P51s'; }
  if($AssetObject.'Model name' -eq '20HJS2AV00'){$AssetObject.'Model name'= 'ThinkPad P52s'; }
  if($AssetObject.'Model name' -eq '20LBS03V00'){$AssetObject.'Model name'= 'ThinkPad P52s'; }
  if($AssetObject.'Model name' -eq '20N6S04A00'){$AssetObject.'Model name'= 'ThinkPad P53s'; }
  
  #workstations-Standard (Model)
  #lenovo
  if($ModelObject.'Name' -eq '10M7S0L900'){$ModelObject.'Name'= 'ThinkCentre M710S'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -eq '10RSS0LE00'){$ModelObject.'Name'= 'ThinkCentre M920q'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -eq '10ST000CAU'){$ModelObject.'Name'= 'ThinkCentre M720'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -Like 'HP * Desktop*' -Or $ModelObject.'Name' -Like 'HP * Small Form Factor*' -Or $ModelObject.'Name' -Like 'HP*Mini*'-Or $ModelObject.'Name' -Like 'HP*SFF*'  ){$ModelObject.'Model categories' = 'Workstation - Standard'}

  #workstations-Standard (Asset)
  #lenovo
  if($AssetObject.'Model name' -eq '10M7S0L900'){$AssetObject.'Model name'= 'ThinkCentre M710S';}
  if($AssetObject.'Model name' -eq '10RSS0LE00'){$AssetObject.'Model name'= 'ThinkCentre M920q';}
  if($AssetObject.'Model name' -eq '10ST000CAU'){$AssetObject.'Model name'= 'ThinkCentre M720'; }

  #Workstations-Advanced (Model)
  #Lenovo
  if($ModelObject.'Name' -eq '30BGS19800'){$ModelObject.'Name'= 'ThinkStation P320'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name'-eq  '30BGS4EE00'){$ModelObject.'Name'= 'ThinkStation P320 (a)'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name' -eq '30CYS0U500'){$ModelObject.'Name'= 'ThinkStation P330 i7 P4000'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name' -eq '30BGS2WJ00'){$ModelObject.'Name'= 'ThinkStation P330 i7'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  #HP
  if($ModelObject.'Name' -Like 'HP Z4*' -and $ModelObject.'Model categories' -NE 'Workstation - Standard' ){$ModelObject.'Model categories' = 'Workstation - Advanced'} 

  #Workstations-Advanced (Asset)
  #Lenovo
  if($AssetObject.'Model name' -eq '30BGS19800'){$AssetObject.'Model name'= 'ThinkStation P320'; }
  if($AssetObject.'Model name'-eq  '30BGS4EE00'){$AssetObject.'Model name'= 'ThinkStation P320 (a)';  }
  if($AssetObject.'Model name' -eq '30CYS0U500'){$AssetObject.'Model name'= 'ThinkStation P330 i7 P4000';  }
  if($AssetObject.'Model name' -eq '30BGS2WJ00'){$AssetObject.'Model name'= 'ThinkStation P330 i7';  }

  #other
  #Tablets (Model)
  if($ModelObject.'Name' -eq 'Surface Book'){$ModelObject.'Name' = 'Microsoft Corporation SURFACE BOOK i7 GPU2'; $ModelObject.'Model categories' = 'Tablet' }     
  if($ModelObject.'Name' -eq 'Surface Pro'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro'; $ModelObject.'Model categories' = 'Tablet' }    
  if($ModelObject.'Name' -eq 'Surface Book 3'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro 3'; $ModelObject.'Model categories' = 'Tablet' } 
  if($ModelObject.'Name' -like '*iPad*'){$ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'Surface Book 3'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro 3'; $ModelObject.'Model categories' = 'Tablet' } 
  if($ModelObject.'Name' -eq 'SM-T636B'){$ModelObject.'Name' = 'Samsung Galaxy Tab Active4 Pro'; $ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'SM-x200'){$ModelObject.'Name' = 'Samsung Galaxy Tab A8 10.5 (2021)'; $ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'F110G5'){$ModelObject.'Model categories' = 'Tablet' }

  #Tablets
  if($AssetObject.'Model name' -eq 'Surface Book'){$AssetObject.'Model name' = 'Microsoft Corporation SURFACE BOOK i7 GPU2';}     
  if($AssetObject.'Model name' -eq 'Surface Pro'){$AssetObject.'Model name' = 'Microsoft Corporation Surface Pro'; }    
  if($AssetObject.'Model name' -eq 'Surface Book 3'){$AssetObject.'Model name' = 'Microsoft Corporation Surface Pro 3';} 
  if($AssetObject.'Model name' -eq 'Surface Book 3'){$AssetObject.'Model name' = 'Microsoft Corporation Surface Pro 3';} 
  if($AssetObject.'Model name' -eq 'SM-T636B'){$AssetObject.'Model name' = 'Samsung Galaxy Tab Active4 Pro';}
  if($AssetObject.'Model name' -eq 'SM-x200'){$AssetObject.'Model name' = 'Samsung Galaxy Tab A8 10.5 (2021)';}
 
  #sets asset Model catagory
  $AssetObject.'Model category' = $ModelObject.'Model categories'    
  
  #creates displayname
  $AssetObject.'Model Display name' =  $ModelObject.'Manufacturer' + ' ' + $AssetObject.'Model name' 

  #VM's      
  if($ModelObject.'Name' -eq 'Unknown' -or $ModelObject.'Name' -eq 'VMware Virtual Platform' -or $ModelObject.'Name' -eq 'VMware7,1'-or $ModelObject.'Name' -eq 'INVALID
  '-or $ModelObject.'Name' -eq 'SystemSerialNumber' -or $ModelObject.'Name' -eq 'System Product Name'){$ModelObject.'Name'= 'VM'; $AssetObject.'Model name'= 'VM' }   
  

  #Pals ownership
  if($AssetObject.'Assigned to' -like 'pals*'){$AssetObject.'Assigned to' = $PalsMan; $AssetObject.Comments = $DevComments + "`n"+'Pals User'}
  if($AssetObject.'Last logged in' -like 'pals*'){$AssetObject.'Last logged in' = $PalsMan}

  #Dem lisec ownership
  if($AssetObject.'Assigned to' -eq 'dem lisec'){$AssetObject.'Assigned to' = $DemLi; $AssetObject.Comments = $DevComments + "`n"+ 'dem lisec user'}
  if($AssetObject.'Last logged in' -eq 'dem lisec'){$AssetObject.'Last logged in' = $DemLi}

  #Dem optec ownership
  if($AssetObject.'Assigned to' -eq 'dem op'){$AssetObject.'Assigned to' = $DemLi; $AssetObject.Comments = $DevComments + "`n"+ 'dem Op user'}
  if($AssetObject.'Last logged in' -eq 'dem op'){$AssetObject.'Last logged in' = $DemOP}

  #Dem optec ownership
  if($AssetObject.'Assigned to' -eq 'dem test'){$AssetObject.'Assigned to' = $DemTe; $AssetObject.Comments = $DevComments + "`n"+ 'dem test user'}
  if($AssetObject.'Last logged in' -eq 'dem test'){$AssetObject.'Last logged in' = $DemTe}

  if ($ModelObject.'Owner' -eq 'Ross Lennox' -And $ModelObject.'Name' -notlike 'VM' -And $ModelObject.'Name' -notlike 'INVALID')
    {
      $ModelObjects += $ModelObject
    } 

  #filter corperate only devices and devices named Deskop that have not enrolled properly
  if ($AssetObject.'Company' -Ne 'personal' -And $AssetObject.'Asset tag' -NotLike 'DESKTOP-*' -And $AssetObject.'Model name' -NotLike 'VM'-And $AssetObject.'Model name' -NotLike 'INVALID')
    {
      $AssetObjects += $AssetObject
    } 
}

#Creates an object out of each device in the export
$SophosInport = Import-Csv -Path $sophosCsvFiles.FullName
$SophosInport | foreach-object {

#device details
$DevName = $_.'Name'

#logic filter usernames to be snow freindly
try { $DevLastLog = Get-ADUser -Identity $_.'Last user' -Properties DisplayName | select-object DisplayName -ErrorAction Stop } 
catch { $DevLastLog = '' }
if ($DevLastLog -Like '*Operator*') {$DevLastLog = ''} 

#variable for the latst time logged in
$DevLastAct =([DateTime] $_.'Last active').ToString('dd/MM/yyyy') 

#filter corperate only devices and devices named Deskop that have not enrolled properly
if ($DevName -match '\w{4}[-]\d{4}' -And $DevLastAct -eq $date)
  {
    foreach($AssetObject in $AssetObjects) 
      {
          if($AssetObject.'Asset tag' -eq $DevName)
            {
              #Last log in user
              $AssetObject.'Last logged in' = $DevLastLog.DisplayName
              #Last log in date
              $AssetObject.'Date last logged on' = $DevLastAct
                          
            }
      }
  }

}

#Export for asset models
$ModelObjects | Sort-Object -Property Name -Unique | Select-Object * | Export-Csv -Path $ModelCsvFiles -Append -NoTypeInformation

#Final loop that outputs the Asset obects to csv file 
foreach($AssetObject in $AssetObjects) {$AssetObject |  Select-Object * | Export-Csv -Path $outCsvFiles -Append -NoTypeInformation}

#Azure AD disconection
Disconnect-AzureAD
;
