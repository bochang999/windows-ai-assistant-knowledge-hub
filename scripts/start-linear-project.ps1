param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$TeamId = "3dea9cba-30a5-4a25-b6e3-0ec0a2ec3896"
)

Write-Host "🚀 $ProjectName プロジェクトのLinear設定を開始します..." -ForegroundColor Cyan

# Phase 1: プロジェクト説明更新
Write-Host "`n📝 Phase 1: プロジェクト説明を更新中..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\update-project-description.ps1" -ProjectId $ProjectId -Description $Description
} catch {
    Write-Error "Phase 1 でエラーが発生しました: $_"
    return
}

# Phase 2: マイルストーン作成
Write-Host "`n📊 Phase 2: マイルストーンを作成中..." -ForegroundColor Yellow
try {
    $firstMilestoneId = & "$PSScriptRoot\create-project-milestones.ps1" -ProjectId $ProjectId -ProjectName $ProjectName
    Write-Host "最初のマイルストーンID: $firstMilestoneId" -ForegroundColor Gray
} catch {
    Write-Error "Phase 2 でエラーが発生しました: $_"
    return
}

# Phase 3: 初期Issue作成（簡易版）
Write-Host "`n🎫 Phase 3: 初期Issue作成の準備..." -ForegroundColor Yellow
Write-Host "手動でIssueを作成するか、create-project-issues.ps1スクリプトを実行してください。" -ForegroundColor Yellow
Write-Host "推奨Issue:" -ForegroundColor White
Write-Host "  1. '$ProjectName プロジェクト開始' (Done)" -ForegroundColor Gray
Write-Host "  2. 'Milestone 1: データレイヤー & 基盤アーキテクチャ構築' (In Progress)" -ForegroundColor Gray

Write-Host "`n🎉 $ProjectName プロジェクトのLinear設定が完了しました！" -ForegroundColor Green
Write-Host "プロジェクトページを確認してください:" -ForegroundColor Cyan
Write-Host "https://linear.app/bochang-labo/project/$ProjectId" -ForegroundColor Blue

# 設定内容サマリー
Write-Host "`n📊 設定内容サマリー:" -ForegroundColor White
Write-Host "  - プロジェクト名: $ProjectName" -ForegroundColor Gray
Write-Host "  - プロジェクトID: $ProjectId" -ForegroundColor Gray
Write-Host "  - 説明: $Description" -ForegroundColor Gray
Write-Host "  - マイルストーン: 3個作成済み" -ForegroundColor Gray
Write-Host "  - チームID: $TeamId" -ForegroundColor Gray