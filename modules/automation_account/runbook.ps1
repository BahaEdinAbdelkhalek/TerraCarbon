param(
    [string]$subscriptionId,
    [string]$ResourceGroupName,
    [string]$KeyVaultName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Output "$(Get-Date -Format 'u') | TerraCarbon runbook starting"
Write-Output "Subscription : $subscriptionId"
Write-Output "ResourceGroup: $ResourceGroupName"
Write-Output "KeyVault     : $KeyVaultName"

try {
    Connect-AzAccount -Identity | Out-Null
    Set-AzContext -SubscriptionId $subscriptionId | Out-Null
} catch {
    Write-Error "Authentication failed: $($_.Exception.Message)"
    throw
}

function Get-Secret {
    param([string]$VaultName, [string]$SecretName)
    try {
        return (Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -AsPlainText)
    } catch {
        Write-Warning "Could not read secret '$SecretName' from '$VaultName': $($_.Exception.Message)"
        return $null
    }
}

$carbonThreshold = Get-Secret -VaultName $KeyVaultName -SecretName "carbon-threshold-kg"
$costThreshold   = Get-Secret -VaultName $KeyVaultName -SecretName "cost-threshold-usd"
$cpuThreshold    = Get-Secret -VaultName $KeyVaultName -SecretName "cpu-utilization-threshold"

Write-Output "Thresholds — Carbon: ${carbonThreshold}kg | Cost: $${costThreshold} | CPU: ${cpuThreshold}%"

$headers = @{
    Authorization  = "Bearer $((Get-AzAccessToken -ResourceUrl 'https://management.azure.com').Token)"
    'Content-Type' = 'application/json'
}

$reportUri = "https://management.azure.com/providers/Microsoft.Carbon/carbonEmissionReports?api-version=2025-04-01"
$reportBody = @{
    carbonScopeList  = @("Scope1", "Scope2", "Scope3")
    dateRange        = @{
        start = (Get-Date).AddMonths(-1).ToString("yyyy-MM-01")
        end   = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    }
    reportType       = "TopItemsSummaryReport"
    subscriptionList = @($subscriptionId.ToLower())
    pageSize         = 10
} | ConvertTo-Json -Depth 10

try {
    $reportResponse = Invoke-RestMethod -Uri $reportUri -Headers $headers -Method POST -Body $reportBody
    Write-Output "Carbon report fetched — $(($reportResponse.data | Measure-Object).Count) items"

    foreach ($item in $reportResponse.data) {
        $resourceId = $item.resourceId
        $emissions  = [double]$item.totalEmissions

        Write-Output "Resource: $resourceId | Emissions: ${emissions} kg CO2e"

        if ($emissions -ge [double]$carbonThreshold) {
            Write-Output "  > Exceeds threshold — evaluating resource type"

            $parts        = $resourceId.Split('/')
            $resourceType = "$($parts[6])/$($parts[7])"

            if ($resourceType -eq "Microsoft.Compute/virtualMachines") {
                $vmName  = $parts[8]
                $vmRg    = $parts[4]

                try {
                    $vm = Get-AzVM -ResourceGroupName $vmRg -Name $vmName
                    Write-Output "  > VM $vmName size: $($vm.HardwareProfile.VmSize)"

                    if ($vm.HardwareProfile.VmSize -match "Standard_D[48]") {
                        Write-Output "  > Optimization opportunity: VM may be over-provisioned"
                    }
                } catch {
                    Write-Warning "  > Could not retrieve VM $vmName : $($_.Exception.Message)"
                }
            }
        }
    }
} catch {
    Write-Error "Carbon emissions report failed: $($_.Exception.Message)"
}

Write-Output "$(Get-Date -Format 'u') | TerraCarbon runbook completed"
