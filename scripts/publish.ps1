# =========================================================
#  snu サイト公開スクリプト
#  git-push.bat から呼ばれます。直接編集する必要はありません。
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
Write-Host '  snu サイトを公開します' -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan

# --- Git があるか ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Stop-WithMessage 'Git が見つかりません。管理者に連絡してください。'
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

# --- 変更があるか ---
$changes = git -c core.quotepath=false status --porcelain
if (-not $changes) {
    Write-Host ''
    Write-Host '公開する変更はありません。' -ForegroundColor Yellow
    Read-Host 'Enterキーで閉じます'
    exit 0
}

# --- 変更ファイルの一覧 ---
Write-Host ''
Write-Host '■ 今回公開される変更:' -ForegroundColor White
$draftWarnings = @()
foreach ($line in $changes) {
    $code = $line.Substring(0, 2).Trim()
    $path = $line.Substring(3).Trim('"')
    switch -Regex ($code) {
        'D'      { $label = '削除' }
        '\?\?|A' { $label = '新規' }
        default  { $label = '変更' }
    }
    Write-Host ("   [{0}] {1}" -f $label, $path)
    if ($label -ne '削除' -and $path -match '\.md$' -and (Test-Path -LiteralPath $path)) {
        $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ($text -match '(?m)^draft:\s*true') { $draftWarnings += $path }
    }
}

if ($draftWarnings.Count -gt 0) {
    Write-Host ''
    Write-Host '■ 注意: 次のページは draft: true のため、サイトには表示されません' -ForegroundColor Yellow
    foreach ($d in $draftWarnings) { Write-Host "   $d" -ForegroundColor Yellow }
    Write-Host '   （表示したい場合は Obsidian で draft を false にしてください）' -ForegroundColor Yellow
}

# --- メモと確認 ---
Write-Host ''
$memo = Read-Host '変更内容のメモ（例: 作品ページ追加。空欄のままEnterでもOK）'
$answer = Read-Host '公開してよろしいですか？ (y = はい / n = やめる)'
if ($answer -notmatch '^(y|Y|ｙ|はい)$') {
    Write-Host '中止しました。何も公開していません。' -ForegroundColor Yellow
    Read-Host 'Enterキーで閉じます'
    exit 0
}

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$message = "更新 $stamp"
if ($memo) { $message = "$message : $memo" }
$msgFile = Join-Path $root '.git\PUBLISH_MSG'
[System.IO.File]::WriteAllText($msgFile, $message, (New-Object System.Text.UTF8Encoding $false))

# --- 他の人の更新を先に取り込む ---
Write-Host ''
Write-Host '最新の状態を確認しています...'
git pull --rebase --autostash --quiet
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage '他の人の更新と内容がぶつかりました。何も公開していません。管理者に連絡してください。'
}

# --- 記録して送信 ---
git add -A
git commit --quiet -F $msgFile
if ($LASTEXITCODE -ne 0) { Stop-WithMessage '変更の記録に失敗しました。管理者に連絡してください。' }

Write-Host 'GitHub に送信しています...'
git push --quiet
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage '送信に失敗しました。インターネット接続を確認して、もう一度実行してください。'
}

Write-Host ''
Write-Host '完了しました。2〜3分後に https://snu-o.com/ に反映されます。' -ForegroundColor Green
Write-Host '進み具合: https://github.com/kentng111/mysite/actions'
Write-Host ''
Read-Host 'Enterキーで閉じます'
