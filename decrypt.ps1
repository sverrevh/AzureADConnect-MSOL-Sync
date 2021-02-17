add-type -path 'C:\Program Files\Microsoft Azure AD Sync\Bin\mcrypt.dll'
$entropy=$args[0]
$instance_id = $args[1]
$key_id = $args[2]

$km = New-Object -TypeName Microsoft.DirectoryServices.MetadirectoryServices.Cryptography.KeyManager
$km.LoadKeySet([guid]$entropy, [guid]$instance_id, $key_id);
$key = $null
$km.GetActiveCredentialKey([ref]$key)
$key2 = $null
$km.GetKey(1, [ref]$key2);
$decrypted = $null
$key2.DecryptBase64ToString($(Get-Content -Path C:\Temp\crypted.txt), [ref]$decrypted)
Write-Host "$($decrypted)"