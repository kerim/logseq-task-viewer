# Logseq Task Viewer

A macOS menu bar application for viewing and managing Logseq tasks.

## 🎉 Current Status: Version 0.0.1 Released!

**First Functional Version** - Successfully displays DOING tasks with actual content

## 📋 Quick Start

### Prerequisites
- macOS 13.0+
- Xcode 15+
- Logseq CLI installed (`brew install logseq`)
- Jet CLI for EDN conversion (`brew install jet`)

### Building
```bash
xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer
```

### Running
```bash
open -a Xcode LogseqTaskViewer.xcodeproj
# Then run from Xcode
```

## ✨ Features (Version 0.0.1)

### Working Functionality
- ✅ Query Logseq for DOING tasks
- ✅ Display task UUIDs and content
- ✅ Resolve status names to human-readable format
- ✅ Proper data decoding for complex results
- ✅ Console output of task information

### Sample Output
```
Found 3 DOING tasks
Task 1: "1st December [[68301217-1a99-4d9b-a2f8-e8756851ec28]] post"
Task 2: "[[692a5173-3bb9-49fa-85d2-c74ba89ea796]]"
Task 3: "Watch [[68f48c70-c9cf-4960-89b1-853802050a5f]] Films that I haven't seen yet"
```

## 🚀 Roadmap

### Version 0.0.1 (Current) - "Basic DOING Tasks Display"
- ✅ Functional DOING tasks query
- ✅ Proper data decoding
- ✅ Console display
- ✅ Status resolution

### Version 0.0.2 (Next) - "Complete Task Display"
- 🔜 Actual UI implementation
- 🔜 All status types support
- 🔜 Error handling
- 🔜 Basic user interaction

### Future Versions
- Task filtering and search
- Task creation/editing
- Multiple graph support
- Priority and date display
- Advanced filtering options

## 📚 Documentation

### Development Reports
- [`docs/DEVELOPMENT_REPORT.md`](docs/DEVELOPMENT_REPORT.md) - Comprehensive development journey
- [`docs/CHANGELOG.md`](docs/CHANGELOG.md) - Version history and changes
- [`docs/VERSION_0.0.1_SUMMARY.md`](docs/VERSION_0.0.1_SUMMARY.md) - Current version details

### Technical Documentation
- Query structure and patterns
- Data model insights
- Development lessons learned
- Future architecture plans

## 🧪 Testing

### Test Infrastructure
- 20+ comprehensive test scripts
- Query functionality verification
- Data decoding validation
- Integration testing

### Running Tests
```bash
./tests/test_final_integration.sh  # Complete test suite
./tests/test_doing_tasks.sh       # DOING tasks specifically
./tests/test_app_decoding.sh      # Decoding verification
```

## 🔧 Technical Details

### Architecture
- **Language**: Swift 6 with strict concurrency
- **Platform**: macOS 13.0+ menu bar application
- **UI Framework**: SwiftUI views in AppKit (NSPopover)
- **Data Source**: Logseq CLI with EDN/JSON conversion

### Key Components
- `DatalogQueryBuilder` - Query construction
- `LogseqCLIClient` - CLI execution and data processing
- `LogseqBlock`/`LogseqTask` - Data models
- `AppDelegate` - Application lifecycle

### Query Structure
```clojure
[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]
```

## 📈 Project Metrics

### Version 0.0.1
- **Files**: 55 files
- **Lines of Code**: 5,401
- **Test Scripts**: 20+
- **Documentation**: 3 comprehensive documents
- **Development Time**: ~9 hours

## 🤝 Contributing

### Getting Started
1. Clone the repository
2. Install prerequisites
3. Build and run
4. Check existing tests
5. Implement new features

### Development Guidelines
- Follow existing code patterns
- Add comprehensive tests
- Document changes in CHANGELOG.md
- Update documentation as needed
- Use semantic versioning

## 📝 License

This project is currently proprietary. License information will be added in future versions.

## 🔗 Contact

For questions or issues, please refer to the documentation or open an issue in the repository.

## 🎉 Achievements

### Version 0.0.1 Milestones
- ✅ Fixed core issue (no task content displayed)
- ✅ Established proper query patterns
- ✅ Created comprehensive testing
- ✅ Documented development process
- ✅ Set up version tracking

### Key Learnings
- Logseq data model insights
- Datalog query patterns
- Swift decoding techniques
- Development process improvements

## 🚀 Next Steps

The foundation is solid! Version 0.0.2 will focus on:
1. Building the actual UI
2. Supporting all task statuses
3. Adding user interaction
4. Implementing error handling

**From here, we build upwards!** 🚀