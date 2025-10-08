param(
    [Parameter(Mandatory=$true)]
    [string]$CommitMessage,
    
    [Parameter(Mandatory=$true)]
    [string]$IssueId,
    
    [string]$Branch = "main"
)

# GitHub自動Push & セキュリティチェック統合スクリプト
Write-Host "📤 GitHub自動Push開始" -ForegroundColor Cyan
Write-Host "コミットメッセージ: $CommitMessage" -ForegroundColor White

$result = @{
    success = $false
    commitHash = ""
    commitUrl = ""
    errors = @()
    warnings = @()
}

try {
    # Phase 1: Pre-Push セキュリティチェック
    Write-Host "`n🔒 Phase 1: セキュリティチェック実行中..." -ForegroundColor Yellow
    
    # APIキースキャン
    Write-Host "   APIキー漏洩チェック..." -ForegroundColor Gray
    $apiKeyScanResult = & "$PSScriptRoot\api-key-scanner.ps1" -Directory "."
    
    if ($apiKeyScanResult.detected) {
        $result.errors += "APIキー漏洩検出: $($apiKeyScanResult.files -join ', ')"
        Write-Host "   ❌ APIキー漏洩検出!" -ForegroundColor Red
        Write-Host "   検出ファイル: $($apiKeyScanResult.files -join ', ')" -ForegroundColor Red
        return $result
    } else {
        Write-Host "   ✅ APIキーセキュリティ: 問題なし" -ForegroundColor Green
    }
    
    # .gitignore 確認
    if (Test-Path ".gitignore") {
        $gitignoreContent = Get-Content ".gitignore" -Raw
        $requiredPatterns = @(".env", "*.key", "*-token", "*secret*", "*.pem")
        $missingPatterns = @()
        
        foreach ($pattern in $requiredPatterns) {
            if ($gitignoreContent -notmatch [regex]::Escape($pattern)) {
                $missingPatterns += $pattern
            }
        }
        
        if ($missingPatterns.Count -gt 0) {
            $result.warnings += ".gitignore に不足パターン: $($missingPatterns -join ', ')"
            Write-Host "   ⚠️ .gitignore に不足パターンがあります: $($missingPatterns -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ .gitignore: セキュリティパターン完備" -ForegroundColor Green
        }
    } else {
        $result.warnings += ".gitignore ファイルが存在しません"
        Write-Host "   ⚠️ .gitignore ファイルが存在しません" -ForegroundColor Yellow
    }
    
    # Phase 2: Pre-commit Hooks確認
    Write-Host "`n🪝 Phase 2: Pre-commit Hooks確認..." -ForegroundColor Yellow
    
    $preCommitPath = ".git/hooks/pre-commit"
    if (Test-Path $preCommitPath) {
        Write-Host "   ✅ Pre-commit hooks: 設定済み" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Pre-commit hooks: 未設定 - 自動設定中..." -ForegroundColor Yellow
        
        # Pre-commit hook作成
        $preCommitScript = @'
#!/bin/sh
# API Key Scanner Pre-commit Hook

echo "🔒 APIキー漏洩チェック実行中..."

# PowerShellスクリプトでAPIキーチェック
if command -v pwsh >/dev/null 2>&1; then
    SCAN_RESULT=$(pwsh -File scripts/api-key-scanner.ps1 -Directory ".")
    if [ $? -ne 0 ]; then
        echo "❌ APIキー漏洩が検出されました！"
        echo "コミットを中止します。"
        exit 1
    fi
else
    echo "⚠️ PowerShell未インストール - APIキーチェックをスキップ"
fi

echo "✅ セキュリティチェック通過"
exit 0
'@
        
        $preCommitScript | Out-File -FilePath $preCommitPath -Encoding UTF8
        
        # 実行権限付与（Windows環境での対応）
        if (Get-Command "chmod" -ErrorAction SilentlyContinue) {
            chmod +x $preCommitPath
        }
        
        Write-Host "   ✅ Pre-commit hooks: 自動設定完了" -ForegroundColor Green
    }
    
    # Phase 3: Git操作実行
    Write-Host "`n📋 Phase 3: Git操作実行..." -ForegroundColor Yellow
    
    # 現在のブランチ確認
    $currentBranch = git branch --show-current
    Write-Host "   現在のブランチ: $currentBranch" -ForegroundColor Gray
    
    # ステージング
    Write-Host "   ファイルをステージング中..." -ForegroundColor Gray
    git add .
    
    if ($LASTEXITCODE -ne 0) {
        $result.errors += "git add 失敗"
        Write-Host "   ❌ git add 失敗" -ForegroundColor Red
        return $result
    }
    
    # 変更確認
    $stagedFiles = git diff --cached --name-only
    if (-not $stagedFiles) {
        Write-Host "   ℹ️ コミットする変更がありません" -ForegroundColor Blue
        $result.success = $true
        $result.warnings += "コミットする変更がありませんでした"
        return $result
    }
    
    Write-Host "   ステージされたファイル: $($stagedFiles.Count) 件" -ForegroundColor Gray
    foreach ($file in $stagedFiles) {
        Write-Host "     - $file" -ForegroundColor DarkGray
    }
    
    # コミット実行
    Write-Host "   コミット実行中..." -ForegroundColor Gray
    $fullCommitMessage = @"
$CommitMessage

🤖 Generated with Claude Code - AI Assisted Workflow

Issue: $IssueId
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Co-Authored-By: Claude <noreply@anthropic.com>
"@
    
    git commit -m $fullCommitMessage
    
    if ($LASTEXITCODE -ne 0) {
        $result.errors += "git commit 失敗 - Pre-commit hook エラーの可能性"
        Write-Host "   ❌ git commit 失敗" -ForegroundColor Red
        return $result
    }
    
    # コミットハッシュ取得
    $result.commitHash = git rev-parse HEAD
    Write-Host "   ✅ コミット成功: $($result.commitHash.Substring(0,8))" -ForegroundColor Green
    
    # Phase 4: リモートプッシュ
    Write-Host "`n🌐 Phase 4: リモートプッシュ..." -ForegroundColor Yellow
    
    # リモートURL確認
    $remoteUrl = git remote get-url origin
    Write-Host "   リモートURL: $remoteUrl" -ForegroundColor Gray
    
    # プッシュ実行
    Write-Host "   GitHub へプッシュ中..." -ForegroundColor Gray
    git push origin $currentBranch
    
    if ($LASTEXITCODE -ne 0) {
        $result.errors += "git push 失敗 - 認証またはネットワークエラーの可能性"
        Write-Host "   ❌ git push 失敗" -ForegroundColor Red
        
        # 認証エラーの場合の詳細表示
        Write-Host "   🔧 トラブルシューティング:" -ForegroundColor Yellow
        Write-Host "   1. GitHub Token確認: cat `$env:USERPROFILE\.github-token" -ForegroundColor Gray
        Write-Host "   2. Git設定確認: git config --list | grep user" -ForegroundColor Gray
        Write-Host "   3. リモートURL確認: git remote -v" -ForegroundColor Gray
        
        return $result
    }
    
    Write-Host "   ✅ GitHub プッシュ成功" -ForegroundColor Green
    
    # Phase 5: 結果情報生成
    Write-Host "`n📊 Phase 5: 結果情報生成..." -ForegroundColor Yellow
    
    # コミットURL生成
    if ($remoteUrl -match "github\.com[:/](.+)/(.+)\.git$") {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $result.commitUrl = "https://github.com/$owner/$repo/commit/$($result.commitHash)"
    } elseif ($remoteUrl -match "github\.com[:/](.+)/(.+)$") {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $result.commitUrl = "https://github.com/$owner/$repo/commit/$($result.commitHash)"
    } else {
        $result.commitUrl = "$remoteUrl/commit/$($result.commitHash)"
    }
    
    $result.success = $true
    
    Write-Host "   ✅ コミットURL: $($result.commitUrl)" -ForegroundColor Green
    
    # サマリー表示
    Write-Host "`n🎉 GitHub Push完了！" -ForegroundColor Cyan
    Write-Host "📋 サマリー:" -ForegroundColor White
    Write-Host "   ✅ セキュリティチェック: 通過" -ForegroundColor Green
    Write-Host "   ✅ コミット: $($result.commitHash.Substring(0,8))" -ForegroundColor Green
    Write-Host "   ✅ プッシュ: 成功" -ForegroundColor Green
    Write-Host "   🔗 URL: $($result.commitUrl)" -ForegroundColor Cyan
    
    if ($result.warnings.Count -gt 0) {
        Write-Host "   ⚠️ 警告: $($result.warnings.Count) 件" -ForegroundColor Yellow
        foreach ($warning in $result.warnings) {
            Write-Host "     - $warning" -ForegroundColor Yellow
        }
    }
    
    return $result
    
} catch {
    $result.errors += "予期しないエラー: $($_.Exception.Message)"
    Write-Host "`n❌ Git操作エラー: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "スタックトレース:" -ForegroundColor Red
    Write-Host $_.Exception.StackTrace -ForegroundColor DarkRed
    
    return $result
}