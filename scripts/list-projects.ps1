param(
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896",
    [int]$Limit = 20,
    [switch]$ShowDetails
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

Write-Host "📋 Listing Linear projects..." -ForegroundColor Cyan

$query = @"
query GetProjects(`$teamId: String!, `$first: Int) {
  team(id: `$teamId) {
    name
    projects(first: `$first) {
      nodes {
        id
        name
        description
        state
        progress
        url
        createdAt
        updatedAt
        members {
          nodes {
            name
          }
        }
        projectMilestones {
          nodes {
            id
            name
            targetDate
          }
        }
        issues {
          nodes {
            id
            identifier
            title
            state {
              name
            }
          }
        }
      }
    }
  }
}
"@

$variables = @{
    teamId = $TeamId
    first = $Limit
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

    if ($response.data.team) {
        $team = $response.data.team
        $projects = $team.projects.nodes
        
        Write-Host "Team: $($team.name)" -ForegroundColor Yellow
        Write-Host "Found $($projects.Count) projects:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($project in $projects) {
            # 基本情報
            Write-Host "📁 $($project.name)" -ForegroundColor Cyan
            Write-Host "   ID: $($project.id)" -ForegroundColor Gray
            Write-Host "   State: $($project.state)" -ForegroundColor $(if ($project.state -eq "completed") { "Green" } else { "Yellow" })
            
            if ($project.description) {
                $shortDesc = if ($project.description.Length -gt 80) { 
                    $project.description.Substring(0, 80) + "..." 
                } else { 
                    $project.description 
                }
                Write-Host "   Description: $shortDesc" -ForegroundColor White
            }
            
            # 進捗情報
            if ($project.progress -ne $null) {
                $progressPercent = [Math]::Round($project.progress * 100, 1)
                Write-Host "   Progress: $progressPercent%" -ForegroundColor $(if ($progressPercent -gt 80) { "Green" } elseif ($progressPercent -gt 50) { "Yellow" } else { "Red" })
            }
            
            # 詳細情報
            if ($ShowDetails) {
                # マイルストーン
                if ($project.projectMilestones.nodes.Count -gt 0) {
                    Write-Host "   Milestones:" -ForegroundColor Yellow
                    $project.projectMilestones.nodes | ForEach-Object {
                        $targetDate = if ($_.targetDate) { " (Target: $($_.targetDate))" } else { "" }
                        Write-Host "     - $($_.name)$targetDate" -ForegroundColor Gray
                    }
                }
                
                # Issue統計
                $issues = $project.issues.nodes
                if ($issues.Count -gt 0) {
                    $issueStats = $issues | Group-Object { $_.state.name }
                    Write-Host "   Issues:" -ForegroundColor Yellow
                    $issueStats | ForEach-Object {
                        Write-Host "     - $($_.Name): $($_.Count)" -ForegroundColor Gray
                    }
                }
                
                # メンバー
                if ($project.members.nodes.Count -gt 0) {
                    $memberNames = ($project.members.nodes | ForEach-Object { $_.name }) -join ", "
                    Write-Host "   Members: $memberNames" -ForegroundColor Yellow
                }
                
                # 作成・更新日
                Write-Host "   Created: $($project.createdAt)" -ForegroundColor Gray
                Write-Host "   Updated: $($project.updatedAt)" -ForegroundColor Gray
            }
            
            Write-Host "   URL: $($project.url)" -ForegroundColor Blue
            Write-Host ""
        }
        
        # サマリー
        Write-Host "📊 Summary:" -ForegroundColor Cyan
        $projectStats = $projects | Group-Object state
        $projectStats | ForEach-Object {
            Write-Host "   $($_.Name): $($_.Count) projects" -ForegroundColor White
        }
        
    } else {
        Write-Error "❌ Failed to retrieve projects"
        $response.errors | ForEach-Object { Write-Host "- $($_.message)" -ForegroundColor Red }
    }
} catch {
    Write-Error "API Error: $_"
}