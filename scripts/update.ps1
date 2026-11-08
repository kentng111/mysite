# =========================================================
#  snu サイト：最新の状態を取得
#  get-latest.bat から呼ばれます。作業を始める前に実行してください。
# =========================================================
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Stop-WithMessage($msg) {
    Write-Host ''
    Write-Host $msg -ForegroundColor Red
    Write-Host ''
    Read-Host 'Enterキーで閉じます'
    exit 1
}

Write-Host '=============================================' -ForegroundColor Cyan
Write-Host '  最新の状態を取得します' -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Stop-WithMessage 'Git が見つかりません。手順書「02_新しいPCのセットアップ」を確認してください。'
}

# --- 初回のみ：記録に使う名前とメールを登録 ---
if (-not (git config user.name)) {
    Write-Host ''
    Write-Host '初回のみ、更新履歴に記録する名前とメールアドレスを登録します。' -ForegroundColor Cyan
    $n = Read-Host '名前（例: Kento Nagao）'
    $e = Read-Host 'GitHub に登録したメールアドレス'
    if (-not $n -or -not $e) { Stop-WithMessage '名前とメールアドレスが空のため中止しました。' }
    git config --global user.name $n
    git config --global user.email $e
}

$before = git rev-parse HEAD
git pull --rebase --autostash --quiet
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage '取得に失敗しました。インターネット接続を確認して、もう一度実行してください。続く場合は管理者に連絡してください（手順書「05_FAQ」参照）。'
}
$after = git rev-parse HEAD

Write-Host ''
if ($before -eq $after) {
    Write-Host 'すでに最新です。そのまま作業を始めてください。' -ForegroundColor Green
} else {
    Write-Host '■ 取り込んだ更新:' -ForegroundColor White
    git -c core.quotepath=false log --format='   %ad  %an  %s' --date=format:'%m/%d %H:%M' "$before..$after"
    Write-Host ''
    Write-Host '最新になりました。作業を始めてください。' -ForegroundColor Green
}
Write-Host ''
Read-Host 'Enterキーで閉じます'
