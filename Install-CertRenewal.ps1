#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs the Let's Encrypt certificate renewal scripts and creates a weekly scheduled task.

.DESCRIPTION
    Copies Renew-LetsEncryptCert.ps1 and Rotate-IISSSLCert.ps1 to a target directory,
    then registers a Windows Scheduled Task that runs Renew-LetsEncryptCert.ps1 weekly.

.PARAMETER InstallPath
    The directory where the scripts will be copied. Defaults to C:\Scripts\CertRenewal.

.PARAMETER TaskName
    The name of the scheduled task to create. Defaults to "LetsEncrypt-CertRenewal".

.PARAMETER TaskRunTime
    The time of day the task will run each week. Defaults to 3:00 AM.

.PARAMETER TaskDayOfWeek
    The day of the week the task runs. Defaults to Sunday.

.PARAMETER TaskUser
    The user account under which the scheduled task runs. Defaults to SYSTEM.

.EXAMPLE
    .\Install-CertRenewal.ps1

.EXAMPLE
    .\Install-CertRenewal.ps1 -InstallPath "D:\Automation\Certs" -TaskDayOfWeek Monday -TaskRunTime "02:00"

.NOTES
    Author: Tim Sullivan
    Must be run as Administrator.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$InstallPath = 'C:\Scripts\CertRenewal',

    [Parameter()]
    [string]$TaskName = 'LetsEncrypt-CertRenewal',

    [Parameter()]
    [string]$TaskRunTime = '03:00',

    [Parameter()]
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
    [string]$TaskDayOfWeek = 'Sunday',

    [Parameter()]
    [string]$TaskUser = 'SYSTEM'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceDir = $PSScriptRoot
$scripts   = @('Renew-LetsEncryptCert.ps1', 'Rotate-IISSSLCert.ps1')

# --- Copy scripts ---
if (-not (Test-Path -Path $InstallPath)) {
    if ($PSCmdlet.ShouldProcess($InstallPath, 'Create directory')) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "Created directory: $InstallPath"
    }
}

foreach ($script in $scripts) {
    $src  = Join-Path $sourceDir $script
    $dest = Join-Path $InstallPath $script

    if (-not (Test-Path -Path $src)) {
        Write-Error "Source script not found: $src"
    }

    if ($PSCmdlet.ShouldProcess($dest, 'Copy script')) {
        Copy-Item -Path $src -Destination $dest -Force
        Write-Host "Copied $script -> $dest"
    }
}

# --- Create scheduled task ---
$renewScript = Join-Path $InstallPath 'Renew-LetsEncryptCert.ps1'

$action  = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NonInteractive -NoProfile -ExecutionPolicy Bypass -File `"$renewScript`""

$trigger = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek $TaskDayOfWeek `
    -At $TaskRunTime

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

if ($PSCmdlet.ShouldProcess($TaskName, 'Register scheduled task')) {
    # Remove existing task with the same name if present
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed existing task: $TaskName"
    }

    Register-ScheduledTask `
        -TaskName  $TaskName `
        -Action    $action `
        -Trigger   $trigger `
        -Settings  $settings `
        -RunLevel  Highest `
        -User      $TaskUser `
        -Force | Out-Null

    Write-Host "Scheduled task '$TaskName' created successfully."
    Write-Host "  Script : $renewScript"
    Write-Host "  Schedule: Every $TaskDayOfWeek at $TaskRunTime"
    Write-Host "  Run as  : $TaskUser"
}
