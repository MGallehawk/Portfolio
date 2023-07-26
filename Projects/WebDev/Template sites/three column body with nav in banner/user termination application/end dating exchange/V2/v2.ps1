
<####################################################################################################################################################

#script written by Mathew Gallehawk to reduce time and complexity of end dating users in the active directory enviroment
# value in less vulnerabilities due it incorectly terminated accounts
# value in less money waisted on liceses assigned to end dated users.
# value in less storage required for growing shared email accounts with dl groups
# value in reduced time required to perform task

####################################################################################################################################################
version 1
V3 of the user termination program has hung, the application must either be rewritten to function out-side a domain controller or the domain controller needs to be set up to allow connection to exchange online. Both options propose challenges that I require permission and or assistance to over come.
Temporary solution is to calve of the exchange functionality from the original application and implement it in a standalone application outside of the main application 
Later versions of the end dated user application may merge the two applications, however this will move service desk forward in the mean time.

V1 scope
-	UI
o	Name
o	Fields
o	Labels
o	Return msgs

-	Add the code to authenticate
-	Core functionality 
o	Check for email account
o	Set delegate
o	Set out of office
o	Convert to shared

###################################################################################################################################################
Version 2
v1 scope has been met
v2 scope:
    - add logging based of ticket number
    - kill ipsec tunnel on close
    
####################################################################################################################################################>

#Exhcange (Dissabled while ui testing as it hits max allowed conections after 10 tests)
####################################################################################################################################################
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\winrm\client' -Name AllowBasic -Value 1
Connect-ExchangeOnline -useRPSSession

####################################################################################################################################################
#GUI
####################################################################################################################################################

#page format and banner title
#############################################################
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Exchange User terminator'
$main_form.Width = 550
$main_form.Height = 500
$main_form.AutoSize = $false

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#############################################################

#Labels
#############################################################

#Header
$Header = New-Object System.Windows.Forms.Label
$Header.Text = "This Application has been created to make the exchange aspect of the user deletion more seemless."
$Header.Location  = New-Object System.Drawing.Point(0,30)
$Header.AutoSize = $true
$main_form.Controls.Add($Header)

#Header2
$Header2 = New-Object System.Windows.Forms.Label
$Header2.Text = "This application Sets delegate, converts to hared and sets out of office."
$Header2.Location  = New-Object System.Drawing.Point(0,50)
$Header2.AutoSize = $true
$main_form.Controls.Add($Header2)

#Email user label
$Emailusr = New-Object System.Windows.Forms.Label
$Emailusr.Text = "E-number of Termianting user"
$Emailusr.Location  = New-Object System.Drawing.Point(0,70)
$Emailusr.AutoSize = $true
$main_form.Controls.Add($Emailusr)

#Email delegate label
$Emaildel = New-Object System.Windows.Forms.Label
$Emaildel.Text = "E-number of Email Delegate"
$Emaildel.Location  = New-Object System.Drawing.Point(0,90)
$Emaildel.AutoSize = $true
$main_form.Controls.Add($Emaildel)

#RITM label
$Emaildel = New-Object System.Windows.Forms.Label
$Emaildel.Text = "Ritm ticket number"
$Emaildel.Location  = New-Object System.Drawing.Point(0,110)
$Emaildel.AutoSize = $true
$main_form.Controls.Add($Emaildel)

#text boxes
#############################################################

#Termianting user email capture
$termEmail = New-Object System.Windows.Forms.TextBox
$termEmail.Width = 275
$termEmail.Location  = New-Object System.Drawing.Point(250,70)
$main_form.Controls.Add($termEmail)

#email delegate enumber capture box
$emailDelegateEnumber = New-Object System.Windows.Forms.TextBox
$emailDelegateEnumber.Width = 275
$emailDelegateEnumber.Location  = New-Object System.Drawing.Point(250,90)
$main_form.Controls.Add($emailDelegateEnumber)

#RITM Capture
$RITMCap = New-Object System.Windows.Forms.TextBox
$RITMCap.Location  = New-Object System.Drawing.Point(250,110)
$RITMCap.Width =275
$main_form.Controls.Add($RITMCap)

#Retun message capture
$reMessage = New-Object System.Windows.Forms.TextBox
$reMessage.Location  = New-Object System.Drawing.Point(25,225)
$reMessage.Height =100
$reMessage.Width =500
$reMessage.ReadOnly= $true;
$reMessage.AutoSize = $false;
$reMessage.Multiline = $true;
$reMessage.AcceptsReturn = $true;
$main_form.Controls.Add($reMessage)

#############################################################


#buttons
#############################################################

#Convert button
$ConvertButton = New-Object System.Windows.Forms.Button
$ConvertButton.Location = New-Object System.Drawing.Size(150,125)
$ConvertButton.Size = New-Object System.Drawing.Size(80,80)
$ConvertButton.Text = "Convert Account"
$main_form.Controls.Add($ConvertButton)

#clear button
$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Location = New-Object System.Drawing.Size(50,125)
$clearButton.Size = New-Object System.Drawing.Size(80,80)
$clearButton.Text = "Clear Inputs"
$main_form.Controls.Add($clearButton)

####################################################################################################################################################

#variables
#############################################################


#returns current date
$Date= Get-Date -Format "dd/MM/yyyy";

#outof office string
$outOfOfficeExternal = "Sorry the employee you have tried to contact is out of the office at this time, however your email will be read by another of our staff. we are sorry for any inconvenience have a great day. ";
$outOfOfficeInternal = "Sorry the employee you are trieng to contact is out of office ";

#string builder for msg return
$returnString = "";

#variables to hold email names
$termEmployee= $null;
$DelegateEmployee= $null;

#############################################################
#Button logic
#############################################################

#clear button

$clearButton.Add_Click(
    {
        $termEmail.Text = "";
        $emailDelegateEnumber.Text = "";
        $RITMCap.Text = "";
        $reMessage.Text = "";
        $termEmployee= $null;
        $DelegateEmployee= $null;
        $val= $false;   
    }      
)

#Validate button

$ConvertButton.Add_Click(
    {
        #functionality gated behind aproximately correct ticket 7 numbers headed by ritm non case sensitive
        if($RITMCap.Text -match 'RITM+\d{7}')
            {
                #checkes terminating employee has an email account        
                try 
                    {
                        #gets exchange entity from terminating employee field can use email or enumber
                        $termEmployee= get-mailbox $termEmail.Text.trim() -ErrorAction stop;  
                        #boolean switch for positive result
                        $TerminatingEmployyBool= 0;        
                    }
                catch 
                    {
                        #exception handeling sets values if account can not be found
                        $termEmployee= "Terminating employee email look up failed, this may be because user does not have an email or the user was incorectly input.  "
                        #account not found boolean
                        $TerminatingEmployyBool = 1;
                    }
                
                #checks delegate account    
                try 
                    {
                        #gets the entity for Delegate employee.
                        $DelegateEmployee= get-mailbox $emailDelegateEnumber.Text.trim() -ErrorAction stop;
                        #boolean for positive result 
                        $DelegateEmployyBool=0;
                        
                    }
                catch 
                    {
                        #exception handeling for inability to find delegate
                        $manE= "Delegate employee email look up failed, this may be because user does not have an email or the user was incorectly input.  "; 
                        #negative boolean for delegate
                        $DelegateEmployyBool=1;          
                    }

                    #function for same user in both fields
                    if ($termEmployee-like $DelegateEmployee) 
                    {
                        $returnString = "The Terminating account can not be the delegate account";
                        $TerminatingEmployyBool = 2; 
                        $DelegateEmployyBool = 2;
                        
                    }

                    #function for Delegate being found but not terminated user
                    if ($TerminatingEmployyBool -eq 1 -and $DelegateEmployyBool -eq 0) 
                    {
                        $returnString = "An account has been found for the Delegate Employee but not the terminating Employee";
                    
                    }
                    

                    #function for terminating user being found but not delegate
                    if ($TerminatingEmployyBool -eq 0 -and $DelegateEmployyBool -eq 1) 
                    {
                        $returnString = "An account has been found for the Terminating Employee but not the Delegate Employee";
                        
                    }
                    
                    #function for neither being found
                    if ($TerminatingEmployyBool -eq 1 -and $DelegateEmployyBool -eq 1) 
                    {
                        $returnString = "Neither accounts could be found";
                        
                    }
                    
                    #function for both Terminating employee and delegate found
                    if ($TerminatingEmployyBool -eq 0 -and $DelegateEmployyBool -eq 0) 
                        {
                            #sets the out of office
                            Set-MailboxAutoReplyConfiguration –Identity $termEmployee.Name -AutoReplyState Enabled –InternalMessage $outOfOfficeInternal -ExternalMessage $outOfOfficeExternal;
                            #sets the account to shared
                            Set-Mailbox -Identity $termEmployee.Name -Type Shared;
                            #sets teh account delegate
                            Add-MailboxPermission -Identity $termEmployee.Name -User $DelegateEmployee.Name -AccessRights FullAccess -AutoMapping $true;
                            

                            $returnString = "The email Account for " + $termEmployee+ " Has been converted to a 'shared account'. The Delegate has been set to " + $DelegateEmployee;
                            
                        }

                    #returns output to message
                    $reMessage.Text = $returnString;
            }            
        
                    #fail condition for ticket field        
                    else 
                        {
                            $reMessage.Text = "Please check ticket";
                        }
        
        
    }    
)





#############################################################>

$main_form.ShowDialog()



