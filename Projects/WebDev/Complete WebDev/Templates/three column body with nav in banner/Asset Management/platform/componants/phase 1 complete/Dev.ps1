<#
script written by Mathew Gallehawk
Ticket FETR0011805
Purpose of this script is to take in two exports and porduce one export file that is compatible with serviceNow hardware asset management.
#>

#azure Ad connection
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

#cleans up the previous output
Remove-Item $outCsvFiles -Erroraction 'silentlycontinue'

#todays date used later but thought this was good enough place for it 
$date = Get-Date -Format "dd/MM/yyyy"

#Builds object array for devices 
$DeviceObjects =@() 

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

    #Logic for deciding if device is a phone or pc
      If ($DevOS -eq 'Windows' -Or $Dev -eq 'MacOS') { $ModelCat = 'Computer'} 
      else {$ModelCat = 'Mobile Handset'}


  
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
    $DeviceObject = New-Object -TypeName psobject

  #Assigning Variables to Object
    
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Model category' -Value $ModelCat
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Serial number' -Value $DevSerial
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Asset tag' -Value $DevName
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Model Display name' -Value $DevModel
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Assigned to' -Value $AssignedTo
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Company' -Value $comp
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'State' -Value $state
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Owned By' -Value $OwnBy
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Managed by' -Value $ManBy
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Expenditure type' -Value $expen
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Support group' -Value $SupGroup
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Comments' -Value $DevComments
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Depreciated amount' -Value $Dep
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Pre-allocated' -Value $PreAllocated
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Quantity' -Value $Quantity
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Resale price' -Value $resale
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Salvage value' -Value $SalVal
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Last logged in' -Value ''
    $DeviceObject | Add-Member -MemberType NoteProperty -Name 'Date last logged on' -Value ''
    
#Block to transform Intune Model to snow friendly feilds for computers
  
#Laptops-standard

  #HP
  if($DeviceObject.'Model Display name' -eq 'HP Elite Dragonfly G2 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elite Dragonfly x360 G2'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  #add ci to snow
  if($DeviceObject.'Model Display name' -eq 'HP Elite x360 1040 14 inch G9 2-in-1 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook x360 1040 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook 650 15.6 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett Packard HP Elitebook 650 G9'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook 840 14 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook 840 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  #possibly add this ci in snow
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook 840 14 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook 840 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook 840 G8 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook 840 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}      
  #possibly add this ci
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook 860 16 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook 840 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}      
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook x360 1030 G7 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook x360 1030 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook x360 1040 G7 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook x360 1040 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'}  
  if($DeviceObject.'Model Display name' -eq 'HP EliteBook x360 1040 G8 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook x360 1040 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  #ci needed
  if($DeviceObject.'Model Display name' -eq 'HP Elite x360 830 13 inch G9 2-in-1 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP Elitebook x360 1040 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  #possibly add this ci
  if($DeviceObject.'Model Display name' -eq 'HP ProBook 450 15.6 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ProBook 650 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  if($DeviceObject.'Model Display name' -eq 'HP ProBook 650 G8 Notebook PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ProBook 650 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  #possibly ad ci
  if($DeviceObject.'Model Display name' -eq 'HP ProBook 450 15.6 inch G9 Notebook PC'){$DeviceObject.'Model Display name'= '	Hewlett-Packard HP ProBook 650 G8'; $DeviceObject.'Model category' = 'Laptop - Standard'} 
  #lenovo
  if($DeviceObject.'Model Display name' -eq '20F5A18KAU'){$DeviceObject.'Model Display name'= 'Lenovo X260'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20F90012AU'){$DeviceObject.'Model Display name'= 'Lenovo X260'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20F6008EAU'){$DeviceObject.'Model Display name'= 'Lenovo X260'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20FN001CAU'){$DeviceObject.'Model Display name'= 'Lenovo T460'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20HMS04600'){$DeviceObject.'Model Display name'= 'Lenovo X260 c'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20J5S24500'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad L470'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20LSS0DD00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad L480'; $DeviceObject.'Model category' = 'Laptop - Standard'}
  if($DeviceObject.'Model Display name' -eq '20Q5S0CN00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad L490'; $DeviceObject.'Model category' = 'Laptop - Standard'}

#Laptops-Advanced
  #HP
  if($DeviceObject.'Model Display name' -eq 'HP ZBook Firefly 16 inch G9 Mobile Workstation PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ZBook Fury 15 G8'; $DeviceObject.'Model category' = 'Laptop - Advanced'} 
  if($DeviceObject.'Model Display name' -eq 'HP ZBook Fury 15.6 inch G8 Mobile Workstation PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ZBook Fury 15 G8'; $DeviceObject.'Model category' = 'Laptop - Advanced'}  
  #possibly add this ci
  if($DeviceObject.'Model Display name' -eq 'HP ZBook Fury 16 G9 Mobile Workstation PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ZBook Fury 15 G8'; $DeviceObject.'Model category' = 'Laptop - Advanced'}  
  #Lenoovo
  if($DeviceObject.'Model Display name' -eq '20HCS0K100'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad P51s'; $DeviceObject.'Model category' = 'Laptop - Advanced'}
  if($DeviceObject.'Model Display name' -eq '20HJS2AV00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad P52s'; $DeviceObject.'Model category' = 'Laptop - Advanced'}
  if($DeviceObject.'Model Display name' -eq '20LBS03V00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad P52s'; $DeviceObject.'Model category' = 'Laptop - Advanced'}
  if($DeviceObject.'Model Display name' -eq '20N6S04A00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkPad P53s'; $DeviceObject.'Model category' = 'Laptop - Advanced'}

#workstations-Standard
  #HP
  if($DeviceObject.'Model Display name' -eq 'HP Elite Mini 800 G9 Desktop PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard 800 EliteDesk G2 SFF'; $DeviceObject.'Model category' = 'Workstation - Standard'}
  if($DeviceObject.'Model Display name' -eq 'HP Elite SFF 800 G9 Desktop PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard 800 EliteDesk G2 SFF'; $DeviceObject.'Model category' = 'Workstation - Standard'}
  if($DeviceObject.'Model Display name' -eq 'HP EliteDesk 800 G8 Desktop Mini PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard 800 EliteDesk G2 SFF'; $DeviceObject.'Model category' = 'Workstation - Standard'} 
  if($DeviceObject.'Model Display name' -eq 'HP ProDesk 600 G6 Desktop Mini PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard ProDesk 600 G6 Desktop Mini PC'; $DeviceObject.'Model category' = 'Workstation - Standard'} 
  if($DeviceObject.'Model Display name' -eq 'HP ProDesk 600 G6 Small Form Factor PC'){$DeviceObject.'Model Display name'= 'Hewlett-Packard HP ProDesk 600 G2 SFF'; $DeviceObject.'Model category' = 'Workstation - Standard'} 
  #lenovo
  if($DeviceObject.'Model Display name' -eq '10M7S0L900'){$DeviceObject.'Model Display name'= 'Lenovo ThinkCentre M710S'; $DeviceObject.'Model category' = 'Workstation - Standard'}
  if($DeviceObject.'Model Display name' -eq '10RSS0LE00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkCentre M920q'; $DeviceObject.'Model category' = 'Workstation - Standard'}
  if($DeviceObject.'Model Display name' -eq '10ST000CAU'){$DeviceObject.'Model Display name'= 'Lenovo ThinkCentre M720'; $DeviceObject.'Model category' = 'Workstation - Standard'}

#Workstations-Advanced
  #HP
  if($DeviceObject.'Model Display name' -eq 'HP Z240 SFF Workstation'){$DeviceObject.'Model Display name'= 'Hewlett-Packard Z240 SFF Workstation'; $DeviceObject.'Model category' = 'Workstation - Advanced'} 
  if($DeviceObject.'Model Display name' -eq 'HP Z440 Workstation'){$DeviceObject.'Model Display name'= 'Hewlett-Packard Z440 E5 8GB'; $DeviceObject.'Model category' = 'Workstation - Advanced'}  
  #Lenovo
  if($DeviceObject.'Model Display name' -eq '30BGS19800'){$DeviceObject.'Model Display name'= 'Lenovo ThinkStation P320'; $DeviceObject.'Model category' = 'Workstation - Advanced'}
  if($DeviceObject.'Model Display name'-eq '30BGS4EE00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkStation P320 (a)'; $DeviceObject.'Model category' = 'Workstation - Advanced'}
  if($DeviceObject.'Model Display name' -eq '30CYS0U500'){$DeviceObject.'Model Display name'= 'Lenovo ThinkStation P330 i7 P4000'; $DeviceObject.'Model category' = 'Workstation - Advanced'}
  if($DeviceObject.'Model Display name' -eq '30BGS2WJ00'){$DeviceObject.'Model Display name'= 'Lenovo ThinkStation P330 i7'; $DeviceObject.'Model category' = 'Workstation - Advanced'}

#other
  #Tablets
  if($DeviceObject.'Model Display name' -eq 'Surface Book'){$DeviceObject.'Model Display name'= 'Microsoft Corporation SURFACE BOOK i7 GPU2'; $DeviceObject.'Model category' = 'Tablet' }     
  if($DeviceObject.'Model Display name' -eq 'Surface Pro'){$DeviceObject.'Model Display name'= 'Microsoft Corporation Surface Pro'; $DeviceObject.'Model category' = 'Tablet' }    
  if($DeviceObject.'Model Display name' -eq 'Surface Book 3'){$DeviceObject.'Model Display name'= 'Microsoft Corporation Surface Pro 3'; $DeviceObject.'Model category' = 'Tablet' } 
  if($DeviceObject.'Model Display name' -eq 'F110G5'){$DeviceObject.'Model Display name'= 'GETAC F110G3'; $DeviceObject.'Model category' = 'Tablet' }
  #ci's required
  if($DeviceObject.'Model Display name' -eq 'iPad (9th generation)'){$DeviceObject.'Model Display name'= 'Apple iPad (8th Generation)'; $DeviceObject.'Model category' = 'Tablet' } 
  if($DeviceObject.'Model Display name' -eq 'SM-T636B'){$DeviceObject.'Model Display name'= 'Apple iPad (8th Generation)' ; $DeviceObject.'Model category' = 'Tablet' } 
  if($DeviceObject.'Model Display name' -eq 'SM-X200'){$DeviceObject.'Model Display name'= 'Apple iPad (8th Generation)' ; $DeviceObject.'Model category' = 'Tablet' } 

  #VM's      
  if($DeviceObject.'Model Display name' -eq 'Unknown' -or $DeviceObject.'Model Display name' -eq 'VMware Virtual Platform' -or $DeviceObject.'Model Display name' -eq 'VMware7,1'-or $DeviceObject.'Model Display name' -eq 'INVALID
'-or $DeviceObject.'Model Display name' -eq 'SystemSerialNumber' -or $DeviceObject.'Model Display name' -eq 'System Product Name'){$DeviceObject.'Model Display name'= 'VM'}   

#Block to transform Intune Model to snow friendly feilds for Phones

#Android

#Iphone

if($DeviceObject.'Model Display name' -eq 'iPhone 5S'){$DeviceObject.'Model Display name'= 'Apple iPhone 5s'}
if($DeviceObject.'Model Display name' -eq 'iPhone 6s'){$DeviceObject.'Model Display name'= 'Apple iPhone 6s'}
if($DeviceObject.'Model Display name' -eq 'iPhone 6s Plus'){$DeviceObject.'Model Display name'= 'Apple iPhone 6s Plus'}
if($DeviceObject.'Model Display name' -eq 'iPhone 7'){$DeviceObject.'Model Display name'= 'Apple iPhone 7'}
if($DeviceObject.'Model Display name' -eq 'iPhone 8 Plus'){$DeviceObject.'Model Display name'= 'Apple iPhone 8 Plus'}
if($DeviceObject.'Model Display name' -eq 'iPhone SE'){$DeviceObject.'Model Display name'= 	'Apple iPhone SE'}
if($DeviceObject.'Model Display name' -eq 'iPhone SE (1st generation)'){$DeviceObject.'Model Display name'=	'Apple iPhone SE'}
if($DeviceObject.'Model Display name' -eq 'iPhone SE (2nd generation)'){$DeviceObject.'Model Display name'=	'Apple iPhone SE (2nd Generation)'}
if($DeviceObject.'Model Display name' -eq 'iPhone XR'){$DeviceObject.'Model Display name'=	'Apple iPhone XR'}
if($DeviceObject.'Model Display name' -eq 'iPhone 11'){$DeviceObject.'Model Display name'= 'Apple iPhone 11'} 
if($DeviceObject.'Model Display name' -eq 'iPhone 11 Pro'){$DeviceObject.'Model Display name'= 'Apple iPhone 11 Pro'} 
if($DeviceObject.'Model Display name' -eq 'iPhone 12'){$DeviceObject.'Model Display name'= 'Apple iPhone 12'}
if($DeviceObject.'Model Display name' -eq 'iPhone 12 Pro'){$DeviceObject.'Model Display name'= 'Apple iPhone 12 Pro'}  
if($DeviceObject.'Model Display name' -eq 'iPhone 13'){$DeviceObject.'Model Display name'= 'Apple iPhone 13'}
if($DeviceObject.'Model Display name' -eq 'iPhone 13 Pro'){$DeviceObject.'Model Display name'= 'Apple iPhone 13 Pro'}  

#need cis for these
if($DeviceObject.'Model Display name' -eq 'iPhone 14'){$DeviceObject.'Model Display name'= 'Apple iPhone 13'}
if($DeviceObject.'Model Display name' -eq 'iPhone 143 Pro Max'){$DeviceObject.'Model Display name'= 'Apple iPhone 13 Pro'}  
if($DeviceObject.'Model Display name' -eq 'iPhone SE (3rd generation)'){$DeviceObject.'Model Display name'=	'Apple iPhone SE (2nd Generation)'}

#Pals ownership
if($DeviceObject.'Assigned to' -like 'pals*'){$DeviceObject.'Assigned to' = $PalsMan; $DeviceObject.Comments = $DevComments + "`n"+'Pals User'}
if($DeviceObject.'Last logged in' -like 'pals*'){$DeviceObject.'Last logged in' = $PalsMan}

#Dem lisec ownership
if($DeviceObject.'Assigned to' -eq 'dem lisec'){$DeviceObject.'Assigned to' = $DemLi; $DeviceObject.Comments = $DevComments + "`n"+ 'dem lisec user'}
if($DeviceObject.'Last logged in' -eq 'dem lisec'){$DeviceObject.'Last logged in' = $DemLi}

#Dem optec ownership
if($DeviceObject.'Assigned to' -eq 'dem op'){$DeviceObject.'Assigned to' = $DemLi; $DeviceObject.Comments = $DevComments + "`n"+ 'dem Op user'}
if($DeviceObject.'Last logged in' -eq 'dem op'){$DeviceObject.'Last logged in' = $DemOP}

#Dem optec ownership
if($DeviceObject.'Assigned to' -eq 'dem test'){$DeviceObject.'Assigned to' = $DemTe; $DeviceObject.Comments = $DevComments + "`n"+ 'dem test user'}
if($DeviceObject.'Last logged in' -eq 'dem test'){$DeviceObject.'Last logged in' = $DemTe}

#filter corperate only devices and devices named Deskop that have not enrolled properly
  if ($DeviceObject.'Owned By' -eq 'Ross Lennox' -And $DeviceObject.'Asset tag' -NotLike 'DESKTOP-*' -And $DeviceObject.'Model Display name' -notlike 'VM')
    {
      $DeviceObjects += $DeviceObject
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
    foreach($DeviceObject in $DeviceObjects) 
      {
          if($DeviceObject.'Asset tag' -eq $DevName)
            {
              #Last log in user
              $DeviceObject.'Last logged in' = $DevLastLog.DisplayName
              #Last log in date
              $DeviceObject.'Date last logged on' = $DevLastAct
                          
            }
      }
  }

}

#Final loop that outputs the obects to csv file 
foreach($DeviceObject in $DeviceObjects) 
{
    $DeviceObject |  Select-Object * | Export-Csv -Path $outCsvFiles -Append -NoTypeInformation

}

#Azure AD disconection
Disconnect-AzureAD
;
