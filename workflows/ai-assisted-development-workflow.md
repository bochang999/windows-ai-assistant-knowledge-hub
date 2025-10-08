# AI支援統合開発ワークフロー

Sequential Thinking MCP + Linear + GitHub + 品質管理を統合した完全AI協業ワークフロー。

---

## 🎯 ワークフロー概要

### 目的
ユーザーリクエストから完了報告まで、AI支援による完全自動化開発プロセス。

### 処理フロー
```
ユーザーリクエスト
    ↓ (1) 要求分析
Sequential Thinking MCP（多段階思考）
    ↓ (2) プロジェクト判定
Linear プロジェクト作成/既存確認
    ↓ (3) 作業計画
Linear Issue作成（手順書形式）
    ↓ (4) 実装作業
Serena（Claude Code）による開発
    ↓ (5) 品質チェック
ESLint + Pre-commit hooks
    ↓ (6) バージョン管理
GitHub自動Push
    ↓ (7) 完了報告
Linear Issue更新（In Review）
```

---

## 📋 Phase 1: ユーザーリクエスト分析

### 1.1 Sequential Thinking による要求分析

**実行コマンド**:
```powershell
.\scripts\analyze-user-request.ps1 -UserRequest "ユーザーの要求文"
```

**思考プロセス**:
```javascript
// Step 1: 要求の分類
await sequentialthinking({
    thought: `ユーザー要求を分析:
    - 要求内容: [要求の詳細]
    - カテゴリ: [新機能/バグ修正/改善/その他]
    - 技術領域: [Frontend/Backend/Mobile/Infrastructure]
    - 優先度: [高/中/低]`,
    nextThoughtNeeded: true,
    thoughtNumber: 1,
    totalThoughts: 5
});

// Step 2: 技術実現性評価
await sequentialthinking({
    thought: `技術実現性チェック:
    - 利用可能技術: [技術スタック確認]
    - 複雑度評価: [簡単/中程度/複雑]
    - 工数見積もり: [時間数]
    - 依存関係: [必要な前提条件]`,
    nextThoughtNeeded: true,
    thoughtNumber: 2,
    totalThoughts: 5
});

// Step 3: プロジェクト判定
await sequentialthinking({
    thought: `プロジェクト種別判定:
    - 新規プロジェクト: [Yes/No + 理由]
    - 既存プロジェクト: [プロジェクトID特定]
    - マイルストーン: [新規作成/既存使用]`,
    nextThoughtNeeded: true,
    thoughtNumber: 3,
    totalThoughts: 5
});

// Step 4: 実装計画立案
await sequentialthinking({
    thought: `実装計画:
    Phase 1: [具体的なタスク1]
    Phase 2: [具体的なタスク2]
    Phase 3: [具体的なタスク3]
    合計工数: [時間]
    開始条件: [前提条件]`,
    nextThoughtNeeded: true,
    thoughtNumber: 4,
    totalThoughts: 5
});

// Step 5: 最終戦略確定
await sequentialthinking({
    thought: `最終実装戦略:
    - 採用アプローチ: [詳細手法]
    - 品質保証: [ESLint設定、テスト戦略]
    - 完了定義: [完了基準]
    - リスク対策: [想定リスクと対処法]`,
    nextThoughtNeeded: false,
    thoughtNumber: 5,
    totalThoughts: 5
});
```

### 1.2 分析結果の構造化

**出力フォーマット**:
```json
{
    "userRequest": "ユーザーの要求原文",
    "analysis": {
        "category": "新機能",
        "priority": "高",
        "complexity": "中程度",
        "estimatedHours": 4,
        "techStack": ["JavaScript", "Node.js", "React"]
    },
    "projectDecision": {
        "isNewProject": true,
        "projectName": "AI Chat Bot",
        "reason": "完全に新しい機能領域のため"
    },
    "implementationPlan": {
        "phases": [
            "Phase 1: 基盤アーキテクチャ設計",
            "Phase 2: UI/UX実装",
            "Phase 3: API統合とテスト"
        ],
        "strategy": "React + OpenAI API統合パターン"
    }
}
```

---

## 📊 Phase 2: Linear プロジェクト管理

### 2.1 新規プロジェクトの場合

**自動実行**:
```powershell
# 新規プロジェクト作成
.\scripts\create-new-project.ps1 `
    -ProjectName $analysis.projectDecision.projectName `
    -Description $analysis.implementationPlan.strategy

# 完全セットアップ実行
.\scripts\start-linear-project.ps1 `
    -ProjectName $projectName `
    -ProjectId $createdProjectId `
    -Description $description
```

### 2.2 既存プロジェクトの場合

**Issue作成**:
```powershell
# 既存プロジェクトにIssue追加
.\scripts\create-implementation-issue.ps1 `
    -ProjectId $existingProjectId `
    -UserRequest $userRequest `
    -ImplementationPlan $implementationPlan
```

### 2.3 作業手順書Issue生成

**テンプレート**: `templates/implementation-task-template.md`
```markdown
## 🚀 [要求タイトル] 実装タスク

### 📋 ユーザー要求
[ユーザーの要求原文]

### 🎯 実装目標
- **目標1**: [具体的な達成目標]
- **目標2**: [具体的な達成目標]
- **目標3**: [具体的な達成目標]

### 🏗️ 技術仕様
- **技術スタック**: [技術リスト]
- **アーキテクチャ**: [設計パターン]
- **依存関係**: [必要な前提条件]

### 📝 実装手順
#### Phase 1: [フェーズ名]
- [ ] **[タスク1]**: [具体的な作業内容]
- [ ] **[タスク2]**: [具体的な作業内容]
- [ ] **[タスク3]**: [具体的な作業内容]

#### Phase 2: [フェーズ名]
- [ ] **[タスク1]**: [具体的な作業内容]
- [ ] **[タスク2]**: [具体的な作業内容]

#### Phase 3: [フェーズ名]
- [ ] **[タスク1]**: [具体的な作業内容]
- [ ] **[タスク2]**: [具体的な作業内容]

### ✅ 完了定義
- [ ] 機能要件すべて実装完了
- [ ] ESLint品質チェック通過
- [ ] Pre-commit hooks設定完了
- [ ] GitHub Push完了
- [ ] 動作テスト完了

### 🔗 関連リンク
- **GitHub Repository**: [リポジトリURL]
- **Linear Project**: [プロジェクトURL]

🤖 **Generated with Claude Code - AI Assisted Workflow**
```

---

## 💻 Phase 3: Serena実装作業

### 3.1 実装作業の自動開始

**実行コマンド**:
```powershell
.\scripts\execute-implementation.ps1 `
    -IssueId $issueId `
    -ImplementationPlan $plan `
    -WorkingDirectory $projectPath
```

### 3.2 実装作業プロセス

```powershell
# Issue開始通知
.\scripts\sync-linear-status.ps1 -IssueId $issueId -Status InProgress

# Serena（Claude Code）による実装
Write-Host "🤖 Claude Code (Serena) による実装作業を開始..." -ForegroundColor Cyan

# 実装作業（ここでClaude Codeが実際の開発を行う）
# - ファイル作成・編集
# - コード実装
# - 設定ファイル更新
# - ドキュメント作成

Write-Host "✅ 実装作業完了" -ForegroundColor Green
```

### 3.3 実装ログの記録

**ログフォーマット**:
```json
{
    "implementationLog": {
        "startTime": "2025-10-05T10:00:00Z",
        "endTime": "2025-10-05T14:30:00Z",
        "filesCreated": [
            "src/components/ChatBot.jsx",
            "src/api/openai.js",
            "tests/chatbot.test.js"
        ],
        "filesModified": [
            "package.json",
            "src/App.jsx",
            ".eslintrc.js"
        ],
        "technicalDetails": {
            "linesOfCode": 450,
            "testCoverage": "85%",
            "eslintErrors": 0,
            "eslintWarnings": 2
        }
    }
}
```

---

## 🔍 Phase 4: 品質チェック

### 4.1 ESLint品質チェック

**自動実行**:
```powershell
# ESLint実行
Write-Host "🔍 ESLint品質チェック実行中..." -ForegroundColor Yellow

npm run lint
$eslintExitCode = $LASTEXITCODE

if ($eslintExitCode -eq 0) {
    Write-Host "✅ ESLint: 品質チェック通過" -ForegroundColor Green
} else {
    Write-Host "❌ ESLint: 品質問題検出" -ForegroundColor Red
    Write-Host "自動修正を試行中..." -ForegroundColor Yellow
    npm run lint:fix
    
    # 再チェック
    npm run lint
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ESLint: 自動修正完了" -ForegroundColor Green
    } else {
        Write-Host "⚠️ ESLint: 手動対応が必要な問題があります" -ForegroundColor Red
        exit 1
    }
}
```

### 4.2 Pre-commit Hooks検証

**APIキー漏洩チェック**:
```powershell
# APIキースキャン実行
.\scripts\api-key-scanner.ps1 -Directory $projectPath

# Git hooks検証
if (Test-Path ".git/hooks/pre-commit") {
    Write-Host "✅ Pre-commit hooks: 設定済み" -ForegroundColor Green
} else {
    Write-Host "⚠️ Pre-commit hooks: 設定中..." -ForegroundColor Yellow
    Copy-Item "templates/pre-commit" ".git/hooks/pre-commit"
    chmod +x .git/hooks/pre-commit
    Write-Host "✅ Pre-commit hooks: 設定完了" -ForegroundColor Green
}
```

---

## 📤 Phase 5: GitHub自動Push

### 5.1 Git操作の自動化

**実行コマンド**:
```powershell
.\scripts\auto-git-push.ps1 `
    -CommitMessage "実装完了: $userRequestSummary" `
    -IssueId $issueId
```

**実装**:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$CommitMessage,
    
    [Parameter(Mandatory=$true)]
    [string]$IssueId
)

Write-Host "📤 Git操作を開始..." -ForegroundColor Cyan

# ステージング
git add .

# Pre-commit hooks実行（APIキーチェック等）
Write-Host "🔒 Pre-commit検証実行中..." -ForegroundColor Yellow
$preCommitResult = git commit -m "$CommitMessage`n`n🤖 Generated with Claude Code`n`nCo-Authored-By: Claude <noreply@anthropic.com>"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Pre-commit検証通過" -ForegroundColor Green
    
    # リモートプッシュ
    Write-Host "📤 GitHub へ Push 中..." -ForegroundColor Yellow
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHub Push 完了" -ForegroundColor Green
        
        # 最新コミットURLを取得
        $commitHash = git rev-parse HEAD
        $repoUrl = git remote get-url origin
        $commitUrl = $repoUrl -replace "\.git$", "/commit/$commitHash"
        
        return @{
            success = $true
            commitHash = $commitHash
            commitUrl = $commitUrl
        }
    } else {
        Write-Host "❌ GitHub Push 失敗" -ForegroundColor Red
        return @{ success = $false }
    }
} else {
    Write-Host "❌ Pre-commit検証失敗" -ForegroundColor Red
    return @{ success = $false }
}
```

---

## 📊 Phase 6: 完了報告とLinear更新

### 6.1 作業報告書の自動生成

**テンプレート**: `templates/completion-report-template.md`
```markdown
## 📊 [要求タイトル] 実装完了報告

### ✅ 完了済みタスク
[実装ログから自動生成されるタスクリスト]

### 🏗️ 実装内容
#### 新規作成ファイル
[filesCreated から自動生成]

#### 変更ファイル
[filesModified から自動生成]

### 📈 品質メトリクス
- **コード行数**: [linesOfCode]
- **ESLint状態**: ✅ 通過 (エラー: 0, 警告: [warnings])
- **テストカバレッジ**: [testCoverage]
- **API キーセキュリティ**: ✅ 漏洩なし

### 🔗 関連リンク
- **GitHub Commit**: [commitUrl]
- **実装ファイル**: [実装ファイルのリスト]

### 🎯 完了確認
- [x] **機能要件**: 全て実装完了
- [x] **品質チェック**: ESLint通過
- [x] **セキュリティ**: Pre-commit hooks設定・実行
- [x] **バージョン管理**: GitHub Push完了

🤖 **Generated with Claude Code - AI Assisted Development Workflow**
```

### 6.2 Linear Issue更新

**自動実行**:
```powershell
# 完了報告投稿
.\scripts\add-completion-report.ps1 `
    -IssueId $issueId `
    -ReportContent $completionReport `
    -CommitUrl $commitUrl

# ステータス更新
.\scripts\sync-linear-status.ps1 -IssueId $issueId -Status InReview

Write-Host "🎉 AI支援開発ワークフロー完了！" -ForegroundColor Green
```

---

## 🚀 Phase 7: マスターワークフロー実行

### 7.1 統合コマンド

**実行コマンド**:
```powershell
.\scripts\ai-assisted-workflow.ps1 -UserRequest "ユーザーの要求文"
```

### 7.2 完全自動化フロー

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$UserRequest
)

Write-Host "🤖 AI支援統合開発ワークフロー開始" -ForegroundColor Cyan
Write-Host "ユーザー要求: $UserRequest" -ForegroundColor White

try {
    # Phase 1: Sequential Thinking分析
    Write-Host "`n🧠 Phase 1: 要求分析中..." -ForegroundColor Yellow
    $analysis = .\scripts\analyze-user-request.ps1 -UserRequest $UserRequest
    
    # Phase 2: Linear プロジェクト管理
    Write-Host "`n📊 Phase 2: プロジェクト管理..." -ForegroundColor Yellow
    if ($analysis.projectDecision.isNewProject) {
        $project = .\scripts\create-new-project.ps1 -ProjectName $analysis.projectDecision.projectName -Description $analysis.implementationPlan.strategy
        .\scripts\start-linear-project.ps1 -ProjectName $project.name -ProjectId $project.id -Description $analysis.implementationPlan.strategy
    }
    $issue = .\scripts\create-implementation-issue.ps1 -ProjectId $project.id -UserRequest $UserRequest -ImplementationPlan $analysis.implementationPlan
    
    # Phase 3: Serena実装
    Write-Host "`n💻 Phase 3: 実装作業..." -ForegroundColor Yellow
    $implementation = .\scripts\execute-implementation.ps1 -IssueId $issue.id -ImplementationPlan $analysis.implementationPlan
    
    # Phase 4: 品質チェック
    Write-Host "`n🔍 Phase 4: 品質チェック..." -ForegroundColor Yellow
    $quality = .\scripts\quality-check.ps1 -ProjectPath $implementation.projectPath
    
    # Phase 5: GitHub Push
    Write-Host "`n📤 Phase 5: GitHub Push..." -ForegroundColor Yellow
    $gitResult = .\scripts\auto-git-push.ps1 -CommitMessage "実装完了: $($analysis.implementationPlan.summary)" -IssueId $issue.id
    
    # Phase 6: 完了報告
    Write-Host "`n📊 Phase 6: 完了報告..." -ForegroundColor Yellow
    $report = .\scripts\generate-completion-report.ps1 -Implementation $implementation -Quality $quality -GitResult $gitResult
    .\scripts\add-completion-report.ps1 -IssueId $issue.id -ReportContent $report -CommitUrl $gitResult.commitUrl
    .\scripts\sync-linear-status.ps1 -IssueId $issue.id -Status InReview
    
    Write-Host "`n🎉 AI支援開発ワークフロー完了！" -ForegroundColor Green
    Write-Host "Linear Issue: https://linear.app/bochang-labo/issue/$($issue.identifier)" -ForegroundColor Cyan
    Write-Host "GitHub Commit: $($gitResult.commitUrl)" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n❌ ワークフローエラー: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "デバッグ情報をLinearに記録中..." -ForegroundColor Yellow
    .\scripts\create-support-request.ps1 -ProjectName $project.name -ProblemSummary $_.Exception.Message -ErrorMessage $_.Exception.StackTrace
}
```

---

## 📚 ベストプラクティス

### DO ✅

1. **明確な要求定義**
   - ユーザー要求は具体的に
   - 期待結果を明示

2. **段階的品質管理**
   - ESLint → Pre-commit → Git Push の順序厳守
   - 各段階での自動チェック

3. **完全なトレーサビリティ**
   - 要求から完了まで全記録
   - Linear Issue URLとGitHub Commitの紐付け

### DON'T ❌

1. ❌ 手動ステップを残さない
2. ❌ 品質チェックをスキップしない
3. ❌ API キーを含むファイルをコミットしない
4. ❌ エラー時の自動復旧機能を無視しない

---

## 🔧 トラブルシューティング

### よくあるエラーと対処法

#### ESLint エラー
```powershell
# 自動修正試行
npm run lint:fix

# 設定確認
cat .eslintrc.js
```

#### Pre-commit Hook失敗
```powershell
# Hook再設定
Copy-Item "templates/pre-commit" ".git/hooks/pre-commit"
chmod +x .git/hooks/pre-commit
```

#### GitHub Push失敗
```powershell
# 認証確認
git config --list | grep user
cat $env:USERPROFILE\.github-token
```

---

## 📋 実行チェックリスト

### 事前準備
- [ ] Sequential Thinking MCP 動作確認
- [ ] Linear API Key 設定完了
- [ ] GitHub Token 設定完了
- [ ] ESLint 設定完了
- [ ] Pre-commit hooks 設定完了

### 実行時確認
- [ ] ユーザー要求の明確化
- [ ] Sequential Thinking 分析完了
- [ ] Linear Issue 作成完了
- [ ] 実装作業完了
- [ ] 品質チェック通過
- [ ] GitHub Push 成功
- [ ] 完了報告投稿完了

---

**最終更新**: 2025-10-05
**バージョン**: 1.0.0
**対応環境**: Windows AI Assistant Knowledge Hub