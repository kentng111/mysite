# Obsidian title -> folder rename watcher (PowerShell)
# Configure watch root:
$WatchRoot = "C:\Users\kentn\myApp\mysite\content"

$DebounceMs = 800
$DryRun = $false

function Sanitize-FolderName([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) { return $null }
  $invalid = '[\\\/:\*\?"<>\|]'
  $clean = ($name -replace $invalid, "-").Trim()
  $clean = $clean.TrimEnd('.', ' ')
  if ($clean.Length -eq 0) { return $null }
  return $clean
}

function Get-FrontmatterTitle([string]$filePath) {
  try { $lines = Get-Content -LiteralPath $filePath -ErrorAction Stop }
  catch { return $null }

  if ($lines.Count -lt 3) { return $null }
  if ($lines[0].Trim() -ne "---") { return $null }

  $endIndex = -1
  for ($i=1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq "---") { $endIndex = $i; break }
  }
  if ($endIndex -lt 0) { return $null }

  for ($i=1; $i -lt $endIndex; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*title\s*:\s*(.+)\s*$') {
      $raw = $Matches[1].Trim()
      if (($raw.StartsWith('"') -and $raw.EndsWith('"')) -or ($raw.StartsWith("'") -and $raw.EndsWith("'"))) {
        $raw = $raw.Substring(1, $raw.Length-2)
      }
      return $raw.Trim()
    }
  }
  return $null
}

$lastHandled = @{}

function Handle-FileChange([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return }
  if ([IO.Path]::GetExtension($path).ToLower() -ne ".md") { return }

  $folder = Split-Path -Parent $path
  if (-not $folder) { return }

  $now = [DateTime]::UtcNow
  if ($lastHandled.ContainsKey($folder)) {
    $delta = ($now - $lastHandled[$folder]).TotalMilliseconds
    if ($delta -lt $DebounceMs) { return }
  }
  $lastHandled[$folder] = $now

  $title = Get-FrontmatterTitle $path
  $safeTitle = Sanitize-FolderName $title
  if (-not $safeTitle) {
    Write-Host "[SKIP] title not found/invalid: $path"
    return
  }

  $parent = Split-Path -Parent $folder
  $currentFolderName = Split-Path -Leaf $folder

  if ($currentFolderName -eq $safeTitle) {
    Write-Host "[OK] already matched: $folder"
    return
  }

  $newFolder = Join-Path $parent $safeTitle
  if (Test-Path -LiteralPath $newFolder) {
    Write-Host "[SKIP] target already exists: $newFolder"
    return
  }

  Write-Host "[RENAME] '$currentFolderName' -> '$safeTitle' (file: $path)"
  if ($DryRun) {
    Write-Host "        DryRun=true (no rename)"
    return
  }

  try {
    Rename-Item -LiteralPath $folder -NewName $safeTitle -ErrorAction Stop
    Write-Host "        DONE: $newFolder"
  } catch {
    Write-Host "[ERROR] rename failed: $($_.Exception.Message)"
  }
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WatchRoot
$watcher.Filter = "*.md"
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, Size'

Register-ObjectEvent $watcher Changed -Action { Handle-FileChange $Event.SourceEventArgs.FullPath } | Out-Null
Register-ObjectEvent $watcher Created -Action { Handle-FileChange $Event.SourceEventArgs.FullPath } | Out-Null
Register-ObjectEvent $watcher Renamed -Action { Handle-FileChange $Event.SourceEventArgs.FullPath } | Out-Null

$watcher.EnableRaisingEvents = $true

Write-Host "Watching: $WatchRoot"
Write-Host "Close this window to stop."
while ($true) { Start-Sleep -Seconds 2 }
