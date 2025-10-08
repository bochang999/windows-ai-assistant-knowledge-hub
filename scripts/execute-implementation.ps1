param(
    [Parameter(Mandatory=$true)]
    [string]$IssueId,
    
    [Parameter(Mandatory=$true)]
    [hashtable]$ImplementationPlan,
    
    [string]$WorkingDirectory = ".",
    [switch]$DryRun,
    [switch]$Verbose
)

# Serena (Claude Code) 実装作業オーケストレーター
Write-Host "💻 Serena実装作業オーケストレーター" -ForegroundColor Cyan
Write-Host "Issue ID: $IssueId" -ForegroundColor White
Write-Host "実装戦略: $($ImplementationPlan.strategy)" -ForegroundColor Gray

$result = @{
    success = $false
    filesCreated = @()
    filesModified = @()
    linesOfCode = 0
    technicalDetails = @{}
    implementationLog = @()
    duration = 0
    errors = @()
}

$startTime = Get-Date

try {
    # Phase 1: 事前準備
    Write-Host "`n📋 Phase 1: 実装準備" -ForegroundColor Yellow
    
    # Issue開始通知
    if (-not $DryRun) {
        Write-Host "   Linear Issue状態更新中..." -ForegroundColor Gray
        & "$PSScriptRoot\sync-linear-status.ps1" -IssueId $IssueId -Status InProgress
    } else {
        Write-Host "   [DRY RUN] Issue状態更新をスキップ" -ForegroundColor Yellow
    }
    
    # 作業ディレクトリの確認・作成
    $fullWorkingPath = Resolve-Path $WorkingDirectory -ErrorAction SilentlyContinue
    if (-not $fullWorkingPath) {
        $fullWorkingPath = $WorkingDirectory
    }
    
    Write-Host "   作業ディレクトリ: $fullWorkingPath" -ForegroundColor Gray
    
    # Git リポジトリの確認
    $isGitRepo = Test-Path "$fullWorkingPath\.git"
    Write-Host "   Git リポジトリ: $(if($isGitRepo) { '✅ 確認済み' } else { '⚠️ 未初期化' })" -ForegroundColor $(if($isGitRepo) { 'Green' } else { 'Yellow' })
    
    # package.json の確認（JavaScript/Node.js プロジェクトの場合）
    $packageJsonPath = "$fullWorkingPath\package.json"
    $hasPackageJson = Test-Path $packageJsonPath
    Write-Host "   package.json: $(if($hasPackageJson) { '✅ 存在' } else { 'ℹ️ なし' })" -ForegroundColor $(if($hasPackageJson) { 'Green' } else { 'Blue' })
    
    # Phase 2: 技術環境セットアップ
    Write-Host "`n🔧 Phase 2: 技術環境セットアップ" -ForegroundColor Yellow
    
    # 技術スタックに応じた環境確認
    $techStack = $ImplementationPlan.analysis.techStack
    Write-Host "   対象技術: $($techStack -join ', ')" -ForegroundColor Gray
    
    # Node.js/JavaScript プロジェクトの場合
    if ($techStack -contains "JavaScript" -or $techStack -contains "React" -or $techStack -contains "Node.js") {
        Write-Host "   🟨 JavaScript/Node.js環境検出" -ForegroundColor Yellow
        
        # Node.js バージョン確認
        if (Get-Command "node" -ErrorAction SilentlyContinue) {
            $nodeVersion = node --version
            Write-Host "     Node.js: $nodeVersion ✅" -ForegroundColor Green
        } else {
            Write-Host "     Node.js: 未インストール ⚠️" -ForegroundColor Yellow
        }
        
        # npm 依存関係インストール
        if ($hasPackageJson -and -not $DryRun) {
            Write-Host "   依存関係インストール中..." -ForegroundColor Gray
            npm install
            if ($LASTEXITCODE -eq 0) {
                Write-Host "     ✅ npm install 完了" -ForegroundColor Green
            } else {
                Write-Host "     ⚠️ npm install に問題があります" -ForegroundColor Yellow
            }
        }
        
        # ESLint 設定確認・作成
        $eslintConfigExists = @(".eslintrc.js", ".eslintrc.json", "eslint.config.js") | Where-Object { Test-Path "$fullWorkingPath\$_" }
        if (-not $eslintConfigExists -and -not $DryRun) {
            Write-Host "   ESLint設定作成中..." -ForegroundColor Gray
            
            $eslintConfig = @{
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
                    "semi" = @("error", "always")
                    "quotes" = @("error", "single")
                }
            }
            
            $eslintConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath "$fullWorkingPath\.eslintrc.json" -Encoding UTF8
            $result.filesCreated += ".eslintrc.json"
            Write-Host "     ✅ .eslintrc.json 作成完了" -ForegroundColor Green
        }
    }
    
    # Android/Kotlin プロジェクトの場合  
    if ($techStack -contains "Android" -or $techStack -contains "Kotlin") {
        Write-Host "   🟢 Android/Kotlin環境検出" -ForegroundColor Green
        
        # Gradle wrapper 確認
        $gradlewExists = Test-Path "$fullWorkingPath\gradlew" -or Test-Path "$fullWorkingPath\gradlew.bat"
        Write-Host "     Gradle Wrapper: $(if($gradlewExists) { '✅ 存在' } else { '⚠️ なし' })" -ForegroundColor $(if($gradlewExists) { 'Green' } else { 'Yellow' })
        
        # build.gradle 確認
        $buildGradleExists = Test-Path "$fullWorkingPath\build.gradle" -or Test-Path "$fullWorkingPath\build.gradle.kts"
        Write-Host "     build.gradle: $(if($buildGradleExists) { '✅ 存在' } else { '⚠️ なし' })" -ForegroundColor $(if($buildGradleExists) { 'Green' } else { 'Yellow' })
    }
    
    # Phase 3: 実装作業指示（Serena への移譲）
    Write-Host "`n🤖 Phase 3: Claude Code (Serena) 実装作業" -ForegroundColor Yellow
    
    Write-Host "   🎯 実装指示書生成中..." -ForegroundColor Gray
    
    # Serena への詳細実装指示を生成
    $implementationInstructions = @"
## 🤖 Claude Code (Serena) 実装指示書

### 📋 実装要求
**Issue ID**: $IssueId
**実装戦略**: $($ImplementationPlan.strategy)
**技術スタック**: $($techStack -join ", ")

### 🎯 実装フェーズ
$($ImplementationPlan.phases | ForEach-Object { $index = [array]::IndexOf($ImplementationPlan.phases, $_) + 1; "**Phase $index**: $_" } | Join-String "`n")

### 🏗️ 技術要件
- **言語/フレームワーク**: $($techStack -join " + ")
- **複雑度**: $($ImplementationPlan.analysis.complexity)
- **予想工数**: $($ImplementationPlan.analysis.estimatedHours) 時間

### 📝 実装ガイドライン

#### コード品質
- ESLint設定に準拠したコード
- 適切なエラーハンドリング
- コメントは最小限（コードで意図を表現）
- 関数・変数名は明確で理解しやすく

#### セキュリティ
- APIキーは環境変数またはローカルファイルに配置
- 機密情報はコードに含めない
- 入力値検証を適切に実装

#### 構造・設計
- 既存プロジェクト構造に合わせる
- 再利用可能なコンポーネント設計
- 適切な関心の分離

### ✅ 完了条件
1. **機能実装**: すべての要求機能が動作
2. **品質チェック**: ESLintエラー0件
3. **テスト**: 基本動作確認完了
4. **ドキュメント**: 必要に応じてREADME更新

### 🔧 開発環境情報
- **作業ディレクトリ**: $fullWorkingPath
- **Git リポジトリ**: $(if($isGitRepo) { '初期化済み' } else { '要初期化' })
- **package.json**: $(if($hasPackageJson) { '存在' } else { 'なし' })
- **ESLint**: $(if($eslintConfigExists) { '設定済み' } else { '自動作成済み' })

---

**この指示書に基づいて実装を開始してください。**
**実装完了後は、このスクリプトの続行部分で品質チェックと Git Push を実行します。**
"@

    # 実装指示書をファイルに保存
    $instructionsPath = "$env:TEMP\implementation-instructions-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    $implementationInstructions | Out-File -FilePath $instructionsPath -Encoding UTF8
    
    Write-Host "   📄 実装指示書: $instructionsPath" -ForegroundColor Cyan
    
    # 実装作業の状態管理
    if (-not $DryRun) {
        Write-Host "`n   🤖 Claude Code (Serena) による実装作業..." -ForegroundColor Cyan
        Write-Host "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "   実装指示書が生成されました。" -ForegroundColor White
        Write-Host "   この内容に基づいて Claude Code で実装作業を行ってください。" -ForegroundColor White
        Write-Host "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        
        # 実装完了の確認
        $continueChoice = Read-Host "`n   実装作業完了後、続行しますか？ (y/n)"
        
        if ($continueChoice -ne "y") {
            Write-Host "   ⏳ 実装作業待機中... 完了後に再実行してください" -ForegroundColor Yellow
            
            # 一時的な結果を返す
            $result.success = $false
            $result.technicalDetails.status = "実装待機中"
            $result.technicalDetails.instructionsPath = $instructionsPath
            return $result
        }
        
        # 実装完了後の確認
        Write-Host "`n   🔍 実装完了の確認..." -ForegroundColor Gray
        
    } else {
        Write-Host "   [DRY RUN] 実装作業をシミュレート" -ForegroundColor Yellow
        
        # DRY RUN時のシミュレーション
        $result.filesCreated += @("src/main.js", "src/utils.js", "tests/main.test.js")
        $result.filesModified += @("package.json", "README.md")
        $result.linesOfCode = 247
        
        Start-Sleep -Seconds 2  # シミュレーション待機
    }
    
    # Phase 4: 実装結果の検証・記録
    Write-Host "`n📊 Phase 4: 実装結果の検証・記録" -ForegroundColor Yellow
    
    # Git status で変更ファイルを検出
    if ($isGitRepo) {
        Write-Host "   Git変更ファイル検出中..." -ForegroundColor Gray
        
        $gitStatus = git status --porcelain 2>$null
        if ($gitStatus) {
            foreach ($line in $gitStatus) {
                $status = $line.Substring(0, 2).Trim()
                $file = $line.Substring(3)
                
                switch ($status) {
                    "A" { $result.filesCreated += $file }
                    "M" { $result.filesModified += $file }
                    "??" { $result.filesCreated += $file }
                }
            }
        }
        
        Write-Host "     新規ファイル: $($result.filesCreated.Count) 件" -ForegroundColor Green
        Write-Host "     変更ファイル: $($result.filesModified.Count) 件" -ForegroundColor Green
    }
    
    # コード行数の計算
    $allFiles = $result.filesCreated + $result.filesModified
    $totalLines = 0
    
    foreach ($file in $allFiles) {
        $filePath = Join-Path $fullWorkingPath $file
        if (Test-Path $filePath) {
            $lines = (Get-Content $filePath -ErrorAction SilentlyContinue).Count
            $totalLines += $lines
        }
    }
    
    $result.linesOfCode = $totalLines
    Write-Host "   コード行数: $totalLines 行" -ForegroundColor White
    
    # 技術詳細の記録
    $result.technicalDetails = @{
        framework = ($techStack -join ", ")
        approach = $ImplementationPlan.strategy
        complexity = $ImplementationPlan.analysis.complexity
        estimatedHours = $ImplementationPlan.analysis.estimatedHours
        workingDirectory = $fullWorkingPath
        gitRepository = $isGitRepo
        nodeProject = $hasPackageJson
        instructionsPath = $instructionsPath
    }
    
    # 実装ログの記録
    $result.implementationLog += @{
        timestamp = Get-Date
        phase = "環境セットアップ"
        action = "技術環境確認・設定"
        result = "完了"
    }
    
    $result.implementationLog += @{
        timestamp = Get-Date
        phase = "実装指示"
        action = "Serena実装指示書生成"
        result = "完了"
        details = $instructionsPath
    }
    
    $result.implementationLog += @{
        timestamp = Get-Date
        phase = "実装作業"
        action = "Claude Code実装作業"
        result = if($DryRun) { "シミュレート" } else { "待機/完了" }
    }
    
    # 実行時間の計算
    $result.duration = ((Get-Date) - $startTime).TotalSeconds
    
    $result.success = $true
    
    Write-Host "`n✅ 実装作業オーケストレーション完了" -ForegroundColor Green
    Write-Host "   実行時間: $([math]::Round($result.duration, 1)) 秒" -ForegroundColor White
    Write-Host "   処理ファイル: $($allFiles.Count) 件" -ForegroundColor White
    Write-Host "   コード行数: $($result.linesOfCode) 行" -ForegroundColor White
    
    if ($Verbose) {
        Write-Host "`n📋 詳細ログ:" -ForegroundColor DarkGray
        foreach ($log in $result.implementationLog) {
            Write-Host "   [$($log.timestamp.ToString('HH:mm:ss'))] $($log.phase): $($log.action) → $($log.result)" -ForegroundColor DarkGray
        }
    }
    
    return $result
    
} catch {
    $result.errors += $_.Exception.Message
    $result.duration = ((Get-Date) - $startTime).TotalSeconds
    
    Write-Host "`n❌ 実装作業エラー: $($_.Exception.Message)" -ForegroundColor Red
    
    # エラー時のデバッグ情報
    Write-Host "🔧 デバッグ情報:" -ForegroundColor Yellow
    Write-Host "   作業ディレクトリ: $WorkingDirectory" -ForegroundColor Gray
    Write-Host "   実行時間: $([math]::Round($result.duration, 1)) 秒" -ForegroundColor Gray
    Write-Host "   Issue ID: $IssueId" -ForegroundColor Gray
    
    return $result
}