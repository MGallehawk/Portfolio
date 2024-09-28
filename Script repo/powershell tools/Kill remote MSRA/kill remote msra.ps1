$machinename = read-host "Enter Macine name"
$task = 'msra.exe'
taskkill /s $machinename /F /IM $task


