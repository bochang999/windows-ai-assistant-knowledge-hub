param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [switch]$FixIssues,
    [switch]$Verbose
)

# ESLint + 品質チェック統合スクリプト
Write-Host "🔍 品質チェック開始" -ForegroundColor Cyan
Write-Host "プロジェクトパス: $ProjectPath" -ForegroundColor White

$result = @{
    success = $false
    eslint = @{
        errors = 0
        warnings = 0
        fixedIssues = 0
        status = "未実行"
    }
    security = @{
        apiKeyLeaks = @()
        vulnerabilities = @()
        status = "未実行"
    }
    metrics = @{
        linesOfCode = 0
        testCoverage = "0%"
        fileCount = 0
    }
    summary = ""
}

# プロジェクトディレクトリに移動
$originalLocation = Get-Location
Set-Location $ProjectPath

try {
    # Phase 1: プロジェクト構造分析
    Write-Host "`n📊 Phase 1: プロジェクト構造分析..." -ForegroundColor Yellow
    
    # ファイル数とコード行数カウント
    $codeFiles = Get-ChildItem -Recurse -Include "*.js", "*.jsx", "*.ts", "*.tsx", "*.java", "*.kt", "*.py" | Where-Object { $_.FullName -notmatch "node_modules|\.git|build|dist" }
    $result.metrics.fileCount = $codeFiles.Count
    
    $totalLines = 0
    foreach ($file in $codeFiles) {
        $lines = (Get-Content $file.FullName -ErrorAction SilentlyContinue).Count
        $totalLines += $lines
    }
    $result.metrics.linesOfCode = $totalLines
    
    Write-Host "   ✅ ファイル数: $($result.metrics.fileCount) | コード行数: $($result.metrics.linesOfCode)" -ForegroundColor Green
    
    # Phase 2: ESLint品質チェック
    Write-Host "`n🔍 Phase 2: ESLint品質チェック..." -ForegroundColor Yellow
    
    # package.jsonの存在確認
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        
        # ESLint設定確認
        $eslintConfigFiles = @(".eslintrc.js", ".eslintrc.json", ".eslintrc.yml", "eslint.config.js")
        $eslintConfigExists = $false
        
        foreach ($configFile in $eslintConfigFiles) {
            if (Test-Path $configFile) {
                $eslintConfigExists = $true
                Write-Host "   ✅ ESLint設定ファイル検出: $configFile" -ForegroundColor Green
                break
            }
        }
        
        if (-not $eslintConfigExists) {
            Write-Host "   ⚠️ ESLint設定ファイルが見つかりません" -ForegroundColor Yellow
            
            # 基本的なESLint設定を作成
            $basicEslintConfig = @{
                env = @{
                    browser = $true
                    es2021 = $true
                    node = $true
                }
                extends = @("eslint:recommended")
                parserOptions = @{
                    ecmaVersion = "latest"
                    sourceType = "module"
                }
                rules = @{
                    "no-unused-vars" = "warn"
                    "no-console" = "warn"
                }
            }
            
            $basicEslintConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath ".eslintrc.json" -Encoding UTF8
            Write-Host "   ✅ 基本的なESLint設定を作成しました" -ForegroundColor Green
        }
        
        # ESLint実行
        Write-Host "   ESLint実行中..." -ForegroundColor Gray
        
        # npm run lint が定義されているかチェック
        $hasLintScript = $false
        if ($packageJson.scripts -and $packageJson.scripts.lint) {
            $hasLintScript = $true
            Write-Host "   package.json lint スクリプト検出" -ForegroundColor Gray
        }
        
        if ($hasLintScript) {
            # npm run lint を実行
            $eslintOutput = npm run lint 2>&1
            $eslintExitCode = $LASTEXITCODE
        } else {
            # npx eslint を直接実行
            $eslintOutput = npx eslint . --ext .js,.jsx,.ts,.tsx 2>&1
            $eslintExitCode = $LASTEXITCODE
        }
        
        # ESLint結果解析
        $errorCount = 0
        $warningCount = 0
        
        if ($eslintOutput) {
            # エラー・警告数を抽出
            $eslintOutput | ForEach-Object {
                if ($_ -match "(\d+) error") {
                    $errorCount += [int]$Matches[1]
                }
                if ($_ -match "(\d+) warning") {
                    $warningCount += [int]$Matches[1]
                }
            }
        }
        
        $result.eslint.errors = $errorCount
        $result.eslint.warnings = $warningCount
        
        if ($eslintExitCode -eq 0) {
            $result.eslint.status = "通過"
            Write-Host "   ✅ ESLint: 品質チェック通過" -ForegroundColor Green
        } else {
            $result.eslint.status = "失敗"
            Write-Host "   ❌ ESLint: エラー $errorCount 件, 警告 $warningCount 件" -ForegroundColor Red
            
            if ($FixIssues) {
                Write-Host "   🔧 自動修正を試行中..." -ForegroundColor Yellow
                
                # 自動修正実行
                if ($hasLintScript -and $packageJson.scripts."lint:fix") {
                    $fixOutput = npm run lint:fix 2>&1
                } else {
                    $fixOutput = npx eslint . --ext .js,.jsx,.ts,.tsx --fix 2>&1
                }
                
                # 修正後に再チェック
                if ($hasLintScript) {
                    $recheckOutput = npm run lint 2>&1
                    $recheckExitCode = $LASTEXITCODE
                } else {
                    $recheckOutput = npx eslint . --ext .js,.jsx,.ts,.tsx 2>&1
                    $recheckExitCode = $LASTEXITCODE
                }
                
                if ($recheckExitCode -eq 0) {
                    $result.eslint.status = "自動修正完了"
                    $result.eslint.fixedIssues = $errorCount + $warningCount
                    Write-Host "   ✅ ESLint: 自動修正完了" -ForegroundColor Green
                } else {
                    Write-Host "   ⚠️ ESLint: 一部問題が残っています" -ForegroundColor Yellow
                }
            }
        }
        
        if ($Verbose -and $eslintOutput) {
            Write-Host "   ESLint詳細出力:" -ForegroundColor DarkGray
            $eslintOutput | ForEach-Object { Write-Host "     $_" -ForegroundColor DarkGray }
        }
        
    } else {
        Write-Host "   ℹ️ package.json が見つかりません - JavaScriptプロジェクトではない可能性" -ForegroundColor Blue
        $result.eslint.status = "適用外"
    }
    
    # Phase 3: セキュリティチェック
    Write-Host "`n🔒 Phase 3: セキュリティチェック..." -ForegroundColor Yellow
    
    # APIキー漏洩チェック
    Write-Host "   APIキー漏洩スキャン中..." -ForegroundColor Gray
    
    $apiKeyPatterns = @(
        "sk-[a-zA-Z0-9]{48}",           # OpenAI API Key
        "lin_api_[a-zA-Z0-9]+",         # Linear API Key
        "ghp_[a-zA-Z0-9]{36}",          # GitHub Personal Access Token
        "secret_[a-zA-Z0-9]{43}",       # Notion API Key
        "ctx7_[a-zA-Z0-9]+",            # Context7 API Key
        "AKIA[0-9A-Z]{16}",             # AWS Access Key
        "[a-zA-Z0-9]{32}-[a-zA-Z0-9]{16}" # Generic API Key Pattern
    )
    
    $suspiciousFiles = @()
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            foreach ($pattern in $apiKeyPatterns) {
                if ($content -match $pattern) {
                    $suspiciousFiles += $file.FullName
                    break
                }
            }
        }
    }
    
    $result.security.apiKeyLeaks = $suspiciousFiles
    
    if ($suspiciousFiles.Count -eq 0) {
        $result.security.status = "安全"
        Write-Host "   ✅ APIキー漏洩: 検出されませんでした" -ForegroundColor Green
    } else {
        $result.security.status = "警告"
        Write-Host "   ⚠️ 疑わしいファイル検出: $($suspiciousFiles.Count) 件" -ForegroundColor Yellow
        foreach ($file in $suspiciousFiles) {
            Write-Host "     - $file" -ForegroundColor Yellow
        }
    }
    
    # Phase 4: テストカバレッジ確認
    Write-Host "`n🧪 Phase 4: テストカバレッジ確認..." -ForegroundColor Yellow
    
    # テストファイル検索
    $testFiles = Get-ChildItem -Recurse -Include "*.test.js", "*.spec.js", "*.test.ts", "*.spec.ts" | Where-Object { $_.FullName -notmatch "node_modules" }
    
    if ($testFiles.Count -gt 0) {
        Write-Host "   ✅ テストファイル: $($testFiles.Count) 件検出" -ForegroundColor Green
        
        # Jest カバレッジ実行試行
        if (Test-Path "package.json") {
            $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
            if ($packageJson.scripts -and $packageJson.scripts."test:coverage") {
                Write-Host "   カバレッジ実行中..." -ForegroundColor Gray
                $coverageOutput = npm run test:coverage 2>&1
                
                # カバレッジ情報抽出
                $coverageOutput | ForEach-Object {
                    if ($_ -match "All files.*?(\d+\.?\d*)%") {
                        $result.metrics.testCoverage = "$($Matches[1])%"
                    }
                }
            }
        }
        
        Write-Host "   ✅ テストカバレッジ: $($result.metrics.testCoverage)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ テストファイルが見つかりません" -ForegroundColor Yellow
        $result.metrics.testCoverage = "0%"
    }
    
    # Phase 5: 総合評価
    Write-Host "`n📊 Phase 5: 総合評価..." -ForegroundColor Yellow
    
    $score = 100
    $issues = @()
    
    # ESLint評価
    if ($result.eslint.status -eq "失敗") {
        $score -= ($result.eslint.errors * 10 + $result.eslint.warnings * 2)
        $issues += "ESLint: エラー $($result.eslint.errors) 件, 警告 $($result.eslint.warnings) 件"
    }
    
    # セキュリティ評価
    if ($result.security.status -eq "警告") {
        $score -= ($result.security.apiKeyLeaks.Count * 25)
        $issues += "セキュリティ: 疑わしいファイル $($result.security.apiKeyLeaks.Count) 件"
    }
    
    # テストカバレッジ評価
    $coverageNumber = [int]($result.metrics.testCoverage -replace "%", "")
    if ($coverageNumber -lt 50) {
        $score -= (50 - $coverageNumber)
        $issues += "テストカバレッジ: $($result.metrics.testCoverage) (50%未満)"
    }
    
    # 最終評価
    $score = [Math]::Max(0, $score)
    
    if ($score -ge 80) {
        $grade = "優秀"
        $color = "Green"
    } elseif ($score -ge 60) {
        $grade = "良好"
        $color = "Yellow"
    } else {
        $grade = "要改善"
        $color = "Red"
    }
    
    $result.success = ($score -ge 60)
    $result.summary = "品質スコア: $score/100 ($grade)"
    
    Write-Host "   📈 品質スコア: $score/100 ($grade)" -ForegroundColor $color
    
    if ($issues.Count -gt 0) {
        Write-Host "   🔍 検出された問題:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "     - $issue" -ForegroundColor Yellow
        }
    }
    
    # サマリー表示
    Write-Host "`n🎯 品質チェック完了!" -ForegroundColor Cyan
    Write-Host "📋 サマリー:" -ForegroundColor White
    Write-Host "   📊 品質スコア: $score/100 ($grade)" -ForegroundColor $color
    Write-Host "   📝 コード行数: $($result.metrics.linesOfCode)" -ForegroundColor White
    Write-Host "   🔍 ESLint: $($result.eslint.status)" -ForegroundColor $(if($result.eslint.status -eq "通過") {"Green"} else {"Yellow"})
    Write-Host "   🔒 セキュリティ: $($result.security.status)" -ForegroundColor $(if($result.security.status -eq "安全") {"Green"} else {"Yellow"})
    Write-Host "   🧪 テストカバレッジ: $($result.metrics.testCoverage)" -ForegroundColor White
    
    return $result
    
} catch {
    Write-Host "`n❌ 品質チェックエラー: $($_.Exception.Message)" -ForegroundColor Red
    $result.summary = "品質チェックエラー: $($_.Exception.Message)"
    return $result
    
} finally {
    # 元のディレクトリに戻る
    Set-Location $originalLocation
}