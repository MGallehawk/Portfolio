#Auther Mathew Gallehawk
#Tool for remote administartion when required

#reboot a remote device
function kickIt($computerName) {
    #wmi calls are restricted to local subnets
    #Restart-Computer -ComputerName $computerName
    shutdown /m \\$computerName /r /f /t 0
}

#function to output to csv
function outputToCsv($list, $filename) {
    $path = "$psscriptroot\$filename" +".csv"
    $list | outputToCsv -NoTypeInformation -Path $path
    write-host "Output exported to $path"
}

#check services on remote device
function remoteServices($computerName) {
    $output = "$psscriptroot\$computerName.csv"
    $list = tasklist /s $computerName /v /fo csv 
    return $list 
    write-host "Services exported to $output"
}

#kill a process on a remote device
function killIt($computerName) {
    $i = 1
    while ($i -lt 10) {
        Write-host "Remote process termination function "
        Write-host "BE CAREFUL WITH THIS FUNCTION"
        $choice = Read-Host " Type 1 ->  kill a process using pid. Type -> 2 to kill a process using name. Type exit -> exit"
        if ($choice -eq "1") {
            $task = tasklist /s $computerName
            $task | format-table -AutoSize
            outputToCsv $task $computerName
        }
        elseif ($choice -eq "2") {
            $id = Read-Host "Enter the process id"
            taskkill /s $computerName /pid $id /f
        }
        elseif ($choice -eq "3") {
            $processName = Read-Host "Enter the process name"
            taskkill /s $computerName /im $processName /f
        }
        elseif ($choice -eq "exit") {
            Write-Host "Later!"
            start-sleep 3
            exit
        }
        else {
            Write-host "Your An idiot, try again"
        }
    }  
}


#function for main
function main{
    $loop = $true
    while ($loop) {
        Write-Host "Remote Admin Tool"
        Write-Host "1. Reboot a remote device"
        Write-Host "2. Check services on a remote device"
        Write-Host "3. Kill a process on a remote device"
        Write-Host "4. Exit"
        $choice = Read-Host "Enter your choice"
        $computerName = Read-Host "Enter the computer name"
        if ($choice -eq "1") {
            kickIt $computerName
        }
        elseif ($choice -eq "2") {
            $task = remoteServices $computerName
            $task | format-table -AutoSize
        }
        elseif ($choice -eq "3") {
            killIt $computerName
        }
        elseif ($choice -eq "4") {
            Write-Host "Later!"
            $loop = $false
        }
        else {
            Write-Host "Invalid choice"
        }
    }

}

main