# QEMU-Converter.ps1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Path Configuration ---
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = $PWD.Path }
$qemuFolder = Join-Path $scriptDir "qemu-tools"
$qemuExe = Join-Path $qemuFolder "qemu-img.exe"
# QEMU-IMG Archive URL (Cloudbase x64)
$qemuUrl = "https://cloudbase.it/downloads/qemu-img-win-x64-2_3_0.zip"

# --- Main Window Creation ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "RAW to Dynamic VHDX Converter"
$form.Size = New-Object System.Drawing.Size(600, 350)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# --- QEMU Status Label and Button ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 20)
$lblStatus.Size = New-Object System.Drawing.Size(250, 20)
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblStatus)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Location = New-Object System.Drawing.Point(280, 15)
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
$txtInput.Size = New-Object System.Drawing.Size(450, 20)
$txtInput.ReadOnly = $true
$form.Controls.Add($txtInput)

$btnInput = New-Object System.Windows.Forms.Button
$btnInput.Location = New-Object System.Drawing.Point(480, 89)
$btnInput.Size = New-Object System.Drawing.Size(80, 22)
$btnInput.Text = "Browse..."
$form.Controls.Add($btnInput)

# --- Destination File Selection (VHDX) ---
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Location = New-Object System.Drawing.Point(20, 130)
$lblOutput.Text = "Destination File (VHDX):"
$lblOutput.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(20, 150)
$txtOutput.Size = New-Object System.Drawing.Size(450, 20)
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

$btnOutput = New-Object System.Windows.Forms.Button
$btnOutput.Location = New-Object System.Drawing.Point(480, 149)
$btnOutput.Size = New-Object System.Drawing.Size(80, 22)
$btnOutput.Text = "Browse..."
$form.Controls.Add($btnOutput)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 200)
$progressBar.Size = New-Object System.Drawing.Size(540, 30)
$form.Controls.Add($progressBar)

$lblProgress = New-Object System.Windows.Forms.Label
$lblProgress.Location = New-Object System.Drawing.Point(20, 235)
$lblProgress.Size = New-Object System.Drawing.Size(540, 20)
$lblProgress.Text = "Ready."
$form.Controls.Add($lblProgress)

# --- Convert Button ---
$btnConvert = New-Object System.Windows.Forms.Button
$btnConvert.Location = New-Object System.Drawing.Point(200, 260)
$btnConvert.Size = New-Object System.Drawing.Size(180, 40)
$btnConvert.Text = "Start Conversion"
$btnConvert.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnConvert.Enabled = $false
$form.Controls.Add($btnConvert)

# --- Interface Logic ---

function Update-QemuStatus {
    if (Test-Path $qemuExe) {
        $lblStatus.Text = "[OK] qemu-img found"
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

$btnDownload.Add_Click({
    $btnDownload.Enabled = $false
    $lblProgress.Text = "Downloading QEMU..."
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
        Update-QemuStatus
    }
})

$btnOutput.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "VHDX file (*.vhdx)|*.vhdx"
    $dialog.DefaultExt = "vhdx"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtOutput.Text = $dialog.FileName
        Update-QemuStatus
    }
})

$btnConvert.Add_Click({
    $btnConvert.Enabled = $false
    $btnInput.Enabled = $false
    $btnOutput.Enabled = $false
    $progressBar.Value = 0
    $lblProgress.Text = "Conversion in progress, please wait..."

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $qemuExe
    $process.StartInfo.Arguments = "convert -p -f raw -O vhdx -o subformat=dynamic `"$($txtInput.Text)`" `"$($txtOutput.Text)`""
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.CreateNoWindow = $true

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
    
    $progressBar.Value = 100
    $lblProgress.Text = "Conversion completed successfully!"
    $btnConvert.Enabled = $true
    $btnInput.Enabled = $true
    $btnOutput.Enabled = $true
})

# Initialization
Update-QemuStatus
$form.ShowDialog() | Out-Null