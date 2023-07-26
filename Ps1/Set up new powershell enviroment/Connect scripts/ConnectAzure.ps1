Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\winrm\client' -Name AllowBasic -Value 1
Connect-AzureAD 