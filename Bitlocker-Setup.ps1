param (
    [string]$RecoveryKeyPath = "C:\BitLocker-Key.txt" # Default file path for the recovery key
)

# Ensure the script is running as an administrator
function Check-Admin {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    $AdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $Principal.IsInRole($AdminRole)) {
        Write-Host "This script requires administrative privileges. Please run as administrator!" -ForegroundColor Red
        exit
    }
}

# Configure Group Policy settings for BitLocker pre-boot authentication
function Set-Registry {
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"

    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Enforce TPM + PIN authentication
    Set-ItemProperty -Path $RegPath -Name "UseTPMPIN" -Value 1 -Type DWord
    Set-ItemProperty -Path $RegPath -Name "UseAdvancedStartup" -Value 1 -Type DWord
    Set-ItemProperty -Path $RegPath -Name "EnablePrebootInputProtectorsOnSlates" -Value 1 -Type DWord

    Write-Host "Configured Group Policy for BitLocker pre-boot authentication." -ForegroundColor Green
}

# Enable BitLocker with TPM + PIN and XTS-AES 256-bit encryption
function Enable-BitLockerSecurely {
    $BitLockerStatus = Get-BitLockerVolume -MountPoint "C:"

    if ($BitLockerStatus -eq $null -or $BitLockerStatus.ProtectionStatus -ne 1) {
        Write-Host "Enabling BitLocker with TPM + PIN and XTS-AES 256-bit encryption..." -ForegroundColor Yellow
        
        # Prompt user for pre-boot PIN
        $BitLockerPin = Read-Host "Enter a numeric PIN (4-20 digits) for BitLocker" -AsSecureString

        # Enable BitLocker with TPM + PIN
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -Pin $BitLockerPin -TPMandPinProtector
        
        # Add a recovery key protector
        Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

        Write-Host "BitLocker encryption has started." -ForegroundColor Green
    } else {
        Write-Host "BitLocker is already enabled on C:." -ForegroundColor Cyan
    }
}

# Retrieve and store the BitLocker Recovery Key and KeyProtectorID
function Store-RecoveryKey {
    Write-Host "Retrieving BitLocker Recovery Key..." -ForegroundColor Cyan
    
    $RecoveryProtector = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }
    
    if ($RecoveryProtector) {
        $RecoveryKey = $RecoveryProtector.RecoveryPassword
        $KeyProtectorID = $RecoveryProtector.KeyProtectorId

        # Save Recovery Key and KeyProtectorID to the specified file
        "==== BitLocker Recovery Information ====" | Out-File -FilePath $RecoveryKeyPath -Force
        "Date: $(Get-Date)" | Out-File -FilePath $RecoveryKeyPath -Append
        "Recovery Key: $RecoveryKey" | Out-File -FilePath $RecoveryKeyPath -Append
        "KeyProtectorID: $KeyProtectorID" | Out-File -FilePath $RecoveryKeyPath -Append
        "=========================================" | Out-File -FilePath $RecoveryKeyPath -Append

        Write-Host "BitLocker recovery details saved at: $RecoveryKeyPath" -ForegroundColor Green
    } else {
        Write-Host "Failed to retrieve BitLocker Recovery Key!" -ForegroundColor Red
    }
}

# Main Execution
Check-Admin
Set-Registry
Enable-BitLockerSecurely
Store-RecoveryKey

Write-Host "BitLocker with pre-boot PIN has been successfully configured!" -ForegroundColor Green
Write-Host "Please restart your computer for changes to take effect." -ForegroundColor Cyan