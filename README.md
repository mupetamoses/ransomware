# ransomware
SThis is a training-only ransomware simulation designed to demonstrate how ransomware operates without putting any real files at risk. It:

Targets the root folder and all subfolders where the script is placed.

Simulates encryption for all files including .php, .html, .txt, .docx, etc.

Creates .locked placeholder files and moves originals to a backup folder.

Displays a popup with a countdown timer to simulate a ransom deadline.

Creates a fake ransom note (READ_ME_FAKE_RANSOM.txt).

Fully reversible: files can be restored safely with the -Restore -LabMode option.

Safe for training: no real encryption occurs; all original files are stored and recoverable.

Features

Targets all files in folder and subfolders.

Simulates ransom note and payment instructions (training only).

Popup countdown timer mimics real ransomware pressure.

Backup and restore functionality ensures all files can be safely recovered.

Dummy files created automatically if folder is empty (for testing).

Safe for educational environments.

Requirements

Windows OS

PowerShell (v5+ recommended)

Execution policy allowing script run:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Usage
1. Run the simulation (encrypt files)
cd "C:\Path\To\enrs"
.\ransomware.ps1 -LabMode


Moves files to .fake_ransom_backup

Replaces files with .locked placeholders

Shows popup with countdown timer

Creates READ_ME_FAKE_RANSOM.txt

2. Restore all files
.\ransomware.ps1 -LabMode -Restore


Moves all original files back from backup folder

Removes .locked placeholders and ransom note

Deletes backup folder after restore

3. Notes

Do not run on production or important data; use test folders only.

Script is intended for educational and training purposes.

Dummy files are automatically created if folder is empty.

Example Folder Structure After Encryption
enrs\
    demo1.txt.locked
    demo2.docx.locked
    demo3.html.locked
    demo4.php.locked
    READ_ME_FAKE_RANSOM.txt
    .fake_ransom_backup\
        demo1.txt
        demo2.docx
        demo3.html
        demo4.php

License

Free for educational and training purposes only.

Do not distribute for malicious use.

If you want, I can also create a ready-to-use README.md file you can drop directly into the folder with formatted Markdown, including commands, warnings, and examples.
