param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

# マイルストーン定義
$milestones = @(
    @{
        name = "Milestone 1: データレイヤー & 基盤アーキテクチャ"
        description = "データベース設計、Repository Pattern実装、移行ユーティリティ作成"
        targetDate = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")
    },
    @{
        name = "Milestone 2: UIレイヤー実装"
        description = "メイン画面・詳細画面・追加/編集画面など、主要なUIを実装"
        targetDate = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
    },
    @{
        name = "Milestone 3: 拡張機能実装"
        description = "ネイティブ機能統合、追加機能、最適化などの実装"
        targetDate = (Get-Date).AddDays(12).ToString("yyyy-MM-dd")
    }
)

$mutation = @"
mutation CreateProjectMilestone(`$projectId: String!, `$name: String!, `$description: String, `$targetDate: TimelessDate) {
  projectMilestoneCreate(input: {projectId: `$projectId, name: `$name, description: `$description, targetDate: `$targetDate}) {
    success
    projectMilestone { id name }
  }
}
"@

$createdMilestones = @()

foreach ($milestone in $milestones) {
    Write-Host "📅 作成中: $($milestone.name)..." -ForegroundColor Yellow
    
    $variables = @{
        projectId = $ProjectId
        name = $milestone.name
        description = $milestone.description
        targetDate = $milestone.targetDate
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
        
        if ($response.data.projectMilestoneCreate.success) {
            $createdMilestone = $response.data.projectMilestoneCreate.projectMilestone
            Write-Host "  ✅ 作成成功: $($createdMilestone.name)" -ForegroundColor Green
            $createdMilestones += $createdMilestone
        } else {
            Write-Host "  ❌ 作成失敗" -ForegroundColor Red
            $response.errors | ForEach-Object { Write-Host "    - $($_.message)" -ForegroundColor Red }
        }
    } catch {
        Write-Error "API Error: $_"
    }
}

Write-Host "`n🎉 マイルストーン作成完了！" -ForegroundColor Cyan
Write-Host "作成されたマイルストーン:" -ForegroundColor White
$createdMilestones | ForEach-Object { Write-Host "  - $($_.name) (ID: $($_.id))" -ForegroundColor Gray }

# 最初のマイルストーンのIDを返す（Issue作成で使用）
if ($createdMilestones.Count -gt 0) {
    return $createdMilestones[0].id
}