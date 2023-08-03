<# 
This function's purpose is to remove the WDAC block policy.
Use citool.exe

Look at microsoft
Use google and chatgpt

setup wdac creates the policy and creates a binary file
use (get childitem | where extension = ".cip").Name.Replace(".cip", "")     This gives me all of the objects
Use citool.exe

remove policy PolicyGUID



#>

function resetWDAC() {
  
    
}
