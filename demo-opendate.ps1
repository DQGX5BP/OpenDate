chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
$Root = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Root)) { $Root = (Get-Location).Path }
Set-Location -LiteralPath $Root
$Host.UI.RawUI.WindowTitle = "OpenDate 0.1.0 · 离线演示（不发送任何消息）"
try {
    $cols = [int]$Host.UI.RawUI.WindowSize.Width
    if ($cols -gt 160) { $cols = 160 }
    $env:COLUMNS = "$cols"
    $env:LINES = "$([int]$Host.UI.RawUI.WindowSize.Height)"
} catch { }
Clear-Host
Write-Host ""
Write-Host "  OpenDate 0.1.0  ·  离线演示" -ForegroundColor Cyan
Write-Host "  mock 数据 + stub 模型：不联网、不登录、不发送任何消息" -ForegroundColor DarkGray
Write-Host ""
& (Join-Path $Root ".venv\Scripts\python.exe") -m opendate --mock run --cycles 1 --no-interactive
Write-Host ""
Write-Host "  演示结束 —— 以上都是 proposed / dry-run，没有一条消息被真的发出去。" -ForegroundColor DarkGray
Write-Host ""