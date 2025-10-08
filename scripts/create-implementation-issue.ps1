param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$UserRequest,
    
    [Parameter(Mandatory=$true)]
    [hashtable]$ImplementationPlan,
    
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896"
)

# Linear 実装Issue作成スクリプト
Write-Host "🎫 Linear実装Issue作成開始" -ForegroundColor Cyan
Write-Host "プロジェクトID: $ProjectId" -ForegroundColor White

$result = @{
    success = $false
    issue = $null
    errors = @()
}

try {
    # Linear APIキー取得
    $linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop
    
    # Issue詳細情報を構築
    $issueTitle = "実装: $($ImplementationPlan.summary)"
    
    # 実装手順書を生成
    $implementationDescription = @"
## 🚀 $($ImplementationPlan.summary) 実装タスク

### 📋 ユーザー要求
$UserRequest

### 🎯 実装目標
- **カテゴリ**: $($ImplementationPlan.analysis.category)
- **優先度**: $($ImplementationPlan.analysis.priority)
- **複雑度**: $($ImplementationPlan.analysis.complexity)
- **予想工数**: $($ImplementationPlan.analysis.estimatedHours) 時間

### 🏗️ 技術仕様
- **技術スタック**: $($ImplementationPlan.analysis.techStack -join ", ")
- **アーキテクチャ**: $($ImplementationPlan.strategy)
- **実装アプローチ**: Sequential Thinking + AI支援開発

### 📝 実装手順

$($ImplementationPlan.phases | ForEach-Object { $index = [array]::IndexOf($ImplementationPlan.phases, $_) + 1; "#### Phase $index`: $_`n- [ ] **設計**: 詳細設計と技術選定`n- [ ] **実装**: コア機能実装`n- [ ] **テスト**: 動作確認とデバッグ`n" })

### ✅ 完了定義
- [ ] 機能要件すべて実装完了
- [ ] ESLint品質チェック通過 (エラー0件)
- [ ] Pre-commit hooks設定完了
- [ ] APIキー漏洩チェック通過
- [ ] GitHub Push完了
- [ ] 動作テスト完了

### 🔍 品質要件

#### Sequential Thinking戦略
```
思考1: 要求分析 → $($ImplementationPlan.analysis.category)として分類
思考2: 技術選定 → $($ImplementationPlan.analysis.techStack -join " + ")
思考3: アーキテクチャ → $($ImplementationPlan.strategy)
思考4: リスク評価 → 複雑度$($ImplementationPlan.analysis.complexity)、工数$($ImplementationPlan.analysis.estimatedHours)時間
思考5: 実装戦略 → AI支援ワークフロー採用
```

#### 品質チェック項目
- **ESLint**: エラー0件、警告最小限
- **セキュリティ**: APIキー漏洩なし
- **Pre-commit**: hooks設定・動作確認
- **Git**: 適切なコミットメッセージ

### 🎯 AI支援ワークフロー適用

この Issue は **AI支援統合開発ワークフロー** を使用して実装されます:

1. ✅ **Sequential Thinking分析**: 完了
2. ⏳ **Serena実装作業**: Claude Code による実装
3. ⏳ **品質チェック**: ESLint + セキュリティ
4. ⏳ **GitHub Push**: 自動化Push + Pre-commit
5. ⏳ **完了報告**: 自動生成レポート

### 🔗 関連リンク
- **プロジェクト**: https://linear.app/bochang-labo/project/$ProjectId
- **ワークフロー**: AI支援統合開発ワークフロー v1.0

---

🤖 **Generated with Claude Code - AI Assisted Workflow**
**作成日時**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Sequential Thinking**: 多段階思考分析完了
**実装予定**: Serena (Claude Code) による AI支援実装
"@

    # State ID取得（プロジェクトから推定）
    $stateIds = @{
        "Backlog" = "ce969021-9293-46ba-882b-912905298ac4"
        "InProgress" = "1cebb56e-524e-4de0-b676-0f574df9012a"
        "InReview" = "a7ee14b6-9c5b-4ab5-bcc7-6b24ac0ca7e8"
        "Done" = "6b7c4fbc-05b6-426e-bf3e-0daa54e165d9"
    }
    
    # 優先度マッピング
    $priorityMapping = @{
        "低" = 1
        "中" = 2
        "高" = 3
        "緊急" = 4
    }
    
    $priority = $priorityMapping[$ImplementationPlan.analysis.priority]
    if (-not $priority) { $priority = 2 }  # デフォルト: 中
    
    # Issue作成GraphQL mutation
    $mutation = @"
mutation CreateIssue(`$teamId: String!, `$title: String!, `$description: String!, `$projectId: String!, `$priority: Int!, `$stateId: String!) {
  issueCreate(input: {
    teamId: `$teamId
    title: `$title
    description: `$description
    projectId: `$projectId
    priority: `$priority
    stateId: `$stateId
  }) {
    success
    issue {
      id
      identifier
      title
      url
      state { name }
      priority
      createdAt
    }
    lastSyncId
  }
}
"@

    $variables = @{
        teamId = $TeamId
        title = $issueTitle
        description = $implementationDescription
        projectId = $ProjectId
        priority = $priority
        stateId = $stateIds["Backlog"]  # 初期状態はBacklog
    } | ConvertTo-Json -Depth 5

    $body = @{
        query = $mutation
        variables = $variables
    } | ConvertTo-Json -Depth 10

    Write-Host "   Issue作成中..." -ForegroundColor Gray
    Write-Host "   タイトル: $issueTitle" -ForegroundColor DarkGray

    # Linear APIリクエスト実行
    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $body

    # レスポンス検証
    if ($response.errors) {
        $result.errors += $response.errors | ForEach-Object { $_.message }
        throw "Linear API エラー: $($response.errors | ForEach-Object { $_.message } | Join-String ', ')"
    }

    if ($response.data.issueCreate.success) {
        $createdIssue = $response.data.issueCreate.issue
        $result.success = $true
        $result.issue = $createdIssue
        
        Write-Host "✅ Issue作成成功" -ForegroundColor Green
        Write-Host "   ID: $($createdIssue.identifier)" -ForegroundColor White
        Write-Host "   URL: $($createdIssue.url)" -ForegroundColor Cyan
        Write-Host "   状態: $($createdIssue.state.name)" -ForegroundColor Gray
        Write-Host "   優先度: $($createdIssue.priority)" -ForegroundColor Gray
        
        # プロジェクトマイルストーンが存在する場合は紐付け
        Write-Host "   マイルストーン確認中..." -ForegroundColor Gray
        
        # プロジェクトのマイルストーン取得
        $milestoneQuery = @"
query GetProjectMilestones(`$projectId: String!) {
  project(id: `$projectId) {
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

        $milestoneVariables = @{ projectId = $ProjectId } | ConvertTo-Json
        $milestoneBody = @{
            query = $milestoneQuery
            variables = $milestoneVariables
        } | ConvertTo-Json

        try {
            $milestoneResponse = Invoke-RestMethod `
                -Uri "https://api.linear.app/graphql" `
                -Method Post `
                -Headers @{
                    "Authorization" = $linearKey
                    "Content-Type" = "application/json"
                } `
                -Body $milestoneBody

            $milestones = $milestoneResponse.data.project.projectMilestones.nodes
            
            if ($milestones -and $milestones.Count -gt 0) {
                # 最初のマイルストーンに紐付け（より高度なロジックも可能）
                $firstMilestone = $milestones[0]
                Write-Host "   マイルストーン紐付け: $($firstMilestone.name)" -ForegroundColor Green
                
                # Issue更新でマイルストーン設定
                $updateMutation = @"
mutation UpdateIssue(`$issueId: String!, `$projectMilestoneId: String!) {
  issueUpdate(id: `$issueId, input: { projectMilestoneId: `$projectMilestoneId }) {
    success
  }
}
"@

                $updateVariables = @{
                    issueId = $createdIssue.id
                    projectMilestoneId = $firstMilestone.id
                } | ConvertTo-Json

                $updateBody = @{
                    query = $updateMutation
                    variables = $updateVariables
                } | ConvertTo-Json

                $updateResponse = Invoke-RestMethod `
                    -Uri "https://api.linear.app/graphql" `
                    -Method Post `
                    -Headers @{
                        "Authorization" = $linearKey
                        "Content-Type" = "application/json"
                    } `
                    -Body $updateBody

                if ($updateResponse.data.issueUpdate.success) {
                    Write-Host "   ✅ マイルストーン紐付け完了" -ForegroundColor Green
                }
            } else {
                Write-Host "   ℹ️ プロジェクトにマイルストーンがありません" -ForegroundColor Blue
            }
        } catch {
            Write-Host "   ⚠️ マイルストーン紐付けをスキップ: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # ラベル追加（AI支援ワークフロー識別用）
        Write-Host "   AI支援ワークフローラベル追加中..." -ForegroundColor Gray
        
        # ラベル追加は実装をシンプル化するためスキップ
        # 実際の実装では、ラベル作成→Issue紐付けのAPIコールが必要
        
        return $result
        
    } else {
        throw "Issue作成に失敗しました: レスポンスでsuccess=false"
    }

} catch {
    $result.errors += $_.Exception.Message
    Write-Host "❌ Issue作成エラー: $($_.Exception.Message)" -ForegroundColor Red
    
    # デバッグ情報表示
    Write-Host "🔧 デバッグ情報:" -ForegroundColor Yellow
    Write-Host "   プロジェクトID: $ProjectId" -ForegroundColor Gray
    Write-Host "   チームID: $TeamId" -ForegroundColor Gray
    Write-Host "   APIキーファイル存在: $(Test-Path "$env:USERPROFILE\.linear-api-key")" -ForegroundColor Gray
    
    if ($response) {
        Write-Host "   API レスポンス:" -ForegroundColor Gray
        $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor DarkGray
    }
    
    return $result
}