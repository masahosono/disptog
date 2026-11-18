<p align="center">
  <img src="Resources/icon_1024.png" alt="DispTog アイコン" width="128" height="128">
</p>

# DispTog 🖥️

[English](README.md) | 日本語

ディスプレイの **ミラーリング／拡張** モードをワンクリックで切り替えられる macOS 用メニューバーアプリです。

[![Check](https://github.com/your-username/disptog/actions/workflows/check.yml/badge.svg)](https://github.com/your-username/disptog/actions/workflows/check.yml)
![macOS](https://img.shields.io/badge/macOS-11.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

## ✨ 特徴

- 🖱️ メニューバーから **ワンクリックで切り替え**
- ⌨️ **グローバルショートカット**（`⌘⇧M`）でどこからでも切り替え可能
- 🪶 **軽量でシンプル** - 必要最小限の機能のみ
- 🚫 **Dock に表示されない** - メニューバーにのみ常駐

## 📦 インストール

### 方法 1: DMG をダウンロード（推奨）

1. [Releases](https://github.com/your-username/disptog/releases/latest) から最新の DMG をダウンロード
2. DMG を開き、DispTog をアプリケーションフォルダへドラッグ
3. DispTog を起動

### 方法 2: ソースからビルド

```bash
# リポジトリをクローン
git clone https://github.com/your-username/disptog.git
cd disptog

# XcodeGen をインストール
brew install xcodegen

# Xcode プロジェクトを生成
xcodegen generate

# コマンドラインでビルド
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Release -derivedDataPath build

# または Xcode で開いてビルド
open DispTog.xcodeproj
# ⌘B でビルド、⌘R で実行
```

### 方法 3: Xcode でビルド

1. Xcode を開く
2. File > New > Project > macOS > App を選択
3. `Sources/` 内の Swift ファイルをプロジェクトに追加
4. `Sources/Info.plist` の内容をプロジェクトの Info.plist にマージ
5. ビルドして実行

## 🚀 使い方

### 起動

```bash
# Xcode でビルドした後に実行
open build/Build/Products/Debug/DispTog.app

# リリース版を実行
open build/Build/Products/Release/DispTog.app

# アプリケーションフォルダから起動（インストール済みの場合）
open /Applications/DispTog.app
```

### 操作方法

| 操作 | 説明 |
|------|------|
| 🖱️ メニューバーアイコンをクリック | メニューを表示 |
| 🔄 「Toggle Mirroring/Extended」を選択 | モードを切り替え |
| ⌨️ `⌘⇧M`（Command + Shift + M） | グローバルショートカットで切り替え |

### ディスプレイモード

- **🪞 ミラーリング**: すべてのディスプレイに同じ画面を表示
- **📺 拡張デスクトップ**: 各ディスプレイを独立した画面として使用

## ⚙️ 初期設定

グローバルショートカットを使うには、アクセシビリティの許可が必要です。

1. **システム設定** を開く
2. **プライバシーとセキュリティ** > **アクセシビリティ** に移動
3. **DispTog** を有効にする

## 🔧 開発

### 必要なもの

- macOS 11.0（Big Sur）以降
- Xcode Command Line Tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（プロジェクト生成）

```bash
# Command Line Tools をインストール
xcode-select --install

# XcodeGen をインストール
brew install xcodegen

# Xcode プロジェクトを生成
xcodegen generate

# SPM の依存関係を解決（SwiftLint、SwiftFormat 用）
swift package resolve
```

### ビルドコマンド

```bash
# Xcode プロジェクトを生成（クローン後、または project.yml の更新後に必要）
xcodegen generate

# Xcode で開く
open DispTog.xcodeproj

# Xcode でビルド・実行
# ⌘B でビルド
# ⌘R で実行

# コマンドラインでビルド
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Debug

# リリース版をビルド
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Release -derivedDataPath build

# コード品質ツール
swift run swiftformat .          # コードを整形
swift run swiftformat --lint .   # 整形をチェック
swift run swiftlint              # Lint を実行
```

### プロジェクト構成

```
disptog/
├── README.md              # README（英語）
├── README_ja.md           # このファイル（日本語）
├── LICENSE                # MIT ライセンス
├── CONTRIBUTING.md        # コントリビューションガイド
├── AGENTS.md              # AI コーディングエージェント向けガイド
├── project.yml            # XcodeGen のプロジェクト設定
├── Package.swift          # SPM の依存関係（SwiftLint、SwiftFormat）
├── .swiftlint.yml         # SwiftLint の設定
├── .swiftformat           # SwiftFormat の設定
├── .github/
│   └── workflows/
│       ├── check.yml      # CI: Lint とビルド（PR 時）
│       └── build.yml      # CD: リリースと DMG の作成
├── Sources/
│   ├── DispTogApp.swift      # メインアプリ（エントリーポイント）
│   ├── DisplayManager.swift  # ディスプレイ制御ロジック
│   └── Info.plist            # アプリの設定
└── build/                 # ビルド成果物（.gitignore 対象）
    └── Build/Products/
        ├── Debug/DispTog.app
        └── Release/DispTog.app
```

### コードの解説

Swift のコードには、TypeScript/JavaScript 開発者向けの詳しいコメント（英語）を付けています。

#### `DispTogApp.swift`
- **役割**: アプリケーションのエントリーポイント
- **相当する概念**: `index.ts` / `main.ts`
- **主な責務**:
  - メニューバー項目の作成
  - グローバルショートカットの登録
  - UI イベントの処理

#### `DisplayManager.swift`
- **役割**: ディスプレイ制御のビジネスロジック
- **相当する概念**: サービスクラス / ユーティリティモジュール
- **主な責務**:
  - ディスプレイ情報の取得
  - ミラーリング／拡張モードの切り替え

### リリース方法

新しいバージョンをリリースする手順:

1. GitHub の [Releases](https://github.com/your-username/disptog/releases) ページで新しいリリースを作成
2. タグ名を `v1.0.0` の形式で設定
3. リリースを **Publish** する

GitHub Actions が自動的に DMG をビルドし、リリースのアセットにアップロードします。

## 🐛 トラブルシューティング

### ショートカットが効かない

1. システム設定 > プライバシーとセキュリティ > アクセシビリティ で許可されているか確認
2. アプリを再起動

### ディスプレイが切り替わらない

1. ディスプレイが 2 台以上接続されているか確認
2. Console.app のログを確認

### ビルドエラー

```bash
# Xcode Command Line Tools を再インストール
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

## 🤝 コントリビュート

Issue や Pull Request を歓迎します。詳しくは [CONTRIBUTING.md](CONTRIBUTING.md)（英語）をご覧ください。

## 📄 ライセンス

MIT ライセンス - 詳しくは [LICENSE](LICENSE) をご覧ください。

## 🙏 謝辞

- [Apple CoreGraphics Framework](https://developer.apple.com/documentation/coregraphics)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SwiftLint](https://github.com/realm/SwiftLint)
