chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

$Root = if ($PSScriptRoot) { $PSScriptRoot } else { "F:\OpenDate" }
$Py   = Join-Path $Root ".venv\Scripts\python.exe"
$Cli  = Join-Path $Root ".venv\Scripts\opendate.exe"

Set-Location -LiteralPath $Root
$Host.UI.RawUI.WindowTitle = "OpenDate 0.1.0  |  $Root"

if (-not (Test-Path -LiteralPath $Py)) {
    Write-Host ""
    Write-Host "  未找到运行环境：$Py" -ForegroundColor Red
    Write-Host "  安装目录不完整，需要重新安装。" -ForegroundColor Red
    Write-Host ""
    Read-Host "  按回车退出" | Out-Null
    exit 1
}

# 首次使用自动生成 config.yaml 与 .env（已存在则不动）
$needInit = (-not (Test-Path -LiteralPath (Join-Path $Root "config.yaml"))) -or (-not (Test-Path -LiteralPath (Join-Path $Root ".env")))
if ($needInit) {
    & $Py -m opendate init . | Out-Null
}

function Pause-Any {
    Write-Host ""
    Read-Host "  按回车返回菜单" | Out-Null
}

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "  OpenDate 0.1.0   开源 AI 约会助手" -ForegroundColor Cyan
    Write-Host "  安装位置  $Root" -ForegroundColor DarkGray
    Write-Host "  默认配置：每条消息发送前都会问你，不会自己发出去" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1] 离线试跑      不联网、不发消息，先看它怎么工作" -ForegroundColor Gray
    Write-Host "  [2] 查看技能      14 个约会技能及打法" -ForegroundColor Gray
    Write-Host "  [3] 查看模型      19 家模型提供方与对应密钥变量" -ForegroundColor Gray
    Write-Host "  [4] 编辑配置      config.yaml（行为）与 .env（密钥）" -ForegroundColor Gray
    Write-Host "  [5] 重建配置      重新生成模板，覆盖前会先备份" -ForegroundColor Gray
    Write-Host "  [6] 真实运行      读你的配置跑一轮，逐条确认才发送" -ForegroundColor Gray
    Write-Host "  [7] 使用说明      打开中文完整使用说明" -ForegroundColor Gray
    Write-Host "  [8] 打开安装目录  资源管理器定位到 $Root" -ForegroundColor Gray
    Write-Host "  [0] 退出" -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "  输入序号后回车"
    if ($null -eq $choice) { $choice = "" }

    switch ($choice.Trim()) {
        "1" {
            Clear-Host
            Write-Host "  离线试跑：mock 数据 + 桩模型，不联网、不登录、不发送任何消息" -ForegroundColor Cyan
            Write-Host ""
            & $Cli --mock run --cycles 1 --no-interactive
            Write-Host ""
            Write-Host "  以上都是 proposed / dry-run，没有一条消息真的发出去。" -ForegroundColor DarkGray
            Pause-Any
        }
        "2" {
            Clear-Host
            & $Cli skills -v
            Pause-Any
        }
        "3" {
            Clear-Host
            & $Cli providers
            Write-Host ""
            Write-Host "  把对应的密钥变量写进 .env，再在 config.yaml 里选 llm.provider。" -ForegroundColor DarkGray
            Pause-Any
        }
        "4" {
            Clear-Host
            if (Test-Path -LiteralPath (Join-Path $Root "config.yaml")) { Start-Process notepad.exe -ArgumentList (Join-Path $Root "config.yaml") }
            if (Test-Path -LiteralPath (Join-Path $Root ".env")) { Start-Process notepad.exe -ArgumentList (Join-Path $Root ".env") }
            Write-Host "  已用记事本打开 config.yaml 与 .env，改完保存即可。" -ForegroundColor DarkGray
            Pause-Any
        }
        "5" {
            Clear-Host
            $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
            foreach ($f in @("config.yaml", ".env")) {
                $p = Join-Path $Root $f
                if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination "$p.bak-$stamp" -Force }
            }
            & $Py -m opendate init . --force
            Write-Host ""
            Write-Host "  已重新生成模板，旧文件备份为 *.bak-$stamp" -ForegroundColor DarkGray
            Pause-Any
        }
        "6" {
            Clear-Host
            Write-Host "  真实运行：需要 .env 里已有 TINDER_AUTH_TOKEN 和模型密钥。" -ForegroundColor Yellow
            Write-Host "  每一条拟发消息都会先问你，回车或输 n 即不发送。" -ForegroundColor Yellow
            Write-Host ""
            & $Cli run --cycles 1
            Pause-Any
        }
        "7" {
            $doc = Join-Path $Root "中文使用说明.md"
            if (Test-Path -LiteralPath $doc) { Start-Process notepad.exe -ArgumentList $doc }
            else { Write-Host "  未找到：$doc" -ForegroundColor Red; Pause-Any }
        }
        "8" {
            Start-Process explorer.exe -ArgumentList $Root
        }
        "0" {
            exit 0
        }
        default {
            Write-Host "  没有这个序号，请重新输入。" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 700
        }
    }
}