param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$Description
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

$mutation = @"
mutation ProjectUpdate(`$projectId: String!, `$description: String!) {
  projectUpdate(id: `$projectId, input: { description: `$description }) {
    success
    project { id name }
  }
}
"@

$variables = @{
    projectId = $ProjectId
    description = $Description
} | ConvertTo-Json

$body = @{
    query = $mutation
    variables = $variables
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $body

    if ($response.data.projectUpdate.success) {
        Write-Host "✅ プロジェクト説明を更新しました" -ForegroundColor Green
        Write-Host "   Project: $($response.data.projectUpdate.project.name)" -ForegroundColor Cyan
    } else {
        Write-Error "❌ プロジェクト説明の更新に失敗しました"
        $response.errors | ForEach-Object { Write-Host "- $($_.message)" -ForegroundColor Red }
    }
} catch {
    Write-Error "API Error: $_"
}