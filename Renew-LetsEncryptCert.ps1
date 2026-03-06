# you need to supply a email later the first time you create a certificate for a domain, i just always do it with a variable
$CFemail = ""

# supply the hostname that matches the record you created at cloudflare
$hostname = ""

# supply your API token created above as a secure string within the $pArgs hash table. This will have the effect of prompting you to type or paste your token into the screen.
$pArgs = @{
    CFToken = (Read-Host 'API Token' -AsSecureString)
}

#this string will create the certificate and install it automatically into the Windows certificates store
New-PACertificate $hostname -Plugin Cloudflare -PluginArgs $pArgs -Install -AcceptTOS -Contact $CFemail -Force