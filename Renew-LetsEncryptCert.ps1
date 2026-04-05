<#
.SYNOPSIS
    Script to renew a LetsEncrypt cert on a Windows Server.

.DESCRIPTION
    Renew-LetsEncrypt automates the process of renewing a LetsEncrypt certificate 
    on a Windows Server. Configured for Cloudflare DNS validation, it uses the Posh-ACME 
    module to handle the certificate.

.PARAMETER CFemail
    The email address associated with your Cloudflare account. 
    This is used for notifications.

.PARAMETER hostname
    The hostname for which you want to renew the certificate. 
    This should match the DNS record you have set up in Cloudflare.

.PARAMETER pArgs
    A hash table containing the API token for Cloudflare. 
    This will prompt you to enter your API token securely.
   
.NOTES
    Author: Tim Sullivan
    Version: 1.0
    Contact: tsull360@outlook.com
    Date: 05/04/2026
    Name: Renew-LetsEncryptCert.ps1

    CHANGE LOG
    Version 1.0: Initial Release

.EXAMPLE
    .\Renew-LetsEncryptCert.ps1 -CFemail foo@mail.com -hostname example.com -pargs
#>


Param (
    # you need to supply a email later the first time you create a certificate for a domain, i just always do it with a variable
    $CFemail,

    # supply the hostname that matches the record you created at cloudflare
    $hostname,

    # supply your API token created above as a secure string within the $pArgs hash table. This will have the effect of prompting you to type or paste your token into the screen.
    $pArgs = @{
        CFToken = (Read-Host 'API Token' -AsSecureString)
    }
)

# Install the Posh-ACME module if it is not already installed
function Install-ModuleIfMissing {
    param ([string]$ModuleName, [string]$Scope = 'CurrentUser')
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Install-Module $ModuleName -Scope $Scope -Force
    }
}

Install-ModuleIfMissing -ModuleName 'Posh-ACME'

#this string will create the certificate and install it automatically into the Windows certificates store
New-PACertificate $hostname -Plugin Cloudflare -PluginArgs $pArgs -Install -AcceptTOS -Contact $CFemail -Force