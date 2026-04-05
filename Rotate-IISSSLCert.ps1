<#
.SYNOPSIS
    Script to rotate an SSL certificate in IIS on a Windows Server.

.DESCRIPTION
    Rotate-IISSSLCert automates the process of rotating an SSL certificate in IIS 
    on a Windows Server. It updates the certificate for all IIS bindings that use the old certificate.

.PARAMETER OldThumbprint
    The thumbprint of the old SSL certificate to be replaced.

.PARAMETER NewThumbprint
    The thumbprint of the new SSL certificate to be installed.


.NOTES
    Author: Tim Sullivan
    Version: 1.0
    Contact: tsull360@outlook.com
    Date: 05/04/2026
    Name: Rotate-IISSSLCert.ps1

    CHANGE LOG
    Version 1.0: Initial Release

.EXAMPLE
    .\Rotate-IISSSLCert.ps1 -OldThumbprint "ABC123..." -NewThumbprint "DEF456..."
#>

# Needed parameters for this script.
Param(
    # Cert thumbprint to replace.
    $OldThumbprint = "",

    # New cert thumbprint to install.
    $NewThumbprint = ""
)

Get-WebBinding | Where-Object { $_.certificateHash -eq $OldThumbprint} | ForEach-Object {
    Write-Host "Replacing Cert For "  $_ 
    $_.RemoveSslCertificate()
    $_.AddSslCertificate($NewThumbprint, 'My')
}