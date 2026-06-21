<#
.SYNOPSIS
    システム全体を UTF-8 (コードページ 65001) に統一する。
.DESCRIPTION
    「ベータ: ワールドワイド言語サポートで Unicode UTF-8 を使用」相当のレジストリ変更。
    ACP / OEMCP を 65001 に設定する。反映には再起動が必要。
    元に戻すには値を 932 (Shift_JIS) に戻す。
#>
[CmdletBinding()]
param()

# 管理者権限がなければ昇格して再実行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`""
    exit
}

$nls = "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage"
Set-ItemProperty -Path $nls -Name "ACP"   -Value "65001"
Set-ItemProperty -Path $nls -Name "OEMCP" -Value "65001"

Write-Host "システムコードページを UTF-8 (65001) に設定しました。" -ForegroundColor Green
Write-Host "反映には再起動が必要です。" -ForegroundColor Yellow
