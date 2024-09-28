<#auther Mathew Gallehawk
requested by: brett Luck
tool to audit who has access to email accounts#>


#function to output an array of shared mailboxes.
function get-sharedMailboxes {
 
    $mailboxes = Get-Mailbox | Where-Object { $_.AccountDisabled -eq $true }
    return $mailboxes 
}
#function to output an array of non shared mailboxes.
function get-nonsharedMailboxes {
    $mailboxes = Get-Mailbox | Where-Object { $_.AccountDisabled -eq $false }
    return $mailboxes
}
#function to capture and return a targeted mailbox
Function Get-TargetMailbox {
    while ($true) {
        $input = Read-Host "Enter the mailbox or username of the mailbox"
        $mailbox = Get-Mailbox -Identity $input
        if ($mailbox -eq $null) {
            Write-Host "Mailbox not found please retry"
        }
        else {
            $name = $mailbox.Name
            return $mailbox , $name
        }
    }
 
}

#unsure this is working
#function to pull mailboxes a user has access to
function get_UserAccess($mailbox) {
    $User = Get-Mailbox -Identity $mailbox 
    $allMailboxes = Get-Mailbox -ResultSize Unlimited
    $mailboxes = @()
    $allMailboxes | foreach-object {
        $email = $_.PrimarySmtpAddress
        $result = get-mailboxPermission -identity $_.Name
        $result | foreach-object {
            $entry = New-Object PSObject
            $entry | Add-Member -MemberType NoteProperty -Name "MailBox" -Value $_.Identity
            $entry | Add-Member -MemberType NoteProperty -Name "Email" -Value $email
            $entry | Add-Member -MemberType NoteProperty -Name "User" -Value $_.User
            $entry | Add-Member -MemberType NoteProperty -Name "AccessRights" -Value $_.AccessRights
            if ($entry.User -like $User.PrimarySmtpAddress) {
                $mailboxes += $entry
            }
        }
    }
    return $mailboxes
}

#function to output the users with access to a mailbox and permisions.
function get-mailboxAccess($mailbox) {
    $result = get-mailboxPermission -identity $mailbox
    $array = @()
    $result | foreach-object {
        $entry = New-Object PSObject
        $entry | Add-Member -MemberType NoteProperty -Name "MailBox" -Value $mailbox
        $entry | Add-Member -MemberType NoteProperty -Name "Identity" -Value $_.Identity
        $entry | Add-Member -MemberType NoteProperty -Name "User" -Value $_.User
        $entry | Add-Member -MemberType NoteProperty -Name "AccessRights" -Value $_.AccessRights
        if ($entry.User -notlike "NT AUTHORITY\SELF") {
            $array += $entry
        }
    }
    return $array
}

#function to implement logic
function run-workflow($mailboxArray) {
    $arr = @()
    $mailboxArray | foreach-object {
        $result = get-mailboxAccess($_)
        $result | foreach-object {
            $arr += $_
        }
    }
    return $arr
}

#fnction to export report
function Export-Report($array, $fileName) {
    $array | Export-Csv -Path "$psscriptroot/$fileName" -NoTypeInformation
}

#function for ui
function UI {
    Write-Host "This tool will allow you to audit who has access to mailboxes"
    Write-Host "1. Export all shared mailboxes"
    Write-Host "2. Export all non shared mailboxes"
    Write-Host "3. Export all mailboxes a user has access to"
    Write-Host "4. Export all users that can access a mailbox"
    Write-Host "5. Export who has access to shared mailboxes"   
    Write-Host "6. Export who has access to non shared mailboxes"
    Write-Host "7. Exit"
    $return = Read-Host "Enter a number"
    if ($return -match "[1-7]") {
        return $return
    }
    else {
        Write-Host "Invalid input"
    }
}

#function for main
function main {
    #connect to exchange online
    Connect-ExchangeOnline
    While ($true) {
        $val = UI

        switch ($val) {
            # export all shared mailboxes
            1 { 
                $mailboxes = get-sharedMailboxes
                Export-Report $mailboxes "shared_mailbox_report.csv"
            }
            #export all non shared mailboxes
            2 { 
                $mailboxes = get-nonsharedMailboxes
                Export-Report $mailboxes "nonshared_mailbox_report.csv"
            }
            #export all mailboxes a user has access to
            3 {    
                $user = Get-TargetMailbox
                $name = $user[1]
                $array = $user[0]
                $mailboxes = get_UserAccess($array)
                if ($mailboxes -eq $null) {
                    Write-Host "User $name has no access to any other mailbokes other than their own."
                    Write-Host "Returning to menu..."
                }
                else {
                    Export-Report $mailboxes "user mailbox $name report.csv"
                    Write-Host "Report exported to user mailbox $name report.csv"
                    Write-Host "Returning to menu..."
                }   
            }
            #export all users that can access a mailbox
            4 {     
                $mailbox = Get-TargetMailbox
                $name = $mailbox[1]
                $array = $mailbox[0]
                $result = run-workflow($array)
                if ($result -eq $null) {
                    Write-Host "No users have access to $name"
                    Write-Host "Returning to menu..."
                }
                else {
                    Export-Report $result "mailbox $name report.csv"
                    Write-Host "Report exported to mailbox $name report.csv"
                    Write-Host "Returning to menu..."
                } 
            }
            # export who has access to shared mailboxes
            5 {     
                $mailoxes = get-sharedMailboxes
                $result = run-workflow($mailoxes)
                Export-Report $result "shared_mailbox_report.csv"
            }
            #export who has access to non shared mailboxes
            6 { 
                $mailboxes = get-nonsharedMailboxes
                $result = run-workflow($mailboxes)
                Export-Report $result "nonshared_mailbox_report.csv"
            }
            #exit
            7 {
                Write-Host "Exiting..."
                Write-Host "Goodbye"
                start-sleep 2
                exit(0)
            }
        }
    }
    Disconnect-ExchangeOnline -Confirm:$false
}
#call main
main