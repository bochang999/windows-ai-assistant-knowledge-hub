# 🚀 AI支援統合開発ワークフロー - クイックスタートガイド

Sequential Thinking + Linear + GitHub + 品質管理を統合した**完全AI協業ワークフロー**のクイックスタートガイド。

---

## 🎯 このワークフローで実現できること

✅ **ユーザーリクエスト** → **Sequential Thinking分析** → **Linear Issue作成** → **Serena実装** → **品質チェック** → **GitHub Push** → **完了報告**

### 🤖 完全自動化された開発プロセス
1. **要求を入力** → AI が多段階思考で分析
2. **Linear管理** → プロジェクト・Issue自動作成
3. **Serena実装** → Claude Code による AI支援実装
4. **品質保証** → ESLint + Pre-commit hooks + APIキーチェック
5. **GitHub統合** → 自動Push + セキュリティ確認
6. **完了報告** → 自動生成レポート + Linear更新

---

## ⚡ 30秒クイックスタート

### 1. 前提条件確認
```powershell
# PowerShell 5.1+ 確認
$PSVersionTable.PSVersion

# 必要なAPIキー設定
Test-Path "$env:USERPROFILE\.linear-api-key"  # Linear API Key
Test-Path "$env:USERPROFILE\.github-token"    # GitHub Token
```

### 2. ワークフロー実行
```powershell
# メインワークフロー実行
.\scripts\ai-assisted-workflow.ps1 -UserRequest "あなたの実装要求をここに入力"

# 例: JavaScript関数作成
.\scripts\ai-assisted-workflow.ps1 -UserRequest "ユーザー認証機能付きのTodoアプリをReactで作成"
```

### 3. 完了確認
- ✅ Linear Issue自動作成・更新
- ✅ GitHub自動Push完了
- ✅ 品質チェック通過
- ✅ 完了報告自動生成

---

## 📋 詳細セットアップ (初回のみ)

### Step 1: APIキー設定
```powershell
# Linear API Key (https://linear.app/settings/api)
echo "lin_api_your_key_here" > $env:USERPROFILE\.linear-api-key

# GitHub Token (https://github.com/settings/tokens)
echo "ghp_your_token_here" > $env:USERPROFILE\.github-token

# Linear Team ID (https://linear.app/bochang-labo/team)
echo "your_team_id_here" > $env:USERPROFILE\.linear-team-id
```

### Step 2: Sequential Thinking MCP セットアップ
```powershell
# MCP Server インストール
npm install -g mcp-server-sequential-thinking

# Claude Desktop設定 (claude_desktop_config.json)
notepad $env:APPDATA\Claude\claude_desktop_config.json
```

**設定内容**:
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "mcp-server-sequential-thinking"]
    }
  }
}
```

### Step 3: 動作確認
```powershell
# テストスイート実行
.\scripts\test-ai-workflow.ps1

# 軽量テスト
.\scripts\test-ai-workflow.ps1 -TestType unit

# 完全テスト
.\scripts\test-ai-workflow.ps1 -FullTest
```

---

## 🎨 使用例・サンプル

### 🟨 JavaScript/React アプリ開発
```powershell
.\scripts\ai-assisted-workflow.ps1 -UserRequest "
天気予報APIを使用したReactアプリを作成。
- 現在地の天気表示
- 5日間の予報表示  
- レスポンシブデザイン
- Local Storage での都市保存機能
"
```

### 🟢 Android/Kotlin アプリ開発
```powershell
.\scripts\ai-assisted-workflow.ps1 -UserRequest "
タスク管理Androidアプリの改善:
- オフライン同期機能追加
- Material Design 3適用
- 通知機能強化
- SQLite → Room Database 移行
"
```

### 🔧 PowerShell自動化スクリプト
```powershell
.\scripts\ai-assisted-workflow.ps1 -UserRequest "
Linearプロジェクト管理の自動化スクリプト:
- 毎日のスタンドアップレポート自動生成
- Issue進捗の可視化
- GitHubコミットとLinear Issue自動紐付け
"
```

### 🛠️ バグ修正・改善
```powershell
.\scripts\ai-assisted-workflow.ps1 -UserRequest "
ESLintエラー修正とコード品質向上:
- 未使用変数の削除
- console.log の適切な置換
- 型安全性の向上
- パフォーマンス最適化
"
```

---

## 🔧 高度なオプション

### ドライランモード
```powershell
# 実際の変更なしでワークフローをテスト
.\scripts\ai-assisted-workflow.ps1 -UserRequest "テスト要求" -DryRun
```

### 詳細ログモード
```powershell
# 詳細なデバッグ情報を表示
.\scripts\ai-assisted-workflow.ps1 -UserRequest "要求" -Verbose
```

### 個別スクリプト実行
```powershell
# 要求分析のみ
.\scripts\analyze-user-request.ps1 -UserRequest "要求文"

# 品質チェックのみ
.\scripts\quality-check.ps1 -ProjectPath "." -FixIssues

# GitHub Push のみ
.\scripts\auto-git-push.ps1 -CommitMessage "実装完了" -IssueId "issue-id"
```

---

## 📊 ワークフロー構成要素

### 🧠 Sequential Thinking MCP
- **多段階思考分析**: 複雑な要求を構造化
- **仮説検証サイクル**: 試行錯誤の可視化
- **戦略立案支援**: Phase 4 思考フレームワーク

### 📋 Linear プロジェクト管理
- **自動プロジェクト作成**: 新規/既存判定
- **Issue手順書生成**: 実装タスクテンプレート
- **進捗自動更新**: Backlog → In Progress → In Review

### 💻 Serena (Claude Code) 実装
- **AI支援コーディング**: Claude Code による実装
- **技術環境セットアップ**: ESLint/Gradle等の自動設定
- **実装指示書生成**: 詳細な実装ガイドライン

### 🔍 品質チェック統合
- **ESLint自動実行**: エラー0件保証
- **セキュリティスキャン**: APIキー漏洩防止
- **Pre-commit hooks**: Git Push前の自動検証

### 📤 GitHub自動化
- **セキュアなPush**: Pre-commit hooks + APIキーチェック
- **自動コミットメッセージ**: AI支援ワークフロー情報付加
- **エラーハンドリング**: Push失敗時の詳細ガイダンス

### 📊 完了報告システム
- **自動レポート生成**: 実装内容・品質メトリクス
- **Linear自動更新**: ステータス変更 + コメント追加
- **トレーサビリティ**: 要求→完了まで完全記録

---

## 🏆 ベストプラクティス

### DO ✅
1. **明確な要求定義** - 具体的で実装可能な要求を記述
2. **Sequential Thinking活用** - 複雑な要求は多段階で分析
3. **品質チェック厳守** - ESLint通過とAPIキーセキュリティ確保
4. **継続的改善** - ワークフロー実行後のフィードバック活用

### DON'T ❌
1. ❌ 手動ステップの追加 - 自動化を破綻させない
2. ❌ 品質チェックのスキップ - セキュリティリスクを避ける
3. ❌ APIキーのハードコード - 必ずローカルファイルに保存
4. ❌ エラー時の無視 - トラブルシューティングを活用

---

## 🆘 トラブルシューティング

### よくある問題と解決策

#### ❌ Linear API接続エラー
```powershell
# APIキー確認
cat $env:USERPROFILE\.linear-api-key

# 権限確認
curl -H "Authorization: $(cat $env:USERPROFILE\.linear-api-key)" https://api.linear.app/graphql
```

#### ❌ GitHub Push 失敗
```powershell
# GitHub Token確認
cat $env:USERPROFILE\.github-token

# Git設定確認
git config --list | grep user
```

#### ❌ ESLint エラー
```powershell
# 自動修正実行
npm run lint:fix

# 設定ファイル確認
cat .eslintrc.json
```

#### ❌ PowerShell実行ポリシー
```powershell
# 実行ポリシー変更
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 参考資料

### 内部ドキュメント
- **[AI支援統合開発ワークフロー](workflows/ai-assisted-development-workflow.md)** - 完全技術仕様
- **[Sequential Thinking MCP](workflows/mcp-servers/sequential-thinking.md)** - 多段階思考ガイド
- **[Linear プロジェクト管理](workflows/linear-project-lifecycle-management.md)** - プロジェクト管理詳細

### 外部リンク
- **[Sequential Thinking MCP](https://github.com/sequentialthinking/mcp-server)** - MCP Server本体
- **[Linear API](https://developers.linear.app/docs)** - Linear GraphQL API
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** - Claude Code 公式ドキュメント

---

## 🎯 次のステップ

### 1. 基本習得 (1週間)
- [ ] サンプル要求でワークフロー実行
- [ ] 各フェーズの動作確認
- [ ] Linear Issue管理の理解

### 2. 実践活用 (1ヶ月)
- [ ] 実際のプロジェクトでの活用
- [ ] 品質指標の向上確認
- [ ] ワークフロー効率の測定

### 3. カスタマイズ (3ヶ月)
- [ ] プロジェクト固有の設定調整
- [ ] 追加品質チェックの実装
- [ ] チーム運用への展開

---

## 🤝 サポート・フィードバック

### 質問・課題報告
- **GitHub Issues**: [問題報告](https://github.com/bochang999/windows-ai-assistant-knowledge-hub/issues)
- **Linear Issue**: BOC-XXX Windows Code Mode統合

### 改善提案
- **ワークフロー改善**: 使用感フィードバック歓迎
- **新機能要求**: Sequential Thinking 活用パターン
- **ドキュメント改善**: より分かりやすい説明の提案

---

**🎉 AI支援統合開発ワークフローで、開発効率と品質を同時に向上させましょう！**

🤖 **Generated with Claude Code - AI Assisted Development Workflow v1.0**

**最終更新**: 2025-10-05
**対応環境**: Windows 10/11 + PowerShell 5.1+ + Claude Code
**ワークフロー**: Sequential Thinking + Linear + GitHub + 品質管理統合