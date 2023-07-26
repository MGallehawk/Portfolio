#modified powershell to batch converter
#exit vesion

#Variables
#path to file
$P = "C:\Users\e103719\G.James Australia Pty Ltd\Team ICT Service Desk - General\ICT Service Desk technical Library\Service Desk Technical Documents\6 - Project Work\Cyber security awareness\part 2 removeable media\Simulation\DB approach\convery" 


function Convert-PowerShellToBatch
{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        [Alias("FullName")]
        $Path
    )
 
    process
    {
        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content -Path $Path -Raw -Encoding UTF8)))
        $newPath = [Io.Path]::ChangeExtension($Path, ".bat")
        "@echo off`npowershell.exe -encodedCommand $encoded" | Set-Content -Path $newPath -Encoding Ascii
    }
}
Get-ChildItem -Path $P -Filter *.ps1 |
  Convert-PowerShellToBatch