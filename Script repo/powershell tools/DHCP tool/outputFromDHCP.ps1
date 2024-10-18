#script to output devices from dhcp server

#list dhcp servers
function getDhcpServers {
    #list array
    $list = @()
    #itterator
    $it = 0
    $dhcpServers = Get-DhcpServerInDC
    $dhcpServers | foreach-object {
        $it++
        $newListObject = New-Object PSObject
        $newListObject | Add-Member -MemberType NoteProperty -Name "Number" -Value $it
        $newListObject | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $_.DnsName
        $newListObject | Add-Member -MemberType NoteProperty -Name "ServerIP" -Value $_.IPAddress
        $list += $newListObject
    }
    return $list
}

#slert dhcp server
function serevrSelect {
    $list = getDhcpServers
    $serverName = ""
    $useInput = ""
    write-host("Server Selector:
    Displaying a list of servers: ")
    $list | foreach-object { write-host($_.Number, $_.ServerName, $_.ServerIP) }

    $cont = $false
    while ($cont -eq $false) {
        $option = read-host("Do you want to select a Server by name or number?")
        if ($option -like "name") {
            $userInput = read-host("Enter the name of the server")
            $list | foreach-object {
                if ($_.ServerName -like $userInput) {
                    $serverName = $_.ServerName
                }
            }
        }
        elseif ($option -like "number") {
            $userInput = read-host("Enter the number of the server")
            $list | foreach-object {
                if ($_.Number -like $userInput) {
                    $serverName = $_.ServerName    
                }
            }
        }
        if ($serverName -ne "") {
            $cont = $true
        }
        else {
            write-host("Invalid option")
            $cont = $false
        }
    }
    write-host("server $serverName selected")
    return $serverName
}

#pulls scope id from a server
function scopeId([string]$serverName) {
    $scopList = @()
    $it = 0
    $scopes = Get-DhcpServerv4Scope -ComputerName $serverName
    $scopes | foreach-object {
        $it++
        $scopeObject = New-Object PSObject
        $scopeObject | Add-Member -MemberType NoteProperty -Name "Number" -Value $it
        $scopeObject | Add-Member -MemberType NoteProperty -Name "scopeId" -Value $_.scopeId
        $scopList += $scopeObject
    }
    return $scopList
}


#function to list clients off server
function listClients {
    $serverName = serevrSelect
    $scopeList = scopeId($serverName)
    $scopArr = @()
  
    $cont = $false
    while ($cont -eq $false) {
        $option = read-host("Do you wish to select a single scope (S) or all scopes? (A) or quit (Q)")
        if ($option -like "s") {
            write-host("displaying list of scopes for server $serverName")
            $scopeList | foreach-object { write-host($_.Number, $_.scopeId) }
            $scopeIdNumber = read-host("Enter the scope id number")
            $scopeList | foreach-object {
                if ($_.Number -Like $scopeIdNumber) {
                    write-host("selcted number " + $_.Number + "found")
                    write-host("scope id: " + $_.scopeId)  
                    $scopeObject = New-Object PSObject
                    $scopeObject | Add-Member -MemberType NoteProperty -Name "scopeId" -Value $_.scopeId
                    $scopArr += $scopeObject
                    $cont = $true
                }
            }
        }
    
    elseif ($option -like "a") {
            
        $scopeList | foreach-object {
            $scopeObject = New-Object PSObject
            $scopeObject | Add-Member -MemberType NoteProperty -Name "scopeId" -Value $_.scopeId
            $scopArr += $scopeObject
            $cont = $true
        }

    }
    elseif ($option -like "q") { 

        exit 
    }
    else { write-host("Invalid option") }

}
$list = @()
$it = 0
$scopArr | foreach-object {
    $scopeId = $_.scopeId 
    $clients = Get-DhcpServerv4Lease -ComputerName $serverName -ScopeId $_.scopeId
    $clients | foreach-object {
        $it++
        $newListObject = New-Object PSObject
        $newListObject | Add-Member -MemberType NoteProperty -Name "Number" -Value $it
        $newListObject | Add-Member -MemberType NoteProperty -Name "HostName" -Value $_.HostName
        $newListObject | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $_.IPAddress
        $newListObject | Add-Member -MemberType NoteProperty -Name "scopeId" -Value $_.scopeId
        $newListObject | Add-Member -MemberType NoteProperty -Name "ClientID" -Value $_.ClientID
        $list += $newListObject
       }
     }
return $list, $scopArr
}

#function to count clients in scope
function scope-count($scopeList, $clientList){
    $scopes =@()
    $scopeList | ForEach-Object{
        $scope = new-object psobject
        $scope | Add-Member -MemberType NoteProperty -Name "scopeId" -Value $_.scopeId
        $scope | Add-Member -MemberType NoteProperty -Name "ClientCount" -Value 0

        $clientList | ForEach-Object{
            if($_.scopeId -eq $scope.scopeId){
                $scope.ClientCount++
            }
        }
        $scopes += $scope
    }
return $scopes
}

#output function
function outputFromDHCP($inArray, $fileName) {
    $outputDestination = "$psscriptroot\$fileName.csv"
    $inArray | foreach-object {
        $_ | Export-Csv -Path $outputDestination -NoTypeInformation -append
    }
}


function main {
    $list = listClients
    $clientlist = $list[0]
    $scopeList = scope-count $list[1] $clientlist
    $clientlist| foreach-object { write-host($_.Number, $_.HostName, $_.IPAddress, $_.scopeId, $_.ClientID, $_.IPscope, $_.ServerName) }
    outputFromDHCP $clientlist "Full DHCP Client List"
    outputFromDHCP $scopeList "Scope List"
}

main

