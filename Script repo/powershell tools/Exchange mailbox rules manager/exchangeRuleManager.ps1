<#
Tool for manageing rules of users in Exchange
Auther : Mathew Gallehawk
requires the exchange module to be installed and autherised
#>

#function to get the user
function getUser {
    $i = $true
    while ($i) {
        $user = Read-Host "Please enter the users email address"
        $exists = get-mailbox -Identity $user
    
        if ($null -ne $exists) {
            write-host "$user found"
            $i = $false
            return $user
        }
        else {
            $input = read-host "User not found would you like to try again? y/n"
            if ($input -eq "n" -or $input -eq "N" -or $input -eq "no" -or $input -eq "No") {
                write-host "Goodbye"
                start-sleep -s 3
                exit
            }
        }
    }
}

#function to present rules
function get-rules($mailbox) {
    $ruleList = @()
    $it = 0

    $rules = get-inboxrule -Mailbox $mailbox | select-object -property *
    $rules | foreach-object {
        $it++
        $rule = New-Object PSObject
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Number" -Value $it
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Idetity" -Value $_.Identity
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Name" -Value $_.Name
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Mailbox Owner" -Value $_.MailboxOwnerId
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Description" -Value $_.Description
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Enabled" -Value $_.Enabled
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Priority" -Value $_.Priority
        $rule | Add-Member -MemberType NoteProperty -Name "From" -Value $_.From
        $rule | Add-Member -MemberType NoteProperty -Name "Rule SubjectContainsWords" -Value $_.SubjectContainsWords
        $rule | Add-Member -MemberType NoteProperty -Name "Rule SubjectOrBodyContainsWords" -Value $_.SubjectOrBodyContainsWords
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Redirection" -Value $_.RedirectTo
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Delete Message" -Value $_.DeleteMessage
        $rule | Add-Member -MemberType NoteProperty -Name "Stop processing rules" -Value $_.StopProcessingRules
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Copy To Folder" -Value $_.CopyToFolder
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Forward To" -Value $_.ForwardTo
        $rule | Add-Member -MemberType NoteProperty -Name "Rule Identity" -Value $_.Actions
        $ruleList += $rule
    }
    return $ruleList
}

#function to remove rules
function remove-rule($mailbox, $ruleList) {
    $loop = $true
    while ($loop) {
        $rules | foreach-object {
            view-rule $_
        }
        $input = read-host "Select the number of the rule you would like to remove, or type exit to exit"
        if ($input -eq "exit") {
            exit
        }
        elseif ($input -lt 1 -or $input -gt ($ruleList.Count - 1)) {
            write-host "Invalid selection, please try again"
        }
        else {
            $rule = $ruleList[$input - 1]   
            view-rule $rule
            $check = read-host $rule.Name "will be removed, are you sure? y/n"
            if ($check -eq "y") {
                remove-inboxrule -Mailbox $mailbox -Identity $rule.'Rule Name'
                write-host $rule.Name "has been removed"
                $loop = $false
            }
        }
    }
}

#function to view full details of a rule
function view-rule($rule) {
    write-host "____________________________________________"
    $rule | select-object -property *

}

#function for main
function main {
    Connect-ExchangeOnline -ShowBanner:$false
    write-host "Welcome to the exchange rule manager"
    write-host "This script will allow you to view and remove rules from a users mailbox"

    $loop = $true

    while ($loop) {
        $selection = Read-Host "Please select an option: 1. View rules 2. Remove rules 3. Exit"   
        switch ($selection) {
            1 {
                $user = getUser
                $rules = get-rules $user
                $rules | foreach-object {
                    view-rule $_
                }
            }
            2 {
                $user = getUser
                $rules = get-rules $user
                remove-rule $user $rules
            }
            3{
                $loop = $false
            }
            default {
                write-host "Invalid selection, please try again"
            }
        }
    }
    Write-Host "Goodbye"
    Disconnect-ExchangeOnline -Confirm:$false
    start-sleep -s 3
    exit
}

main

