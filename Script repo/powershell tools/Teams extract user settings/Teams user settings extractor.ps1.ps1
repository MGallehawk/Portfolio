<#tool for temas inc0029276
Author: Mathew Gallehawk
#>

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

#function to get a teams user from user
function get_teams_user{
    $loop = $true
    while ($loop){
        $userEmail = read-host "Enter the email of the user, or type exit to quit"
        $user = Get-CsOnlineUser -Identity $userEmail
        if ($userEmail -eq "exit"){
            bail
        }
        elseif ($user -eq $null){
            Write-Host "User not found, please check the email and try again"
        }
        else{
            $loop = $false
        }
        
    }
    return $userEmail
}

#function get teams calling settings
function teamsCallingSettings($userEmail){
    $result = Get-CsUserCallingSettings -Identity $userEmail
    return $result
}

#function to get teams user policy assignment
function teamsUserPolicyAssignemt($userEmail){
    $result = Get-CsUserPolicyAssignment -Identity $userEmail
    return $result
}

#function to get teams user policy
function teamsUserPolicy($userEmail){
    $result = Get-CsUserPolicyPackage -Identity $userEmail
    return $result
}

#function to output results to file
function outputToFile($outfile, $data){
    $data | out-file -FilePath $outfile -Append
}

#exit function
function bail{
    write-host "Thank you for using my teams script"
    Write-Host "Exiting script"
    start-sleep -s 2
    exit
}

#function for main
function main{
write-host "Welcome to the Teams data puller"
Write-host "Checking that prerequisits are installed"
module_setup
Connect-MicrosoftTeams
$user = get_teams_user
$name = $user -replace "@gjames.com.au", ""
$file = "$psscriptroot\$name teamsData.txt" 
$callingSettings = teamsCallingSettings($user)
$userPolicyAssignment = teamsUserPolicyAssignemt($user)
$userPolicy = teamsUserPolicy($user)
$arr = @($callingSettings, $userPolicyAssignment, $userPolicy)
$arr | out-file -FilePath $file


write-host "Data collected"
write-host "Outputting to file: $file"


Disconnect-MicrosoftTeams

}

main



