# Prompt user for variables
$vcServer = Read-Host -Prompt "Enter vCenter Server address"
$vcUsername = Read-Host -Prompt "Enter vCenter Username"
$vcPassword = Read-Host -Prompt "Enter vCenter Password" -AsSecureString
$clusterCount = Read-Host -Prompt "Enter the number of clusters you want to update"
$clusterNames = @()

for ($i = 1; $i -le $clusterCount; $i++) {
    $clusterName = Read-Host -Prompt "Enter Cluster Name $i"
    $clusterNames += $clusterName
}

$newProductLockerPath = Read-Host -Prompt "Enter the new Product Locker Path"

# Ignore SSL certificate warnings
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to vCenter Server
Connect-VIServer -Server $vcServer -User $vcUsername -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vcPassword)))

# Loop through all specified clusters
foreach ($clusterName in $clusterNames) {
    # Get the cluster
    $cluster = Get-Cluster -Name $clusterName

    # Loop through all ESXi hosts in the cluster
    foreach ($esxiHost in ($cluster | Get-VMHost)) {
        # Update the product locker location
        $esxiHost | Get-AdvancedSetting -Name "UserVars.ProductLockerLocation" | Set-AdvancedSetting -Value $newProductLockerPath -Confirm:$false

        # Output the result
        Write-Host "Product locker location updated successfully on $($esxiHost.Name)"
    }
}

# Disconnect from vCenter Server
Disconnect-VIServer -Server $vcServer -Confirm:$false
