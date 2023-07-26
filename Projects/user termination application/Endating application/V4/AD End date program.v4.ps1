
<####################################################################################################################################################

#script written by Mathew Gallehawk to reduce time and complexity of end dating users in the active directory enviroment
# value in less vulnerabilities due it incorectly terminated accounts
# value in less money waisted on liceses assigned to end dated users.
# value in less storage required for growing shared email accounts with dl groups
# value in reduced time required to perform task

####################################################################################################################################################
version 2
version 2 added:
-UI
-core functionality of end dating a user
-verification function
-strips licenses
-Strips DL groups
-adds description field
-moves user to end dated OU
-sets hid from gal msExchHideFromAddressLists

notes from v2

plans for development

code is currently configured for the test enviroment to switch to production enviroment

-un coment $endDateOU = "OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au"; # operational enviroment
-comment out $endDateOU = "OU=End-dated Users,OU=Corporate,DC=MatsLabDomain,DC=com";# test enviromet


issues

- spaces in fields casue non validation perhaps ignore space- addressed using .Trim() like every where 
- description does not update if field is not blank - addressed using a set to null prior to setting it to new description

-  $dlGroups | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false}  works but could do diffrnetly by scanning of the groups that the user is a member of instead of passing through all groups
-  modified  to use Get-ADPrincipalGroupMembership $deadUser to pass throughsecurity groups member is a part of instead o all security groups
####################################################################################################################################################
Version 3
scope:
Incorperate:

Exchange functionality:
-Set delegate
--option for no delegate
-convert to shared
-set out of office
-note exception handeling required for this as user may not have email.

core:
- v6 removal
- create change log common area
- epics reoval

notes: 
 
- rolled back v3 
- scope for v3 has been added to anaother application to be run external to domain controller for now.
- code added and comented out for now to hold place.
- progressing to V4
####################################################################################################################################################
Version 4
scope:
- Incorperate return message box instead of labels
- Add a log generation system

changes:

-	Added a non editable message return box, moved all message return functionality to this box.
-	Moved all return messages to the message box
-	Changed the validation switch to a Boolean value
-	Added functionality for a log to be generated called the request number in a folder called logs
-	Updated the application name
-	Refactored some unused lines
-	Added functionality for the clear button to wipe the return message
-	Added a clean up function to the go button to stop instances sharing validation after work.
-	Added a gating if statement mandating ritm number for progression
-	Added a gating if statement checking if the user has already been end dating prior to progressing
-   Proof reading and updated GUI strings



####################################################################################################################################################>

#Exhcange 
####################################################################################################################################################
#Connect-ExchangeOnline -useRPSSession

####################################################################################################################################################
#GUI
####################################################################################################################################################

#page format and banner title
#############################################################
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='User Termination Application V4'
$main_form.Width = 500
$main_form.Height = 400
$main_form.AutoSize = $false
#############################################################

#Labels
#############################################################

#Enumber label
$EnumberLabel = New-Object System.Windows.Forms.Label
$EnumberLabel.Text = "Terminating User E-number"
$EnumberLabel.Location  = New-Object System.Drawing.Point(0,30)
$EnumberLabel.AutoSize = $true
$main_form.Controls.Add($EnumberLabel)

#First name label
$FirstNameLabel = New-Object System.Windows.Forms.Label
$FirstNameLabel.Text = "Terminating User First Name"
$FirstNameLabel.Location  = New-Object System.Drawing.Point(0,50)
$FirstNameLabel.AutoSize = $true
$main_form.Controls.Add($FirstNameLabel)

#last name label
$FirstLastLabel = New-Object System.Windows.Forms.Label
$FirstLastLabel.Text = "Terminating User Last Name"
$FirstLastLabel.Location  = New-Object System.Drawing.Point(0,70)
$FirstLastLabel.AutoSize = $true
$main_form.Controls.Add($FirstLastLabel)

#RITM label
$RECLabel = New-Object System.Windows.Forms.Label
$RECLabel.Text = "Relevant Request number"
$RECLabel.Location  = New-Object System.Drawing.Point(0,90)
$RECLabel.AutoSize = $true
$main_form.Controls.Add($RECLabel)

#Validation label
$validationLabel = New-Object System.Windows.Forms.Label
$validationLabel.Location  = New-Object System.Drawing.Point(0,280)
$validationLabel.AutoSize = $true
$validationLabel.Visible= $false;
$main_form.Controls.Add($validationLabel)

#Message return label
$ReturnMessageLabel = New-Object System.Windows.Forms.Label
$ReturnMessageLabel.Location  = New-Object System.Drawing.Point(0,130)
$ReturnMessageLabel.AutoSize = $true
$main_form.Controls.Add($ReturnMessageLabel)

<#
#Email delegation label
$Emailhead = New-Object System.Windows.Forms.Label
$Emailhead.Text = "Email Delegation If Required"
$Emailhead.Location  = New-Object System.Drawing.Point(0,140)
$Emailhead.AutoSize = $true
$main_form.Controls.Add($Emailhead)

#Email delegate label
$Emaildel = New-Object System.Windows.Forms.Label
$Emaildel.Text = "E-number of Email Delegate"
$Emaildel.Location  = New-Object System.Drawing.Point(0,160)
$Emaildel.AutoSize = $true
$main_form.Controls.Add($Emaildel)
#>

#debug labels
#############################################################

#Debug1 message  return label First name from ad
$DebugnMessageLabel1 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel1.Location  = New-Object System.Drawing.Point(0,300)
$DebugnMessageLabel1.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel1)

#Debug2 message  return label last name from ad
$DebugnMessageLabel2 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel2.Location  = New-Object System.Drawing.Point(250,300)
$DebugnMessageLabel2.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel2)

#Debug3 message  return label First name provided
$DebugnMessageLabel3 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel3.Location  = New-Object System.Drawing.Point(0,320)
$DebugnMessageLabel3.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel3)

#Debug4 message  return label last name provided
$DebugnMessageLabel4 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel4.Location  = New-Object System.Drawing.Point(250,320)
$DebugnMessageLabel4.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel4)

#Debug5 message  return ritm NUMBER
$DebugnMessageLabel5 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel5.Location  = New-Object System.Drawing.Point(0,340)
$DebugnMessageLabel5.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel5)

#Debug6 message  return date
$DebugnMessageLabel6 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel6.Location  = New-Object System.Drawing.Point(0,360)
$DebugnMessageLabel6.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel6)

#Debug7 message  description
$DebugnMessageLabel7 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel7.Location  = New-Object System.Drawing.Point(0,380)
$DebugnMessageLabel7.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel7)

#############################################################

#text boxes
#############################################################

#e-number capture box
$EnumberTextBox = New-Object System.Windows.Forms.TextBox
$EnumberTextBox.Width = 100
$EnumberTextBox.Location  = New-Object System.Drawing.Point(150,30)
$main_form.Controls.Add($EnumberTextBox)

#First name  capture box
$FNameTextBox = New-Object System.Windows.Forms.TextBox
$FNameTextBox.Width = 100
$FNameTextBox.Location  = New-Object System.Drawing.Point(150,50)
$main_form.Controls.Add($FNameTextBox)

#Last name  capture box
$LNameTextBox = New-Object System.Windows.Forms.TextBox
$LNameTextBox.Width = 100
$LNameTextBox.Location  = New-Object System.Drawing.Point(150,70)
$main_form.Controls.Add($LNameTextBox)

#RITM  capture box
$RITMTextBox = New-Object System.Windows.Forms.TextBox
$RITMTextBox.Width = 100
$RITMTextBox.Location  = New-Object System.Drawing.Point(150,90)
$main_form.Controls.Add($RITMTextBox)

#Retun message capture
$reMessage = New-Object System.Windows.Forms.TextBox
$reMessage.Location  = New-Object System.Drawing.Point(25,225)
$reMessage.Height =100;
$reMessage.Width =450;
$reMessage.ReadOnly= $true;
$reMessage.AutoSize = $false;
$reMessage.Multiline = $true;
$reMessage.AcceptsReturn = $true;
$main_form.Controls.Add($reMessage)

<#
#email delegate enumber capture box
$emailDelegateEnumber = New-Object System.Windows.Forms.TextBox
$emailDelegateEnumber.Width = 100
$emailDelegateEnumber.Location  = New-Object System.Drawing.Point(150,160)
$main_form.Controls.Add($emailDelegateEnumber)
#>


#############################################################

#buttons
#############################################################

#Validate button
$ValButton = New-Object System.Windows.Forms.Button
$ValButton.Location = New-Object System.Drawing.Size(300,20)
$ValButton.Size = New-Object System.Drawing.Size(80,80)
$ValButton.Text = "Validate"
$main_form.Controls.Add($ValButton)

#clear button
$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Location = New-Object System.Drawing.Size(390,20)
$clearButton.Size = New-Object System.Drawing.Size(80,80)
$clearButton.Text = "Clear Inputs"
$main_form.Controls.Add($clearButton)

<#Email button
$EmailButton = New-Object System.Windows.Forms.Button
$EmailButton.Location = New-Object System.Drawing.Size(300,110)
$EmailButton.Size = New-Object System.Drawing.Size(80,80)
$EmailButton.Text = "Email Delegate"
$main_form.Controls.Add($EmailButton)
#>

#go button
$GoButton = New-Object System.Windows.Forms.Button
$GoButton.Location = New-Object System.Drawing.Size(390,110)
$GoButton.Size = New-Object System.Drawing.Size(80,80)
$GoButton.Text = "End-Date User"
$main_form.Controls.Add($GoButton)


####################################################################################################################################################

#variables
#############################################################

$Vtrue= "Validation successful";
$Vfalse= "Empoyee E-number does not match employee name or Employee does not exist in Active Directory";
$responsePositive= "User has been end-dated Successfully and a log has been generated"
$responseNegative= "Validation required, please check input data, select the validate button to try again"
$Date= Get-Date -Format "dd/MM/yyyy";

<# Email block
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
#>

#############################################################

#Button logic
#############################################################

#clear button

$clearButton.Add_Click(
    {
        $EnumberTextBox.Text = "";
        $FNameTextBox.Text = "";
        $LNameTextBox.Text = "";
        $RITMTextBox.Text = "";
        $validationLabel.Text = $false; 
        $reMessage.Text = "";
    }      
)


#Validate button

$ValButton.Add_Click(
    #functionality gated behind aproximately correct ticket 7 numbers headed by ritm non case sensitive
        
        {
            if($RITMTextBox.Text -match 'RITM+\d{7}')
            {
                #validation logic
                $user =Get-adUser -Identity $EnumberTextBox.Text.Trim();
                $fn= $user.GivenName;
                $LN= $user.Surname;
                $RITM = $RITMTextBox.Text.Trim();
                $Description= ("Disabled on: " + $Date + " for " + $RITM);
                #UI return message 
                #############
                $ValidationADRetun= "Verified Name of user from Active Directory is: " + $fn + " " + $LN+ "          ";
                $ValidationInputRetun= "Name provided by User Input is: " + $FNameTextBox.Text + " " + $LNameTextBox.Text + "            ";
                $OtherDataReturn= "Other Data: " + $RITMTextBox.Text + " " + $Date +" "+ $Description;
                                

                #############

            if ($fn -eq $FNameTextBox.Text.Trim() -and $LN -eq $LNameTextBox.Text.Trim())
                    {
                        if($user.distinguishedname -notlike '*End-dated Users*')
                            {
                                $reMessage.Text = $ValidationADRetun + $Vtrue;
                                $validationLabel.Text = $true;
                            }
                        else 
                            {
                                $reMessage.Text = "User has alread been terminated.";
                                $validationLabel.Text = $false;
                            }
                    
                    }
                elseIf ($fn -ne $FNameTextBox.Text.Trim() -or $LN -ne $LNameTextBox.Text.Trim())
                    {
                        $reMessage.Text = $ValidationADRetun + "  Does not Match  " + $ValidationInputRetun + "   "+ $Vfalse;
                        $validationLabel.Text = $false;
                    }
            
            }
        
            else
                {
                    $reMessage.Text ="An appropriate ticket number is required";
                    $validationLabel.Text = $false;
                } 
        }
        )

#go button

$GoButton.Add_Click(
    {
       if ( $validationLabel.Text -eq $true )
            {
                #vairable apparently the variable must be inside the for loop 
                ##############
                $deadUser = $EnumberTextBox.Text.Trim();
                
                #prod enviroment
                #$endDateOU = "OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au"; 
                
                #test enviroment
                $endDateOU = "OU=End-dated Users,OU=Corporate,DC=MatsLab,DC=com";# test enviromet
                
                #gets ritm number
                $RITM2 = $RITMTextBox.Text;

                #creates description
                $Description2= ("Disabled on: " + $Date + " for " + $RITM2);
                
                #string builder for log content
                $LogString = $deadUser + " " + $Description2;
                #file path using the request number as the name of the file
                $path =  '.\Desktop\Logs\'+$RITM2+'.csv';
                
                
                #locates all security groups assigned to user
                $securityGroups = Get-ADPrincipalGroupMembership $deadUser; 
                $dlGroups = $securityGroups | ? { ($_.name -like '*DL*') };
                $365Licenses = $securityGroups | ? { ($_.name -like '*365*') };
                $project = $securityGroups | ? { ($_.name -like '*project*') };
                $v6 = $securityGroups | ? { ($_.name -like '*v6*') };
                $Epics = $securityGroups | ? { ($_.name -like '*Epics*') };
                              
                ##############
                
                #Ad change task
                ##########################
                Disable-ADAccount -Identity $deadUser;#tested works
                Get-ADUser -Identity $deadUser | Move-ADObject -TargetPath $endDateOU; #tested works
                Set-ADUser -Identity $deadUser -Description null; #tested
                Set-ADUser -Identity $deadUser -Description $Description2; #tested
                Set-ADUser $deadUser -replace @{msExchHideFromAddressLists=$true} #tested

                $dlGroups | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false}   # tested
                $365Licenses | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false} # tested
                $project | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false}  # tested
                $v6 | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false} #not tested
                $Epics | foreach-object {Remove-ADGroupMember -Identity $_ -Members $deadUser -Confirm:$false} #not tested
                
                #generates a log at the designated file path
                $LogString | Out-File $path;
                #######################################
                
                #return confirmation of work msg
                $reMessage.Text = $responsePositive;
                
                #cleanup to turn off the validation post work
                $validationLabel.Text = $false;
                $EnumberTextBox.Text = "";
                $FNameTextBox.Text = "";
                $LNameTextBox.Text = "";
                $RITMTextBox.Text = "";
                $validationLabel.Text = $false; 
                                              
            }
        ElseIf ( $validationLabel.Text -ne $true )
            {
                #error returned if the validation is not true
                $reMessage.Text = $responseNegative;
            }
       
    }
)


<#
#Email convert button coppied from tested external moduel
$EmailButton.Add_Click(
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
                        $TerminatingEmployyBool= 0        
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
#>




#############################################################

$main_form.ShowDialog()

<#
NOTES
#########################################



#>