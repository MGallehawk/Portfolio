function enableWDAC() {
    
    #check available cip files
    $cipFiles = Get-ChildItem -Path ".\*.cip"
    #enable policy using citoo.exe
    if ( ($cipFiles | Measure-Object).Count -gt 0) {

        forEach ($policyID in ($($cipFiles.name) -replace ".cip", "")) {
            
            $folderPath = "$PSScriptRoot\ActivePolicies"
            $fileName = "$policyID.cip"
            $fullPath = Join-Path -Path $folderPath -ChildPath $fileName

            # Check if the folder exists. If not, create it.
            if (-Not (Test-Path $folderPath -PathType Container)) {
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            }
            citool.exe --update-policy "$policyID.cip" #Deploy policy
            Write-Host "[+] Policy $policyID Enabled"

            # Move the file inside the folder.
            Move-Item -Path "$PSScriptRoot\$fileName" -Destination $fullPath -Force | Out-Null
        }

    }
    else {
        write-host "[-] No Policy Found! "
        write-host "[~] Create Policy: .\defend.ps1 setupWDAC"

    }
}

enableWDAC