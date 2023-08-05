<# 
This function's purpose is to remove the WDAC block policy.
#>

function resetWDAC() {

    $folderPath = $PSScriptRoot + "\ActivePolicies"

    if ((Get-ChildItem -Path $folderPath).Count -gt 0) {
        $policyArray = @(((Get-ChildItem -Path $folderPath) | Where-Object -Property Extension -like '*.cip').BaseName)# (".cip".Name.Replace(".cip", ""))
    
        foreach ($policyGuid in $policyArray) {
            citool.exe --remove-policy $policyGuid
            
        }
    }

    else {
        Write-Output "There are no policies currently set by WDAC"
    }
    
    #cleanup
    $a = (Get-ChildItem -Path $folderPath) | Where-Object -Property Extension -like '*.cip'
    $a | foreach-object {
        remove-Item -path $_.FullName
    }
}
