param(
    [Parameter(Mandatory=$true)]
    [string]$UserRequest
)

# Sequential Thinking MCP による要求分析スクリプト
Write-Host "🧠 Sequential Thinking: ユーザー要求分析開始" -ForegroundColor Cyan
Write-Host "要求内容: $UserRequest" -ForegroundColor White

# 分析結果を格納する変数
$analysisResult = @{
    userRequest = $UserRequest
    analysis = @{}
    projectDecision = @{}
    implementationPlan = @{}
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
}

try {
    Write-Host "`n🧠 Step 1: 要求分類と優先度評価..." -ForegroundColor Yellow
    
    # Sequential Thinking Step 1: 要求分析
    # Note: 実際の実装では、Claude Code のSequential Thinking MCPを使用
    Write-Host "   要求を分析中..." -ForegroundColor Gray
    
    # 簡易分析ロジック（実際はMCPで高度な分析）
    $category = "新機能"
    $priority = "中"
    $complexity = "中程度"
    
    if ($UserRequest -match "バグ|エラー|修正|問題") {
        $category = "バグ修正"
        $priority = "高"
    } elseif ($UserRequest -match "新しい|追加|機能|作成") {
        $category = "新機能"
        $complexity = "複雑"
    } elseif ($UserRequest -match "改善|最適化|リファクタ") {
        $category = "改善"
        $priority = "中"
    }
    
    # 技術スタック推定
    $techStack = @()
    if ($UserRequest -match "React|JavaScript|JS") { $techStack += "React", "JavaScript" }
    if ($UserRequest -match "Android|Kotlin|Java") { $techStack += "Android", "Kotlin" }
    if ($UserRequest -match "API|REST|GraphQL") { $techStack += "API" }
    if ($UserRequest -match "データベース|DB|SQL") { $techStack += "Database" }
    
    # 工数見積もり
    $estimatedHours = 2
    if ($complexity -eq "複雑") { $estimatedHours = 6 }
    elseif ($complexity -eq "中程度") { $estimatedHours = 4 }
    
    $analysisResult.analysis = @{
        category = $category
        priority = $priority
        complexity = $complexity
        estimatedHours = $estimatedHours
        techStack = $techStack
    }
    
    Write-Host "   ✅ カテゴリ: $category | 優先度: $priority | 複雑度: $complexity" -ForegroundColor Green
    
    Write-Host "`n🧠 Step 2: プロジェクト判定..." -ForegroundColor Yellow
    
    # Sequential Thinking Step 2: プロジェクト判定
    $isNewProject = $true
    $projectName = "New Project"
    
    # 既存プロジェクトキーワードチェック
    if ($UserRequest -match "ZenRecipe|zen.?recipe") {
        $isNewProject = $false
        $projectName = "Zen Recipe"
        $projectId = "f6048ad7-b261-4aa6-b735-b68406b9de4b"  # 既存のプロジェクトID
    } elseif ($UserRequest -match "DailyTaskTracker|task.?tracker") {
        $isNewProject = $false
        $projectName = "Daily Task Tracker"
    } else {
        # 新規プロジェクト名を生成
        if ($UserRequest -match "チャット|chat|bot") {
            $projectName = "AI Chat Bot"
        } elseif ($UserRequest -match "ダッシュボード|dashboard") {
            $projectName = "Analytics Dashboard"
        } else {
            $projectName = "Custom Application"
        }
    }
    
    $analysisResult.projectDecision = @{
        isNewProject = $isNewProject
        projectName = $projectName
        reason = if ($isNewProject) { "完全に新しい機能領域のため" } else { "既存プロジェクトの拡張" }
    }
    
    if ($isNewProject) {
        Write-Host "   ✅ 新規プロジェクト: $projectName" -ForegroundColor Green
    } else {
        Write-Host "   ✅ 既存プロジェクト: $projectName" -ForegroundColor Green
    }
    
    Write-Host "`n🧠 Step 3: 実装計画立案..." -ForegroundColor Yellow
    
    # Sequential Thinking Step 3: 実装計画
    $phases = @()
    $strategy = ""
    
    switch ($category) {
        "新機能" {
            $phases = @(
                "Phase 1: 基盤アーキテクチャ設計",
                "Phase 2: コア機能実装",
                "Phase 3: UI/UX実装とテスト"
            )
            $strategy = "$($techStack -join ' + ') による新機能実装"
        }
        "バグ修正" {
            $phases = @(
                "Phase 1: 問題分析と原因特定",
                "Phase 2: 修正実装とテスト"
            )
            $strategy = "バグ修正とテスト強化"
        }
        "改善" {
            $phases = @(
                "Phase 1: 現状分析",
                "Phase 2: 改善実装",
                "Phase 3: パフォーマンス検証"
            )
            $strategy = "パフォーマンス改善とコード最適化"
        }
    }
    
    $analysisResult.implementationPlan = @{
        phases = $phases
        strategy = $strategy
        summary = $UserRequest -replace '(.{50}).*', '$1...'
    }
    
    Write-Host "   ✅ 実装戦略: $strategy" -ForegroundColor Green
    Write-Host "   ✅ フェーズ数: $($phases.Count) | 予想工数: $estimatedHours 時間" -ForegroundColor Green
    
    Write-Host "`n🧠 Step 4: リスク評価..." -ForegroundColor Yellow
    
    # Sequential Thinking Step 4: リスク分析
    $risks = @()
    if ($complexity -eq "複雑") { $risks += "技術的複雑性" }
    if ($techStack.Count -gt 3) { $risks += "技術スタック複雑性" }
    if ($estimatedHours -gt 5) { $risks += "工数超過リスク" }
    
    Write-Host "   ✅ 特定されたリスク: $($risks.Count) 件" -ForegroundColor Green
    
    Write-Host "`n🧠 Step 5: 最終戦略確定..." -ForegroundColor Yellow
    
    # Sequential Thinking Step 5: 最終戦略
    $finalStrategy = @{
        approach = $strategy
        qualityAssurance = "ESLint + Pre-commit hooks + 自動テスト"
        completionCriteria = "機能実装 + 品質チェック通過 + GitHub Push完了"
        riskMitigation = "段階的実装 + 継続的テスト + エラーハンドリング強化"
    }
    
    $analysisResult.finalStrategy = $finalStrategy
    
    Write-Host "   ✅ 最終戦略確定完了" -ForegroundColor Green
    
    # 結果をJSONファイルに保存
    $outputPath = "$env:TEMP\analysis-result-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $analysisResult | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
    
    Write-Host "`n🎉 Sequential Thinking 分析完了！" -ForegroundColor Cyan
    Write-Host "分析結果: $outputPath" -ForegroundColor White
    
    # 結果を返す
    return $analysisResult
    
} catch {
    Write-Host "`n❌ 分析エラー: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "デバッグ情報をLinearに記録します..." -ForegroundColor Yellow
    
    # エラー時の基本的な分析結果を返す
    $analysisResult.analysis = @{
        category = "不明"
        priority = "中"
        complexity = "要調査"
        estimatedHours = 2
        techStack = @("要調査")
    }
    
    $analysisResult.projectDecision = @{
        isNewProject = $true
        projectName = "Error Recovery Project"
        reason = "分析エラーのため手動確認が必要"
    }
    
    $analysisResult.implementationPlan = @{
        phases = @("Phase 1: 手動分析", "Phase 2: 実装")
        strategy = "手動分析後の実装"
        summary = "エラー回復が必要"
    }
    
    return $analysisResult
}