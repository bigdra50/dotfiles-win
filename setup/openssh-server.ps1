<#
.SYNOPSIS
    OpenSSH サーバーをセットアップする。
.DESCRIPTION
    - OpenSSH Server をインストール
    - sshd サービスを自動起動で開始
    - ファイアウォールでポート 22 を開放
    - 既定シェルを pwsh (PowerShell 7) に設定
    - 管理者ユーザー向けの公開鍵ファイル (administrators_authorized_keys) を
      正しい ACL で配置する補助
.PARAMETER PublicKey
    登録する公開鍵文字列 (例: "ssh-ed25519 AAAA... mac")。省略時は鍵設定をスキップ。
#>
[CmdletBinding()]
param(
    [string]$PublicKey
)

# 管理者権限がなければ昇格して再実行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"")
    if ($PublicKey) { $argList += @("-PublicKey", "`"$PublicKey`"") }
    Start-Process pwsh -Verb RunAs -ArgumentList $argList
    exit
}

# 1. OpenSSH Server インストール
$cap = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
if ($cap.State -ne "Installed") {
    Write-Host "OpenSSH Server をインストールします..." -ForegroundColor Cyan
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
} else {
    Write-Host "OpenSSH Server はインストール済みです。" -ForegroundColor Green
}

# 2. sshd を自動起動で開始
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd
Write-Host "sshd サービスを開始しました (自動起動)。" -ForegroundColor Green

# 3. ファイアウォール (ポート 22)
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Write-Host "ファイアウォールでポート 22 を開放しました。" -ForegroundColor Green
} else {
    Write-Host "ファイアウォール規則は既に存在します。" -ForegroundColor Green
}

# 4. 既定シェルを pwsh に
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
if (Test-Path $pwshPath) {
    if (-not (Test-Path "HKLM:\SOFTWARE\OpenSSH")) {
        New-Item -Path "HKLM:\SOFTWARE\OpenSSH" -Force | Out-Null
    }
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" `
        -Value $pwshPath -PropertyType String -Force | Out-Null
    Write-Host "SSH 既定シェルを pwsh に設定しました。" -ForegroundColor Green
}

# 5. 公開鍵の登録 (管理者ユーザーは administrators_authorized_keys を使用)
if ($PublicKey) {
    $keyFile = "C:\ProgramData\ssh\administrators_authorized_keys"
    Add-Content -Path $keyFile -Value $PublicKey -Encoding ascii

    # ACL を Administrators と SYSTEM のみに制限 (これを怠ると鍵が無視される)
    icacls $keyFile /inheritance:r | Out-Null
    icacls $keyFile /grant "Administrators:F" /grant "SYSTEM:F" | Out-Null
    Write-Host "公開鍵を登録し、ACL を設定しました。" -ForegroundColor Green
} else {
    Write-Host "公開鍵は指定されませんでした (パスワード認証のまま)。" -ForegroundColor Yellow
    Write-Host "鍵を登録するには -PublicKey '<key>' を渡してください。" -ForegroundColor Yellow
}
