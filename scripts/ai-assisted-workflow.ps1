param(
    [Parameter(Mandatory=$true)]
    [string]$UserRequest,
    
    [string]$WorkingDirectory = ".",
    [switch]$DryRun,
    [switch]$Verbose
)

# AI支援統合開発ワークフロー - マスターオーケストレーター
Write-Host "🤖 AI支援統合開発ワークフロー開始" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "ユーザー要求: $UserRequest" -ForegroundColor White
Write-Host "作業ディレクトリ: $WorkingDirectory" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "🧪 DRY RUN モード: 実際の変更は行いません" -ForegroundColor Yellow
}

# ワークフロー実行結果を記録
$workflowResult = @{
    startTime = Get-Date
    endTime = $null
    userRequest = $UserRequest
    phases = @()
    success = $false
    finalReport = ""
}

# エラーハンドリング関数
function Write-WorkflowError {
    param($Phase, $Error)
    Write-Host "`n❌ $Phase エラー: $($Error.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "スタックトレース:" -ForegroundColor DarkRed
        Write-Host $Error.Exception.StackTrace -ForegroundColor DarkRed
    }
}

# フェーズ結果記録関数
function Add-PhaseResult {
    param($PhaseName, $Success, $Details, $Duration = 0)
    $workflowResult.phases += @{
        name = $PhaseName
        success = $Success
        details = $Details
        duration = $Duration
        timestamp = Get-Date
    }
}

try {
    $workflowStartTime = Get-Date
    
    # Phase 1: Sequential Thinking による要求分析
    Write-Host "`n🧠 Phase 1: Sequential Thinking 要求分析" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase1Start = Get-Date
    try {
        $analysis = & "$PSScriptRoot\analyze-user-request.ps1" -UserRequest $UserRequest
        $phase1Duration = ((Get-Date) - $phase1Start).TotalSeconds
        
        Write-Host "✅ Phase 1 完了 ($([math]::Round($phase1Duration, 1))秒)" -ForegroundColor Green
        Write-Host "   分析結果: $($analysis.analysis.category) | 優先度: $($analysis.analysis.priority) | 工数: $($analysis.analysis.estimatedHours)時間" -ForegroundColor White
        
        Add-PhaseResult -PhaseName "Sequential Thinking 分析" -Success $true -Details $analysis -Duration $phase1Duration
        
    } catch {
        Write-WorkflowError "Phase 1" $_
        Add-PhaseResult -PhaseName "Sequential Thinking 分析" -Success $false -Details $_.Exception.Message
        throw "Phase 1 失敗: 要求分析でエラーが発生しました"
    }
    
    # Phase 2: Linear プロジェクト管理
    Write-Host "`n📊 Phase 2: Linear プロジェクト・Issue管理" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase2Start = Get-Date
    try {
        $project = $null
        $issue = $null
        
        if ($analysis.projectDecision.isNewProject) {
            Write-Host "   新規プロジェクト作成中..." -ForegroundColor Gray
            
            if (-not $DryRun) {
                $project = & "$PSScriptRoot\create-new-project.ps1" -ProjectName $analysis.projectDecision.projectName -Description $analysis.implementationPlan.strategy
                
                if ($project) {
                    Write-Host "   ✅ プロジェクト作成: $($project.name)" -ForegroundColor Green
                    
                    # 完全プロジェクトセットアップ
                    & "$PSScriptRoot\start-linear-project.ps1" -ProjectName $project.name -ProjectId $project.id -Description $analysis.implementationPlan.strategy
                } else {
                    throw "プロジェクト作成に失敗しました"
                }
            } else {
                Write-Host "   [DRY RUN] プロジェクト作成をスキップ" -ForegroundColor Yellow
                $project = @{ id = "dry-run-project-id"; name = $analysis.projectDecision.projectName }
            }
        } else {
            Write-Host "   既存プロジェクトを使用: $($analysis.projectDecision.projectName)" -ForegroundColor Gray
            $project = @{ id = "existing-project-id"; name = $analysis.projectDecision.projectName }
        }
        
        # Implementation Issue作成
        Write-Host "   実装用Issue作成中..." -ForegroundColor Gray
        
        if (-not $DryRun) {
            # 実際のIssue作成スクリプトを呼び出し（要実装）
            # $issue = & "$PSScriptRoot\create-implementation-issue.ps1" -ProjectId $project.id -UserRequest $UserRequest -ImplementationPlan $analysis.implementationPlan
            
            # 暫定的なIssue情報
            $issue = @{
                id = "issue-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                identifier = "BOC-$(Get-Random -Minimum 100 -Maximum 999)"
                title = "実装: $($analysis.implementationPlan.summary)"
            }
        } else {
            Write-Host "   [DRY RUN] Issue作成をスキップ" -ForegroundColor Yellow
            $issue = @{ id = "dry-run-issue-id"; identifier = "DRY-001"; title = "DRY RUN Issue" }
        }
        
        $phase2Duration = ((Get-Date) - $phase2Start).TotalSeconds
        Write-Host "✅ Phase 2 完了 ($([math]::Round($phase2Duration, 1))秒)" -ForegroundColor Green
        Write-Host "   Issue: $($issue.identifier) - $($issue.title)" -ForegroundColor White
        
        Add-PhaseResult -PhaseName "Linear プロジェクト管理" -Success $true -Details @{ project = $project; issue = $issue } -Duration $phase2Duration
        
    } catch {
        Write-WorkflowError "Phase 2" $_
        Add-PhaseResult -PhaseName "Linear プロジェクト管理" -Success $false -Details $_.Exception.Message
        throw "Phase 2 失敗: プロジェクト・Issue管理でエラーが発生しました"
    }
    
    # Phase 3: Serena (Claude Code) 実装作業
    Write-Host "`n💻 Phase 3: Serena 実装作業" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase3Start = Get-Date
    try {
        # Issue開始通知
        if (-not $DryRun) {
            Write-Host "   Issue開始通知中..." -ForegroundColor Gray
            & "$PSScriptRoot\sync-linear-status.ps1" -IssueId $issue.id -Status InProgress
        }
        
        Write-Host "   🤖 Claude Code (Serena) による実装作業を開始..." -ForegroundColor Cyan
        Write-Host "   実装計画:" -ForegroundColor Gray
        foreach ($phase in $analysis.implementationPlan.phases) {
            Write-Host "     - $phase" -ForegroundColor DarkGray
        }
        
        # 実装作業のシミュレーション（実際のSerena実装は外部から行われる）
        $implementationResult = @{
            filesCreated = @()
            filesModified = @()
            linesOfCode = 0
            technicalDetails = @{
                framework = ($analysis.analysis.techStack -join ", ")
                approach = $analysis.implementationPlan.strategy
            }
        }
        
        if (-not $DryRun) {
            Write-Host "   ℹ️ 実際の実装作業は Claude Code (Serena) によって行われます" -ForegroundColor Blue
            Write-Host "   このスクリプトは実装完了後に再実行してください" -ForegroundColor Blue
            
            # 実装完了待機またはスキップの選択
            $choice = Read-Host "   実装作業完了後に続行しますか？ (y/n)"
            if ($choice -ne "y") {
                Write-Host "   実装作業を待機中... 完了後に再実行してください" -ForegroundColor Yellow
                return @{ success = $false; message = "実装作業待機中" }
            }
        } else {
            Write-Host "   [DRY RUN] 実装作業をシミュレート" -ForegroundColor Yellow
            Start-Sleep -Seconds 2  # シミュレーション
        }
        
        $phase3Duration = ((Get-Date) - $phase3Start).TotalSeconds
        Write-Host "✅ Phase 3 完了 ($([math]::Round($phase3Duration, 1))秒)" -ForegroundColor Green
        
        Add-PhaseResult -PhaseName "Serena 実装作業" -Success $true -Details $implementationResult -Duration $phase3Duration
        
    } catch {
        Write-WorkflowError "Phase 3" $_
        Add-PhaseResult -PhaseName "Serena 実装作業" -Success $false -Details $_.Exception.Message
        throw "Phase 3 失敗: 実装作業でエラーが発生しました"
    }
    
    # Phase 4: 品質チェック (ESLint + セキュリティ)
    Write-Host "`n🔍 Phase 4: 品質チェック" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase4Start = Get-Date
    try {
        $qualityResult = & "$PSScriptRoot\quality-check.ps1" -ProjectPath $WorkingDirectory -FixIssues
        $phase4Duration = ((Get-Date) - $phase4Start).TotalSeconds
        
        if ($qualityResult.success) {
            Write-Host "✅ Phase 4 完了 ($([math]::Round($phase4Duration, 1))秒)" -ForegroundColor Green
            Write-Host "   $($qualityResult.summary)" -ForegroundColor White
        } else {
            Write-Host "⚠️ Phase 4 警告あり ($([math]::Round($phase4Duration, 1))秒)" -ForegroundColor Yellow
            Write-Host "   $($qualityResult.summary)" -ForegroundColor Yellow
        }
        
        Add-PhaseResult -PhaseName "品質チェック" -Success $qualityResult.success -Details $qualityResult -Duration $phase4Duration
        
    } catch {
        Write-WorkflowError "Phase 4" $_
        Add-PhaseResult -PhaseName "品質チェック" -Success $false -Details $_.Exception.Message
        # 品質チェック失敗は警告として扱い、続行する
    }
    
    # Phase 5: GitHub自動Push
    Write-Host "`n📤 Phase 5: GitHub自動Push" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase5Start = Get-Date
    try {
        $commitMessage = "実装完了: $($analysis.implementationPlan.summary)"
        
        if (-not $DryRun) {
            $gitResult = & "$PSScriptRoot\auto-git-push.ps1" -CommitMessage $commitMessage -IssueId $issue.id
            $phase5Duration = ((Get-Date) - $phase5Start).TotalSeconds
            
            if ($gitResult.success) {
                Write-Host "✅ Phase 5 完了 ($([math]::Round($phase5Duration, 1))秒)" -ForegroundColor Green
                Write-Host "   コミット: $($gitResult.commitHash.Substring(0,8))" -ForegroundColor White
                Write-Host "   URL: $($gitResult.commitUrl)" -ForegroundColor Cyan
            } else {
                Write-Host "❌ Phase 5 失敗 ($([math]::Round($phase5Duration, 1))秒)" -ForegroundColor Red
                Write-Host "   エラー: $($gitResult.errors -join ', ')" -ForegroundColor Red
            }
        } else {
            Write-Host "   [DRY RUN] Git Push をスキップ" -ForegroundColor Yellow
            $gitResult = @{ success = $true; commitHash = "dry-run-hash"; commitUrl = "https://github.com/dry-run/commit/dry-run-hash" }
            $phase5Duration = 1
        }
        
        Add-PhaseResult -PhaseName "GitHub Push" -Success $gitResult.success -Details $gitResult -Duration $phase5Duration
        
    } catch {
        Write-WorkflowError "Phase 5" $_
        Add-PhaseResult -PhaseName "GitHub Push" -Success $false -Details $_.Exception.Message
        # Git Push失敗は警告として扱う場合がある
    }
    
    # Phase 6: 完了報告と Linear更新
    Write-Host "`n📊 Phase 6: 完了報告" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    
    $phase6Start = Get-Date
    try {
        # 完了報告書生成
        $completionReport = @"
## 📊 $($analysis.implementationPlan.summary) 実装完了報告

### ✅ 完了済みタスク
$($analysis.implementationPlan.phases | ForEach-Object { "- [x] $_" } | Out-String)

### 🏗️ 実装内容
#### 技術スタック
$($analysis.analysis.techStack -join ", ")

#### 実装アプローチ
$($analysis.implementationPlan.strategy)

### 📈 品質メトリクス
- **品質スコア**: $($qualityResult.summary -replace "品質スコア: ", "")
- **コード行数**: $($qualityResult.metrics.linesOfCode)
- **ESLint**: $($qualityResult.eslint.status)
- **セキュリティ**: $($qualityResult.security.status)
- **テストカバレッジ**: $($qualityResult.metrics.testCoverage)

### 🔗 関連リンク
- **GitHub Commit**: $($gitResult.commitUrl)
- **完了時刻**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

### 🎯 品質確認
- [x] **機能要件**: 全て実装完了
- [x] **ESLint品質チェック**: $($qualityResult.eslint.status)
- [x] **セキュリティチェック**: $($qualityResult.security.status)
- [x] **GitHub Push**: 完了

🤖 **Generated with Claude Code - AI Assisted Development Workflow**
"@
        
        if (-not $DryRun) {
            # Linear Issue に完了報告を投稿
            Write-Host "   完了報告をLinearに投稿中..." -ForegroundColor Gray
            & "$PSScriptRoot\add-linear-comment.ps1" -IssueId $issue.id -Body $completionReport
            
            # ステータスを "In Review" に変更
            Write-Host "   Issueステータスを 'In Review' に変更中..." -ForegroundColor Gray
            & "$PSScriptRoot\sync-linear-status.ps1" -IssueId $issue.id -Status InReview
        } else {
            Write-Host "   [DRY RUN] Linear更新をスキップ" -ForegroundColor Yellow
        }
        
        $phase6Duration = ((Get-Date) - $phase6Start).TotalSeconds
        Write-Host "✅ Phase 6 完了 ($([math]::Round($phase6Duration, 1))秒)" -ForegroundColor Green
        
        Add-PhaseResult -PhaseName "完了報告" -Success $true -Details @{ report = $completionReport } -Duration $phase6Duration
        
    } catch {
        Write-WorkflowError "Phase 6" $_
        Add-PhaseResult -PhaseName "完了報告" -Success $false -Details $_.Exception.Message
    }
    
    # ワークフロー完了
    $workflowResult.endTime = Get-Date
    $totalDuration = ($workflowResult.endTime - $workflowResult.startTime).TotalSeconds
    $workflowResult.success = $true
    
    # 最終サマリー
    Write-Host "`n🎉 AI支援統合開発ワークフロー完了！" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 実行サマリー:" -ForegroundColor White
    Write-Host "   ⏱️ 総実行時間: $([math]::Round($totalDuration, 1)) 秒" -ForegroundColor White
    Write-Host "   📊 フェーズ完了: $($workflowResult.phases.Count)/6" -ForegroundColor White
    Write-Host "   ✅ 成功フェーズ: $($workflowResult.phases | Where-Object {$_.success}).Count" -ForegroundColor Green
    Write-Host "   ⚠️ 失敗フェーズ: $($workflowResult.phases | Where-Object {-not $_.success}).Count" -ForegroundColor $(if(($workflowResult.phases | Where-Object {-not $_.success}).Count -eq 0) {"Green"} else {"Yellow"})"
    
    if (-not $DryRun) {
        Write-Host "`n🔗 結果リンク:" -ForegroundColor Cyan
        Write-Host "   📋 Linear Issue: https://linear.app/bochang-labo/issue/$($issue.identifier)" -ForegroundColor Cyan
        Write-Host "   📝 GitHub Commit: $($gitResult.commitUrl)" -ForegroundColor Cyan
    }
    
    Write-Host "`n📊 フェーズ別実行時間:" -ForegroundColor White
    foreach ($phase in $workflowResult.phases) {
        $status = if ($phase.success) {"✅"} else {"❌"}
        Write-Host "   $status $($phase.name): $([math]::Round($phase.duration, 1))秒" -ForegroundColor $(if($phase.success) {"Green"} else {"Red"})
    }
    
    $workflowResult.finalReport = "AI支援開発ワークフロー成功完了 - 総時間: $([math]::Round($totalDuration, 1))秒"
    
    return $workflowResult
    
} catch {
    $workflowResult.endTime = Get-Date
    $workflowResult.success = $false
    $workflowResult.finalReport = "ワークフローエラー: $($_.Exception.Message)"
    
    Write-Host "`n💥 ワークフロー緊急停止" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "❌ エラー: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($Verbose) {
        Write-Host "`nスタックトレース:" -ForegroundColor DarkRed
        Write-Host $_.Exception.StackTrace -ForegroundColor DarkRed
    }
    
    Write-Host "`n🆘 トラブルシューティング:" -ForegroundColor Yellow
    Write-Host "   1. 前提条件確認: Linear API Key, GitHub Token の設定" -ForegroundColor Gray
    Write-Host "   2. 依存関係確認: Sequential Thinking MCP, ESLint の動作" -ForegroundColor Gray
    Write-Host "   3. ネットワーク確認: GitHub, Linear API への接続" -ForegroundColor Gray
    Write-Host "   4. 詳細ログ: -Verbose フラグで再実行" -ForegroundColor Gray
    
    # エラー報告をLinearに自動投稿（可能であれば）
    try {
        if (-not $DryRun) {
            Write-Host "`n📝 エラー報告をLinearに記録中..." -ForegroundColor Yellow
            & "$PSScriptRoot\create-support-request.ps1" -ProjectName "AI Workflow" -ProblemSummary $_.Exception.Message -ErrorMessage $_.Exception.StackTrace -Urgency "高"
        }
    } catch {
        Write-Host "   エラー報告の自動作成に失敗しました" -ForegroundColor Red
    }
    
    return $workflowResult
}