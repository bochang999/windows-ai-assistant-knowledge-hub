param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896"
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

Write-Host "🚀 Creating new Linear project: $ProjectName" -ForegroundColor Cyan

$mutation = @"
mutation CreateProject(`$teamIds: [String!]!, `$name: String!, `$description: String) {
  projectCreate(input: {teamIds: `$teamIds, name: `$name, description: `$description}) {
    success
    project {
      id
      name
      description
      url
    }
  }
}
"@

$variables = @{
    teamIds = @($TeamId)
    name = $ProjectName
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

    if ($response.data.projectCreate.success) {
        $project = $response.data.projectCreate.project
        
        Write-Host "✅ Project created successfully!" -ForegroundColor Green
        Write-Host "   Name: $($project.name)" -ForegroundColor Cyan
        Write-Host "   ID: $($project.id)" -ForegroundColor Gray
        Write-Host "   URL: $($project.url)" -ForegroundColor Blue
        Write-Host ""
        
        # 次のステップ提案
        Write-Host "🎯 Next steps:" -ForegroundColor Yellow
        Write-Host "   1. Setup project with full workflow:" -ForegroundColor White
        Write-Host "      .\scripts\start-linear-project.ps1 -ProjectName '$ProjectName' -ProjectId '$($project.id)' -Description '$Description'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   2. Or manually add milestones:" -ForegroundColor White
        Write-Host "      .\scripts\create-project-milestones.ps1 -ProjectId '$($project.id)' -ProjectName '$ProjectName'" -ForegroundColor Gray
        
        # プロジェクトIDを返す
        return $project.id
    } else {
        Write-Error "❌ Project creation failed"
        $response.errors | ForEach-Object { Write-Host "- $($_.message)" -ForegroundColor Red }
        return $null
    }
} catch {
    Write-Error "API Error: $_"
    return $null
}