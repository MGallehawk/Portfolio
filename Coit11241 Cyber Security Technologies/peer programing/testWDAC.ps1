<# COIT11241
auther: Mathew Gallehawk
soap box test for test testWDC()
scope:
-attempt to open an exe
-report on success
-logging append to a csv log in the working directory
-find an app
-log if it is up
#>

#function opens the specified exe by file path
function startBadApp {
    #variable to be passed in is manditory
    param ([Parameter(Mandatory = $true)] [String]$appPath
        
    )
    try {
        #opens the app based on the path passed in
        start-process $appPath;
    }
    catch {
        #outpts to cmdline if exe can not be loaded
        Write-Output "File can not be loaded. File path is incorrect or app has been blocked"
    }
    
}

#function logs all instances of running processors that match the specifies app
function test4App {
    param (
        #variable to be passed in is manditory
        [Parameter(Mandatory = $true)] [String]$app
    )

    #gets local time used for logging
    $time = Get-Date;
    #Feild indicates the file that the script runs from
    $LogFile = $PSScriptRoot + "\testWDCLog.csv";

    #define target process here
    $badApp = $app

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

    #creates an aray of processors object containing that meet the conditions 
    $ob = get-process | Where-Object { ($_.Name -like $badApp) -or ($_.Description -like $badApp) };

    # if the get-process finds things do this
    if ($null -ne $ob) {

        #initilises a counter
        $count = 0;
        #for loop passing each process that matched teh condition
        $ob | ForEach-Object {
            #adds values to the object    
            $LogObject.'Application file Name' = $ob.name[$count];
            $LogObject.'Application Name' = $ob.Description[$count];
            $LogObject.'App Running?' = 'True';
            $LogObject.'Application ID' = $ob.Id[$count];
            $LogObject.'App File Location' = $ob.Path[$count];
            $LogObject.'App CPU Usage' = $ob.CPU[$count];
            $LogObject.'App CPU Up time' = $ob.TotalProcessorTime[$count];
            $LogObject.'App Max working set size' = $ob.MaxWorkingSet[$count];
            #itterates the loop
            $count ++;
            #outputs current processor to csv
            $LogObject | Export-Csv -Path $LogFile -Append -NoTypeInformation -Force;
        }
    }
    #else condition if the get-process found nothing
    else {
        #updates object variables
        $LogObject.'App Running?' = 'False';
        $LogObject.'Application ID' = "N/A";
        $LogObject.'App File Location' = "N/A";
        $LogObject.'App CPU Usage' = 0;
        $LogObject.'App CPU Up time' = 0;
        $LogObject.'App Max working set size' = 0;
        #exports log object to csv
        $LogObject | Export-Csv -Path $LogFile -Append -NoTypeInformation -Force;
    }
}

#path to app
$testAppPath = "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
#approximate name or description of app
$app = "acrobat"

#starts the app
startBadApp -appPath $testAppPath 
#tests the is preasent
test4App -app $app;
