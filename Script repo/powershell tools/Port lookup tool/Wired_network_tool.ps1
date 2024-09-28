<#
Script to discover the network devices using the discovery protocol.
Refrence: https://github.com/lahell/PSDiscoveryProtocol
Auther Mathew Gallehawk
used to tell what switch a port is connected to and what vlan it has assigned to it.

#>

#function to check if module is installed
function module-check {
    $module = Get-Module -ListAvailable -Name PSDiscoveryProtocol
    if ($module -eq $null) {
        return $false
    } else {
        return $true
    }
}

#function to install modules
function installmodule {
    $input = read-host "Module PSDiscoveryProtocol is not installed. Do you want to install it? (Y/N)"
    if ($input -eq "Y") {
        write-host "Installing module PSDiscoveryProtocol"
        Install-Module -Name PSDiscoveryProtocol
    } else {
        bail
    }
}

#function to generate data
function do-thing{
    $Packet = Invoke-DiscoveryProtocolCapture -Force
    $data = Get-DiscoveryProtocolData -Packet $Packet
    return $data
}

#function to output data to file
function output-file($dataFrame) {
    $folder = "C:\temp"
    $name = (get-date -f "MM-dd") + "_network scan.txt"
    $path = $folder + "\" + $name
    $dataFrame | Out-File -FilePath $path
}

#function to output data to console
function output-console($dataFrame) {
    write-host "Outputting data to console"
    write-host "_________________________________________________________"
    $dataFrame
    write-host "_________________________________________________________"
}

#function to exit
function bail {
    write-host "Thankyou for using the script"
    write-host "Exiting"
    start-sleep -s 2
    exit
}

#function for main
function main {
    #module manegment
    $loop = $true
    while ($loop) {
        write-host "Checking for module PSDiscoveryProtocol"
        $module = module-check
        if ($module -eq $false) {
            write-host "Module PSDiscoveryProtocol is not installed"
            installmodule
        } else {
            write-host "Module PSDiscoveryProtocol is installed"
            $loop = $false
        }
    }

    #main logic
    $loop2 = $true
    while ($loop2) {
        write-host "Starting network scan"
        $dataFrame = do-thing
        write-host "Network scan complete"
        write-host "Outputting data"
        output-console $dataFrame
        output-file $dataFrame
        write-host "Data output complete"
        write-host "Do you want to scan again? (Y/N)"
        $input = read-host
        if ($input -eq "N") {
            $loop2 = $false
        }
    }
    
}


main