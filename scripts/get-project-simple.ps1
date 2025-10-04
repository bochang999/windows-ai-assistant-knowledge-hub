param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

Write-Host "Getting project details for: $ProjectId" -ForegroundColor Cyan

$query = @"
query GetProject(`$projectId: String!) {
  project(id: `$projectId) {
    id
    name
    description
    state
    progress
    url
    createdAt
    updatedAt
    issues {
      nodes {
        id
        identifier
        title
        state {
          name
        }
        url
      }
    }
    projectMilestones {
      nodes {
        id
        name
        targetDate
      }
    }
  }
}
"@

$variables = @{
    projectId = $ProjectId
} | ConvertTo-Json

$body = @{
    query = $query
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

    if ($response.data.project) {
        $project = $response.data.project
        
        Write-Host "Project: $($project.name)" -ForegroundColor Yellow
        Write-Host "ID: $($project.id)" -ForegroundColor Gray
        Write-Host "State: $($project.state)" -ForegroundColor Green
        Write-Host "URL: $($project.url)" -ForegroundColor Blue
        
        if ($project.description) {
            Write-Host "Description: $($project.description)" -ForegroundColor White
        }
        
        if ($project.progress -ne $null) {
            $progressPercent = [Math]::Round($project.progress * 100, 1)
            Write-Host "Progress: $progressPercent%" -ForegroundColor Cyan
        }
        
        if ($project.projectMilestones.nodes.Count -gt 0) {
            Write-Host "`nMilestones:" -ForegroundColor Yellow
            $project.projectMilestones.nodes | ForEach-Object {
                $targetDate = if ($_.targetDate) { " (Target: $($_.targetDate))" } else { "" }
                Write-Host "  - $($_.name)$targetDate" -ForegroundColor Gray
            }
        }
        
        if ($project.issues.nodes.Count -gt 0) {
            Write-Host "`nIssues ($($project.issues.nodes.Count)):" -ForegroundColor Yellow
            $issueStats = $project.issues.nodes | Group-Object { $_.state.name }
            $issueStats | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
            }
            
            Write-Host "`nRecent Issues:" -ForegroundColor Yellow
            $project.issues.nodes | Select-Object -First 5 | ForEach-Object {
                Write-Host "  $($_.identifier): $($_.title) [$($_.state.name)]" -ForegroundColor Gray
                Write-Host "    $($_.url)" -ForegroundColor Blue
            }
        }
        
        Write-Host "`nCreated: $($project.createdAt)" -ForegroundColor Gray
        Write-Host "Updated: $($project.updatedAt)" -ForegroundColor Gray
        
    } else {
        Write-Error "Project not found: $ProjectId"
    }
} catch {
    Write-Error "API Error: $($_.Exception.Message)"
}