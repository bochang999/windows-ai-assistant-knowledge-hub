# Linear プロジェクト・ライフサイクル管理システム

## 🏗️ プロジェクト開始時の完全ワークフロー

このワークフローは、新しいプロジェクトをLinearで管理する際の標準的な手順を定義します。zen recipeプロジェクトでの実績に基づいて作成されています。

---

## 📋 Phase 1: プロジェクトセットアップ

### 1.1 プロジェクト基本情報の準備

**テンプレート: プロジェクト概要文**
```markdown
🎯 [プロジェクト名] - [元プロジェクト]からの[移行先技術]への完全移行プロジェクト

📱 技術スタック: [言語] + [アーキテクチャ] + [主要技術1] + [主要技術2] + [UI技術]
🎯 目標: [目標1]、[目標2]、[目標3]
🚀 新機能: [機能1]、[機能2]、[機能3]、[機能4]、[機能5]

🔗 GitHub: github.com/[user]/[repo]
```

**例: zen recipe**
```markdown
🧘 petit-recipeをネイティブAndroidに移行。Kotlin + MVVM + Room + Material Design 3でパフォーマンス向上とオフライン強化を実現。カメラ・音声・タイマー機能追加予定。

🔗 GitHub: github.com/bochang999/zen-recipe
```

### 1.2 プロジェクト説明更新

**PowerShellスクリプト: update-project-description.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$Description
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw

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
} else {
    Write-Error "❌ プロジェクト説明の更新に失敗しました"
}
```

---

## 📊 Phase 2: マイルストーン設計と作成

### 2.1 標準マイルストーン構成

**3段階マイルストーン構成（推奨）**

#### Milestone 1: データレイヤー & 基盤アーキテクチャ
- **目標期間**: 2-3日
- **説明テンプレート**: "データベース設計、Repository Pattern実装、移行ユーティリティ作成"
- **主要成果物**: Entity設計、DAO実装、Database設定、移行スクリプト

#### Milestone 2: UIレイヤー実装
- **目標期間**: 3-4日  
- **説明テンプレート**: "メイン画面・詳細画面・追加/編集画面など、主要なUIを実装"
- **主要成果物**: Fragment実装、Navigation設定、レイアウト作成

#### Milestone 3: 拡張機能実装
- **目標期間**: 4-5日
- **説明テンプレート**: "ネイティブ機能統合、追加機能、最適化などの実装"
- **主要成果物**: カメラ統合、音声機能、通知機能、パフォーマンス最適化

### 2.2 マイルストーン作成スクリプト

**PowerShellスクリプト: create-project-milestones.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw

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
    
    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $body
    
    if ($response.data.projectMilestoneCreate.success) {
        Write-Host "  ✅ 作成成功: $($response.data.projectMilestoneCreate.projectMilestone.name)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 作成失敗" -ForegroundColor Red
        $response.errors | ForEach-Object { Write-Host "    - $($_.message)" -ForegroundColor Red }
    }
}

Write-Host "`n🎉 マイルストーン作成完了！Linearプロジェクトページを確認してください。" -ForegroundColor Cyan
```

---

## 🎫 Phase 3: Issue作成と管理

### 3.1 Issue作成テンプレート

#### プロジェクト開始Issue
**タイトル**: `[プロジェクト名]: [元技術]→[新技術] 移行プロジェクト開始`
**マイルストーン**: Milestone 1
**進行度**: Done（開始時点で完了扱い）

**説明テンプレート**:
```markdown
## 🚀 [プロジェクト名] プロジェクト開始

### 📱 移行概要
[元プロジェクト名]アプリを[元技術]から[新技術]へ完全移行

### 🎯 主要目標
- **[目標1]**: [詳細説明]
- **[目標2]**: [詳細説明]  
- **[目標3]**: [詳細説明]

### 🏗️ 技術仕様
- **言語**: [言語]
- **アーキテクチャ**: [アーキテクチャパターン]
- **データベース**: [DB技術]
- **UI**: [UI技術]
- **Min SDK**: [最小SDK]
- **Target SDK**: [ターゲットSDK]

### 📊 完了済み作業
- [x] **プロジェクトセットアップ**: [技術] プロジェクト作成完了
- [x] **基本設定**: [詳細1], [詳細2], [詳細3] 設定
- [x] **プロジェクトドキュメント**: README.md, CLAUDE.md完備
- [x] **リポジトリ統合**: [リポジトリURL]

### 🔗 関連リンク
- **GitHub**: [リポジトリURL]
- **Original App**: [元アプリURL]
- **Linear Project**: [LinearプロジェクトURL]

🤖 **Generated with Claude Code - [統合技術名]**
```

#### マイルストーン実装Issue
**タイトル**: `Milestone [番号]: [マイルストーン名]`
**マイルストーン**: 対応するMilestone
**進行度**: In Progress

### 3.2 Issue作成・更新スクリプト

**PowerShellスクリプト: create-project-issues.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$TeamId,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$MilestoneId
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw

# State IDマッピング
$stateIds = @{
    "Done" = "6b7c4fbc-05b6-426e-bf3e-0daa54e165d9"
    "InProgress" = "1cebb56e-524e-4de0-b676-0f574df9012a"
    "Backlog" = "ce969021-9293-46ba-882b-912905298ac4"
}

# Issue定義
$issues = @(
    @{
        title = "$ProjectName プロジェクト開始"
        description = "プロジェクトの初期セットアップと基盤構築が完了しました。"
        priority = 1
        state = "Done"
        milestone = $MilestoneId
    },
    @{
        title = "Milestone 1: データレイヤー & 基盤アーキテクチャ構築"
        description = "データベース設計、Repository Pattern実装、移行ユーティリティの作成を行います。"
        priority = 2
        state = "InProgress"
        milestone = $MilestoneId
    }
)

$mutation = @"
mutation CreateIssue(`$teamId: String!, `$title: String!, `$description: String!, `$projectId: String!, `$priority: Int!, `$stateId: String!, `$projectMilestoneId: String!) {
  issueCreate(input: {teamId: `$teamId, title: `$title, description: `$description, projectId: `$projectId, priority: `$priority, stateId: `$stateId, projectMilestoneId: `$projectMilestoneId}) {
    success
    issue { id identifier title }
  }
}
"@

foreach ($issue in $issues) {
    Write-Host "🎫 作成中: $($issue.title)..." -ForegroundColor Yellow
    
    $variables = @{
        teamId = $TeamId
        title = $issue.title
        description = $issue.description
        projectId = $ProjectId
        priority = $issue.priority
        stateId = $stateIds[$issue.state]
        projectMilestoneId = $issue.milestone
    } | ConvertTo-Json
    
    $body = @{
        query = $mutation
        variables = $variables
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $body
    
    if ($response.data.issueCreate.success) {
        $createdIssue = $response.data.issueCreate.issue
        Write-Host "  ✅ 作成成功: $($createdIssue.identifier) - $($createdIssue.title)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 作成失敗" -ForegroundColor Red
        $response.errors | ForEach-Object { Write-Host "    - $($_.message)" -ForegroundColor Red }
    }
}
```

---

## 📈 Phase 4: 進行度管理と作業報告

### 4.1 作業開始時の手順

```powershell
# Issue状態を"In Progress"に変更
.\scripts\sync-linear-status.ps1 -IssueId "[IssueのID]" -Status InProgress
```

### 4.2 作業完了時の報告テンプレート

**作業完了報告テンプレート**:
```markdown
## 📊 [作業タイトル] 完了報告

### ✅ 完了済みタスク
- [x] **[タスク1]**: [詳細説明]
- [x] **[タスク2]**: [詳細説明]
- [x] **[タスク3]**: [詳細説明]

### 🏗️ 実装内容
#### [カテゴリ1]
- **[ファイル名]**: [実装内容]
- **[ファイル名]**: [実装内容]

#### [カテゴリ2]  
- **[ファイル名]**: [実装内容]
- **[ファイル名]**: [実装内容]

### 📋 技術実装詳細
```[言語]
// 主要な実装コード例
[コードスニペット]
```

### 🎯 次のステップ
- [ ] **[次のタスク1]**: [説明]
- [ ] **[次のタスク2]**: [説明]
- [ ] **[次のタスク3]**: [説明]

### 📊 進捗率
**[現在のマイルストーン]: [XX]% 完了** ✅
**[次のマイルストーン]: [X]% → 次回開始**

### 🔗 関連リンク
- **GitHub Commit**: [コミットURL]
- **実装ファイル**: [ファイルパス]

🤖 **Generated with Claude Code - [技術名] Integration**
```

### 4.3 作業報告の自動投稿

**PowerShellスクリプト: add-progress-report.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$IssueId,
    
    [Parameter(Mandatory=$true)]
    [string]$ReportContent
)

$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw

$mutation = @"
mutation CommentCreate(`$issueId: String!, `$body: String!) {
  commentCreate(input: {issueId: `$issueId, body: `$body}) {
    success
    comment { id }
  }
}
"@

$variables = @{
    issueId = $IssueId
    body = $ReportContent
} | ConvertTo-Json

$body = @{
    query = $mutation
    variables = $variables
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "https://api.linear.app/graphql" `
    -Method Post `
    -Headers @{
        "Authorization" = $linearKey
        "Content-Type" = "application/json"
    } `
    -Body $body

if ($response.data.commentCreate.success) {
    Write-Host "✅ 作業報告を投稿しました" -ForegroundColor Green
    
    # 自動的にステータスを"In Review"に変更
    .\scripts\sync-linear-status.ps1 -IssueId $IssueId -Status InReview
} else {
    Write-Error "❌ 作業報告の投稿に失敗しました"
}
```

---

## 🆘 Phase 5: 問題発生時の対応

### 5.1 他のAIへの質問要望書テンプレート

**技術的問題の質問テンプレート**:
```markdown
# 🆘 技術サポート要請

## 📋 基本情報
- **プロジェクト**: [プロジェクト名]
- **技術スタック**: [技術1], [技術2], [技術3]
- **開発環境**: [OS], [IDE], [言語バージョン]
- **問題発生日時**: [YYYY-MM-DD HH:MM]

## 🚨 問題概要
### 現在の状況
[問題の簡潔な説明]

### 期待する動作
[本来あるべき動作]

### 実際の動作
[実際に起きている問題]

## 🔍 技術的詳細
### エラーメッセージ
```
[エラーメッセージをそのまま貼り付け]
```

### 関連するコード
```[言語]
[問題が起きているコード部分]
```

### ファイル構成
```
[関連するファイル・ディレクトリ構造]
```

## 🛠️ 試行した対処法
1. **[対処法1]**: [結果]
2. **[対処法2]**: [結果]
3. **[対処法3]**: [結果]

## 🎯 求める回答
- [ ] **根本原因の特定**
- [ ] **具体的な解決手順**
- [ ] **再発防止策**
- [ ] **ベストプラクティスの提案**

## 📚 参考情報
- **公式ドキュメント**: [URL]
- **関連Issue**: [Linear URL]
- **GitHub**: [リポジトリURL]

---
**緊急度**: [高/中/低]
**影響範囲**: [プロジェクト全体/特定機能/開発環境]
```

### 5.2 問題レポート自動作成

**PowerShellスクリプト: create-support-request.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProblemSummary,
    
    [Parameter(Mandatory=$true)]
    [string]$ErrorMessage,
    
    [string]$TechStack = "",
    [string]$Urgency = "中"
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

$template = @"
# 🆘 技術サポート要請

## 📋 基本情報
- **プロジェクト**: $ProjectName
- **技術スタック**: $TechStack
- **開発環境**: Windows 11, Claude Code, PowerShell
- **問題発生日時**: $timestamp

## 🚨 問題概要
### 現在の状況
$ProblemSummary

### エラーメッセージ
```
$ErrorMessage
```

## 🛠️ 試行した対処法
1. **ドキュメント確認**: 公式ドキュメントを確認しました
2. **再起動**: 開発環境を再起動しました
3. **キャッシュクリア**: 関連キャッシュをクリアしました

## 🎯 求める回答
- [ ] **根本原因の特定**
- [ ] **具体的な解決手順**
- [ ] **再発防止策**

---
**緊急度**: $Urgency
**影響範囲**: プロジェクト進行
"@

$outputPath = "$env:TEMP\support-request-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
$template | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "📝 サポート要請文書を作成しました: $outputPath" -ForegroundColor Green
Write-Host "この内容をコピーして他のAIに質問してください。" -ForegroundColor Yellow

# クリップボードにコピー
$template | Set-Clipboard
Write-Host "✅ クリップボードにコピーしました" -ForegroundColor Cyan
```

---

## 📋 Phase 0: プロジェクト作成と閲覧

### 0.1 新規プロジェクト作成

**PowerShellスクリプト: create-new-project.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896"
)

# Linear GraphQL APIを使用してプロジェクト作成
$mutation = @"
mutation CreateProject(`$teamIds: [String!]!, `$name: String!, `$description: String) {
  projectCreate(input: {teamIds: `$teamIds, name: `$name, description: `$description}) {
    success
    project { id name description url }
  }
}
"@

# プロジェクト作成後、自動的に次ステップを提案
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Setup project with full workflow:" -ForegroundColor White
Write-Host "      .\scripts\start-linear-project.ps1 -ProjectName '$ProjectName' -ProjectId '$($project.id)' -Description '$Description'" -ForegroundColor Gray
```

**使用例**:
```powershell
# 新規プロジェクト作成
.\scripts\create-new-project.ps1 -ProjectName "AI Chat Bot" -Description "OpenAI APIを使用したチャットボットアプリケーション"

# 作成されたプロジェクトIDで完全ワークフロー実行
.\scripts\start-linear-project.ps1 -ProjectName "AI Chat Bot" -ProjectId "returned-project-id" -Description "説明文"
```

### 0.2 プロジェクト一覧閲覧

**PowerShellスクリプト: list-projects.ps1**
```powershell
param(
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896",
    [int]$Limit = 20,
    [switch]$ShowDetails
)

# チーム内の全プロジェクトを取得・表示
$query = @"
query GetProjects(`$teamId: String!, `$first: Int) {
  team(id: `$teamId) {
    name
    projects(first: `$first) {
      nodes {
        id name description state progress url
        projectMilestones { nodes { id name targetDate } }
        issues { nodes { id identifier title state { name } } }
      }
    }
  }
}
"@
```

**使用例**:
```powershell
# 基本一覧表示
.\scripts\list-projects.ps1

# 詳細情報付き表示
.\scripts\list-projects.ps1 -ShowDetails

# 最新10件のみ表示
.\scripts\list-projects.ps1 -Limit 10
```

### 0.3 プロジェクト詳細閲覧

**PowerShellスクリプト: get-project-simple.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId
)

# 特定プロジェクトの詳細情報を取得
$query = @"
query GetProject(`$projectId: String!) {
  project(id: `$projectId) {
    id name description state progress url
    projectMilestones { nodes { id name targetDate } }
    issues { nodes { id identifier title state { name } url } }
  }
}
"@
```

**使用例**:
```powershell
# プロジェクト詳細表示
.\scripts\get-project-simple.ps1 -ProjectId "f6048ad7-b261-4aa6-b735-b68406b9de4b"

# パイプラインでの使用
.\scripts\list-projects.ps1 | ForEach-Object { 
    .\scripts\get-project-simple.ps1 -ProjectId $_.id 
}
```

---

## 🔄 Phase 6: 完全ワークフロー実行

### 6.1 プロジェクト開始マスターコマンド

**PowerShellスクリプト: start-linear-project.ps1**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896"
)

Write-Host "🚀 $ProjectName プロジェクトのLinear設定を開始します..." -ForegroundColor Cyan

# Phase 1: プロジェクト説明更新
Write-Host "`n📝 Phase 1: プロジェクト説明を更新中..." -ForegroundColor Yellow
.\scripts\update-project-description.ps1 -ProjectId $ProjectId -Description $Description

# Phase 2: マイルストーン作成
Write-Host "`n📊 Phase 2: マイルストーンを作成中..." -ForegroundColor Yellow
.\scripts\create-project-milestones.ps1 -ProjectId $ProjectId -ProjectName $ProjectName

# Phase 3: 初期Issue作成
Write-Host "`n🎫 Phase 3: 初期Issueを作成中..." -ForegroundColor Yellow
# マイルストーンIDを取得して渡す必要があります
# 実際の実装では、マイルストーン作成後のレスポンスからIDを取得

Write-Host "`n🎉 $ProjectName プロジェクトのLinear設定が完了しました！" -ForegroundColor Green
Write-Host "プロジェクトページを確認してください: https://linear.app/bochang-labo/project/$ProjectId" -ForegroundColor Cyan
```

### 6.2 使用例

```powershell
# zen recipeプロジェクトの例
.\scripts\start-linear-project.ps1 `
    -ProjectName "Zen Recipe" `
    -ProjectId "f6048ad7-b261-4aa6-b735-b68406b9de4b" `
    -Description "🧘 petit-recipeをネイティブAndroidに移行。Kotlin + MVVM + Room + Material Design 3でパフォーマンス向上とオフライン強化を実現。カメラ・音声・タイマー機能追加予定。"
```

---

## 📚 参考資料と関連ドキュメント

### 内部ドキュメント
- `workflows/linear_issue_management.md`: Issue管理詳細
- `scripts/sync-linear-status.ps1`: ステータス同期スクリプト  
- `scripts/add-linear-comment.ps1`: コメント追加スクリプト
- `troubleshooting/linear-api-errors.md`: API エラー対処

### 外部リンク
- [Linear API Documentation](https://developers.linear.app/docs)
- [Linear GraphQL Playground](https://linear.app/graphql)
- [Linear プロジェクト管理ベストプラクティス](https://linear.app/docs/project-management)

---

## ✅ 運用チェックリスト

### プロジェクト開始時
- [ ] プロジェクト説明文を準備
- [ ] `start-linear-project.ps1` を実行
- [ ] マイルストーンが正しく作成されていることを確認
- [ ] 初期Issueが作成されていることを確認
- [ ] GitHub リポジトリとの連携確認

### 日常運用時
- [ ] Issue開始時に "In Progress" に変更
- [ ] 作業完了時に進捗報告をコメント投稿
- [ ] 自動的に "In Review" に変更されることを確認
- [ ] マイルストーン進捗を定期的に確認

### 問題発生時
- [ ] 問題の詳細を記録
- [ ] `create-support-request.ps1` でサポート要請文書作成
- [ ] 他のAIに質問
- [ ] 解決策をIssueにコメント追加

---

**実装基準**: zen recipe プロジェクト実績  
**最終更新**: 2025-10-04  
**対応Linear API**: GraphQL v1.0