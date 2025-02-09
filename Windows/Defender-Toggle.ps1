# Ensure the script is running as an administrator
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$AdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $Principal.IsInRole($AdminRole)) {
    Write-Host "This script requires administrative privileges. Please run as administrator!" -ForegroundColor Red
    exit
}

# Function to Disable Windows Defender Real-Time Protection
function Disable-Defender {
    Write-Host "Disabling Windows Defender Real-Time Protection..." -ForegroundColor Yellow
    Set-MpPreference -DisableRealtimeMonitoring $true

    # Ensure Registry Path Exists
    if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Force | Out-Null
    }

    # Modify Registry for Persistence
    Write-Host "Modifying registry to prevent Defender from re-enabling..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord

    Write-Host "Windows Defender Real-Time Protection has been disabled!" -ForegroundColor Green
}

# Function to Enable Windows Defender Real-Time Protection
function Enable-Defender {
    Write-Host "Enabling Windows Defender Real-Time Protection..." -ForegroundColor Yellow
    Set-MpPreference -DisableRealtimeMonitoring $false

    # Remove Registry Modifications
    Write-Host "Restoring original registry settings..." -ForegroundColor Yellow
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -ErrorAction SilentlyContinue

    Write-Host "Windows Defender Real-Time Protection has been enabled!" -ForegroundColor Green
}

# User Selection
Write-Host "Select an option:" -ForegroundColor Cyan
Write-Host "1) Disable Windows Defender Real-Time Protection" -ForegroundColor White
Write-Host "2) Enable Windows Defender Real-Time Protection" -ForegroundColor White
$Choice = Read-Host "Enter choice (1 or 2)"

if ($Choice -eq "1") {
    Disable-Defender
} elseif ($Choice -eq "2") {
    Enable-Defender
} else {
    Write-Host "Invalid option. Please select 1 or 2." -ForegroundColor Red
}
