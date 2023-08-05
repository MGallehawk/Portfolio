<# 
This function's purpose is to remove the WDAC block policy.
Use citool.exe

Look at microsoft
Use google and chatgpt

#>

function resetWDAC()
{

    $folderPath = "$PSScriptRoot\ActivePolicies"

    if ((Get-ChildItem -Path $folderPath).Count -gt 0)
    {
        $policyArray = @((Get-ChildItem -Path $folderPath | where Extension = ".cip").Name.Replace(".cip", ""))
    
        foreach ($policyGuid in policyArray)
        {
            .\citool.exe --remove-policy $policyGuid
        }

        gpupdate /force

    }
    else 
    {
        Write-Output "There are no policies currently set by WDAC"
    }
    
}
