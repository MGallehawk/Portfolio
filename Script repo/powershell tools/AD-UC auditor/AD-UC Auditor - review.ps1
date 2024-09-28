#this script written by Mathew Gallehawk to automate anumber of queries through ad an create a report in my hdrive

#function to write to log file
function writeOut($arr, $folder, $fileName) {
    $date = Get-Date -Format "dd-MM-yyyy"
    $path = "$psscriptRoot\Report\$folder\$date"
    $file = "$path\$fileName.csv"
    $arr | Export-Csv -Path $file -NoTypeInformation
}

#function to check if a folder exists
function ReportFolder{
    $date = Get-Date -Format "dd-MM-yyyy"
    $path1 = "$psscriptRoot\Report"
    $path2 = "$path1\Licenses"
    $path4 = "$path1\Other"
    $path5 = "$path1\DLGroups"
    $subPath = @($path2, $path4, $path5)
    $subPath | foreach-object {
        $exists = Test-Path $_
        if ($exists -eq $false) {
            New-Item -ItemType Directory -Path $_
        }
        $exists2 = Test-Path "$_\$date"
        if ($exists2 -eq $false) {
            New-Item -ItemType Directory -Path "$_\$date"
        }
    }
}

#function to pull members of a group
function GetMembers($group) {
    $list = @()   
    $userList = Get-ADGroupMember -Identity $group | select-object name 
    $userList | foreach-object {
        $name = $_.name
        $user = new-object psobject
        $user | add-member -membertype NoteProperty -name Name -value $name
        $list += $user
    }
    return $list
}

#function to populate a list of users in an ou
function GetEndDatedUsers($path) {
    $users = Get-ADUser -SearchBase $path -Filter * | Select-object Name, SamAccountName, Enabled
    return $users
}

#function to return users based on enabled or not
function UserStatus($arr, $state) {
    $list = @()
    $arr | foreach-object {
        $name = $_.Name
        $getuser = Get-ADUser -Filter {name -eq $name}
        if ($getuser) {
            $user = New-Object PSObject
            $user | Add-Member -MemberType NoteProperty -Name Name -Value $getuser.Name
            $user | Add-Member -MemberType NoteProperty -Name Enabled -Value $getuser.Enabled
            if ($user.Enabled -eq $state) {
                $list += $user
            }
        }
    }
    return $list
}

#function to return users who have noty logged in for a set time
function GetGhostUsers($InactiveDays) {
    $Days = (Get-Date).Adddays( - ($InactiveDays))
    $users = Get-ADUser -Filter { LastLogonTimeStamp -lt $Days -and enabled -eq $true } 
    return $users
}

#function for main
function main{
    # groups
    $licenses = @("M365 E5", "M365 E5 - No Calling", "M365 F3", "Mex_User_Test" , "Mex_User", "Office 365 Power BI Pro", "Office 365 Visio Plan 2", "Project Online Essentials", "Project Online Premium", "Project Online Professional", "Promapp - SSO Users", "Citrix Cloud - DG-W2K19-Applications-Prod", "XA7 - V6", "XA7 - EPICS", "XA7 - V6 RO")
    $disabledOU= 'OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au'
    #check report folder exists
    ReportFolder
    # logic to output the disabled users in the groups to a csv
    $licenses | foreach-object {
        $members = GetMembers $_
        $disabled = UserStatus $members $false
        if ($disabled -ne $null) {
            writeOut $disabled 'Licenses' $_
        }
    }

    #logic o output enabled users in disabled ou
    $endDatedUsers = GetEndDatedUsers $disabledOU
    $enabled = UserStatus $endDatedUsers $true
    writeOut $enabled "Other" "EnabledUsersInDisabledOU"
    #logic to output users who have not logged in for a set time
    $ghosts = GetGhostUsers 365
    writeOut $ghosts "Other" "GhostUsers"
    #logic to output disabled users in dl groups
    Get-ADGroup -Filter { name -like "DL -*" } | foreach-object {
        $name = $_.name
        $dlMembers = GetMembers $name
        if ($dlMembers -ne $null) {
            $disabled = UserStatus $dlMembers $false
            if ($disabled -ne $null) {
                writeOut $disabled "DLGroups" $_.Name
            }
        }
    }

    #logic to output users who have not been moved to end dated ou
    $userList = get-aduser -filter {(enabled -eq $false)} | ? { ($_.distinguishedname -notlike '*End-dated Users*') } |  ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) } 
    writeOut $userList "Other" "UsersNotMovedToEndDatedOU"
    #logic to output users who have not been hidden from gal
    $gal = get-aduser -filter .\AppData{(enabled -eq $false)} -property msExchHideFromAddressLists | ? { ($_.msExchHideFromAddressLists -xor 'true') } | ? { ($_.distinguishedname -match '[A-Z]+\d{6}' ) }
    writeOut $gal "Other" "UsersNotHiddenFromGal"

    }
    main

