<#
Script to oputput all calanders in the tenant to a CSV file
Auther: Mathew Gallehawk
#>

#function to check if module is preasent
function check_module($module) {
    $moduleName = "$module"
    $module = Get-Module -ListAvailable -Name $module
    if ($null -eq $module) {
        Write-Host "Module $module not found, installing module"
        Install-Module -Name $moduleName -Force -AllowClobber
    }
    else {
        Write-Host "Module $module found"
    }
}

#function to list required modules and set up if required
function module_setup {
    $modules = @("ExchangeOnlineManagement")
    $modules | foreach-object {
        write-host "Checking for module $_"
        check_module $_
    }
    write-host "All modules installed"
    write-host "setup complete"
    start-sleep -s 2
}

#function to export list to csv
function csv-out($arr, $fileName) {
    $path = "$PSScriptRoot/$fileName" + ".csv"
    $arr | Export-Csv -Path $path -NoTypeInformation
}


#function to get all calanders assosiated to mailbox
function get_calendars($email) {
    $dataPull = Get-MailboxFolderStatistics -Identity $email.WindowsEmailAddress -Folderscope Calendar | select-object Name, Identity, FolderType, ItemsInFolder, FolderSize, CreationTime, LastModifiedTime
    $calendars = @()
    $dataPull | foreach-object {
        $calendar = new-object psobject
        $calendar | add-member -membertype NoteProperty -name "Email" -Value $email.WindowsEmailAddress
        $calendar | add-member -membertype NoteProperty -name "Name" -Value $_.Name
        $calendar | add-member -membertype NoteProperty -name "Identity" -Value $_.Identity
        $calendar | add-member -membertype NoteProperty -name "FolderType" -Value $_.FolderType
        $calendar | add-member -membertype NoteProperty -name "ItemsInFolder" -Value $_.ItemsInFolder
        $calendar | add-member -membertype NoteProperty -name "FolderSize" -Value $_.FolderSize
        $calendar | add-member -membertype NoteProperty -name "CreationDate" -Value $_.CreationTime
        $calendar | add-member -membertype NoteProperty -name "LastModified" -Value $_.LastModifiedTime
        $calendars += $calendar
    }
    return $calendars
}

# Function for main
function main {
    module_setup
    Connect-ExchangeOnline
    Write-host "This is going to take a loooong time..."
    $arr = @()
    $emails = get-mailbox -ResultSize Unlimited | select-object WindowsEmailAddress
    $emails | foreach-object {
        $calendars = get_calendars $_
        write-host "Processing $_"
        $arr += $calendars
    }
    write-host "Completed, now exporting to CSV"
    csv-out $arr "calendars"
    Disconnect-ExchangeOnline -Confirm:$false
}

main