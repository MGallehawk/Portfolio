$FileLocation = $PSScriptRoot;
$gjlt1636 =  $FileLocation+'\gjlt-1636'
$gjws1546 =  $FileLocation+'\gjws-1546'
$outgjlt1636 =  $FileLocation+'\gjlt-1636-out.csv'
$outgjws1546 =  $FileLocation+'\gjws-1546-out.csv'

$gjlt1636in = Get-ChildItem -Path $gjlt1636;
$gjws1546in = Get-ChildItem -Path $gjws1546;

$gjlt1636in | foreach-object {
    $_ | ForEach-Object{
        $a = Import-Csv -Path $_.FullName 
       
        $a | Export-Csv -Path $outgjlt1636 -Append -NoTypeInformation
    }

}

$gjws1546in | foreach-object {
    $_ | ForEach-Object{
        $a = Import-Csv -Path $_.FullName 
       
        $a | Export-Csv -Path $outgjws1546 -Append -NoTypeInformation
    }

}


