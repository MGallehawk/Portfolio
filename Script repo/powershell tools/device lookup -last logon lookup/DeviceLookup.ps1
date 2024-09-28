<#
Script to look up details for a intune device
Auther: Mathew Gallehawk

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

#function to capture desired device
function captureDevice {
    $deviceName = $null
    $deviceName = Read-Host "What is the device's hostname?"
    return $deviceName
}

#function to extract last logged on user of that device
function lastLoggedOn($device) {
    $details = Get-MgBetaDeviceManagementManagedDevice -Filter "contains(deviceName,'$device')"
    $loggedOn = $details.UsersLoggedOn
    $usersList = ''
    $usersList = @()
    foreach ($user in $loggedOn) {
        $lastLogon = $user.LastLogOnDateTime
        $userObject = New-Object PSObject -Property @{
            UserId               = $user.UserId
            DisplayName          = (Get-MgBetaUser -UserId $user.UserId).DisplayName
            LastLoggedOnDateTime = $lastLogon
        }
        $usersList += $userObject
    }

    return $usersList
}

#function to pull device details
function pullDeviceDetails($device) {
    $details = Get-MgBetaDeviceManagementManagedDevice -Filter "contains(deviceName,'$device')" 
    $device = New-Object PSObject
    $device | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $details.DeviceName
    $device | Add-Member -MemberType NoteProperty -Name "DeviceId" -Value $details.DeviceId
    $device | Add-Member -MemberType NoteProperty -Name "DeviceType" -Value $details.DeviceType
    $device | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $details.Manufacturer
    $device | Add-Member -MemberType NoteProperty -Name "Model" -Value $details.Model
    $device | Add-Member -MemberType NoteProperty -Name "Sku" -Value $details.SkuNumber
    $device | Add-Member -MemberType NoteProperty -Name "SerialNumber" -Value $details.SerialNumber
    $device | Add-Member -MemberType NoteProperty -Name "EnrolledDateTime" -Value $details.EnrolledDateTime
    $device | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $details.OperatingSystem
    $device | Add-Member -MemberType NoteProperty -Name "OSVersion" -Value $details.OSVersion
    $device | Add-Member -MemberType NoteProperty -Name "ComplianceState" -Value $details.ComplianceState
    $device | Add-Member -MemberType NoteProperty -Name "EthernetMacAddress " -Value $details.EthernetMacAddress 
    $device | Add-Member -MemberType NoteProperty -Name "WiFiMacAddress" -Value $details.WiFiMacAddress
    $device | Add-Member -MemberType NoteProperty -Name "AutopilotEnrolled" -Value $details.AutopilotEnrolled


    return $device
}


#function for main
function main {
    intro
    moduleManage
    Import-Module Microsoft.Graph.Beta.Devicemanagement
    Import-Module Microsoft.Graph.Beta.Users
    Connect-MgGraph -NoWelcome
    $loop = $true
    While ($loop) {
        $device = $null
        $device = captureDevice
        $details = lastLoggedOn($device)
        $device = pullDeviceDetails($device)
        $details | Select-object DisplayName, LastLoggedOnDateTime | Out-Host -Paging
        $device | Out-Host -Paging
        #extract last logged on user of that device
        $loop = Read-Host "Do you want to check another device? (Y/N)"
        if ($loop -eq "N") {
            $loop = $false
        }
    }

    Disconnect-MgGraph
}

main




