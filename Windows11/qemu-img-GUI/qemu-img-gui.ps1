# QEMU-Converter.ps1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Path Configuration ---
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = $PWD.Path }
$qemuFolder = Join-Path $scriptDir "qemu-tools"
$qemuExe = Join-Path $qemuFolder "qemu-img.exe"

# Updated URL to a recent QEMU v10.0.0 Windows x64 standalone build
$qemuUrl = "https://github.com/fdcastel/qemu-img-windows-x64/releases/download/v10.0.0/qemu-img-windows-x64-v10.0.0.zip"

# --- Main Window Creation ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "RAW to VHDX Converter"
$form.Size = New-Object System.Drawing.Size(650, 560)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# --- QEMU Status Label and Button ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 20)
$lblStatus.Size = New-Object System.Drawing.Size(320, 20)
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblStatus)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Location = New-Object System.Drawing.Point(350, 15)
$btnDownload.Size = New-Object System.Drawing.Size(150, 30)
$btnDownload.Text = "Download qemu-img"
$form.Controls.Add($btnDownload)

# --- Source File Selection (RAW) ---
$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Location = New-Object System.Drawing.Point(20, 70)
$lblInput.Text = "Source File (RAW / IMG / DD):"
$lblInput.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($lblInput)

$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Location = New-Object System.Drawing.Point(20, 90)
$txtInput.Size = New-Object System.Drawing.Size(500, 20)
$txtInput.ReadOnly = $true
$form.Controls.Add($txtInput)

$btnInput = New-Object System.Windows.Forms.Button
$btnInput.Location = New-Object System.Drawing.Point(530, 89)
$btnInput.Size = New-Object System.Drawing.Size(80, 22)
$btnInput.Text = "Browse..."
$form.Controls.Add($btnInput)

# --- Info Note (Clickable Link) ---
$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Location = New-Object System.Drawing.Point(20, 115)
$lblInfo.Text = "Note: .img files can be produced using"
$lblInfo.Size = New-Object System.Drawing.Size(225, 15)
$lblInfo.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($lblInfo)

$lnkInfo = New-Object System.Windows.Forms.LinkLabel
$lnkInfo.Location = New-Object System.Drawing.Point(245, 115)
$lnkInfo.Text = "https://win32diskimager.org/"
$lnkInfo.Size = New-Object System.Drawing.Size(250, 15)
$lnkInfo.Add_LinkClicked({
    [System.Diagnostics.Process]::Start("https://win32diskimager.org/") | Out-Null
})
$form.Controls.Add($lnkInfo)

# --- Output Folder Selection ---
$lblOutputDir = New-Object System.Windows.Forms.Label
$lblOutputDir.Location = New-Object System.Drawing.Point(20, 140)
$lblOutputDir.Text = "Output Folder (Optional, for batching):"
$lblOutputDir.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($lblOutputDir)

$txtOutputDir = New-Object System.Windows.Forms.TextBox
$txtOutputDir.Location = New-Object System.Drawing.Point(20, 160)
$txtOutputDir.Size = New-Object System.Drawing.Size(500, 20)
$txtOutputDir.ReadOnly = $true
$form.Controls.Add($txtOutputDir)

$btnOutputDir = New-Object System.Windows.Forms.Button
$btnOutputDir.Location = New-Object System.Drawing.Point(530, 159)
$btnOutputDir.Size = New-Object System.Drawing.Size(80, 22)
$btnOutputDir.Text = "Select..."
$form.Controls.Add($btnOutputDir)

# --- Destination File Selection (VHDX) ---
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Location = New-Object System.Drawing.Point(20, 200)
$lblOutput.Text = "Destination File (VHDX):"
$lblOutput.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(20, 220)
$txtOutput.Size = New-Object System.Drawing.Size(500, 20)
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

$btnOutput = New-Object System.Windows.Forms.Button
$btnOutput.Location = New-Object System.Drawing.Point(530, 219)
$btnOutput.Size = New-Object System.Drawing.Size(80, 22)
$btnOutput.Text = "Browse..."
$form.Controls.Add($btnOutput)

# --- Advanced Options ---
$lblSubformat = New-Object System.Windows.Forms.Label
$lblSubformat.Location = New-Object System.Drawing.Point(20, 260)
$lblSubformat.Text = "VHDX Format:"
$lblSubformat.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblSubformat)

$cmbSubformat = New-Object System.Windows.Forms.ComboBox
$cmbSubformat.Location = New-Object System.Drawing.Point(120, 257)
$cmbSubformat.Size = New-Object System.Drawing.Size(100, 20)
$cmbSubformat.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbSubformat.Items.Add("dynamic") | Out-Null
$cmbSubformat.Items.Add("fixed") | Out-Null
$cmbSubformat.SelectedIndex = 0
$form.Controls.Add($cmbSubformat)

$lblAdvanced = New-Object System.Windows.Forms.Label
$lblAdvanced.Location = New-Object System.Drawing.Point(240, 260)
$lblAdvanced.Text = "Advanced Arguments:"
$lblAdvanced.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($lblAdvanced)

$txtAdvanced = New-Object System.Windows.Forms.TextBox
$txtAdvanced.Location = New-Object System.Drawing.Point(360, 257)
$txtAdvanced.Size = New-Object System.Drawing.Size(250, 20)
$txtAdvanced.Text = "-W -m 16"
$form.Controls.Add($txtAdvanced)

# --- Command Preview ---
$lblCommand = New-Object System.Windows.Forms.Label
$lblCommand.Location = New-Object System.Drawing.Point(20, 300)
$lblCommand.Text = "Command Preview:"
$lblCommand.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($lblCommand)

$txtCommandPreview = New-Object System.Windows.Forms.TextBox
$txtCommandPreview.Location = New-Object System.Drawing.Point(20, 320)
$txtCommandPreview.Size = New-Object System.Drawing.Size(590, 20)
$txtCommandPreview.ReadOnly = $true
$txtCommandPreview.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($txtCommandPreview)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 360)
$progressBar.Size = New-Object System.Drawing.Size(590, 30)
$form.Controls.Add($progressBar)

$lblProgress = New-Object System.Windows.Forms.Label
$lblProgress.Location = New-Object System.Drawing.Point(20, 395)
$lblProgress.Size = New-Object System.Drawing.Size(590, 20)
$lblProgress.Text = "Ready."
$form.Controls.Add($lblProgress)

# --- Convert Button ---
$btnConvert = New-Object System.Windows.Forms.Button
$btnConvert.Location = New-Object System.Drawing.Point(235, 430)
$btnConvert.Size = New-Object System.Drawing.Size(180, 40)
$btnConvert.Text = "Start Conversion"
$btnConvert.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnConvert.Enabled = $false
$form.Controls.Add($btnConvert)

# --- Interface Logic ---

function Update-CommandPreview {
    $advArgs = $txtAdvanced.Text.Trim()
    $subFormat = $cmbSubformat.SelectedItem.ToString()
    $inPath = if ($txtInput.Text) { $txtInput.Text } else { "<source_file>" }
    $outPath = if ($txtOutput.Text) { $txtOutput.Text } else { "<destination_file>" }
    
    if ($advArgs) {
        $txtCommandPreview.Text = "qemu-img.exe convert -p $advArgs -f raw -O vhdx -o subformat=$subFormat `"$inPath`" `"$outPath`""
    } else {
        $txtCommandPreview.Text = "qemu-img.exe convert -p -f raw -O vhdx -o subformat=$subFormat `"$inPath`" `"$outPath`""
    }
}

function Update-QemuStatus {
    if (Test-Path $qemuExe) {
        $lblStatus.Text = "[OK] qemu-img found in qemu-tools folder"
        $lblStatus.ForeColor = [System.Drawing.Color]::Green
        $btnDownload.Enabled = $false
        if ($txtInput.Text -ne "" -and $txtOutput.Text -ne "") { $btnConvert.Enabled = $true }
    } else {
        $lblStatus.Text = "[X] qemu-img missing"
        $lblStatus.ForeColor = [System.Drawing.Color]::Red
        $btnDownload.Enabled = $true
        $btnConvert.Enabled = $false
    }
}

# Attach events for live command preview update
$txtInput.Add_TextChanged({ Update-CommandPreview })
$txtOutput.Add_TextChanged({ Update-CommandPreview })
$txtAdvanced.Add_TextChanged({ Update-CommandPreview })
$cmbSubformat.Add_SelectedIndexChanged({ Update-CommandPreview })

$btnDownload.Add_Click({
    $btnDownload.Enabled = $false
    $lblProgress.Text = "Downloading modern QEMU build..."
    [System.Windows.Forms.Application]::DoEvents()

    try {
        if (-not (Test-Path $qemuFolder)) { New-Item -ItemType Directory -Path $qemuFolder | Out-Null }
        $zipPath = Join-Path $qemuFolder "qemu.zip"
        Invoke-WebRequest -Uri $qemuUrl -OutFile $zipPath
        
        $lblProgress.Text = "Extracting files..."
        [System.Windows.Forms.Application]::DoEvents()
        Expand-Archive -Path $zipPath -DestinationPath $qemuFolder -Force
        Remove-Item $zipPath -Force
        
        $lblProgress.Text = "Download complete."
    } catch {
        $lblProgress.Text = "Download error: $_"
    }
    Update-QemuStatus
})

$btnInput.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "RAW files (*.raw;*.img;*.dd)|*.raw;*.img;*.dd|All files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtInput.Text = $dialog.FileName
        
        # Auto-fill output path
        $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($dialog.FileName)
        if ($txtOutputDir.Text -ne "") {
            # Use selected output folder
            $txtOutput.Text = Join-Path $txtOutputDir.Text "$fileNameWithoutExt.vhdx"
        } else {
            # Use source file folder
            $txtOutput.Text = [System.IO.Path]::ChangeExtension($dialog.FileName, ".vhdx")
        }
        Update-QemuStatus
    }
})

$btnOutputDir.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select Output Folder for converted files"
    $dialog.ShowNewFolderButton = $true
    
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtOutputDir.Text = $dialog.SelectedPath
        
        # Update destination path dynamically if source is already selected
        if ($txtInput.Text -ne "") {
            $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($txtInput.Text)
            $txtOutput.Text = Join-Path $txtOutputDir.Text "$fileNameWithoutExt.vhdx"
            Update-QemuStatus
        }
    }
})

$btnOutput.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "VHDX file (*.vhdx)|*.vhdx"
    $dialog.DefaultExt = "vhdx"
    
    # Start in the same directory if input is already selected
    if ($txtOutput.Text -ne "") {
        $dialog.InitialDirectory = [System.IO.Path]::GetDirectoryName($txtOutput.Text)
        $dialog.FileName = [System.IO.Path]::GetFileName($txtOutput.Text)
    }

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtOutput.Text = $dialog.FileName
        Update-QemuStatus
    }
})

$btnConvert.Add_Click({
    $btnConvert.Enabled = $false
    $btnInput.Enabled = $false
    $btnOutputDir.Enabled = $false
    $btnOutput.Enabled = $false
    $txtAdvanced.Enabled = $false
    $cmbSubformat.Enabled = $false
    $progressBar.Value = 0
    $lblProgress.Text = "Calculating file size..."
    [System.Windows.Forms.Application]::DoEvents()

    # Get source file size in Megabytes for speed calculation
    try {
        $sourceSizeMB = (Get-Item $txtInput.Text).Length / 1MB
    } catch {
        $sourceSizeMB = 0
    }

    $advArgs = $txtAdvanced.Text.Trim()
    $subFormat = $cmbSubformat.SelectedItem.ToString()

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $qemuExe
    
    if ($advArgs) {
        $process.StartInfo.Arguments = "convert -p $advArgs -f raw -O vhdx -o subformat=$subFormat `"$($txtInput.Text)`" `"$($txtOutput.Text)`""
    } else {
        $process.StartInfo.Arguments = "convert -p -f raw -O vhdx -o subformat=$subFormat `"$($txtInput.Text)`" `"$($txtOutput.Text)`""
    }
    
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.CreateNoWindow = $true

    # Start performance timer
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $process.Start() | Out-Null

    $buffer = ""
    while (-not $process.HasExited) {
        $char = $process.StandardOutput.Read()
        while ($char -ne -1) {
            $c = [char]$char
            if ($c -eq "`r" -or $c -eq "`n") {
                if ($buffer -match '\((\d+\.\d+)/100%\)') {
                    $val = [double]::Parse($matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
                    $progressBar.Value = [math]::Min(100, [math]::Max(0, [math]::Floor($val)))
                    
                    # Calculate real-time estimated speed
                    $elapsedSec = $stopwatch.Elapsed.TotalSeconds
                    if ($elapsedSec -gt 0 -and $sourceSizeMB -gt 0) {
                        $convertedMB = $sourceSizeMB * ($val / 100)
                        $speedMBs = [math]::Round($convertedMB / $elapsedSec, 1)
                        $lblProgress.Text = "Converting... $val% (Estimated Speed: $speedMBs MB/s)"
                    } else {
                        $lblProgress.Text = "Converting... $val%"
                    }
                }
                $buffer = ""
            } else {
                $buffer += $c
            }
            [System.Windows.Forms.Application]::DoEvents()
            
            if ($process.StandardOutput.Peek() -ne -1) {
                $char = $process.StandardOutput.Read()
            } else {
                break
            }
        }
        Start-Sleep -Milliseconds 50
    }
    
    $stopwatch.Stop()
    
    # Final stats calculation
    $totalTimeStr = "{0:hh\:mm\:ss}" -f $stopwatch.Elapsed
    if ($stopwatch.Elapsed.TotalSeconds -gt 0 -and $sourceSizeMB -gt 0) {
        $avgSpeed = [math]::Round($sourceSizeMB / $stopwatch.Elapsed.TotalSeconds, 1)
        $lblProgress.Text = "Completed successfully in $totalTimeStr (Estimated Average Speed: $avgSpeed MB/s)!"
    } else {
        $lblProgress.Text = "Conversion completed successfully in $totalTimeStr!"
    }
    
    $progressBar.Value = 100
    $btnConvert.Enabled = $true
    $btnInput.Enabled = $true
    $btnOutputDir.Enabled = $true
    $btnOutput.Enabled = $true
    $txtAdvanced.Enabled = $true
    $cmbSubformat.Enabled = $true
})

# Initialization
Update-QemuStatus
Update-CommandPreview
$form.ShowDialog() | Out-Null