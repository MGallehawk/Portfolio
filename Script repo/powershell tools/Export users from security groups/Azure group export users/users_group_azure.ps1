<#script written by mathew gallehawk to export a list of members of a azure group
Auther Mathew Gallehawk
#>

#function for into
function intro {
    Write-Host "This script will help you to find the details of a device."
    Write-Host "This script will install the appropriate modules if not already installed."
}

#function to check the moduels are installed
function module-check {
    Write-host "Checking Modules are installed or not"
    $module1exists = Get-Module -ListAvailable -Name Microsoft.Graph.Beta.Devicemanagement
    $module2exists = Get-Module -ListAvailable -Name Microsoft.Graph.Beta.Users
    return $module1exists, $module2exists 
}

#function to install the modules
function module-install($choice) {
    Write-Host "Installing the module"
    Write-Host "This will require the script being run as administrator"
    Write-Host "Please wait while the module is installed, and enter Y when prompted"
    switch ($choice) {
        '1' { Install-Module -Name Microsoft.Graph.Beta.Devicemanagement -Force -AllowClobber }
        '2' { Install-Module -Name Microsoft.Graph.Beta.Users -Force -AllowClobber }
        Default { "error" }
    }
}

#function to manage module
function moduleManage {
    $module1exists, $module2exists = module-check
    if ($module1exists -eq $null) {
        Write-Host "Microsoft.Graph.Beta.Devicemanagement is not installed. Do you want to install it? (Y/N)"
        $choice = Read-Host
        if ($choice -eq "Y") {
            module-install 1
        }
    }
    if ($module2exists -eq $null) {
        Write-Host "Microsoft.Graph.Beta.Users is not installed. Do you want to install it? (Y/N)"
        $choice = Read-Host
        if ($choice -eq "Y") {
            module-install 2
        }
    }
}

function get-group($name) {
    $group = Get-MgGroup -Filter "displayName eq '$name'"
    $groupID = $group.Id
    $groupMail = $group.Mail
    return $groupID , $groupMail
}

function get-groupmembers($groupID) {
    $members = Get-MgGroupMember -GroupId $groupID
    return $members
}

function get-username($id) {
    $user = Get-MgUser -UserId $id
    [string]$userName = $user.DisplayName
    return $userName
}
function Build-List($members) {
    $users = @()
    $members | ForEach-Object {
        $userName = get-username $_.Id
   
        $user = [PSCustomObject]@{
            "User Name" = $userName
            "User ID"   = $_.Id
        }
        $users += $user
    }
    return $users
}

function export-list($groupMail, $users) {
    [string]$groupMailname = $groupMail
    $users | Export-Csv -Path "$psscriptRoot\$groupMailname.csv" -NoTypeInformation -append
}

function main {
    module-check
    connect-MgGraph
    $loop = $true
    While ($loop) {
        $group = Read-Host "Enter the name of the group"
        $group = get-group $group
        $groupID = $group[0]
        $groupMail = $group[1]
        $members = get-groupmembers $groupID
        if ($members -eq $null) {
            Write-Host "No members found in the group"
        }
        else{
        $list = Build-List $members
        export-list $groupMail $list
        Write-Host "List of members exported to $psscriptRoot\$groupMail.csv"
        }        

        $choice = Read-Host "Do you want to export another group? (Y/N)"
        if ($choice -eq "N") {
            $loop = $false
        }
    }      
    Disconnect-MgGraph        
}
main