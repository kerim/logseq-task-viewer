# Logseq Task Viewer

A macOS menu bar application for viewing and managing tasks from Logseq DB graphs.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 📥 Installation

### Option 1: Download Pre-Built App (Recommended)

1. Download `LogseqTaskViewer.app.zip` from [Releases](https://github.com/kerim/logseq-task-viewer/releases/latest)
2. Unzip and move to Applications folder
3. **First launch:** Right-click → Open (to bypass Gatekeeper)
4. Install dependencies (see Requirements below)

### Option 2: Build from Source

```bash
git clone https://github.com/kerim/logseq-task-viewer.git
cd logseq-task-viewer
xcodebuild -scheme LogseqTaskViewer -configuration Release build
```

Built app will be in: `build/Release/LogseqTaskViewer.app`

## 📋 Requirements

**System:**
- macOS 13.0 or later

**Dependencies** (install via Homebrew):
```bash
brew install logseq  # Logseq CLI
brew install jet     # EDN/JSON converter
```

**Logseq Setup:**
- Must use **DB graph** (database-based, not file/markdown)
- Tasks must have `#Task` tag
- Supports status: Todo, Doing, Done, Cancelled
- Supports priority: Urgent, High, Medium, Low

## ✨ Features

- 🎯 **Menu Bar Integration** - Quick access from macOS menu bar
- 📋 **Multiple Queries** - DOING, TODO, High Priority (default)
- 🔍 **Custom Queries** - Create and save your own Datalog queries
- 🎨 **Priority Display** - Color-coded icons (Urgent=🔴, High=🟠, Medium=🟡, Low=🔵)
- 📅 **Date Conversion** - Timestamps shown as readable dates
- 💾 **Query Persistence** - Saved queries persist across launches
- 🔄 **Graph Switching** - Select between multiple Logseq databases
- ⚡ **Query Manager** - Double-click to execute, easy editing

## 🚀 Quick Start

1. **Install dependencies** (see Requirements)
2. **Launch app** - Find checkmark icon in menu bar
3. **Select graph** - Open Query Manager → Choose your Logseq database
4. **View tasks** - Click menu bar icon to see current query results
5. **Switch queries** - Open Query Manager → Double-click different query

## 📖 Documentation

- [CHANGELOG.md](docs/CHANGELOG.md) - Version history
- [DEVELOPMENT_REPORT.md](docs/DEVELOPMENT_REPORT.md) - Development journey
- [QUERY_UPDATE_SUMMARY.md](docs/QUERY_UPDATE_SUMMARY.md) - Query implementation details

## 🐛 Known Issues

- Link resolution in custom queries (workaround: use block references)
- Loading text always shows "DOING" (cosmetic issue)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Built for the Logseq community
- Uses Logseq CLI and Jet for data processing
- Inspired by other Logseq productivity tools

## 📧 Contact

For questions or issues, please [open an issue](https://github.com/kerim/logseq-task-viewer/issues) on GitHub.
