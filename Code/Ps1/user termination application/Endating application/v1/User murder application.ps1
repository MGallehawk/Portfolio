####################################################################################################################################################

#script written by Mathew Gallehawk to reduce time and complexity of end dating users in the active directory enviroment
# value in less vulnerabilities due it incorectly terminated accounts
# value in less money waisted on liceses assigned to end dated users.
# value in less storage required for growing shared email accounts with dl groups
# value in reduced time required to perform task

####################################################################################################################################################

#GUI
####################################################################################################################################################


#page format and banner title
#############################################################
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='END DATE ALLL THE PEOPLE!!'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true
#############################################################

#Labels
#############################################################

#Enumber label
$EnumberLabel = New-Object System.Windows.Forms.Label
$EnumberLabel.Text = "User E-number"
$EnumberLabel.Location  = New-Object System.Drawing.Point(0,30)
$EnumberLabel.AutoSize = $true
$main_form.Controls.Add($EnumberLabel)

#First name label
$FirstNameLabel = New-Object System.Windows.Forms.Label
$FirstNameLabel.Text = "User First Name"
$FirstNameLabel.Location  = New-Object System.Drawing.Point(0,50)
$FirstNameLabel.AutoSize = $true
$main_form.Controls.Add($FirstNameLabel)

#last name label
$FirstLastLabel = New-Object System.Windows.Forms.Label
$FirstLastLabel.Text = "User Last Name"
$FirstLastLabel.Location  = New-Object System.Drawing.Point(0,70)
$FirstLastLabel.AutoSize = $true
$main_form.Controls.Add($FirstLastLabel)

#RITM label
$RECLabel = New-Object System.Windows.Forms.Label
$RECLabel.Text = "User Request number"
$RECLabel.Location  = New-Object System.Drawing.Point(0,90)
$RECLabel.AutoSize = $true
$main_form.Controls.Add($RECLabel)

#Validation label
$validationLabel = New-Object System.Windows.Forms.Label
$validationLabel.Location  = New-Object System.Drawing.Point(0,110)
$validationLabel.AutoSize = $true
$main_form.Controls.Add($validationLabel)

#Message return label
$ReturnMessageLabel = New-Object System.Windows.Forms.Label
$ReturnMessageLabel.Location  = New-Object System.Drawing.Point(0,130)
$ReturnMessageLabel.AutoSize = $true
$main_form.Controls.Add($ReturnMessageLabel)

#debug labels
#############################################################

#Debug1 message  return label First name from ad
$DebugnMessageLabel1 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel1.Location  = New-Object System.Drawing.Point(0,200)
$DebugnMessageLabel1.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel1)

#Debug2 message  return label last name from ad
$DebugnMessageLabel2 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel2.Location  = New-Object System.Drawing.Point(50,200)
$DebugnMessageLabel2.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel2)

#Debug3 message  return label First name provided
$DebugnMessageLabel3 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel3.Location  = New-Object System.Drawing.Point(0,220)
$DebugnMessageLabel3.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel3)

#Debug4 message  return label last name provided
$DebugnMessageLabel4 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel4.Location  = New-Object System.Drawing.Point(50,220)
$DebugnMessageLabel4.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel4)

#Debug5 message  return ritm NUMBER
$DebugnMessageLabel5 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel5.Location  = New-Object System.Drawing.Point(0,240)
$DebugnMessageLabel5.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel5)

#Debug6 message  return date
$DebugnMessageLabel6 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel6.Location  = New-Object System.Drawing.Point(0,260)
$DebugnMessageLabel6.AutoSize = $true
$main_form.Controls.Add($DebugnMessageLabel6)

#Debug7 message  description
$DebugnMessageLabel7 = New-Object System.Windows.Forms.Label
$DebugnMessageLabel7.Location  = New-Object System.Drawing.Point(0,280)
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

#############################################################

#buttons
#############################################################

#Validate button
$ValButton = New-Object System.Windows.Forms.Button
$ValButton.Location = New-Object System.Drawing.Size(400,45)
$ValButton.Size = New-Object System.Drawing.Size(120,23)
$ValButton.Text = "Check me"
$main_form.Controls.Add($ValButton)

#go button
$GoButton = New-Object System.Windows.Forms.Button
$GoButton.Location = New-Object System.Drawing.Size(400,90)
$GoButton.Size = New-Object System.Drawing.Size(120,23)
$GoButton.Text = "END THEM!!"
$main_form.Controls.Add($GoButton)

#clear button
$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Location = New-Object System.Drawing.Size(400,135)
$clearButton.Size = New-Object System.Drawing.Size(120,23)
$clearButton.Text = "wipe the board!!"
$main_form.Controls.Add($clearButton)
####################################################################################################################################################

#variables
#############################################################

$Vtrue= "Employee number matchs name";
$Vfalse= "Empoyee number does not match name or does not exist";
$responsePositive= "User has been end dated"
$responseNegative= "Validation required, please validate and try again"
$Date= Get-Date -Format "dd/MM/yyyy";
$endDateOU = "OU=End-dated Users,OU=Corporate,DC=aus,DC=gjames,DC=com,DC=au";

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
        $validationLabel.Text = $Vfalse; 
        $DebugnMessageLabel1.Text = "";
        $DebugnMessageLabel2.Text = "";   
        $DebugnMessageLabel3.Text = "";
        $DebugnMessageLabel4.Text = "";
        $DebugnMessageLabel5.Text = "";
        $DebugnMessageLabel6.Text = "";
        $DebugnMessageLabel7.Text = "";
    }      
)


#Validate button

$ValButton.Add_Click(
    {
        #validation logic
        $user =Get-adUser -Identity $EnumberTextBox.Text;
        $fn= $user.GivenName;
        $LN= $user.Surname;
        $RITM = $RITMTextBox.Text;
        $Description= ("Disabled on: " + $Date + " for " + $RITM);
        #debug 
        #############
        $DebugnMessageLabel1.Text = $fn;
        $DebugnMessageLabel2.Text = $LN;
        $DebugnMessageLabel3.Text = $FNameTextBox.Text;
        $DebugnMessageLabel4.Text = $LNameTextBox.Text;
        $DebugnMessageLabel5.Text = $RITMTextBox.Text;
        $DebugnMessageLabel6.Text = $Date;
        $DebugnMessageLabel7.Text = $Description;
        #############

       if ($fn -eq $FNameTextBox.Text -and $LN -eq $LNameTextBox.Text)
            {
               $validationLabel.Text = $Vtrue;
            }
        elseIf ($fn -ne $FNameTextBox.Text -or $LN -ne $LNameTextBox.Text)
            {
                   $validationLabel.Text = $Vfalse; 
            }
      
    }
)



#go button

$GoButton.Add_Click(
    {
       if ( $validationLabel.Text -eq $Vtrue )
            {
                #return confirmation of work msg
                $ReturnMessageLabel.Text = $responsePositive;
                #Change scripts will go here this part not tested as i need a non production enviroment

                <#
                $dls = get-adgroup -filter {name -like "DL -*"}
                $dls | foreach-object {$_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$True}
                
                
                
                Disable-ADAccount -Identity $user;
                Move-ADObject -Identity $user -TargetPath $endDateOU;
                Set-ADUser -Identity $user -Description $Description;
                Set-ADUser -Identity $user -property msExchHideFromAddressLists $true;
                
                #>
            }
        ElseIf ( $validationLabel.Text -ne $Vtrue )
            {
                #error returned if the validation is not true
                $ReturnMessageLabel.Text = $responseNegative;
            }
       
    }
)

#############################################################





$main_form.ShowDialog()