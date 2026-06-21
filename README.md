# dotfiles-win

Windows 用 dotfiles。macOS/Linux 版は [dotfiles](https://github.com/bigdra50/dotfiles) で管理する。

シンボリックリンクベースで設定を管理し、クロスプラットフォーム設定 (wezterm, nvim, git 等) は本体 dotfiles に委譲する。

## 構成

```
dotfiles-win/
├── install.ps1            # シンボリックリンク作成
├── powershell/            # PowerShell 7 プロファイル
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── functions/         # 機能別モジュール (Aliases, PSReadLine, OhMyPosh 等)
│   ├── packages.json      # パッケージ定義 (PackageManagement.ps1 用)
│   └── powershell.config.json
├── windows-terminal/      # Windows Terminal settings.json
├── packages/              # winget / scoop エクスポート
│   ├── winget.json
│   └── scoop.json
└── setup/                 # マシン初期設定スクリプト
    ├── utf8.ps1           # システム全体を UTF-8 化
    └── openssh-server.ps1 # SSH サーバー構築
```

## セットアップ

### シンボリックリンク作成

開発者モードが有効なら管理者権限なしで実行できる。

```powershell
pwsh -ExecutionPolicy Bypass -File install.ps1
```

既存の実体ファイルは `*.bak.<timestamp>` に退避される。

### システム UTF-8 化

```powershell
pwsh -File setup/utf8.ps1   # 管理者権限へ自動昇格、要再起動
```

### SSH サーバー構築

```powershell
# パスワード認証のみ
pwsh -File setup/openssh-server.ps1

# 公開鍵を登録 (管理者ユーザーは administrators_authorized_keys を使用)
pwsh -File setup/openssh-server.ps1 -PublicKey "ssh-ed25519 AAAA... mac"
```

### パッケージ復元

```powershell
winget import -i packages/winget.json
scoop import packages/scoop.json
```

## 前提

- PowerShell 7 (`pwsh`)
- 開発者モード有効 (symlink 作成用)
- winget / scoop
