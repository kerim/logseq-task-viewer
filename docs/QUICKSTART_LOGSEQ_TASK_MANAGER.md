# Quick Start: Logseq Task Manager Project

**Last Updated**: 2025-12-15
**Status**: Planning Complete, Ready for Implementation
**Version**: 0.0.0 (not yet created)

## Project Overview

Creating a **native macOS menu bar app** (Swift/SwiftUI) that displays today's tasks from a Logseq DB graph. The app is a task manager that uses Logseq as the backend, avoiding the CSS complexity of browser extensions or Logseq plugins.

## Why This Project?

- **Problem**: The logseq-sidekick browser extension and logseq-today-sidebar plugin both struggle with Logseq's complex CSS
- **Solution**: Native macOS app with full UI control, accessing Logseq data via HTTP API
- **Goal**: Clean, native task manager interface without fighting web/CSS limitations

## Key Decisions Made

### Technology Stack
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **App Type**: Menu bar app (lives in macOS menu bar)
- **Data Source**: logseq-http-server (Python server at localhost:8765)
- **Architecture**: MVVM pattern

### Features (Approved)
- ✅ View today's tasks (scheduled or deadline = today)
- ✅ Display task properties (scheduled, deadline, priority, tags)
- ✅ Filter/group by status (TODO/DOING/WAITING), priority, tags
- ✅ Read-only (no task editing)
- ✅ Auto-refresh every 60 seconds
- ✅ Menu bar icon with dropdown panel

## Project Structure

```
LogseqTaskManager/
├── App/
│   ├── LogseqTaskManagerApp.swift        # App entry point
│   └── AppDelegate.swift                  # Menu bar setup
├── Models/
│   ├── LogseqTask.swift                   # Task data model
│   ├── LogseqBlock.swift                  # Raw block from server
│   ├── TaskFilter.swift                   # Filter/group options
│   └── ServerConfig.swift                 # Server connection config
├── ViewModels/
│   ├── TaskListViewModel.swift            # Main business logic
│   └── SettingsViewModel.swift            # Configuration
├── Views/
│   ├── MenuBarView.swift                  # Popup panel
│   ├── TaskRowView.swift                  # Individual task
│   ├── TaskListView.swift                 # Task list container
│   ├── FilterBar.swift                    # Filter controls
│   └── SettingsView.swift                 # Config window
├── Services/
│   ├── LogseqHTTPClient.swift             # HTTP communication
│   ├── DatalogQueryBuilder.swift          # Query construction
│   └── TaskParser.swift                   # Transform blocks → tasks
└── Resources/
    ├── Assets.xcassets                    # Icons
    └── Info.plist                         # App metadata
```

## Important File Locations

### Planning Documents
- **Full Implementation Plan**: `/Users/niyaro/.claude/plans/spicy-napping-valley.md`
  - Complete architecture, data models, code samples
  - Implementation phases with time estimates
  - Detailed SwiftUI view structures

### Reference Projects
- **HTTP Server**: `/Users/niyaro/Documents/Code/Logseq/logseq-http-server`
  - Python server wrapping @logseq/cli
  - Endpoints: `/health`, `/search`, `/query`, `/list`, `/show`
  - Port: 8765, Host: localhost

- **Logseq Plugin (for query reference)**: `/Users/niyaro/Documents/Code/Logseq UI/logseq today sidebar`
  - Shows how Logseq queries work
  - CSS-heavy approach we're avoiding
  - Reference for task filtering logic

- **Browser Extension (for HTTP client reference)**: `/Users/niyaro/Documents/Code/Logseq/logseq-sidekick`
  - Shows how to communicate with HTTP server
  - TypeScript/JavaScript patterns
  - See: `src/logseq/httpServerClient.ts`

### Where to Create Project
- **Project Location**: `/Users/niyaro/Documents/Code/Logseq/logseq task viewer/LogseqTaskManager.xcodeproj`

## How to Continue

### Starting Next Session

1. **Load context** - Say:
   > "I'm continuing the Logseq Task Manager project. Read /Users/niyaro/Documents/Code/Logseq/logseq task viewer/QUICKSTART_LOGSEQ_TASK_MANAGER.md and /Users/niyaro/.claude/plans/spicy-napping-valley.md to understand the project."

2. **Load relevant skill**:
   > "Load the logseq-db-plugin-api-skill"

3. **Verify HTTP server**:
   > "Check if the HTTP server is running at localhost:8765"

4. **Start implementation** - Choose phase:
   - **Phase 1**: Project setup (create Xcode project)
   - **Phase 2**: Data models and HTTP client
   - **Phase 3**: Task parser
   - ... (see full plan for all 9 phases)

### Quick Test of HTTP Server

```bash
# Check if server is running
curl http://localhost:8765/health

# Expected response:
{"success": true, "status": "healthy", "message": "Logseq HTTP Server is running"}

# Start server if not running
cd /Users/niyaro/Documents/Code/Logseq/logseq-http-server
python3 logseq_server.py
```

### What's Already Done

✅ **Planning Complete**:
- Architecture designed (MVVM, SwiftUI)
- Data models defined (LogseqTask, LogseqBlock, TaskFilter)
- HTTP client structure planned
- All SwiftUI views outlined with code samples
- Datalog query patterns identified
- 9 implementation phases defined

❌ **Not Yet Started**:
- Xcode project creation
- Any actual code implementation
- Testing with real Logseq data

## Implementation Phases (Summary)

| Phase | Task | Time | Priority |
|-------|------|------|----------|
| 1 | Project Setup | 1-2h | Must have |
| 2 | Data Models & HTTP Client | 2-3h | Must have |
| 3 | Task Parser | 1-2h | Must have |
| 4 | Basic UI | 3-4h | Must have |
| 5 | View Model & Data Flow | 2-3h | Must have |
| 6 | Filtering & Grouping | 2-3h | Nice to have |
| 7 | Settings & Configuration | 2-3h | Must have |
| 8 | Polish & Testing | 2-3h | Nice to have |
| 9 | Refinement | Ongoing | Nice to have |

**MVP (Phases 1-5, 7)**: ~15-20 hours
**Full Featured (All phases)**: ~25-30 hours

## Key Technical Details

### HTTP API Usage

The app will use the `/query` endpoint to execute datalog queries:

```bash
POST http://localhost:8765/query
Content-Type: application/json

{
  "graph": "your-graph-name",
  "query": "[:find (pull ?b [:block/uuid :block/content ...]) :where ...]"
}
```

### Datalog Query for Today's Tasks

```clojure
[:find (pull ?b [:db/id
                :block/uuid
                :block/content
                :block/marker
                :block/priority
                :block/properties
                :block/tags
                :block/page
                {:block/page [:block/title :block/name]}
                :logseq.property/scheduled
                :logseq.property/deadline])
 :where
 [?b :block/marker ?marker]
 [(contains? #{"TODO" "DOING" "WAITING" "LATER"} ?marker)]
 (or-join [?b]
   (and [?b :logseq.property/scheduled ?s]
        [(= ?s TODAY_DATE)])
   (and [?b :logseq.property/deadline ?d]
        [(= ?d TODAY_DATE)]))]
```

**Note**: Query syntax will need refinement based on actual server responses.

### Data Flow

```
Logseq DB Graph
    ↓
@logseq/cli (command line tool)
    ↓
logseq-http-server (Python wrapper)
    ↓
HTTP POST /query (JSON)
    ↓
Swift URLSession
    ↓
LogseqHTTPClient.executeQuery()
    ↓
TaskParser.parse()
    ↓
TaskListViewModel (filters/groups)
    ↓
SwiftUI Views (display)
```

## Common Questions

### Q: Why not use the Logseq plugin API directly?
**A**: The plugin approach (logseq-today-sidebar) requires extensive CSS manipulation to fight Logseq's complex styling. A native app gives full UI control without CSS complexity.

### Q: Why Swift instead of Electron or web technologies?
**A**: Native Swift/SwiftUI provides better macOS integration (menu bar, notifications, keyboard shortcuts), better performance, and avoids the CSS issues that motivated this project.

### Q: Can the app edit tasks?
**A**: Not in v1.0. The HTTP server is read-only. Future versions could add write capabilities via direct database access or CLI commands.

### Q: What if the HTTP server isn't running?
**A**: The app will show a connection error and prompt the user to start the server. Future enhancement could auto-start the server.

## Dependencies

### System Requirements
- macOS 13+ (for SwiftUI features)
- Xcode 15+ (for Swift 6.0)
- Python 3.x (for HTTP server)

### External Services
- **logseq-http-server**: Must be running on localhost:8765
- **Logseq DB graph**: Must be configured (not file-based/markdown graph)
- **@logseq/cli**: Installed and accessible to HTTP server

### Swift Packages (None Required)
The app uses only native Swift/macOS frameworks:
- SwiftUI (UI)
- AppKit (menu bar integration)
- Foundation (networking, JSON)

## Next Steps Checklist

When starting next session:

- [ ] Read this quick start document
- [ ] Read the full plan at `/Users/niyaro/.claude/plans/spicy-napping-valley.md`
- [ ] Load logseq-db-plugin-api-skill
- [ ] Verify HTTP server is running (curl localhost:8765/health)
- [ ] Decide which phase to start (recommend Phase 1: Project Setup)
- [ ] Create Xcode project at specified location
- [ ] Follow implementation plan phase by phase

## Useful Commands

```bash
# Start HTTP server
cd /Users/niyaro/Documents/Code/Logseq/logseq-http-server
python3 logseq_server.py

# Test server health
curl http://localhost:8765/health

# List available graphs
curl http://localhost:8765/list

# Build Xcode project (once created)
cd "/Users/niyaro/Documents/Code/Logseq/logseq task viewer"
xcodebuild -scheme LogseqTaskManager -configuration Debug

# Run tests (once created)
xcodebuild test -scheme LogseqTaskManager
```

## Resources

- **Full Plan**: `/Users/niyaro/.claude/plans/spicy-napping-valley.md`
- **HTTP Server Docs**: `/Users/niyaro/Documents/Code/Logseq/logseq-http-server/README.md`
- **Logseq Plugin Skill**: logseq-db-plugin-api-skill (for understanding Logseq DB structure)
- **Apple SwiftUI Docs**: https://developer.apple.com/documentation/swiftui
- **Apple NSStatusBar Docs**: https://developer.apple.com/documentation/appkit/nsstatusbar

## Notes

- Remember to update version number with each build iteration (never reuse version numbers)
- Follow MVVM architecture strictly for testability
- Test with real Logseq data early and often
- Datalog query syntax may need refinement - start simple, iterate
- Keep UI simple and native (macOS Human Interface Guidelines)

---

**Status**: Ready to start Phase 1 (Project Setup)
**Next Action**: Create Xcode project and implement basic structure
