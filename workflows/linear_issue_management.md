# Linear Issue & Project Management System (Windows版)

## 🔄 Linear プロジェクト & Issue統合管理システム

```powershell
# 完全プロジェクトライフサイクル管理:
1. プロジェクト開始 → 概要設定・マイルストーン作成・Issue作成
2. Issue読み取り開始 → status: "In Progress"
3. 作業実行・コード実装
4. 作業完了 → 内容・コード記録 → status: "In Review"
5. 問題発生時 → サポート要請文書自動生成
→ 許可不要の完全自動管理
```

## 🚀 新機能: プロジェクト開始ワークフロー

### プロジェクトマスターコマンド
```powershell
# zen recipeプロジェクトの例
.\scripts\start-linear-project.ps1 `
    -ProjectName "Zen Recipe" `
    -ProjectId "f6048ad7-b261-4aa6-b735-b68406b9de4b" `
    -Description "🧘 petit-recipeをネイティブAndroidに移行。Kotlin + MVVM + Room + Material Design 3でパフォーマンス向上とオフライン強化を実現。"
```

**自動実行内容**:
1. プロジェクト概要更新
2. 3つのマイルストーン作成（データレイヤー → UIレイヤー → 拡張機能）
3. 初期Issue準備
4. 設定確認レポート生成

---

## 📋 Linear Status管理ルール

**開始時**: Issue確認と同時に自動的に "In Progress" に変更
**完了時**: 作業内容とコードを記録後 "In Review" に変更
**コメント追加時**: **必ず** "In Review" に変更（必須自動実行）

### 実装方法（PowerShell）

```powershell
# Status更新 GraphQL
$mutation = @"
mutation {
  issueUpdate(
    id: "$issueId",
    input: { stateId: "$stateId" }
  ) {
    success
    issue { state { name } }
  }
}
"@

# State IDs (固定値):
$IN_PROGRESS_ID = "1cebb56e-524e-4de0-b676-0f574df9012a"
$IN_REVIEW_ID = "33feb1c9-3276-4e13-863a-0b93db032a0f"
```

---

## 🤖 自動実行コマンド (PowerShell)

### Issue開始時

```powershell
$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw
$issueId = "cff8f12c-d085-4e18-937a-2c07d402cfe8"  # 実際のIssue ID

$body = @{
    query = "mutation { issueUpdate(id: \`"$issueId\`", input: { stateId: \`"1cebb56e-524e-4de0-b676-0f574df9012a\`" }) { success } }"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.linear.app/graphql" `
    -Method Post `
    -Headers @{ "Authorization" = $linearKey; "Content-Type" = "application/json" } `
    -Body $body
```

### Issue完了時 / コメント追加時（必須）

```powershell
$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw
$issueId = "cff8f12c-d085-4e18-937a-2c07d402cfe8"

$body = @{
    query = "mutation { issueUpdate(id: \`"$issueId\`", input: { stateId: \`"33feb1c9-3276-4e13-863a-0b93db032a0f\`" }) { success } }"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.linear.app/graphql" `
    -Method Post `
    -Headers @{ "Authorization" = $linearKey; "Content-Type" = "application/json" } `
    -Body $body
```

---

## 🔄 必須プロセス: コメント追加時の検証

**重要ルール**: Linearコメント追加後、**即座に**検証システム実行

```powershell
# 1. コメント追加（PowerShell関数使用）
Add-LinearComment -IssueId "BOC-XX" -Body "作業完了報告"

# 2. 即座に検証（絶対必須実行）
Get-LinearIssue -IssueId "BOC-XX"

# 3. 検証チェック: 最新コメント存在確認
# 最新createdAtタイムスタンプが追加時刻と一致しているか確認
# 不一致の場合 → 緊急: 自動化システム障害として対応
```

### 適用ケース
- 作業完了コメント
- 追加レポート・分析結果
- エラー訂正報告
- 進捗更新
- 技術的知見追加

---

## 📜 PowerShell自動化スクリプト

### scripts/sync-linear-status.ps1

```powershell
# Linear Issueステータス自動更新スクリプト
param(
    [Parameter(Mandatory=$true)]
    [string]$IssueId,

    [Parameter(Mandatory=$true)]
    [ValidateSet("InProgress", "InReview")]
    [string]$Status
)

# State ID マッピング
$stateIds = @{
    "InProgress" = "1cebb56e-524e-4de0-b676-0f574df9012a"
    "InReview" = "33feb1c9-3276-4e13-863a-0b93db032a0f"
}

# APIキー読み込み
$linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw -ErrorAction Stop

# GraphQL mutation
$mutation = @"
mutation {
  issueUpdate(
    id: \"$IssueId\",
    input: { stateId: \"$($stateIds[$Status])\" }
  ) {
    success
    issue {
      id
      identifier
      state { name }
    }
  }
}
"@

$body = @{ query = $mutation } | ConvertTo-Json

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $body

    if ($response.data.issueUpdate.success) {
        Write-Host "✅ Status updated to $Status" -ForegroundColor Green
        Write-Host "   Issue: $($response.data.issueUpdate.issue.identifier)" -ForegroundColor Cyan
        Write-Host "   State: $($response.data.issueUpdate.issue.state.name)" -ForegroundColor Yellow
    } else {
        Write-Error "Status update failed"
    }
} catch {
    Write-Error "API Error: $_"
}
```

### 使用例

```powershell
# Issue開始
.\scripts\sync-linear-status.ps1 -IssueId "cff8f12c-d085-4e18-937a-2c07d402cfe8" -Status InProgress

# Issue完了
.\scripts\sync-linear-status.ps1 -IssueId "cff8f12c-d085-4e18-937a-2c07d402cfe8" -Status InReview
```

---

## 📝 コメント追加関数

### Add-LinearComment.ps1

```powershell
function Add-LinearComment {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IssueId,

        [Parameter(Mandatory=$true)]
        [string]$Body
    )

    $linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw

    $mutation = @"
mutation {
  commentCreate(
    input: {
      issueId: \"$IssueId\",
      body: \"$($Body -replace '"', '\"')\"
    }
  ) {
    success
    comment {
      id
      createdAt
      body
    }
  }
}
"@

    $requestBody = @{ query = $mutation } | ConvertTo-Json

    $response = Invoke-RestMethod `
        -Uri "https://api.linear.app/graphql" `
        -Method Post `
        -Headers @{
            "Authorization" = $linearKey
            "Content-Type" = "application/json"
        } `
        -Body $requestBody

    if ($response.data.commentCreate.success) {
        Write-Host "✅ Comment added successfully" -ForegroundColor Green
        Write-Host "   Comment ID: $($response.data.commentCreate.comment.id)"
        Write-Host "   Created At: $($response.data.commentCreate.comment.createdAt)"

        # 自動的にステータスを"In Review"に変更
        .\scripts\sync-linear-status.ps1 -IssueId $IssueId -Status InReview
    } else {
        Write-Error "Failed to add comment"
    }
}
```

---

## 🔗 Linear API統合

**常にGraphQL API使用**（CLIは動作しない）

```powershell
# エンドポイント
$uri = "https://api.linear.app/graphql"

# 認証
$headers = @{
    "Authorization" = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw
    "Content-Type" = "application/json"
}

# 固定チームID
$teamId = Get-Content "$env:USERPROFILE\.linear-team-id" -Raw
# = "bochang's lab"
```

---

## 🚨 トラブルシューティング

### エラー1: `Cannot find path '\.linear-api-key'`

**原因**: APIキーファイル未作成
**対処**:
```powershell
# APIキー保存
echo "lin_api_your_key_here" > $env:USERPROFILE\.linear-api-key

# 確認
cat $env:USERPROFILE\.linear-api-key
```

### エラー2: `Invoke-RestMethod: 401 Unauthorized`

**原因**: APIキー無効または形式エラー
**対処**:
```powershell
# APIキー再取得: https://linear.app/settings/api
# 形式確認: lin_api_xxxxx

# 再保存
echo "lin_api_new_key" > $env:USERPROFILE\.linear-api-key
```

### エラー3: GraphQL エラー

**原因**: Issue ID不正またはState ID間違い
**対処**:
```powershell
# Issue ID確認（Linear URLから）
# https://linear.app/team/issue/BOC-116
# → Issue ID: cff8f12c-d085-4e18-937a-2c07d402cfe8

# State ID確認（固定値使用）
$IN_PROGRESS_ID = "1cebb56e-524e-4de0-b676-0f574df9012a"
$IN_REVIEW_ID = "33feb1c9-3276-4e13-863a-0b93db032a0f"
```

---

## 📋 チェックリスト

### セットアップ
- [ ] `~\.linear-api-key` ファイル作成
- [ ] `~\.linear-team-id` ファイル作成
- [ ] `sync-linear-status.ps1` スクリプト配置
- [ ] API接続テスト成功

### 運用
- [ ] Issue開始時にステータス自動変更
- [ ] コメント追加時に "In Review" 自動設定
- [ ] 完了時の検証実施

---

---

## 🆘 問題発生時のサポート要請

### サポート要請文書自動生成
```powershell
.\scripts\create-support-request.ps1 `
    -ProjectName "Zen Recipe" `
    -ProblemSummary "Room Database設定でエラーが発生" `
    -ErrorMessage "Cannot find symbol: class RecipeDatabase" `
    -TechStack "Kotlin, Room, MVVM" `
    -Urgency "高"
```

**自動生成内容**:
- 構造化された問題レポート
- 技術的詳細テンプレート
- 他のAIへの質問用フォーマット
- クリップボード自動コピー

---

## 📚 関連ドキュメント

### 新規ワークフロー
- **workflows/linear-project-lifecycle-management.md**: 完全プロジェクト管理ワークフロー
- **templates/linear-project-setup-template.md**: プロジェクトセットアップテンプレート
- **scripts/start-linear-project.ps1**: プロジェクト開始マスターコマンド
- **scripts/create-support-request.ps1**: サポート要請文書生成

### 既存ドキュメント
- workflows/powershell-automation.md: PowerShell自動化
- scripts/sync-linear-status.ps1: 実装スクリプト
- troubleshooting/linear-api-errors.md: API エラー対処

### 実績プロジェクト
- **zen recipe**: プロジェクト管理ワークフロー実証済み
- **Linear Project**: https://linear.app/bochang-labo/project/zen-recipe-936f974b5deb

**Linear連携Issue**: BOC-116, BOC-120, BOC-121
