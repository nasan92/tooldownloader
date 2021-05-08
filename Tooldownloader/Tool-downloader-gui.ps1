#Define all the Links from where it should be possible to downlaod tools
$Links = @(
  ("https://download.sysinternals.com/files/CPUSTRES.zip"),
  ("https://prdownloads.sourceforge.net/windirstat/windirstat1_1_2_setup.exe"),
  ("https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/paping/paping_1.5.5_x86_windows.zip"),
  ("https://download.sysinternals.com/files/Testlimit.zip") 
  #"https://download.sysinternals.com/files/SysinternalsSuite.zip"
)

#Define your local ToolsPath
$ToolsPath = "C:\Tools"

# Add Form Types
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Add Form For Toolsinput with Size and Text
$form = New-Object System.Windows.Forms.Form
$form.Width = 400
$form.Height = 200
$form.Text = "Download your favourite IT tools"

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,30)
$label.Text = 'Please enter the Location for the tools, default is C:\Tools'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,60)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$addButton = New-Object System.Windows.Forms.Button
$addButton.Location = New-Object System.Drawing.Point(270,60)
$addButton.Size = New-Object System.Drawing.Size(75,23)
$addButton.Text = 'OK'
$addButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
#$window.AcceptButton = $addButton
$form.Controls.Add($addButton)

[void]$form.ShowDialog()

if (-not ([string])::IsNullOrEmpty($textBox.Text)){
  $ToolsPath = $textBox.Text
    $ToolsPath
}

#Add Window with Size and Text (Will contain checkboxes)
$window = New-Object System.Windows.Forms.Form
$window.Width = 800
$window.Height = 800
$window.Text = "Download your favourite IT tools"

#function - creates Tools folder if it doesn't exist already
function create_T_folder{
  If(!(test-path $ToolsPath))
{
  New-Item -ItemType Directory -Force -Path $ToolsPath
}
}

# function to add Path to environment Variable Path
function Add-MrEnvPath {

  [CmdletBinding(SupportsShouldProcess)]
  param (
      [Parameter(Mandatory,
                 ValueFromPipeline,
                 ValueFromPipelineByPropertyName)]
      [string[]]$pathToAdd
  )

  BEGIN{
      $path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  }

  PROCESS {
      $path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
          if ($path -like "*$pathToAdd*" ){
              Write-Host "scho dinne, mache nüt"
              Write-Verbose -Message "$path already in there"
          
          }else {
              Write-Host "no nid dinn, duene ifüege"
              Write-Verbose -Message "$path will be added"
              $newpath = $path + $pathToAdd
              [Environment]::SetEnvironmentVariable("Path", $newpath, 'Machine')
          }
      
  }

}


# Prepare groupbox - checkbox items will be added to the groupbox later on
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Point(10, 20)
$groupBox.Name = 'groupBox'
#$groupBox.Size = $groupBoxSize #New-Object System.Drawing.Size (400, 144)
$groupBox.Text = 'Select your tools'

# Define checkbox size? 
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 200
$System_Drawing_Size.Height = 20


# Keep track of number of checkboxes
$CheckBoxCounter = 1
# Array for checkboxes
$checkboxarray = @()

# foreach item in the links array, create a checkbox and change the location 
foreach ($li in $links){
  
  # Create checkbox with Name counted up for each item and, text Leaf Name of the Path = Filename + extension
  $checkbox = New-Object System.Windows.Forms.CheckBox
  $checkbox.Name = "checkbox$CheckBoxCounter"
  $checkbox.Text = Split-Path -Path $li -Leaf
  $checkbox.size = $System_Drawing_Size

  # groupbox size - extend height for each additional checkbox
  $groupBoxSize = New-Object System.Drawing.Size
  $groupBoxSize.Width = 400
  $groupBoxSize.Height = 100 + (($CheckBoxCounter - 1) * 31)
  $groupBox.Size = $groupBoxSize

   # Define location for each checkbox - use counter to move Y Point dynamically
   $System_Drawing_Point = New-Object System.Drawing.Point
   $System_Drawing_Point.X = 8
   # Make sure to vertically space them dynamically, counter comes in handy
   $System_Drawing_Point.Y = 32 + (($CheckBoxCounter - 1) * 31)
   $CheckBox.Location = $System_Drawing_Point
   
   #$checkbox.Location = New-Object System.Drawing.Point(8, 32)

  # Adds groupbox to window
  $window.Controls.Add($groupBox)
  $groupBox.Controls.AddRange($checkbox)

  #Extend array for every checkbox item
  $checkboxarray += $checkbox

  # increment our counter
  $CheckBoxCounter++
  
} 

#$checkboxarray
#$CheckBoxCounter


# Create OK Windows Button -> Point Y dynamically
$windowButton = New-Object System.Windows.Forms.Button
$windowButton_Point = New-Object System.Drawing.Point
$windowButton_Point.X = 10
$windowButton_Point.Y = 150 + (($CheckBoxCounter - 1) * 31)
#$windowButton.Location = New-Object System.Drawing.Point(10,170)
$windowButton.Location = $windowButton_Point
$windowButton.Text = "OK"
$createfolder

$windowButton.Add_Click({


# Foreach object in the checkboxarry create Tools folder if it doesn't exist + download file + extract zips + remove zips 
foreach ($o in @($checkboxarray)){

    if ($o.Checked){
    #call function to create Tools folder if it doesn't exist
    create_T_folder 
    
    #write out selected options
    $option = $o.Text

      foreach ($l in $links){
        $leafname = Split-Path -Path $l -Leaf
        
        # Compares the links array with the checkboxarray - for all equal filenames, download file
        if ($leafname -eq $option){
          Write-host "Download $leafname laeuft"
          Write-host "Folgender Downloadlink wird verwendet: $l"
          Invoke-WebRequest -Uri $l -OutFile "$($ToolsPath)\$leafname" 
          
          #get all zipfiles in the ToolsPath
          $zipfiles = Get-ChildItem -recurse ($ToolsPath) -File -Include *.zip
          
          #Extract all ZIP Files and delete them after extraction
          foreach ($zip in $zipfiles){
            $zip.name
           # Expand-Archive -Path "$($ToolsPath)\$($zip)" -DestinationPath $ToolsPath
           $filenameonly = [System.IO.Path]::GetFileNameWithoutExtension($zip.name)#Split-Path -Path $link -Le
           $filenameonly
           Write-host "Zip wird entpackt $zip"
           Expand-Archive -Path $zip -DestinationPath "$($ToolsPath)\$filenameonly" -Force
           Write-host "Zip $zip wird geloescht"
           Remove-Item -Path $zip 
        } 
        }
      }
      #write-host $option

    $window.Dispose()

    }

  }
  write-host  "Downloads abgeschlossen" 
  # Query all Folders in the Toolspath
  $foldersToAddPath = (Get-ChildItem -Directory -Path $ToolsPath).FullName 
  Write-Host "Folgende Pfade werden der Systemvariable hinzugefügt $foldersToAddPath"
  # Call the Add-MrEnvPath function to add the tools folder paths to the environment variable path
  foreach($f in $foldersToAddPath){
    Add-MrEnvPath -pathToAdd ";$f" -WhatIf
    Write-Host "add ;$f"
  }
}


)

$window.Controls.Add($windowButton)

[void]$window.ShowDialog()


