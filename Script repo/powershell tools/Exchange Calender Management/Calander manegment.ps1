<#
Script by Mathew Gallehawk
manage mailbox permisions
built for INC0040265

#>

#function to check if the module is installed
function Check-Module {
    $module = Get-Module -ListAvailable -Name ExchangeOnlineManagement
    if ($module -eq $null){
        Write-Output "Module not installed, installing now"
        Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    }
    else {
        Write-Output "Module is installed"
    }
}

function ViewCalander {
    Write-Output "This fuction will output a file listing the user permisions for an outlook calaner."
    $calanderEmail = read-host "Please imput the calander email address"
    $calanderName = read-host "Please imput the name of the calander, most cases its just Calendar"
    $Calendar = $calanderEmail + '\' + $calanderName 
    $output = "$PSScriptRoot/$calanderEmail-mailboxpermisions.csv"
    Get-MailboxFolderPermission -Identity $Calendar
    Get-MailboxFolderPermission -Identity $Calendar >> $output
  }  
function removeUser {
    $removeUser = read-host "Please imput email of user you wish to remove from calander"
    $calanderEmail = read-host "Please imput the calander email address"
    $calanderName = read-host "Please imput the name of the calander, most cases its just Calendar"
    $Calendar = $calanderEmail+'\'+$calanderName 
    $preMessage = "current permision list for  $Calendar"
    $postMessage = "altered permisions for $Calendar"
    $output = "$PSScriptRoot/$calanderEmail-mailoxpermisions.csv"  
    $preMessage >> $output
    Get-MailboxFolderPermission -Identity $Calendar >> $output
    $postMessage >> $output
    Remove-MailboxFolderPermission -Identity $Calendar -User $removeUser -Confirm:$false
    remove-MailboxPermission -Identity $Calendar -User $removeUser -AccessRights FullAccess -Confirm:$false
    remove-MailboxPermission -Identity $calanderEmail -User $removeUser -AccessRights ReadPermission -Confirm:$false
     
    Get-MailboxFolderPermission -Identity $Calendar
    Get-MailboxFolderPermission -Identity $Calendar >> $output
}

function addUser{
    $useraccess = read-host 'Select 1 for reviewer, 2 for Editor'
    $AccessRights = ''
    $user = read-host "Please imput email of user you wish to Add to the calander"
    $calanderEmail = read-host "Please imput the calander email address"
    $calanderName = read-host "Please imput the name of the calender, most cases its just Calendar"
    $Calendar = $calanderEmail+'\'+$calanderName 
    $preMessage = "current permision list for $Calendar"
    $postMessage = "altered permisions for $Calendar"
    $output = "$PSScriptRoot/$calanderEmail-mailoxpermisions.csv"
    $preMessage >> $output
    Get-MailboxFolderPermission -Identity $Calendar >> $output
    $postMessage >> $output
    #Add-MailboxFolderPermission -Identity $Calendar -User $user -AccessRights Author
    switch ( $useraccess) {
        1 {$AccessRights = 'Reviewer'
        add-MailboxFolderPermission -Identity $Calendar -User $user -AccessRights  $AccessRights
        Add-MailboxPermission -Identity $calanderEmail -User $user -AccessRights ReadPermission -AutoMapping $true
       }
        2 {$AccessRights = 'Editor'
        add-MailboxFolderPermission -Identity $Calendar -User $user -AccessRights  $AccessRights 
        Add-MailboxPermission -Identity $calanderEmail -User $user -AccessRights FullAccess -AutoMapping $true
        }
       
        Default {Write-output "Inapropriate input, please try again"}
    }

    Get-MailboxFolderPermission -Identity $Calendar
    Get-MailboxFolderPermission -Identity $Calendar >> $output
}

function main{
Check-Module
Connect-ExchangeOnline
#variable for the forever loop
$i = 0

while ($i -eq 0){
    
    Write-host "This tool helps users manage calander permisions"
    write-host "options menue:"
    write-host "1: view calander permisions"
    write-host "2: remove user from calander"
    write-host "3: add user to calander"
    write-host "EXIT: to exit"
    write-host "_________________________________________________________"

    $choice = Read-Host "Please make your menue selection"
    switch ($choice) {
        '1' { viewCalander}
        '2' { removeUser }
        '3' { addUser }
        'EXIT' {
            Disconnect-ExchangeOnline -Confirm:$false
            Write-Output "Session closed, Exiting Now"
            Start-Sleep -Seconds 1
            Exit
        }
        Default {Write-output "Inapropriate input, please try again"}
    }

}

}

main





