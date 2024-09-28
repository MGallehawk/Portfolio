#script to output users of a security group to a csv file
#auther Mathew Gallehawk

#function to get teh security group from user
function get-security-group{
    $securityGroup = Read-Host "Enter the security group name"
    return $securityGroup
}

#function to check if the security group exists
function security-group-exists($securityGroup){
    $group = Get-ADGroup -Filter {Name -eq $securityGroup}
    if($group -eq $null){
        write-host "Security group does not exist"
        return $false
    }
    else{
        write-host "Security group exists"
        return $true
    }
}

#function to get the users of the security group
function get-users($securityGroup){
    $GroupArray = @()
    Get-ADGroupMember -Identity $securityGroup | foreach-object{
        $user = Get-ADUser $_.name -Properties * | select-object name, Enabled
        $GroupArray += $user
    }
    return $GroupArray
}
#function to output list to csv file
function write-out($array, $path){
    $file = "$psscriptroot\$path"+'.csv'
    $array | Export-Csv -Path $file -NoTypeInformation
}
#function for main
function main{
Write-host 'This script will output the users of a security group to a csv file'
$loop = $true
while($loop){
    $securityGroup = get-security-group
    $exists = security-group-exists $securityGroup
    if($exists){
        $users = get-users $securityGroup
        write-out $users $securityGroup
        write-host "Users of $securityGroup have been output to a csv file"
        $loop = $false
    }
    else{
        $loop = $true
    }

}
}

main




