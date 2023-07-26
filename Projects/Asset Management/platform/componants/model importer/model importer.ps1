<#
script written by Mathew Gallehawk
Ticket FETR0011805
Purpose of this script is to take in Intune and convert Models into a script to upload Models into snow
#>

#portability block designed so that the scrip and three folders could be zipped up and dumped anywhere and just work
#Feild indicates the file that the script runs from
$FileLocation = $PSScriptRoot
#feilds indicate the defult location of the Intun, Sophos,output folders
$IntuneInportLocation =  $FileLocation+'\Intune'
$OutputLocation =  $FileLocation+'\Output'

# Get a list of CSV files in the Intune directory 
#files can have garbage random name so this block gets around that so long as there is only one csv in the folders
$intuneCsvFiles = Get-ChildItem -Path $IntuneInportLocation -Filter *.csv 
$ModelCsvFiles = $OutputLocation+ '\Snow_Model_Update.csv'

#cleans up the previous output
Remove-Item $ModelCsvFiles -Erroraction 'silentlycontinue'

#Builds object array for devices 
$ModelObjects =@() 

#Creates an object out of each device in the intune export
$IntuneInport = Import-Csv -Path $intuneCsvFiles.FullName
$IntuneInport | foreach-object {

  $DevOSMU = $_.'OS'
  $ClassMU = 'cmdb_hardware_product_model'
  $DevManMU = $_.'Manufacturer'
  $DevModelMU = $_.'Model'
  $ownerMU = $_.'Ownership'
  $stateMU = 'In Production'
  $expenMU = 'Capex'
  $Track = 'Leave to category'
  $TrackUnit = 'Individual Unit'
  $DevNameMU = $_.'Model'

  If ($DevOSMU -eq 'Windows' -Or $DevOSMU -eq 'MacOS') { 
    $ModelCatMU = 'Computer'} 
  else 
  {$ModelCatMU = 'Mobile Handset'}

  If ($ownerMU -eq 'Corporate') 
      {
        $ownerMU = 'Ross Lennox'
      } 
    Else 
      {
        $ownerMU = 'personal'
      }

    
  #Device Object builder 
    $ModelObject = New-Object -TypeName psobject

  #Assigning Variables to Object
    
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Model categories' -Value $ModelCatMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Class' -Value $ClassMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Manufacturer' -Value $DevManMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Model number' -Value $DevModelMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $DevNameMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Owner' -Value $ownerMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Status' -Value $stateMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Expenditure type' -Value $expenMU
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking strategy' -Value $Track
    $ModelObject | Add-Member -MemberType NoteProperty -Name 'Asset tracking unit' -Value $TrackUnit
    
    
#Block to transform Intune Model to snow friendly feilds for computers
  
#Laptops-standard

 
  if($ModelObject.'Name' -eq '20F5A18KAU'){$ModelObject.'Name'= 'Lenovo X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20F90012AU'){$ModelObject.'Name'= 'Lenovo X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20F6008EAU'){$ModelObject.'Name'= 'Lenovo X260'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20FN001CAU'){$ModelObject.'Name'= 'Lenovo T460'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20HMS04600'){$ModelObject.'Name'= 'Lenovo X260 c'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20J5S24500'){$ModelObject.'Name'= 'Lenovo ThinkPad L470'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20LSS0DD00'){$ModelObject.'Name'= 'Lenovo ThinkPad L480'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -eq '20Q5S0CN00'){$ModelObject.'Name'= 'Lenovo ThinkPad L490'; $ModelObject.'Model categories' = 'Laptop - Standard'}
  if($ModelObject.'Name' -Like 'HP EliteBook *' -Or $ModelObject.'Name' -Like 'HP * Notebook *' ){$ModelObject.'Model categories' = 'Laptop - Standard'}    
#Laptops-Advanced
  if($ModelObject.'Name' -eq '20HCS0K100'){$ModelObject.'Name'= 'Lenovo ThinkPad P51s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20HJS2AV00'){$ModelObject.'Name'= 'Lenovo ThinkPad P52s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20LBS03V00'){$ModelObject.'Name'= 'Lenovo ThinkPad P52s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -eq '20N6S04A00'){$ModelObject.'Name'= 'Lenovo ThinkPad P53s'; $ModelObject.'Model categories' = 'Laptop - Advanced'}
  if($ModelObject.'Name' -Like 'HP ZBook *'){$ModelObject.'Model categories' = 'Laptop - Advanced'}
  
#workstations-Standard
  #lenovo
  if($ModelObject.'Name' -eq '10M7S0L900'){$ModelObject.'Name'= 'Lenovo ThinkCentre M710S'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -eq '10RSS0LE00'){$ModelObject.'Name'= 'Lenovo ThinkCentre M920q'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -eq '10ST000CAU'){$ModelObject.'Name'= 'Lenovo ThinkCentre M720'; $ModelObject.'Model categories' = 'Workstation - Standard'}
  if($ModelObject.'Name' -Like 'HP * Desktop*' -Or $ModelObject.'Name' -Like 'HP * Small Form Factor*' -Or $ModelObject.'Name' -Like 'HP*Mini*'-Or $ModelObject.'Name' -Like 'HP*SFF*'  ){$ModelObject.'Model categories' = 'Workstation - Standard'}
#Workstations-Advanced
  #Lenovo
  if($ModelObject.'Name' -eq '30BGS19800'){$ModelObject.'Name'= 'Lenovo ThinkStation P320'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name'-eq  '30BGS4EE00'){$ModelObject.'Name'= 'Lenovo ThinkStation P320 (a)'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name' -eq '30CYS0U500'){$ModelObject.'Name'= 'Lenovo ThinkStation P330 i7 P4000'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  if($ModelObject.'Name' -eq '30BGS2WJ00'){$ModelObject.'Name'= 'Lenovo ThinkStation P330 i7'; $ModelObject.'Model categories' = 'Workstation - Advanced'}
  #HP
  if($ModelObject.'Name' -Like 'HP Z4*' -and $ModelObject.'Model categories' -NE 'Workstation - Standard' ){$ModelObject.'Model categories' = 'Workstation - Advanced'} 
#other
  #Tablets
  if($ModelObject.'Name' -eq 'Surface Book'){$ModelObject.'Name' = 'Microsoft Corporation SURFACE BOOK i7 GPU2'; $ModelObject.'Model categories' = 'Tablet' }     
  if($ModelObject.'Name' -eq 'Surface Pro'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro'; $ModelObject.'Model categories' = 'Tablet' }    
  if($ModelObject.'Name' -eq 'Surface Book 3'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro 3'; $ModelObject.'Model categories' = 'Tablet' } 
  if($ModelObject.'Name' -like '*iPad*'){$ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'Surface Book 3'){$ModelObject.'Name' = 'Microsoft Corporation Surface Pro 3'; $ModelObject.'Model categories' = 'Tablet' } 
  if($ModelObject.'Name' -eq 'SM-T636B'){$ModelObject.'Name' = 'Samsung Galaxy Tab Active4 Pro'; $ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'SM-x200'){$ModelObject.'Name' = 'Samsung Galaxy Tab A8 10.5 (2021)'; $ModelObject.'Model categories' = 'Tablet' }
  if($ModelObject.'Name' -eq 'F110G5'){$ModelObject.'Model categories' = 'Tablet' }


  #VM's      
  if($ModelObject.'Name' -eq 'Unknown' -or $ModelObject.'Name' -eq 'VMware Virtual Platform' -or $ModelObject.'Name' -eq 'VMware7,1'-or $ModelObject.'Name' -eq 'INVALID
'-or $ModelObject.'Name' -eq 'SystemSerialNumber' -or $ModelObject.'Name' -eq 'System Product Name'){$ModelObject.'Name'= 'VM'}   




  if ($ModelObject.'Owner' -eq 'Ross Lennox' -And $ModelObject.'Name' -notlike 'VM' -And $ModelObject.'Name' -notlike 'INVALID')
    {
      $ModelObjects += $ModelObject
    } 
}
$ModelObjects | Sort-Object -Property Name -Unique | Select-Object * | Export-Csv -Path $ModelCsvFiles -Append -NoTypeInformation
;
