<#
.SYNOPSIS
    dotfiles-win のシンボリックリンクを作成する。
.DESCRIPTION
    リポジトリ内の設定ファイルを実際の配置先へ symlink する。
    既存の実体ファイルは .bak.<timestamp> に退避してから置き換える。
    開発者モードが有効なら管理者権限なしで symlink を作成できる。
#>
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot

# リンク対象: @{ Link = 配置先; Target = リポジトリ内パス }
$psHome = Join-Path $HOME "Documents\PowerShell"
$wtState = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

$links = @(
    @{ Link = Join-Path $psHome "Microsoft.PowerShell_profile.ps1"; Target = "$repo\powershell\Microsoft.PowerShell_profile.ps1" }
    @{ Link = Join-Path $psHome "profile.ps1";                       Target = "$repo\powershell\profile.ps1" }
    @{ Link = Join-Path $psHome "powershell.config.json";           Target = "$repo\powershell\powershell.config.json" }
    @{ Link = Join-Path $psHome "packages.json";                    Target = "$repo\powershell\packages.json" }
    @{ Link = Join-Path $psHome "CLAUDE.md";                        Target = "$repo\powershell\CLAUDE.md" }
    @{ Link = Join-Path $psHome "functions";                        Target = "$repo\powershell\functions" }
    @{ Link = Join-Path $wtState "settings.json";                   Target = "$repo\windows-terminal\settings.json" }
)

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"

foreach ($l in $links) {
    $link = $l.Link
    $target = $l.Target

    if (-not (Test-Path $target)) {
        Write-Host "[SKIP] ターゲットが存在しません: $target" -ForegroundColor DarkYellow
        continue
    }

    # 既に正しい symlink ならスキップ
    $existing = Get-Item $link -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $target) {
        Write-Host "[OK]   既にリンク済み: $link" -ForegroundColor Green
        continue
    }

    # 配置先ディレクトリを用意
    $parent = Split-Path -Parent $link
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    # 既存の実体を退避
    if ($existing) {
        $backup = "$link.bak.$stamp"
        Move-Item -Path $link -Destination $backup -Force
        Write-Host "[BAK]  退避: $link -> $backup" -ForegroundColor DarkCyan
    }

    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "[LINK] $link -> $target" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "完了。新しいシェルを開いて反映を確認してください。" -ForegroundColor Green
