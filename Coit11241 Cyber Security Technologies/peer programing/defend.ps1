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


function showUsage() {
    Write-Host "Usage: defend.ps1 <command>"
    Write-Host "Commands:"
    Write-Host "  testWDAC"
    Write-Host "  setupWDAC"
    Write-Host "  enableWDAC"
    Write-Host "  resetWDAC"
}

function testWDAC() {
    
    
}

#converts policy to .cip
function setupWDAC() {
    $policyPath = Read-Host "Enter Policy Path"
    if((Test-Path $policyPath) -and ((Get-Content $policyPath) -as [xml])){
        #get policy ID
        [xml]$xml = Get-Content $policyPath
        $policyID = $xml.Sipolicy.PolicyTypeID
        #convert policy to .cip
        ConvertFrom-CIPolicy -XmlFilePath $policyPath -BinaryFilePath "$policyID.cip"
        #save policy ID
        echo "$policyID" >> disabledPolicies.txt
        echo "[+] Policy $policyID Created!\n"
        echo "[~] Deployed Policy: .\defend.ps1 enableWDAC"
    }
    else{
        write-host "[-] Invalid Path!"
    }
    
}

function enableWDAC([String]$policyPath=".\disabledPolicies.txt") {
    #Might need to run as admin
    # if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    #     Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    #     Break
    # }

    #enable policy using citoo.exe
    if((Test-Path $policyPath) -and $($(Get-Content .\disabledPolicies.txt).Length) -gt 0){
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


switch ($args[0]) {
    "testWDAC" { testWDAC }
    "setupWDAC" { setupWDAC }
    "enableWDAC" { enableWDAC }
    "resetWDAC" { resetWDAC }
    default { showUsage }
}
