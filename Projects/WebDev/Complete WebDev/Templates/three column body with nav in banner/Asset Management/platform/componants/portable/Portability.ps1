$FileLocation = $PSScriptRoot
$IntuneInportLocation =  $FileLocation+'\Intune'
$SophosInportLocation = $FileLocation+'\Sophos'
$OutputLocation =  $FileLocation+'\Output'


# Get a list of CSV files in the Intune directory
$intuneCsvFiles = Get-ChildItem -Path $IntuneInportLocation -Filter *.csv 
$sophosCsvFiles = Get-ChildItem -Path $SophosInportLocation -Filter *.csv -Name
$outCsvFiles = Get-ChildItem -Path $OutputLocation -Filter *.csv -Name

$intuneCsvFiles.FullName
#Creates an object out of each device in the export
$IntuneInport = Import-Csv -Path $intuneCsvFiles.FullName
$IntuneInport 