<#
Script to take in a intune export and out put a list of users who have multiple computers
#>

<#file path for intune export#>
try {
    $in = Get-ChildItem -Path ($PSScriptRoot +'\export') -Filter *.csv
    $out = $PSScriptRoot +'\export\out.csv'
    $intuneData = Import-Csv -Path $in.FullName
    echo "import found"
}
catch {
    echo 'no data file ' 
}
<#object arrays#>
$AssetObjects =@()
$UserObjects =@()

$intuneData | ForEach-Object {
    $UserObject = New-Object -TypeName psobject
    $AssetObject = New-Object -TypeName psobject
    $UserObject | Add-Member -MemberType NoteProperty -Name 'Email' -value ($_.'Primary user UPN')
    $AssetObject | Add-Member -MemberType NoteProperty -Name 'Asset Tag' -Value ($_.'Device name')
    $AssetObject | Add-Member -MemberType NoteProperty -Name 'Serial number' -Value ($_.'Serial number')
    $AssetObject | Add-Member -MemberType NoteProperty -Name 'model' -Value ($_.'Model')
    $AssetObject | Add-Member -MemberType NoteProperty -Name 'Assigned to' -Value ($_.'Primary user UPN')
    $AssetObjects += $AssetObject
    $UserObjects += $UserObject

}
<#Sanity checks#>
#$UserObjects | Sort-Object
#$AssetObjects | Sort-Object

$UserObjects | Sort-Object -Unique -Property 'Email' | ForEach-Object{
    $thisName = $_."Email"
    $devCount = $AssetObjects | Where-Object {$_.'Assigned to' -eq $thisName} | Measure-Object
    if ($devCount.Count -gt 1) {
        Add-Content $out $thisName
        Add-Content $out $devCount.Count
        $AssetObjects | Where-Object {$_.'Assigned to' -eq $thisName} | ForEach-Object{
        $DeviceName = $_.'Asset Tag'
        $DeviceSerial =$_.'Serial number'
        $DeviceModel =$_.'model'
        Add-Content $out $DeviceName 
        Add-Content $out $DeviceSerial
        Add-Content $out $DeviceModel
        }
    }
}
    <#Sanity check#>
    #$thisName
    #$devCount.Count
    
    