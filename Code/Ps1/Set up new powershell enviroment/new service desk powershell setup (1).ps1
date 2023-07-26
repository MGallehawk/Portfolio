<#
Auther Mathew Gallehawk
Script to set up a new service desk with the powershell access they require for bau
Requires Administrator privlages
Scope:
Exchange, AzureAD,Security & compliance, Teams
Reference:
https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-and-maintain-the-exchange-online-powershell-module
https://thesysadminchannel.com/how-to-install-exchange-online-powershell-module/

May prompt for nugert update and or powershell update
#>

#Sets execution policy to allow scripting has to be done prior to running this script
#Set-ExecutionPolicy RemoteSigned

#update powershell
Import-Module -Name PowerShellGet 
Install-Module -Name PowerShellGet -Force

#Azure connect
Install-Module -Name Az
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#Exchange
Import-Module -Name ExchangeOnlineManagement
Find-Module -Name ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
Get-Command -Module ExchangeOnlineManagement


#security and complience
#this is handeled by exchange powershell, however user requires the appropriate permisions

#Teams
Import-Module -Name MicrosoftTeams 
Install-Module -Name MicrosoftTeams -Force -AllowClobber
