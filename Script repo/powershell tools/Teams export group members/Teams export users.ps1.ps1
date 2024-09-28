<#script written by mathew gallehawk to export a list of members of a teams chanel#>

#module check install

#function to check if module is preasent
function check_module($module){
    $module = Get-Module -ListAvailable -Name $module
    if ($module -eq $null){
        Write-Host "Module not found, installing module"
        Install-Module -Name $module -Force -AllowClobber
    }
    else{
        Write-Host "Module $module found"
    }
}

#function to list required modules and set up if required
function module_setup{
    $modules = @("PowerShellGet", "MicrosoftTeams")
    $modules | foreach-object {
        write-host "Checking for module $_"
        check_module $_
    }
    write-host "All modules installed"
    write-host "setup complete"
    start-sleep -s 2
}


#function to get the parent team of a channel
function retrieve_team{
    $loop = $true
    while ($loop){
        $teamName = read-host "Enter the name of the team, or type exit to quit"
        $team = Get-Team | where-object {$_.DisplayName -eq $teamName} 
        if ($teamName -eq "exit"){
            bail
        }
        elseif ($team -eq $null){
            Write-Host "Team not found, please check the name and try again"
        }
        else{
            $loop = $false
        }
        
    }
    return $team.GroupId, $teamName
}

#function to get all the channels in a team 
function get_chanels($groupID)
{
    $chanels = Get-TeamAllChannel -GroupId $groupID
    $channels = @()
    $ittr = 0
    $chanels | foreach-object {
        $ittr = $ittr + 1
        $chanel = [PSCustomObject]  @{
            "Channel Number" = $ittr
            "Chanel Name" = $_.DisplayName
            "chanel ID" = $_.Id
        }
        $channels += $chanel   
        }
       return $channels  
}

function select_chanel($channels){
    $loop = $true
    while ($loop){
        $channels | foreach-object {
            Write-Host "$($_.'Channel Number') - $($_.'Chanel Name')"
        }
        $selection = Read-Host "Enter the number of the chanel you want to get the members of"
        $chanel = $channels[$selection -1]
        if ($chanel -eq $null){
            Write-Host "Invalid selection, please try again"
        }
        else{
            $loop = $false
        }
    }
    return $chanel
}

function get_chanel_members($chanel, $groupID){
    
    #$chanelID = $chanel.'chanel ID'
    $displayName = $chanel.'Chanel Name'
    $users = Get-TeamChannelUser -GroupID $groupID -DisplayName $displayName
    return $users
}

#function to output the members of a chanel to a csv file
function output_members($members, $fileName){
    $users =@()
    $members | ForEach-Object {
            $user = [PSCustomObject]@{
            "User Name" = $_.Name
            "User ID" = $_.UserId
        }
        $users += $user
    }
    $users | Export-Csv -Path $fileName -NoTypeInformation -Append
}

#exit function
function bail{
    write-host "Thank you for using my teams script"
    Write-Host "Exiting script"
    start-sleep -s 2
    exit
}

#main function
function main{
module_setup
Connect-MicrosoftTeams
$Group_id, $group_name = retrieve_team 
$chanels = get_chanels $Group_id
$selected_chanel = select_chanel $chanels
$members = get_chanel_members $selected_chanel $Group_id
$fileName = "$psscriptroot\$group_name " + $selected_chanel.'Chanel Name'+'.csv'
$cleanFileName = $fileName -replace '\|', "_"
write-host "Outputting members to $cleanFileNAme"
output_members $members $cleanFileNAme
Disconnect-MicrosoftTeams
}

main



