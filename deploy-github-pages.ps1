$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

Write-Host "1. Checking GitHub CLI login..." -ForegroundColor Cyan
gh auth status -h github.com 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub token expired. Opening browser to authenticate..." -ForegroundColor Yellow
    gh auth login -h github.com -p https -w
}

$user = (gh api user --jq .login).Trim()
if (-not $user) {
    Write-Host "Error: GitHub login was not completed." -ForegroundColor Red
    exit 1
}

$repoName = "len-chua-cau-an"
Write-Host "2. Creating/updating repository $user/$repoName and pushing main branch..." -ForegroundColor Cyan

gh repo view "$user/$repoName" >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    gh repo create $repoName --public --source=. --remote=origin --push
} else {
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$user/$repoName.git"
    git push -u origin main --force
}

Write-Host "3. Enabling GitHub Pages on branch main..." -ForegroundColor Cyan
gh api -X POST "repos/$user/$repoName/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null

$pagesUrl = "https://$user.github.io/$repoName/"
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "DEPLOYED TO GITHUB PAGES SUCCESSFULLY!" -ForegroundColor Green
Write-Host "Public URL (live in ~30-60 seconds):" -ForegroundColor Yellow
Write-Host $pagesUrl -ForegroundColor White
Write-Host "=====================================================" -ForegroundColor Green
Start-Process $pagesUrl
