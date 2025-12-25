# Changelog

All notable changes to the Logseq Task Viewer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Known Issues
- Link resolution in custom queries (workaround: use block references)
- Loading text always shows "DOING" (cosmetic issue)

## [1.0.0] - 2025-12-25

### First Public Release 🎉

**Repository:** https://github.com/kerim/logseq-task-viewer

This is the first public release of Logseq Task Viewer - a macOS menu bar application for viewing and managing tasks from Logseq DB graphs.

### Features
- ✅ **Menu Bar Integration** - Quick access from macOS menu bar
- ✅ **Query Manager** - Saved queries with double-click execution and live editing
- ✅ **Graph Selection UI** - Dropdown to select which Logseq database to query
- ✅ **Default Queries** - DOING, TODO, High Priority (regenerate automatically)
- ✅ **Custom Queries** - Create and save your own Datalog queries
- ✅ **Priority Display** - Color-coded icons for Urgent, High, Medium, Low priorities
- ✅ **Timestamp Conversion** - Logseq timestamps shown as readable dates
- ✅ **Loading/Error States** - Proper UI feedback during operations
- ✅ **Query Persistence** - User-created queries persist across launches
- ✅ **Reset to Defaults** - Safety mechanism to restore default queries
- ✅ **Window Focus** - Query Manager window floats on top for easy access

### Requirements
- macOS 13.0+
- Logseq CLI (`brew install logseq`)
- Jet CLI (`brew install jet`)
- Logseq DB graph (not file-based)

### Installation
- Download pre-built app from GitHub Releases
- Or build from source using Xcode 15+

### License
- MIT License

## [0.0.12] - 2025-12-24

### Added
- ✅ **Graph Selection UI** in Query Manager
- ✅ Dropdown to select which Logseq database to query
- ✅ Auto-discovery of available graphs using CLI
- ✅ Selected graph persists in UserDefaults
- ✅ Graph changes update app immediately via NotificationCenter

### Fixed
- 🐛 **CRITICAL**: Fixed High Priority query for DB graphs
- 🐛 Changed from "A" (Markdown priority) to "High" and "Urgent" (DB graph priorities)
- 🐛 Query now correctly filters High and Urgent priority tasks

### Changed
- 🔧 Graph name no longer hardcoded in AppDelegate
- 🔧 Graph selection available in Query Manager header
- 🔧 App shows alert if no graph selected on first launch
- 🔧 ViewModel client made accessible for graph discovery

### Technical Details
- **Graph Selection Pattern**: Based on logseq-sidekick and raycast-logseq-search
- **Storage**: UserDefaults with key "selectedGraph"
- **Discovery**: LogseqCLIClient.listGraphs() via `logseq list` command
- **UI Location**: Query Manager header (above saved queries list)
- **Notification**: GraphChanged notification triggers ViewModel reinitialization
- **Priority Query**: Uses `or` clause to match both "High" and "Urgent" priority values
- **Files Modified**:
  - DatalogQueryBuilder.swift: Updated highPriorityTasksQuery()
  - QueryManagerView.swift: Added graph selector dropdown
  - AppDelegate.swift: Read selected graph from UserDefaults, added NotificationCenter listener
  - TaskViewModel.swift: Made client accessible

### Breaking Changes
- Graph must be selected on first launch (alert shown if none selected)
- High Priority query now returns different results (High + Urgent instead of "A")

### Developer Benefits
- ✅ No more hardcoded graph names
- ✅ Switch between graphs without editing code
- ✅ Graph selection persists across launches
- ✅ Priority query works with DB graphs

## [0.0.11] - 2025-12-24

### Fixed
- 🐛 **CRITICAL**: Fixed query caching breaking development workflow
- 🐛 Default queries now update automatically when code changes
- 🐛 Removed temporary UserDefaults clear that ran on every launch

### Added
- ✅ `isDefault` flag to distinguish app-provided queries from user-created queries
- ✅ Automatic default query regeneration on each app launch
- ✅ Reset button (counterclockwise arrow) in Query Manager to restore defaults
- ✅ Confirmation dialog for reset operation
- ✅ One-time migration system for existing users (`queriesMigratedToV2`)

### Changed
- 🔧 Default queries now regenerate from code on every launch (always up-to-date)
- 🔧 User-created queries persist across launches (not deleted with defaults)
- 🔧 Query Manager version updated to v0.0.3

### Technical Details
- **Root Problem**: UserDefaults caching old queries broke testing workflow - code changes didn't apply
- **Solution**: Added `isDefault: Bool` field to SavedQuery model
- **Load Pattern**:
  1. Load saved queries from UserDefaults
  2. Remove all queries with `isDefault: true` (old defaults)
  3. Generate fresh defaults from code (always current)
  4. Preserve user queries (isDefault: false)
  5. Save combined list
- **Migration**: One-time migration clears old data using `queriesMigratedToV2` flag
- **Safety Net**: Reset button allows users to recover if custom queries break the app
- **Files Modified**:
  - SavedQuery.swift: Added isDefault field
  - QueryStorageService.swift: Regenerate defaults, migration, reset functionality
  - AppDelegate.swift: Removed temp UserDefaults clear, added migration call
  - QueryManagerView.swift: Added reset button with confirmation dialog

### Breaking Changes
- Existing saved queries will be cleared on first launch after update (one-time migration)
- Users will need to recreate any custom queries they had saved

### Developer Benefits
- ✅ Code changes to default queries apply immediately
- ✅ No manual UserDefaults clearing during development
- ✅ Testing workflow no longer broken by cached queries
- ✅ Separation between defaults and user queries

## [0.0.10] - 2025-12-24

### Removed
- 🗑️ Removed "All Tasks" query from default queries (still hung even with status filtering)

### Changed
- 🔧 Default queries now: DOING Tasks, TODO Tasks, High Priority
- 🔧 App defaults to DOING Tasks on startup (already existing behavior)

### Technical Details
- Simplified default query set for testing
- "All Tasks" still had performance issues even with Done/Cancelled filtering
- May add back later with more aggressive filtering or pagination

## [0.0.9] - 2025-12-24

### Fixed
- 🐛 **CRITICAL**: Fixed All Tasks query by filtering out Done/Cancelled tasks
- 🐛 Reverted invalid `:limit` clause (Datalog doesn't support this syntax)
- 🐛 Query now excludes completed tasks, dramatically reducing result set

### Changed
- 🔧 Updated Query Manager version to v0.0.3
- 🔧 Renamed "All Tasks" to focus on ACTIVE tasks (excludes Done/Cancelled)
- 🔧 Added valid Datalog filters: `[(not= ?status-name "Done")]` and `[(not= ?status-name "Cancelled")]`

### Technical Details
- **Root Cause Identified**: "All Tasks" was fetching ALL statuses including Done/Cancelled (hundreds/thousands)
- **Why v0.0.8 Failed**: Datalog (Datascript) does NOT support `:limit` inside queries - invalid syntax
- **Lesson Learned**: ALWAYS test Datalog queries in CLI before incorporating in code
- **Correct Approach**: Filter at query level using valid Datalog predicates
- **Query Pattern**: DOING works because it filters to one status - All Tasks needed similar filtering
- **Result**: Now fetches only active tasks (Todo, Doing, Waiting, etc.) not completed ones

### Breaking Changes
- "All Tasks" query now excludes Done/Cancelled tasks (renamed to "Active Tasks" conceptually)

## [0.0.8] - 2025-12-24 [REVERTED - Invalid Datalog syntax]

### Attempted Fix (Did Not Work)
- ❌ Tried to add `:limit 51` to Datalog query
- ❌ Datalog/Datascript does NOT support `:limit` clause in query syntax
- ❌ This was invalid syntax and would cause query errors

### Lesson Learned
- Must test Datalog queries in CLI before incorporating into code
- Datalog limits must be applied in application layer, not query layer

## [0.0.7] - 2025-12-24

### Fixed
- 🐛 **CRITICAL**: Fixed All Tasks query hanging by limiting results BEFORE block reference resolution
- 🐛 Fixed double-click functionality in Query Manager (broken by concurrent execution issue)
- 🐛 Fixed Query Manager window not coming to front when opened
- 🐛 Performance: Block reference resolution now only processes displayed results (max 50) instead of all results

### Added
- ✅ Version number (v0.0.1) displayed in Query Manager window footer
- ✅ Query Manager window now floats on top of other windows
- ✅ "More results" notice when result count exceeds 50 tasks
- ✅ Debug logging for result limiting

### Changed
- 🔧 Result limiting now happens before expensive block reference resolution
- 🔧 Query Manager window level set to `.floating` for better visibility
- 🔧 Query Manager collection behavior set to join all spaces

### Technical Details
- **Performance Fix**: Changed order of operations in `executeCustomQuery()`:
  1. Execute query → Get all results
  2. **Limit to 50 results** (new step)
  3. Resolve block references (only for 50 results, not hundreds)
  4. Display tasks
- **Window Behavior**: Query Manager now uses `.floating` level and `.canJoinAllSpaces` behavior
- **User Experience**: Orange notice displays when more than 50 results available
- **Version Tracking**: Query Manager component version displayed for debugging

### Breaking Changes
- None - performance improvements and bug fixes only

## [0.0.6] - 2025-12-18

### Added
- ✅ Settings UI for custom datalog queries
- ✅ Sample query selection (DOING, TODO, All Tasks, High Priority, Comprehensive TODO)
- ✅ Custom query editor with syntax highlighting
- ✅ Query execution functionality for custom queries
- ✅ Settings access via gear icon in main UI
- ✅ Comprehensive TODO query supporting class-based task inheritance

### Changed
- 🔧 Extended TaskViewModel with custom query execution methods
- 🔧 Added query methods to DatalogQueryBuilder (todoTasksQuery, highPriorityTasksQuery)
- 🔧 Enhanced main UI with settings button and sheet presentation

### Fixed
- 🐛 Added missing query methods for comprehensive query support
- 🐛 Improved UI navigation with settings integration
- 🐛 Enhanced user experience with query management

### Technical Details
- **Settings UI**: Modal sheet with sample queries and custom query editor
- **Query Execution**: Async execution of custom datalog queries
- **Sample Queries**: Predefined queries for common task filtering scenarios
- **User Experience**: Intuitive interface for query management and execution
- **Comprehensive TODO Query**: Advanced query supporting both direct task tags and class-based task inheritance using `or-join`

### Known Limitations
- ⚠️ Still using hardcoded graph name in configuration
- ⚠️ No query saving/persistence yet
- ⚠️ No query history or favorites

### Breaking Changes
- None - enhancement to existing functionality

### Migration Guide
- No migration needed - existing functionality enhanced with query management

### Deprecations
- None in this version

## [0.0.5] - 2025-12-18

### Fixed
- 🐛 Fixed timestamp detection logic to properly handle large timestamp values
- 🐛 Dates now display correctly instead of showing Jan 1, 1970
- 🐛 Improved timestamp vs YYYYMMDD format detection using magnitude check

### Technical Details
- **Timestamp Detection**: Values > 99991231 are treated as timestamps (milliseconds)
- **Format Conversion**: Timestamps are properly converted to YYYYMMDD format
- **Backward Compatibility**: Still supports existing YYYYMMDD format
- **User Experience**: Dates now show correct values like "Dec 18, 2025" instead of "Jan 1, 1970"

## [0.0.4] - 2025-12-18

### Added
- ✅ Timestamp to date conversion for EDN data compatibility
- ✅ Custom JSON decoder for LogseqBlock to handle multiple date formats
- ✅ Comprehensive date parsing that handles both YYYYMMDD and timestamp formats

### Changed
- 🔧 Updated LogseqBlock model with custom decoder for timestamp conversion
- 🔧 Enhanced date formatting to handle milliseconds-since-epoch timestamps
- 🔧 Improved data compatibility with Logseq EDN export format

### Fixed
- 🐛 Date parsing now correctly handles timestamp format (1772130600000) from EDN data
- 🐛 Scheduled and deadline dates now display properly for live query results
- 🐛 Maintained backward compatibility with existing YYYYMMDD format
- 🐛 Dates are now converted from timestamps to readable format (e.g., "Dec 18, 2025")

### Technical Details
- **Date Conversion**: Timestamps (milliseconds since epoch) are converted to YYYYMMDD integers
- **Format Support**: Handles both timestamp format (1772130600000) and YYYYMMDD format (20251218)
- **User Experience**: Dates now display in user-friendly format like "Dec 18, 2025"
- **Data Compatibility**: Works with Logseq's EDN export format from SQLite database

### Known Limitations
- ⚠️ Still using hardcoded graph name in configuration
- ⚠️ No retry mechanism for failed queries yet
- ⚠️ Query is fixed to DOING tasks only

### Breaking Changes
- None - enhancement to existing functionality

### Migration Guide
- No migration needed - existing functionality enhanced with proper date handling

### Deprecations
- None in this version

## [0.0.3] - 2025-12-18

### Added
- ✅ Live DOING query functionality with real Logseq data
- ✅ Loading state with progress indicator
- ✅ Error handling with user-friendly error messages
- ✅ State management for all UI scenarios

### Changed
- 🔧 Replaced cached test data with live query results
- 🔧 Enhanced TaskListView to handle loading, error, empty, and success states
- 🔧 Improved user experience with visual feedback during data loading

### Fixed
- 🐛 App now shows real data from Logseq instead of cached test data
- 🐛 Added proper error handling for query failures
- 🐛 Improved state management for better user experience

### Technical Details
- **Live Data**: App now queries Logseq in real-time
- **State Management**: Comprehensive handling of loading, error, empty, and success states
- **User Experience**: Visual feedback during data loading with progress indicators
- **Error Handling**: User-friendly error messages with retry capability

### Known Limitations
- ⚠️ Still using hardcoded graph name in configuration
- ⚠️ No retry mechanism for failed queries yet
- ⚠️ Query is fixed to DOING tasks only

### Breaking Changes
- None - enhancement to existing functionality

### Migration Guide
- No migration needed - existing functionality enhanced with live data

### Deprecations
- None in this version

## [0.0.2] - 2025-12-18

### Added
- ✅ Complete UI implementation with interactive task display
- ✅ Link-specific hover effects for better user experience
- ✅ Clean, professional visual design without debug clutter
- ✅ Single-click functionality (no more double-click required)

### Changed
- 🔧 Fixed hover effects to apply only to links, not entire task boxes
- 🔧 Removed visual clutter from debug borders and backgrounds
- 🔧 Cleaned up all debug logging and print statements
- 🔧 Improved code organization and readability

### Fixed
- 🐛 Double-click issue resolved with proper window activation
- 🐛 Visual clutter from debug elements removed
- 🐛 Hover effects now properly target individual links
- 🐛 All debug logging cleaned up for production readiness
- 🐛 Added refined task-level hover effect while maintaining link-specific hover

### Technical Details
- **UI Improvements**: Link-specific hover with blue background highlight + subtle task-level hover
- **User Experience**: Single-click operation with proper window focus
- **Code Quality**: Removed 110 lines of debug code, added 32 lines of production code
- **Testing**: Verified build success and app launch without errors

### Known Limitations
- ⚠️ Still using cached test data for UI development
- ⚠️ Real data loading commented out for stability during UI work
- ⚠️ Graph name hardcoded in configuration

### Breaking Changes
- None - all changes are improvements to existing functionality

### Migration Guide
- No migration needed - existing functionality enhanced

### Deprecations
- None in this version

## [0.0.1] - 2025-12-17

### Added
- ✅ Basic DOING tasks query functionality
- ✅ Proper data decoding for tuple-based Logseq query results
- ✅ Console display of task UUIDs and content
- ✅ Status resolution for task statuses
- ✅ Comprehensive test suite for query functionality
- ✅ Development report documenting lessons learned
- ✅ Changelog system for tracking future changes

### Changed
- 🔧 Fixed `DatalogQueryBuilder.doingTasksQuery()` to properly return task content
- 🔧 Updated query structure to use tuple-based results `[block, status-name]`
- 🔧 Improved status filtering using `[(= ?status-name "Doing")]` syntax
- 🔧 Verified existing decoding logic handles new query format

### Fixed
- 🐛 App now displays actual task content instead of just UUIDs
- 🐛 Query properly resolves status names to human-readable format
- 🐛 Task content correctly extracted from `:block/title` field
- 🐛 Status filtering works correctly for DOING tasks

### Technical Details
- **Query Structure**: Changed from single entity to tuple-based results
- **Data Model**: Task content stored in `:block/title`, not `:block/content`
- **Decoding**: Uses `LogseqBlockWithStatus` model for tuple parsing
- **Testing**: Comprehensive test scripts verify all functionality

### Known Limitations
- ⚠️ No actual UI implementation (console output only)
- ⚠️ Only DOING tasks supported (other statuses not implemented)
- ⚠️ No error handling for missing data fields
- ⚠️ No user interaction capabilities
- ⚠️ Hardcoded graph name in configuration

### Breaking Changes
- None in this initial version

### Migration Guide
- No migration needed for initial version

### Deprecations
- None in this version

## Development Notes

### Version 0.0.1 Achievements
- Successfully resolved the core issue of displaying task content
- Established proper query patterns for Logseq data resolution
- Created comprehensive testing infrastructure
- Documented development process and lessons learned

### Next Version Goals (0.0.2)
- Implement actual UI for task display
- Add support for all task statuses (TODO, DOING, DONE, etc.)
- Improve error handling and edge cases
- Add basic user interaction capabilities
- Implement graph selection functionality

## Test Results

### Query Functionality
- ✅ DOING tasks query returns 3 tasks with content
- ✅ Status resolution works correctly
- ✅ Data decoding handles tuple format properly
- ✅ Project builds without errors

### Sample Output
```
Task 1: "1st December [[68301217-1a99-4d9b-a2f8-e8756851ec28]] post"
Task 2: "[[692a5173-3bb9-49fa-85d2-c74ba89ea796]]"
Task 3: "Watch [[68f48c70-c9cf-4960-89b1-853802050a5f]] Films that I haven't seen yet"
```

## Contributing

This changelog follows semantic versioning principles. When making changes:

1. **Added**: New features
2. **Changed**: Changes in existing functionality
3. **Deprecated**: Soon-to-be removed features
4. **Removed**: Removed features
5. **Fixed**: Bug fixes
6. **Security**: Vulnerability fixes

## Version History

- 0.0.1: Initial functional version with DOING tasks display
- Future versions will be documented as development progresses