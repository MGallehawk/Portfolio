
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
####################################################################################################################################################
Version 5
scope:
- Address issue of user able to change data post valadation possible error
- move the end date button so it is not hit when targeting the clear button reducing user error potential.

changes:
- added a read only lock for input fields that is active when validation is true.
- added an read only = false to the end of the go function and the clear function
- moved return msg box up for asthetics
- moved the end dating buttong to the bottom away from the validate and clear button

- test within test enviroment have been successfull 
- prepping documentation and submitting for review for Prod release


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
$main_form.Text ='User Termination Application V5'
$main_form.Width = 500
$main_form.Height = 370
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
$ReturnMessageLabel.Location  = New-Object System.Drawing.Point(0,100)
$ReturnMessageLabel.AutoSize = $true
$main_form.Controls.Add($ReturnMessageLabel)


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
$reMessage.Location  = New-Object System.Drawing.Point(25,130)
$reMessage.Height =100;
$reMessage.Width =450;
$reMessage.ReadOnly= $true;
$reMessage.AutoSize = $false;
$reMessage.Multiline = $true;
$reMessage.AcceptsReturn = $true;
$main_form.Controls.Add($reMessage)


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

#go button
$GoButton = New-Object System.Windows.Forms.Button
$GoButton.Location = New-Object System.Drawing.Size(150,240)
$GoButton.Size = New-Object System.Drawing.Size(200,70)
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
        #UNlock the fields so as to prevent editing post positive validation
        #e-number capture box
        $EnumberTextBox.ReadOnly = $false;
        #First name  capture box
        $FNameTextBox.ReadOnly = $false;
        #Last name  capture box
        $LNameTextBox.ReadOnly = $false;
        #RITM  capture box
        $RITMTextBox.ReadOnly = $false;
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

                                #lock the fields so as to prevent editing post positive validation
                                #e-number capture box
                                $EnumberTextBox.ReadOnly = $true;
                                #First name  capture box
                                $FNameTextBox.ReadOnly = $true;
                                #Last name  capture box
                                $LNameTextBox.ReadOnly = $true;
                                #RITM  capture box
                                $RITMTextBox.ReadOnly = $true;

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
                #UNlock the fields so as to prevent editing post positive validation
                #e-number capture box
                $EnumberTextBox.ReadOnly = $false;
                #First name  capture box
                $FNameTextBox.ReadOnly = $false;
                #Last name  capture box
                $LNameTextBox.ReadOnly = $false;
                #RITM  capture box
                $RITMTextBox.ReadOnly = $false;
                                              
            }
        ElseIf ( $validationLabel.Text -ne $true )
            {
                #error returned if the validation is not true
                $reMessage.Text = $responseNegative;
            }
       
    }
)




#############################################################

$main_form.ShowDialog()

<#
NOTES
#########################################



#>