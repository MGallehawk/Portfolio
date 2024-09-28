<#
auther Mathew Gallehawk
Scirpt to audit the licences that can be removed from users
#>

#function to install graph if not present
function graphCheck {
    $exists = Get-Module -ListAvailable -Name Microsoft.Graph
    $loop = $true
    while ($loop) {
        if (!$exists) {
            write-host "Graph module not installed, installing now"
            Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
            Install-Module Microsoft.Graph.Beta -Repository PSGallery -Force
            $exists = Get-Module -ListAvailable -Name Microsoft.Graph
        }
        else {
            write-host "Graph module is installed"
            $loop = $false
        }
    }
}

#function to attain a list of users with licenses
function licensedArray {
    $arr = @()
    #get a list of users that are disables
    $users = Get-MgUser -All -Property id, userPrincipalName, accountEnabled | Where-Object { $_.accountEnabled -eq $false } | select-object id, userPrincipalName, accountEnabled
    #defined class for user   
    class user {
        [string]$id
        [string]$upn
        [string]$enabled
        [Boolean]$e5
        [Boolean]$Telsa
        [Boolean]$project
        [Boolean]$visio
    }
    #loop through users and get licenses
    $users | ForEach-Object {
        $licenses = Get-MgUserLicenseDetail -UserId $_.id | select-object SkuPartNumber
        #create user object
        $user = [user]@{
            id      = $_.id
            upn     = $_.userPrincipalName
            enabled = $_ | select-object -ExpandProperty accountEnabled 
            e5      = if ($licenses | where-object { $_.skuPartNumber -like "*E5*" } ) { $true } else { $false }
            Telsa   = if ($licenses | where-object { $_.skuPartNumber -like "*MCOPSTNEAU2*" } ) { $true } else { $false }
            project = if ($licenses | where-object { $_.skuPartNumber -like "*PROJECT*" } ) { $true } else { $false }
            visio   = if ($licenses | where-object { $_.skuPartNumber -like "*VISIO*" } ) { $true } else { $false }    
        }
        #add user to array
        if ($user.e5 -eq $true -or $user.Telsa -eq $true -or $user.project -eq $true -or $user.visio -eq $true) {
            $arr += $user
        }
    }
    return $arr
}
#function to output array to csv
function outputarray($arr, $fileName) {
    $arr | Export-Csv -Path "$psscriptroot\$filename.csv" -NoTypeInformation -Append
}

#function for main loop
function main {
    #checks installed modules
    graphCheck
    #connects to graph
    Connect-MgGraph -NoWelcome
    #gets list of users with licenses
    $userArray = licensedArray
    #outputs list of users with licenses
    $licensed_retired = Retired-with-licenses $userArray
    #outputs list of users with licenses
    outputarray $licensed_retired "LicenceAudit retired users with licences"
    #disconnects from graph
    Disconnect-MgGraph
    #outputs script complete
    write-host "Script complete"
    start-sleep -s 3
}
#function to get list of users with licenses
main

