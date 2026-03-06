$OldThumbprint = ""
$NewThumbprint = ""

Get-WebBinding | Where-Object { $_.certificateHash -eq $OldThumbprint} | ForEach-Object {
    Write-Host "Replacing Cert For "  $_ 
    $_.RemoveSslCertificate()
    $_.AddSslCertificate($NewThumbprint, 'My')
}
