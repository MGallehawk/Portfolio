function isNotEmpty([String]$value) {
    return -not [string]::IsNullOrWhiteSpace($value)
}

function isEmpty([String]$value) {
    return [string]::IsNullOrWhiteSpace($value)
}

function createWDACPolicy(){
     param (
        [Parameter(Position=0)][string]$DenyAppPath,   # The path to the binary to block (optional)
        [Parameter(Position=1)][string]$AllowAppPath,
        [Parameter(Position=2)][String]$DefaultPolicyPath

    )
    #clear cip files from root folder if exist
    $cipFiles = Get-ChildItem -Path ".\*.cip"
    if(($cipFiles|Measure-Object).Count -gt 0){
        forEach($file in $cipFiles){
            Remove-Item $file
        }

    }
    try{
        $PathRules = @()

        #create Destination Path
        $PolicyName= "DenyAllPolicy"
        $WDACPolicy=$PSScriptRoot+"\$PolicyName.xml"

        if(isEmpty $DefaultPolicyPath){

            #Load Default Policy
            $DefaultPolicyPath = $env:windir+"\schemas\CodeIntegrity\ExamplePolicies\AllowMicrosoft.xml"

           

            #Move policy to path
            Copy-Item  $DefaultPolicyPath $WDACPolicy

            #Add allow rules
            $PathRules += New-CIPolicyRule -FilePathRule "%windir%\*"
            $PathRules += New-CIPolicyRule -FilePathRule "%OSDrive%\Program Files\*"
            $PathRules += New-CIPolicyRule -FilePathRule "%OSDrive%\Program Files (x86)\*"
        }
       

       

        Set-CIPolicyIdInfo -FilePath $WDACPolicy -PolicyName $PolicyName -ResetPolicyID
        Set-CIPolicyVersion -FilePath $WDACPolicy -Version "1.0.0.0"


        Set-RuleOption -FilePath $WDACPolicy -Option 0 # Enabled UMCI
        Set-RuleOption -FilePath $WDACPolicy -Option 1 # Enable Boot Menu Protection
        Set-RuleOption -FilePath $WDACPolicy -Option 3 -delete # Enable Audit Mode
        Set-RuleOption -FilePath $WDACPolicy -Option 4 # Disable Flight Signing
        Set-RuleOption -FilePath $WDACPolicy -Option 6 # Enable Unsigned Policy
        Set-RuleOption -FilePath $WDACPolicy -Option 10 # Enable Boot Audit on Failure
        Set-RuleOption -FilePath $WDACPolicy -Option 12 # Enable Enforce Store Apps
        Set-RuleOption -FilePath $WDACPolicy -Option 16 # Enable No Reboot
        Set-RuleOption -FilePath $WDACPolicy -Option 17 # Enable Allow Supplemental
        Set-RuleOption -FilePath $WDACPolicy -Option 19 # Enable Dynamic Code Security


        if ($DenyAppPath) {
            # Add blocking rules for specified binary if provided
            $DenyRules = @()
            forEach($Path in $DenyAppPath){
                $DenyRules += New-CIPolicyRule -Level FileName -DriverFilePath $Path -Fallback SignedVersion,Publisher,Hash -Deny
            }
            Merge-CIPolicy -OutputFilePath $WDACPolicy -PolicyPaths $WDACPolicy -Rules $($PathRules+$DenyRules)  |Select-Object TypeId,Id,Name
        
        }
        elseif($AllowAppPath){
            forEach($Path in $AllowAppPath){
                $PathRules += New-CIPolicyRule -Level FileName -DriverFilePath $Path -Fallback SignedVersion,Publisher,Hash
            }
            Merge-CIPolicy -OutputFilePath $WDACPolicy -PolicyPaths $WDACPolicy -Rules $PathRules  |Select-Object TypeId,Id,Name
        } 
        else {
            # Merge the path rules only if no binary is specified
            Merge-CIPolicy -OutputFilePath $WDACPolicy -PolicyPaths $WDACPolicy -Rules $PathRules  |Select-Object TypeId,Id,Name
        }
    }
    catch{
        Write-Host "Failed to create WDAC Policy: $_"
        exit
    }
   

}

#creates and converts policy to .cip
function setupWDAC() {
    param([parameter(Mandatory = $false, Position = 0)]$policyPath, [Parameter(Position = 1)][string]$DenyAppPath, [Parameter(Position = 2)]$AllowAppPath, [Parameter(Position = 3)]$DefaultPolicyPath)

    $xmlFiles = ""
    if (-not ($policyPath)) {
        createWDACPolicy $DenyAppPath $AllowAppPath $DefaultPolicyPath
        #check for available xml files
        $xmlFiles = Get-ChildItem -Path ".\*.xml"
    }

    if(((isNotEmpty($policyPath)) -and (Test-Path $policyPath) -and ((Get-Content $policyPath) -as [xml])) -or ((($xmlFiles|Measure-Object).Count -eq 1) -and (-not $policyPath)) ){
        [xml]$xml = ''
        if ($policyPath) {
            $xml = Get-Content $policyPath
        }
        else {
            $xml = Get-Content $xmlFiles
            $policyPath = "$PSScriptRoot\$($xmlFiles.Name)"
        }
        #get policy ID
        $policyID = $xml.Sipolicy.PolicyID

        #convert policy to .cip
        ConvertFrom-CIPolicy -XmlFilePath $policyPath -BinaryFilePath "$policyID.cip"  | Out-Null
        Write-Output ""
        Write-Output "[+] Policy $policyID Created!"
        Write-Output "[~] Deployed Policy: .\defend.ps1 enableWDAC"
    }
    else {
        if ( (isEmpty $policyPath)) {
            write-host "[-] No Path Provided!"
            
        }
        else {
            write-host "[-] Invalid Path!"
        }
    }
    
}

setupWDAC 
