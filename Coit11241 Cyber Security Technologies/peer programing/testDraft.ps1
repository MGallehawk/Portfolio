<#
this is a scratch pad to develop testWDC()
scope:
-logging append to a csv log in the working directory
-find an app
-log if it is up
#>
<#sanity check basis of the function
$badApp = 'Acrobat';
$LogFile = $PSScriptRoot +"\testWDCLog.csv";
get-process | Where-Object -Property Name -like $badApp | Select-Object -Property Name, Id, SessionId, Path, CPU, TotalProcessorTime, MaxWorkingSet | Export-Csv -Path $LogFile -Append -NoTypeInformation;
#>


#gets local time used for logging
$time = Get-Date;
#Feild indicates the file that the script runs from
$LogFile = $PSScriptRoot +"\testWDCLog.csv";

#define target process here
$badApp = 'Acrobat';

#log object to report on results
$LogObject = New-Object -TypeName psobject;

#assigning variables to log object
#Assigning Variables to Object   
$LogObject | Add-Member -MemberType NoteProperty -Name 'Date Time' -Value $time;
$LogObject | Add-Member -MemberType NoteProperty -Name 'Application Name';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App Running?';
$LogObject | Add-Member -MemberType NoteProperty -Name 'Application ID';
$LogObject | Add-Member -MemberType NoteProperty -Name 'Session ID';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App File Location';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App CPU Usage'; 
$LogObject | Add-Member -MemberType NoteProperty -Name 'App CPU Up time';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App Max working set size';

try {
$LogObject.'Da'
    
$AppName = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property Name;
$AppID = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property Id;
$AppSessionID = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property SessionId;
$AppPath = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property Path;
$AppCpu = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property CPU;
$TotalProTime = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property TotalProcessorTime;
$MaxWorkingSet = get-process | Where-Object -Property Name -like $badApp | Select-Object -Property MaxWorkingSet;
$Appdetected = $true;

}
catch {
    $Appdetected = $False;
    $AppName = $badApp; 
    $AppID = '';
    $AppSessionID = '';
    $AppPath = '';
    $AppCpu = 0;
    $TotalProTime = 0;
    $MaxWorkingSet = 0;
}





#exports log object to csv
$LogObject | Select-Object *;# | Export-Csv -Path $LogFile -Append -NoTypeInformation;


