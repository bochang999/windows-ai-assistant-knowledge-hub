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
``````
$ErrorMessage
``````

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
try {
    $template | Set-Clipboard
    Write-Host "✅ クリップボードにコピーしました" -ForegroundColor Cyan
} catch {
    Write-Host "⚠️ クリップボードへのコピーに失敗しました。手動でファイルを開いてください。" -ForegroundColor Yellow
}

# ファイルを開く
try {
    Start-Process notepad.exe -ArgumentList $outputPath
} catch {
    Write-Host "📂 ファイルパス: $outputPath" -ForegroundColor Gray
}