Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='END DATE ALLL THE PEOPLE!!'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true

$EnumberLabel = New-Object System.Windows.Forms.Label
$EnumberLabel.Text = "User E-number"
$EnumberLabel.Location  = New-Object System.Drawing.Point(0,30)
$EnumberLabel.AutoSize = $true
$main_form.Controls.Add($EnumberLabel)

$EnumberTextBox = New-Object System.Windows.Forms.TextBox
$EnumberTextBox.Width = 100
#Foreach ($User in $Users)
#{
#$ComboBox.Items.Add($User.SamAccountName);
#}
$EnumberTextBox.Location  = New-Object System.Drawing.Point(150,30)
$main_form.Controls.Add($EnumberTextBox)



$FirstNameLabel = New-Object System.Windows.Forms.Label
$FirstNameLabel.Text = "User First Name"
$FirstNameLabel.Location  = New-Object System.Drawing.Point(0,50)
$FirstNameLabel.AutoSize = $true
$main_form.Controls.Add($FirstNameLabel)

$FirstLastLabel = New-Object System.Windows.Forms.Label
$FirstLastLabel.Text = "User Last Name"
$FirstLastLabel.Location  = New-Object System.Drawing.Point(0,70)
$FirstLastLabel.AutoSize = $true
$main_form.Controls.Add($FirstLastLabel)

$FirstRECLabel = New-Object System.Windows.Forms.Label
$FirstRECLabel.Text = "User Request number"
$FirstRECLabel.Location  = New-Object System.Drawing.Point(0,90)
$FirstRECLabel.AutoSize = $true
$main_form.Controls.Add($FirstRECLabel)



$Button = New-Object System.Windows.Forms.Button

$Button.Location = New-Object System.Drawing.Size(400,150)

$Button.Size = New-Object System.Drawing.Size(120,23)

$Button.Text = "END THEM!!"

$main_form.Controls.Add($Button)


$main_form.ShowDialog()