# Script tự động đăng nhập lại GitHub (nếu token hết hạn), tạo repo và bật GitHub Pages
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "1. Kiểm tra đăng nhập GitHub CLI..." -ForegroundColor Cyan
gh auth status -h github.com 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Token GitHub cũ đã hết hạn. Đang mở trình duyệt để xác thực lại..." -ForegroundColor Yellow
    gh auth login -h github.com -p https -w
}

$user = (gh api user --jq .login).Trim()
$repoName = "len-chua-cau-an"

Write-Host "2. Tạo kho chứa (repository) $user/$repoName và đẩy code lên..." -ForegroundColor Cyan
$repoExists = $true
gh repo view "$user/$repoName" >$null 2>&1
if ($LASTEXITCODE -ne 0) { $repoExists = $false }

if (-not $repoExists) {
    gh repo create $repoName --public --source=. --remote=origin --push
} else {
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$user/$repoName.git"
    git push -u origin main --force
}

Write-Host "3. Bật GitHub Pages từ nhánh main..." -ForegroundColor Cyan
gh api -X POST "repos/$user/$repoName/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null

$pagesUrl = "https://$user.github.io/$repoName/"
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "ĐÃ ĐẨY LÊN GITHUB PAGES THÀNH CÔNG!" -ForegroundColor Green
Write-Host "Link công khai của bác (sẽ hoạt động sau ~30-60 giây):" -ForegroundColor Yellow
Write-Host $pagesUrl -ForegroundColor White
Write-Host "=====================================================" -ForegroundColor Green
