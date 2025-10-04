param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

Write-Host "🔍 Getting project details for: $ProjectId" -ForegroundColor Cyan

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
    lead {
      name
      email
    }
    members {
      nodes {
        name
        email
      }
    }
    milestones {
      nodes {
        id
        name
        description
        targetDate
        sortOrder
      }
    }
    issues {
      nodes {
        id
        identifier
        title
        description
        priority
        state {
          name
          type
        }
        assignee {
          name
        }
        creator {
          name
        }
        projectMilestone {
          name
        }
        createdAt
        updatedAt
        url
      }
    }
    teams {
      nodes {
        id
        name
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
        
        # ヘッダー
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "📁 PROJECT DETAILS" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
        # 基本情報
        Write-Host "`n📋 Basic Information" -ForegroundColor Yellow
        Write-Host "   Name: $($project.name)" -ForegroundColor White
        Write-Host "   ID: $($project.id)" -ForegroundColor Gray
        Write-Host "   State: $($project.state)" -ForegroundColor $(if ($project.state -eq "completed") { "Green" } else { "Yellow" })
        Write-Host "   URL: $($project.url)" -ForegroundColor Blue
        
        if ($project.description) {
            Write-Host "   Description: $($project.description)" -ForegroundColor White
        }
        
        if ($project.progress -ne $null) {
            $progressPercent = [Math]::Round($project.progress * 100, 1)
            Write-Host "   Progress: $progressPercent%" -ForegroundColor $(if ($progressPercent -gt 80) { "Green" } elseif ($progressPercent -gt 50) { "Yellow" } else { "Red" })
        }
        
        # リーダー情報
        if ($project.lead) {
            Write-Host "`n👤 Project Lead" -ForegroundColor Yellow
            Write-Host "   Name: $($project.lead.name)" -ForegroundColor White
            Write-Host "   Email: $($project.lead.email)" -ForegroundColor Gray
        }
        
        # チーム情報
        if ($project.teams.nodes.Count -gt 0) {
            Write-Host "`n👥 Teams" -ForegroundColor Yellow
            $project.teams.nodes | ForEach-Object {
                Write-Host "   - $($_.name) (ID: $($_.id))" -ForegroundColor White
            }
        }
        
        # メンバー情報
        if ($project.members.nodes.Count -gt 0) {
            Write-Host "`n👥 Members ($($project.members.nodes.Count))" -ForegroundColor Yellow
            $project.members.nodes | ForEach-Object {
                Write-Host "   - $($_.name) <$($_.email)>" -ForegroundColor White
            }
        }
        
        # マイルストーン
        if ($project.milestones.nodes.Count -gt 0) {
            Write-Host "`n🏃 Milestones ($($project.milestones.nodes.Count))" -ForegroundColor Yellow
            $sortedMilestones = $project.milestones.nodes | Sort-Object sortOrder
            $sortedMilestones | ForEach-Object {
                $targetDate = if ($_.targetDate) { " [Target: $($_.targetDate)]" } else { "" }
                Write-Host "   📅 $($_.name)$targetDate" -ForegroundColor Cyan
                if ($_.description) {
                    Write-Host "      $($_.description)" -ForegroundColor Gray
                }
            }
        }
        
        # Issue統計
        if ($project.issues.nodes.Count -gt 0) {
            Write-Host "`n🎫 Issues ($($project.issues.nodes.Count))" -ForegroundColor Yellow
            
            # 状態別統計
            $issueStats = $project.issues.nodes | Group-Object { $_.state.name }
            Write-Host "   Status breakdown:" -ForegroundColor White
            $issueStats | ForEach-Object {
                $color = switch ($_.Name) {
                    "Done" { "Green" }
                    "In Progress" { "Yellow" }
                    "In Review" { "Cyan" }
                    default { "Gray" }
                }
                Write-Host "     $($_.Name): $($_.Count)" -ForegroundColor $color
            }
            
            # 優先度別統計
            $priorityStats = $project.issues.nodes | Group-Object priority
            Write-Host "   Priority breakdown:" -ForegroundColor White
            $priorityStats | ForEach-Object {
                $priorityName = switch ([int]$_.Name) {
                    1 { "Urgent" }
                    2 { "High" }
                    3 { "Medium" }
                    4 { "Low" }
                    default { "None" }
                }
                $color = switch ([int]$_.Name) {
                    1 { "Red" }
                    2 { "Yellow" }
                    3 { "Cyan" }
                    default { "Gray" }
                }
                Write-Host "     ${priorityName}: $($_.Count)" -ForegroundColor $color
            }
            
            # 最近のIssue (最新5件)
            Write-Host "`n   Recent Issues:" -ForegroundColor White
            $recentIssues = $project.issues.nodes | Sort-Object updatedAt -Descending | Select-Object -First 5
            $recentIssues | ForEach-Object {
                $assignee = if ($_.assignee) { " [@$($_.assignee.name)]" } else { "" }
                $milestone = if ($_.projectMilestone) { " [🏃 $($_.projectMilestone.name)]" } else { "" }
                $color = switch ($_.state.name) {
                    "Done" { "Green" }
                    "In Progress" { "Yellow" }
                    "In Review" { "Cyan" }
                    default { "Gray" }
                }
                Write-Host "     $($_.identifier): $($_.title)$assignee$milestone" -ForegroundColor $color
                Write-Host "       URL: $($_.url)" -ForegroundColor Gray
            }
        }
        
        # タイムスタンプ
        Write-Host "`n⏰ Timestamps" -ForegroundColor Yellow
        Write-Host "   Created: $($project.createdAt)" -ForegroundColor Gray
        Write-Host "   Updated: $($project.updatedAt)" -ForegroundColor Gray
        
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
    } else {
        Write-Error "❌ Project not found: $ProjectId"
        if ($response.errors) {
            $response.errors | ForEach-Object { Write-Host "- $($_.message)" -ForegroundColor Red }
        }
    }
} catch {
    Write-Error "API Error: $_"
}