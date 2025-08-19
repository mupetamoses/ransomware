<#
.SYNOPSIS
    Safe Ransomware Simulation targeting the root folder (enrs)
    - Includes countdown popup and fake ransom note
    - Targets all files recursively
    - Fully reversible
#>

param(
    [switch]$LabMode,
    [switch]$Restore
)

# --- Safety check ---
if (-not $LabMode) { Write-Error "Use -LabMode to run"; exit 1 }

# --- Setup paths ---
$Target = Split-Path -Parent $MyInvocation.MyCommand.Definition  # Root folder (enrs)
$BackupDir = Join-Path $Target ".fake_ransom_backup"
$LockExt = ".locked"
$NoteFile = "READ_ME_FAKE_RANSOM.txt"

# --- Create dummy files if none exist ---
function Make-DummyFiles {
    $existing = Get-ChildItem -Path $Target -Recurse -File
    if ($existing.Count -eq 0) {
        Set-Content (Join-Path $Target "demo1.txt") "Demo text file."
        Set-Content (Join-Path $Target "demo2.docx") "Demo document content."
        Set-Content (Join-Path $Target "demo3.html") "<html>Fake HTML file</html>"
        Set-Content (Join-Path $Target "demo4.php") "<?php echo 'Fake PHP file'; ?>"
    }
}

# --- Write fake ransom note ---
function Write-Note {
    $note = @"
FAKE RANSOMWARE DEMO - TRAINING ONLY
---------------------------------------------------
Your files have been locked as part of a simulation.
All files are safe and fully recoverable.

Fake payment instructions (DO NOT PAY):
- Amount: $100,000 in BTC
- Deadline: 5 minutes

Backup folder: $BackupDir
To restore files, run:
    .\ransomware.ps1 -Restore -LabMode

Timestamp: $(Get-Date -Format o)
"@
    Set-Content -Path (Join-Path $Target $NoteFile) -Value $note -Encoding UTF8
}

# --- Show popup with countdown ---
function Show-Popup {
    Add-Type -AssemblyName PresentationFramework
    $window = New-Object Windows.Window
    $window.Title = "RANSOMWARE DEMO ALERT"
    $window.Width = 450
    $window.Height = 250
    $window.WindowStartupLocation = "CenterScreen"
    $window.Topmost = $true

    $stack = New-Object Windows.Controls.StackPanel
    $stack.Margin = 15

    $title = New-Object Windows.Controls.TextBlock
    $title.Text = "YOUR FILES HAVE BEEN LOCKED"
    $title.Foreground = "Red"
    $title.FontSize = 18
    $title.FontWeight = "Bold"
    $title.TextAlignment = "Center"
    $title.Margin = "0,0,0,10"
    $stack.Children.Add($title)

    $msg = New-Object Windows.Controls.TextBlock
    $msg.Text = "This is a TRAINING SIMULATION ONLY. Your files are safe and fully recoverable."
    $msg.Foreground = "Black"
    $msg.FontSize = 14
    $msg.TextAlignment = "Center"
    $msg.Margin = "0,0,0,10"
    $stack.Children.Add($msg)

    $countdownBlock = New-Object Windows.Controls.TextBlock
    $countdownBlock.Text = "Time left: 05:00"
    $countdownBlock.Foreground = "Blue"
    $countdownBlock.FontSize = 16
    $countdownBlock.FontWeight = "Bold"
    $countdownBlock.TextAlignment = "Center"
    $countdownBlock.Margin = "0,0,0,15"
    $stack.Children.Add($countdownBlock)

    $button = New-Object Windows.Controls.Button
    $button.Content = "OK"
    $button.Width = 80
    $button.HorizontalAlignment = "Center"
    $button.Margin = "0,10,0,0"

    $allowClose = $false
    $button.Add_Click({ $script:allowClose = $true; $window.Close() })
    $stack.Children.Add($button)

    $window.Add_Closing({ if (-not $script:allowClose) { $_.Cancel = $true } })
    $window.Content = $stack

    # Countdown timer
    $minutes = 5
    $seconds = 0
    $timer = New-Object Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(1)
    $timer.Add_Tick({
        if ($minutes -eq 0 -and $seconds -eq 0) {
            $countdownBlock.Text = "Deadline reached!"
            $timer.Stop()
        } else {
            if ($seconds -eq 0) { $minutes--; $seconds = 59 } else { $seconds-- }
            $countdownBlock.Text = ("Time left: {0:D2}:{1:D2}" -f $minutes, $seconds)
        }
    })
    $timer.Start()

    $window.ShowDialog() | Out-Null
}

# --- Simulate "encryption" ---
function Encrypt-Sim {
    Make-DummyFiles
    if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }
    Write-Note
    Show-Popup

    $files = Get-ChildItem -Path $Target -Recurse -File | Where-Object { $_.Name -ne $NoteFile -and $_.Extension -ne $LockExt }

    foreach ($f in $files) {
        $relPath = $f.FullName.Substring($Target.Length).TrimStart('\')
        $backupPath = Join-Path $BackupDir $relPath
        New-Item -ItemType Directory -Force -Path (Split-Path $backupPath) | Out-Null
        $lockPath = "$($f.FullName)$LockExt"

        Move-Item -Path $f.FullName -Destination $backupPath
        $data = [System.IO.File]::ReadAllBytes($backupPath)
        $encoded = [System.Convert]::ToBase64String($data)
        Set-Content -Path $lockPath -Value $encoded -Encoding ASCII
    }

    Write-Host "[OK] Encryption simulation complete."
}

# --- Restore files ---
function Restore-Sim {
    if (-not (Test-Path $BackupDir)) {
        Write-Warning "No backup folder found. Creating it for safety."
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        Write-Warning "Backup folder created but no files to restore."
        return
    }

    $files = Get-ChildItem -Path $BackupDir -Recurse -File
    foreach ($f in $files) {
        $relPath = $f.FullName.Substring($BackupDir.Length).TrimStart('\')
        $dest = Join-Path $Target $relPath
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Move-Item -Path $f.FullName -Destination $dest -Force
        $lockPath = "$dest$LockExt"
        if (Test-Path $lockPath) { Remove-Item $lockPath -Force }
    }

    if (Test-Path (Join-Path $Target $NoteFile)) { Remove-Item (Join-Path $Target $NoteFile) -Force }
    Remove-Item $BackupDir -Recurse -Force

    Write-Host "[OK] Restore complete."
}

# --- MAIN ---
if ($Restore) { Restore-Sim } else { Encrypt-Sim }
