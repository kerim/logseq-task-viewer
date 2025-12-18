# Changelog

All notable changes to the Logseq Task Viewer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Known Issues (To Be Fixed)
- ⚠️ Double-click issue: First click brings window to front, second click registers
- ⚠️ Link resolution in custom queries: Links show UUIDs instead of resolved references
- ⚠️ TODO query performance: Sample query returns too many tasks
- ⚠️ Loading text: Still says "Loading DOING..." regardless of query type

### Current State
- ✅ Live DOING query working with real data
- ✅ Timestamp conversion working (dates display correctly)
- ✅ Settings UI with sample queries and custom query editor
- ✅ Dynamic title working for success states
- ✅ Loading/error/empty states implemented
- ✅ Query execution framework in place

## [0.0.6] - 2025-12-18

### Added
- ✅ Settings UI for custom datalog queries
- ✅ Sample query selection (DOING, TODO, All Tasks, High Priority)
- ✅ Custom query editor with syntax highlighting
- ✅ Query execution functionality for custom queries
- ✅ Settings access via gear icon in main UI

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