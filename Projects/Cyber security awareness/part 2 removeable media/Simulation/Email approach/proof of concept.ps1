$From = "USBsimulation@outlook.com"
$To = "servicedesk@gjames.com.au"
$sub = "Proof of concept for usb phase two code"
$body = "Look at my hourse. my hourse is amazing!"
$SMTPServer = "smtp.office365.com"
$port = '587'
$P = 'gfjhyfhgtf54654'
$pass = ConvertTo-SecureString -String $P -AsPlainText -Force
$Credential  = New-Object System.Management.Automation.PSCredential ($From, $pass)

<#Send-MailMessage -To $To -From $From -Subject $sub -Body $body -SmtpServer $SMTPServer -Credential $Credential -Port $port #>

Send-MailMessage -To $To -From $From -Subject $sub -Body $body -SmtpServer "smtp.office365.com" -Credential (Get-Credential) -Port 587 

