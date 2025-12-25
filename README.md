# Logseq Task Viewer

A macOS menu bar application for viewing tasks from Logseq DB graphs with customizable queries.

![Version](https://img.shields.io/badge/version-1.0.1-blue)
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

## ✏️ Editing Queries

The app includes three default queries (DOING, TODO, High Priority), but you can create custom queries to view tasks however you want.

### Opening the Query Manager

- Click the gear icon (⚙️) in the task list popover, **OR**
- Double-click the menu bar icon

### Editing a Query

1. **Select a query** from the list on the left
2. **Edit the Datalog query** in the text area
3. **Click "Update Query"** to save your changes
4. **Double-click the query name** to execute it and see results

### Creating a New Query

1. Click **"+ New Query"** button
2. Enter a name for your query
3. Write your Datalog query
4. Click "Create Query"
5. Double-click to execute

### Query Examples

**View all tasks with a specific tag:**
```clojure
[:find (pull ?b [*])
 :where
 [?b :block/tags ?t]
 [?t :db/id 140]  ; Task tag
 [?b :block/tags ?tag]
 [?tag :block/title "YourTagName"]]
```

**View tasks due this week:**
```clojure
[:find (pull ?b [*])
 :where
 [?b :block/tags ?t]
 [?t :db/id 140]
 [?b :logseq.property/deadline ?deadline]
 [(< ?deadline 1735689600000)]]  ; Replace with your date
```

**View tasks with both tag and status:**
```clojure
[:find (pull ?b [*])
 :where
 [?b :block/tags ?t]
 [?t :db/id 140]
 [?b :logseq.property/status ?s]
 [?s :block/title "Doing"]
 [?b :block/tags ?tag]
 [?tag :block/title "Work"]]
```

### Important Notes

- **Read-only**: This app only views tasks - you cannot edit tasks from the app
- **Edit in Logseq**: To modify tasks, open Logseq and make changes there
- **DB graphs only**: Queries use Datalog and only work with Logseq database graphs
- **Task tag required**: All tasks must be tagged with `#Task` (db/id 140)
- **Refresh**: Click the menu bar icon to refresh the current query

### Query Tips

- Use `(pull ?b [*])` to get all block properties
- Block references `[[uuid]]` are automatically resolved to titles
- Check [Logseq Datalog documentation](https://docs.logseq.com/#/page/advanced%20queries) for query syntax
- Test queries in Logseq first before adding them to the app

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
