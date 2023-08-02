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
$badApp = 'Discord'

#log object to report on results
$LogObject = New-Object -TypeName psobject;

#assigning variables to log object
$LogObject | Add-Member -MemberType NoteProperty -Name 'Date Time' -Value $time;
$LogObject | Add-Member -MemberType NoteProperty -Name 'Application file Name' -Value $badApp;
$LogObject | Add-Member -MemberType NoteProperty -Name 'Application Name' -Value $badApp;
$LogObject | Add-Member -MemberType NoteProperty -Name 'App Running?' -Value '';
$LogObject | Add-Member -MemberType NoteProperty -Name 'Application ID' -Value '';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App File Location' -Value '';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App CPU Usage' -Value ''; 
$LogObject | Add-Member -MemberType NoteProperty -Name 'App CPU Up time' -Value '';
$LogObject | Add-Member -MemberType NoteProperty -Name 'App Max working set size'-Value '';

#creates an object containing the variable 
$ob = get-process | Where-Object {($_.Name -like $badApp) -or ($_.Description -like $badApp)};

    if($null -ne $ob) {
        $count= 0;
        $ob | ForEach-Object{
        $LogObject.'Application file Name' = $ob.name[$count];
        $LogObject.'Application Name' = $ob.Description[$count];
        $LogObject.'App Running?' = 'True';
        $LogObject.'Application ID' = $ob.Id[$count];
        $LogObject.'App File Location' = $ob.Path[$count];
        $LogObject.'App CPU Usage' = $ob.CPU[$count];
        $LogObject.'App CPU Up time' = $ob.TotalProcessorTime[$count];
        $LogObject.'App Max working set size' = $ob.MaxWorkingSet[$count];
        $count ++;
        $LogObject |Export-Csv -Path $LogFile -Append -NoTypeInformation -Force;
        }
    }
    else {
        $LogObject.'App Running?' = 'False';
        $LogObject.'Application ID' = "N/A";
        $LogObject.'App File Location' = "N/A";
        $LogObject.'App CPU Usage' = 0;
        $LogObject.'App CPU Up time' = 0;
        $LogObject.'App Max working set size' = 0;
        #exports log object to csv
        #$LogObject | Select-Object * | Export-Csv -Path $LogFile -Append -NoTypeInformation;
        $LogObject |Export-Csv -Path $LogFile -Append -NoTypeInformation -Force;
    }




