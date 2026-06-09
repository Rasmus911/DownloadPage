# sync.ps1 — 同步最新的 DOCX 到下载页面并推送到 GitHub
# 用法: 右键运行，或在 PowerShell 中执行 .\sync.ps1
# 每次修改 DOCX 后运行此脚本，确保下载页面始终是最新版本

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$sourceFile = "..\计算机网络整体整理.docx"
$targetFile = ".\计算机网络整体整理.docx"
$pageUrl   = "https://rasmus911.github.io/DownloadPage/"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  📚 计算机网络下载页面 — 同步脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查源文件是否存在
if (-not (Test-Path $sourceFile)) {
    Write-Host "❌ 源文件不存在: $sourceFile" -ForegroundColor Red
    Write-Host "   请确认 DOCX 文件在课件文件夹中。" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

# 2. 比较文件是否变化
$needUpdate = $true
if (Test-Path $targetFile) {
    $sourceHash = (Get-FileHash $sourceFile -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash $targetFile -Algorithm SHA256).Hash
    if ($sourceHash -eq $targetHash) {
        $needUpdate = $false
    }
}

if (-not $needUpdate) {
    Write-Host "⏭️  DOCX 文件未变化，无需同步。" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📎 下载页面: $pageUrl" -ForegroundColor Green
    Read-Host "按回车退出"
    exit 0
}

# 3. 复制最新文件
Write-Host "📋 正在复制最新 DOCX..." -ForegroundColor White
Copy-Item $sourceFile $targetFile -Force
$fileSize = [math]::Round((Get-Item $targetFile).Length / 1KB, 1)
$lastModified = (Get-Item $sourceFile).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
Write-Host "   ✅ 已复制 (${fileSize} KB · 修改时间: $lastModified)" -ForegroundColor Green

# 4. Git 操作
Write-Host ""
Write-Host "📤 正在提交到 Git..." -ForegroundColor White

$status = git status --porcelain
if (-not $status) {
    Write-Host "   ⏭️  没有需要提交的更改。" -ForegroundColor Yellow
} else {
    git add "计算机网络整体整理.docx"
    $commitMsg = "更新 DOCX — $lastModified"
    git commit -m $commitMsg
    Write-Host "   ✅ 已提交: $commitMsg" -ForegroundColor Green

    Write-Host ""
    Write-Host "🚀 正在推送到 GitHub..." -ForegroundColor White
    git push
    Write-Host "   ✅ 已推送成功！" -ForegroundColor Green
}

# 5. 完成
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🎉 同步完成！" -ForegroundColor Green
Write-Host "  📎 下载页面: $pageUrl" -ForegroundColor Cyan
Write-Host "  ⚠️  GitHub Pages 可能需要几十秒才能反映最新更改。" -ForegroundColor DarkYellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "按回车退出"
