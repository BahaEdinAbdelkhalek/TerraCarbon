while ($true) {
    try {
        $rawOutputs = terraform output -json
        if ($rawOutputs) {
            $outputs = ConvertFrom-Json $rawOutputs
            $outputs | Add-Member -MemberType NoteProperty -Name "generated_at" -Value @{ value = (Get-Date -Format "o") } -Force
            $outputs | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 terraform_outputs.json
        }
        $token = az account get-access-token --resource=https://management.azure.com --query accessToken -o tsv
        if ($token) {
            @{ accessToken = $token } | ConvertTo-Json | Out-File -Encoding utf8 token.json
        }
    } catch {
        Write-Error $_.Exception.Message
    }
    Start-Sleep -Seconds 1200
}
