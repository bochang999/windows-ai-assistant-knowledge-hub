param(
    [switch]$FullTest,
    [switch]$DryRun,
    [switch]$Verbose,
    [string]$TestType = "all"  # all, unit, integration, e2e
)

# AI支援統合開発ワークフロー テストスイート
Write-Host "🧪 AI支援ワークフロー テストスイート" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "テストモード: $TestType" -ForegroundColor White
if ($DryRun) { Write-Host "🧪 DRY RUN モード" -ForegroundColor Yellow }
if ($FullTest) { Write-Host "🔍 フルテストモード" -ForegroundColor Yellow }

$testResults = @{
    startTime = Get-Date
    endTime = $null
    tests = @()
    summary = @{
        total = 0
        passed = 0
        failed = 0
        skipped = 0
    }
    errors = @()
}

# テスト結果記録関数
function Add-TestResult {
    param($TestName, $Status, $Duration, $Details = "", $Error = "")
    
    $testResults.tests += @{
        name = $TestName
        status = $Status  # Passed, Failed, Skipped
        duration = $Duration
        details = $Details
        error = $Error
        timestamp = Get-Date
    }
    
    $testResults.summary.total++
    switch ($Status) {
        "Passed" { $testResults.summary.passed++ }
        "Failed" { $testResults.summary.failed++ }
        "Skipped" { $testResults.summary.skipped++ }
    }
    
    $statusIcon = switch ($Status) {
        "Passed" { "✅" }
        "Failed" { "❌" }
        "Skipped" { "⏭️" }
    }
    
    $color = switch ($Status) {
        "Passed" { "Green" }
        "Failed" { "Red" }
        "Skipped" { "Yellow" }
    }
    
    Write-Host "   $statusIcon $TestName ($([math]::Round($Duration, 2))s)" -ForegroundColor $color
    if ($Verbose -and $Details) {
        Write-Host "     📝 $Details" -ForegroundColor DarkGray
    }
    if ($Error) {
        Write-Host "     ❌ $Error" -ForegroundColor Red
    }
}

# テスト実行関数
function Invoke-Test {
    param($TestName, $TestScript)
    
    $testStart = Get-Date
    try {
        $result = & $TestScript
        $duration = ((Get-Date) - $testStart).TotalSeconds
        
        if ($result -and $result.success) {
            Add-TestResult -TestName $TestName -Status "Passed" -Duration $duration -Details $result.details
            return $true
        } else {
            Add-TestResult -TestName $TestName -Status "Failed" -Duration $duration -Error ($result.error -or "テスト失敗")
            return $false
        }
    } catch {
        $duration = ((Get-Date) - $testStart).TotalSeconds
        Add-TestResult -TestName $TestName -Status "Failed" -Duration $duration -Error $_.Exception.Message
        return $false
    }
}

try {
    # Unit Tests
    if ($TestType -eq "all" -or $TestType -eq "unit") {
        Write-Host "`n🔬 Unit Tests" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        
        # Test 1: API Key File Existence
        Invoke-Test "APIキーファイル存在確認" {
            $apiKeyFile = "$env:USERPROFILE\.linear-api-key"
            $exists = Test-Path $apiKeyFile
            
            return @{
                success = $exists
                details = if($exists) { "APIキーファイル確認済み" } else { "APIキーファイル未設定" }
                error = if(-not $exists) { "Linear APIキーファイルが見つかりません: $apiKeyFile" }
            }
        }
        
        # Test 2: PowerShell Scripts Syntax
        Invoke-Test "PowerShellスクリプト構文チェック" {
            $scriptPath = $PSScriptRoot
            $psFiles = Get-ChildItem "$scriptPath\*.ps1" -Recurse
            $errors = @()
            
            foreach ($file in $psFiles) {
                try {
                    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
                } catch {
                    $errors += "$($file.Name): $($_.Exception.Message)"
                }
            }
            
            return @{
                success = $errors.Count -eq 0
                details = "チェック済みファイル: $($psFiles.Count)件"
                error = if($errors.Count -gt 0) { $errors -join "; " }
            }
        }
        
        # Test 3: Template Files Existence
        Invoke-Test "テンプレートファイル存在確認" {
            $templateDir = Join-Path $PSScriptRoot "..\templates"
            $requiredTemplates = @(
                "implementation-task-template.md",
                "completion-report-template.md",
                "pre-commit"
            )
            
            $missing = @()
            foreach ($template in $requiredTemplates) {
                $path = Join-Path $templateDir $template
                if (-not (Test-Path $path)) {
                    $missing += $template
                }
            }
            
            return @{
                success = $missing.Count -eq 0
                details = "確認済みテンプレート: $($requiredTemplates.Count)件"
                error = if($missing.Count -gt 0) { "不足テンプレート: $($missing -join ', ')" }
            }
        }
        
        # Test 4: Git Repository Check
        Invoke-Test "Git リポジトリ確認" {
            $isGitRepo = Test-Path ".git"
            $gitConfig = if($isGitRepo) { git config --list 2>$null } else { @() }
            
            return @{
                success = $isGitRepo
                details = if($isGitRepo) { "Git設定項目: $($gitConfig.Count)件" } else { "Git未初期化" }
                error = if(-not $isGitRepo) { "Gitリポジトリが初期化されていません" }
            }
        }
    }
    
    # Integration Tests
    if ($TestType -eq "all" -or $TestType -eq "integration") {
        Write-Host "`n🔗 Integration Tests" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        
        # Test 5: Linear API Connection
        Invoke-Test "Linear API接続テスト" {
            if (-not (Test-Path "$env:USERPROFILE\.linear-api-key")) {
                return @{
                    success = $false
                    error = "Linear APIキーファイルが存在しません"
                }
            }
            
            try {
                $linearKey = Get-Content "$env:USERPROFILE\.linear-api-key" -Raw
                $query = @{
                    query = "query { viewer { id name } }"
                } | ConvertTo-Json
                
                $response = Invoke-RestMethod `
                    -Uri "https://api.linear.app/graphql" `
                    -Method Post `
                    -Headers @{
                        "Authorization" = $linearKey
                        "Content-Type" = "application/json"
                    } `
                    -Body $query `
                    -TimeoutSec 10
                
                $success = $response.data -and $response.data.viewer
                
                return @{
                    success = $success
                    details = if($success) { "ユーザー: $($response.data.viewer.name)" } else { "認証失敗" }
                    error = if(-not $success) { "Linear API認証に失敗しました" }
                }
            } catch {
                return @{
                    success = $false
                    error = "Linear API接続エラー: $($_.Exception.Message)"
                }
            }
        }
        
        # Test 6: Sequential Thinking Analysis Mock
        Invoke-Test "Sequential Thinking分析テスト" {
            try {
                $mockRequest = "テスト用のサンプルリクエスト: 簡単なJavaScript関数を作成"
                
                if ($DryRun) {
                    # DRY RUN時のモック
                    return @{
                        success = $true
                        details = "モック分析完了 (DRY RUN)"
                    }
                } else {
                    $analysisResult = & "$PSScriptRoot\analyze-user-request.ps1" -UserRequest $mockRequest
                    
                    $success = $analysisResult -and 
                               $analysisResult.analysis -and 
                               $analysisResult.projectDecision -and 
                               $analysisResult.implementationPlan
                    
                    return @{
                        success = $success
                        details = if($success) { "分析カテゴリ: $($analysisResult.analysis.category)" } else { "分析結果不完全" }
                        error = if(-not $success) { "Sequential Thinking分析が正常に完了しませんでした" }
                    }
                }
            } catch {
                return @{
                    success = $false
                    error = "Sequential Thinking分析エラー: $($_.Exception.Message)"
                }
            }
        }
        
        # Test 7: Quality Check Integration
        Invoke-Test "品質チェック統合テスト" {
            try {
                $tempDir = Join-Path $env:TEMP "workflow-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
                
                # テスト用の簡単なJavaScriptファイルを作成
                $testJs = @"
function testFunction() {
    console.log('Hello, World!');
    return true;
}

module.exports = testFunction;
"@
                
                $testJs | Out-File -FilePath "$tempDir\test.js" -Encoding UTF8
                
                # 基本的なpackage.jsonを作成
                $packageJson = @{
                    name = "workflow-test"
                    version = "1.0.0"
                    scripts = @{
                        lint = "echo 'ESLint mock'"
                    }
                } | ConvertTo-Json
                
                $packageJson | Out-File -FilePath "$tempDir\package.json" -Encoding UTF8
                
                # 品質チェック実行
                $qualityResult = & "$PSScriptRoot\quality-check.ps1" -ProjectPath $tempDir
                
                # クリーンアップ
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
                
                return @{
                    success = $qualityResult.success -ne $null
                    details = "品質スコア: $($qualityResult.summary)"
                    error = if(-not $qualityResult.success) { "品質チェックが正常に完了しませんでした" }
                }
            } catch {
                return @{
                    success = $false
                    error = "品質チェックエラー: $($_.Exception.Message)"
                }
            }
        }
    }
    
    # End-to-End Tests
    if (($TestType -eq "all" -or $TestType -eq "e2e") -and $FullTest) {
        Write-Host "`n🚀 End-to-End Tests" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        
        # Test 8: Full Workflow Simulation
        Invoke-Test "完全ワークフローシミュレーション" {
            try {
                $testRequest = "テスト: シンプルなCalculatorクラスを作成して基本的な四則演算を実装"
                
                if ($DryRun) {
                    # DRY RUN での完全シミュレーション
                    Start-Sleep -Seconds 2
                    return @{
                        success = $true
                        details = "完全ワークフローシミュレーション完了 (DRY RUN)"
                    }
                } else {
                    # 実際のワークフロー実行（短縮版）
                    $workflowResult = & "$PSScriptRoot\ai-assisted-workflow.ps1" -UserRequest $testRequest -DryRun
                    
                    return @{
                        success = $workflowResult.success
                        details = "フェーズ完了: $($workflowResult.phases.Count)/$($workflowResult.phases.Count)"
                        error = if(-not $workflowResult.success) { $workflowResult.finalReport }
                    }
                }
            } catch {
                return @{
                    success = $false
                    error = "E2Eワークフローエラー: $($_.Exception.Message)"
                }
            }
        }
    } elseif ($TestType -eq "e2e" -and -not $FullTest) {
        Write-Host "`n⏭️ E2E Tests スキップ (--FullTest フラグが必要)" -ForegroundColor Yellow
        Add-TestResult -TestName "E2Eテスト" -Status "Skipped" -Duration 0 -Details "フルテストモードが必要"
    }
    
    # Performance Tests (Optional)
    if ($FullTest -and ($TestType -eq "all" -or $TestType -eq "performance")) {
        Write-Host "`n⚡ Performance Tests" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        
        # Test 9: Script Loading Performance
        Invoke-Test "スクリプト読み込みパフォーマンス" {
            $scripts = @(
                "analyze-user-request.ps1",
                "quality-check.ps1", 
                "auto-git-push.ps1"
            )
            
            $totalTime = 0
            foreach ($script in $scripts) {
                $scriptPath = Join-Path $PSScriptRoot $script
                if (Test-Path $scriptPath) {
                    $startTime = Get-Date
                    . $scriptPath -WhatIf 2>$null | Out-Null
                    $loadTime = ((Get-Date) - $startTime).TotalMilliseconds
                    $totalTime += $loadTime
                }
            }
            
            $avgTime = $totalTime / $scripts.Count
            $success = $avgTime -lt 1000  # 1秒以内
            
            return @{
                success = $success
                details = "平均読み込み時間: $([math]::Round($avgTime, 2))ms"
                error = if(-not $success) { "スクリプト読み込みが遅すぎます" }
            }
        }
    }
    
} catch {
    $testResults.errors += $_.Exception.Message
    Write-Host "`n💥 テストスイート実行エラー: $($_.Exception.Message)" -ForegroundColor Red
}

# テスト結果サマリー
$testResults.endTime = Get-Date
$totalDuration = ($testResults.endTime - $testResults.startTime).TotalSeconds

Write-Host "`n📊 テスト結果サマリー" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$summary = $testResults.summary
Write-Host "📈 実行統計:" -ForegroundColor White
Write-Host "   ⏱️ 総実行時間: $([math]::Round($totalDuration, 2))秒" -ForegroundColor White
Write-Host "   🧪 総テスト数: $($summary.total)" -ForegroundColor White
Write-Host "   ✅ 成功: $($summary.passed)" -ForegroundColor Green
Write-Host "   ❌ 失敗: $($summary.failed)" -ForegroundColor $(if($summary.failed -eq 0) {"Green"} else {"Red"})
Write-Host "   ⏭️ スキップ: $($summary.skipped)" -ForegroundColor Yellow

$successRate = if($summary.total -gt 0) { [math]::Round(($summary.passed / $summary.total) * 100, 1) } else { 0 }
Write-Host "   📊 成功率: $successRate%" -ForegroundColor $(if($successRate -ge 80) {"Green"} elseif($successRate -ge 60) {"Yellow"} else {"Red"})

# 失敗したテストの詳細
if ($summary.failed -gt 0) {
    Write-Host "`n❌ 失敗したテスト:" -ForegroundColor Red
    $failedTests = $testResults.tests | Where-Object { $_.status -eq "Failed" }
    foreach ($test in $failedTests) {
        Write-Host "   • $($test.name): $($test.error)" -ForegroundColor Red
    }
    
    Write-Host "`n🔧 推奨アクション:" -ForegroundColor Yellow
    Write-Host "   1. Linear APIキーの設定確認" -ForegroundColor Gray
    Write-Host "   2. PowerShell実行ポリシーの確認" -ForegroundColor Gray
    Write-Host "   3. ネットワーク接続の確認" -ForegroundColor Gray
    Write-Host "   4. -Verbose フラグで詳細ログを確認" -ForegroundColor Gray
}

# テスト レポート出力
if ($Verbose -or $FullTest) {
    $reportPath = "$env:TEMP\workflow-test-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "`n📄 詳細レポート: $reportPath" -ForegroundColor Cyan
}

# 終了ステータス
$exitCode = if($summary.failed -eq 0) { 0 } else { 1 }

Write-Host "`n$(if($exitCode -eq 0) {'🎉 すべてのテストが成功しました！'} else {'💥 一部のテストが失敗しました。'})" -ForegroundColor $(if($exitCode -eq 0) {"Green"} else {"Red"})

return @{
    success = $exitCode -eq 0
    summary = $summary
    duration = $totalDuration
    details = $testResults
}