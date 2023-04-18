# Script to change all ESXi host NTP settings

# Set vCenter Server, credentials and NTP server(s)
$vCenterServer = Read-Host -AsSecureString "Please enter vCenter name"
$Username = "administrator@vsphere.local"
$Password = Read-Host -AsSecureString "Please enter the password for vCenter"
$NtpServers = @("ntp1.example.com", "ntp2.example.com")

# Load the VMware PowerCLI module
Import-Module VMware.PowerCLI

# Connect to the vCenter Server
Connect-VIServer -Server $vCenterServer -User $Username -Password $Password

# Retrieve all ESXi hosts
$EsxiHosts = Get-VMHost

# Update NTP settings for each ESXi host
foreach ($EsxiHost in $EsxiHosts) {
    Write-Host "Updating NTP settings for $($EsxiHost.Name)..."
    
    # Get current NTP settings
    $CurrentNtpServers = Get-VMHostNtpServer -VMHost $EsxiHost
    
    # Remove current NTP servers
    if ($CurrentNtpServers) {
        Remove-VMHostNtpServer -NtpServer $CurrentNtpServers -VMHost $EsxiHost -Confirm:$false
    }
    
    # Add new NTP servers
    Add-VMHostNtpServer -NtpServer $NtpServers -VMHost $EsxiHost
    
    # Restart NTP service
    Get-VMHostService -VMHost $EsxiHost | Where-Object { $_.Key -eq "ntpd" } | Restart-VMHostService -Confirm:$false

    Write-Host "NTP settings updated for $($EsxiHost.Name)"
}

# Disconnect from the vCenter Server
Disconnect-VIServer -Server $vCenterServer -Confirm:$false

Write-Host "All ESXi host NTP settings updated successfully."