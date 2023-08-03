<#
peer-programing script for coit11241
authers:
--Chelsea Ajisaka,
--Francis Renzaho,
--Mathew Gallehawk
Lecutrer:
--Jamie Sheilds

Scope:
-pretest testWDAC() attempts to run unautherised app - reports
-setupWDAC() - converts policy to .cip
-enableWDAC-deploys policy
-re run testwdac() reporting
-resetWdac() removes block policy
#>

param([parameter(Mandatory = $false,Position=0)]$command, $policyPath, $testAppPath, $App, $DenyAppPath)

function showUsage() {
    Write-Host "Usage: defend.ps1 <command>"
    Write-Host "Commands:"
    Write-Host "  testWDAC -testAppPath <path> -App <app name>"
    Write-Host "  setupWDAC -policyPath <path>"
    Write-Host "  enableWDAC"
    Write-Host "  resetWDAC"
}

function isNotEmpty([String]$value){
    return -not [string]::IsNullOrWhiteSpace($value)
}

function isEmpty([String]$value){
    return [string]::IsNullOrWhiteSpace($value)
}


#testWdac function takes in two parameters
function testWDAC {
    param (
        [Parameter(Mandatory = $true, Position=0)] $testAppPath, 
        [Parameter(Mandatory = $true, Position=1)] $App
    )
    
    
#function opens the specified exe by file path
function startBadApp {
    #variable to be passed in is manditory
    param ([Parameter(Mandatory = $true)] $appPath
        
    )
    try {
        #opens the app based on the path passed in
        start-process $appPath;
    }
    catch {

        #outpts to cmdline if exe can not be loaded
        Write-Output "File" +$appPath+ "can not be loaded. File path is incorrect or app has been blocked"
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
<#Sanity check#>
<#
$testAppPath
$App 
#>

#starts the app
startBadApp -appPath $testAppPath
#tests the is preasent
test4App -app $App; 
}

function createWDACPolicy(){
     param (
        [Parameter(Mandatory=$false, Position=0)][string]$DenyAppPath   # The path to the binary to block (optional)
    )

    try{

        $PolicyName= "DenyAllPolicy"
        $WDACPolicy=$PSScriptRoot+"\$PolicyName.xml"
        $allowMicrosoft = $env:windir+"\schemas\CodeIntegrity\ExamplePolicies\AllowMicrosoft.xml"

        Copy-Item  $allowMicrosoft $WDACPolicy

        Set-CIPolicyIdInfo -FilePath $WDACPolicy -PolicyName $PolicyName -ResetPolicyID
        Set-CIPolicyVersion -FilePath $WDACPolicy -Version "1.0.0.0"


        Set-RuleOption -FilePath $WDACPolicy -Option 0 # Enabled UMCI
        Set-RuleOption -FilePath $WDACPolicy -Option 1 # Enable Boot Menu Protection
        Set-RuleOption -FilePath $WDACPolicy -Option 3 # Enable Audit Mode
        Set-RuleOption -FilePath $WDACPolicy -Option 4 # Disable Flight Signing
        Set-RuleOption -FilePath $WDACPolicy -Option 6 # Enable Unsigned Policy
        Set-RuleOption -FilePath $WDACPolicy -Option 10 # Enable Boot Audit on Failure
        Set-RuleOption -FilePath $WDACPolicy -Option 12 # Enable Enforce Store Apps
        Set-RuleOption -FilePath $WDACPolicy -Option 16 # Enable No Reboot
        Set-RuleOption -FilePath $WDACPolicy -Option 17 # Enable Allow Supplemental
        Set-RuleOption -FilePath $WDACPolicy -Option 19 # Enable Dynamic Code Security

        $PathRules = @()
        $PathRules += New-CIPolicyRule -FilePathRule "%windir%\*"
        $PathRules += New-CIPolicyRule -FilePathRule "%OSDrive%\Program Files\*"
        $PathRules += New-CIPolicyRule -FilePathRule "%OSDrive%\Program Files (x86)\*"

 

        if ($DenyAppPath) {
            # Add blocking rules for specified binary if provided
            $DenyRules = @()
            forEach($Path in $BinaryPath){
                $DenyRules += New-CIPolicyRule -Level FileName -DriverFilePath $Path -Fallback SignedVersion,Publisher,Hash -Deny
            }
            Merge-CIPolicy -OutputFilePath $WDACPolicy -PolicyPaths $WDACPolicy -Rules $PathRules + $DenyRules
        } else {
            # Merge the path rules only if no binary is specified
            Merge-CIPolicy -OutputFilePath $WDACPolicy -PolicyPaths $WDACPolicy -Rules $PathRules >> CIPolicyLog.txt
        }
    }
    catch{
        Write-Host "Failed to create WDAC Policy: $_"
        
    }
   

    #create supplemental policy
    # Set-CIPolicyIdInfo -FilePath ".\supplemental_policy.xml" [-SupplementsBasePolicyID <BasePolicyGUID>] [-BasePolicyToSupplementPath <basepolicy_path_>] -PolicyId <policy_Id> -PolicyName <PolicyName>
}



#creates and converts policy to .cip
function setupWDAC() {
    param([parameter(Mandatory = $false,Position=0)]$policyPath, [Parameter(Position=1)]$DenyAppPath)

    createWDACPolicy $DenyAppPath

    #check for available xml files
    $xmlFiles = Get-ChildItem -Path ".\*.xml"

    # $policyPath = Read-Host "Enter Policy Path"
    if(((isNotEmpty($policyPath)) -and (Test-Path $policyPath) -and ((Get-Content $policyPath) -as [xml])) -or (($xmlFiles|Measure-Object).Count -eq 1) ){
        [xml]$xml = ''
        if($policyPath){
            $xml = Get-Content $policyPath
        }else{
            $xml = Get-Content $xmlFiles
            $policyPath = "$PSScriptRoot\$($xmlFiles.Name)"
        }
        #get policy ID
        $policyID = $xml.Sipolicy.PolicyID

        #convert policy to .cip
        ConvertFrom-CIPolicy -XmlFilePath $policyPath -BinaryFilePath "$policyID.cip"

        echo "[+] Policy $policyID Created!"
        echo "[~] Deployed Policy: .\defend.ps1 enableWDAC"
    }
    else{
        if( (isEmpty $policyPath)){
            write-host "[-] No Path Provided!"
            showUsage
        }else{
            write-host "[-] Invalid Path!"
        }
    }
    
}

function enableWDAC([String]$policyPath=".\disabledPolicies.txt") {
    #Might need to run as admin
    # if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    #     Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    #     Break
    # }

    #check available cip files
    $cipFiles = Get-ChildItem -Path .\*.cip
    #enable policy using citoo.exe
    if((Test-Path $policyPath) -and ($($(Get-Content .\disabledPolicies.txt).Length) -gt 0) -or $cipFiles.Length -gt 0){
        $policyIDs = Get-Content .\disabledPolicies.txt
        
        foreach($policyID in $policyIDs){
            # .\ciptool.exe --update-policy "$policyID.cip" #Deploy policy
            echo "[+] Policy $policyID Enabled"
        }
        #save enabled policies
        echo "$policyIDs">> enabledPolicies.txt        
        #remove disabledPolicies.txt
        Remove-Item -Path $policyPath
    }
    else{
        write-host "[-] No Policy to enable"
    }
}



function resetWDAC() {
  
    
}


switch ($command) {
    "testWDAC" { testWDAC $testAppPath $App; Break }
    "setupWDAC" { setupWDAC $policyPath $DenyAppPath; Break }
    "enableWDAC" { enableWDAC; Break }
    "resetWDAC" { resetWDAC; Break }
    default { showUsage; Break }
}



<#This is to initalise TestWDAC#>
#path to app
[string]$testAppPath = "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe";
#approximate name or description of app
[string]$App = "acrobat";

#initiates the test function
#testWDAC -testAppPath $testAppPath -App $App; -- commented out for testing)

