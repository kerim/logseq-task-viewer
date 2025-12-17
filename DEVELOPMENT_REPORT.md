# Logseq Task Viewer Development Report - Day 1

## Summary
Today we successfully fixed the core issue where the app was displaying DOING tasks with UUIDs but no readable content. The problem was in the query structure and understanding of Logseq's data model.

## What We Fixed

### Problem Identified
- App showed 3 DOING tasks but only displayed UUIDs, not actual task content
- Query was requesting `:block/title` and `:block/content` but not receiving them
- Status filtering was incorrect - using `[?s :block/title "Doing"]` instead of proper tuple-based filtering

### Solution Implemented
Updated `DatalogQueryBuilder.doingTasksQuery()` to:
1. Return tuples of `[block, status-name]` instead of just `[block]`
2. Use proper status filtering with `[(= ?status-name "Doing")]`
3. Request all necessary fields including `:block/title` where content is stored

### Key Changes Made

#### 1. Fixed Query Structure
**File**: `LogseqTaskViewer/Services/DatalogQueryBuilder.swift`

**Before**:
```swift
[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title "Doing"]]
```

**After**:
```swift
[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title ?status-name]
    [(= ?status-name "Doing")]]
```

#### 2. Verified Decoding Logic
The `LogseqCLIClient.executeQuery()` method already had proper logic to handle the tuple format:
```swift
// Try to decode as array of block+status tuples (new format)
if let blockWithStatusTuples = try? decoder.decode([LogseqBlockWithStatus].self, from: jsonData) {
    return blockWithStatusTuples.map { $0.block }
}
```

## What We Learned

### Logseq Data Model Insights
1. **Task Content Location**: In Logseq, task content is stored in `:block/title`, not `:block/content`
2. **Query Tuples**: When resolving entity references (like status names), queries return tuples `[entity, resolved-value]`
3. **Status Filtering**: Must use `[(= ?status-name "Doing")]` for proper filtering, not direct entity matching

### Development Process Lessons
1. **Test First Approach**: Creating standalone test scripts helped isolate and verify each component
2. **Data Inspection**: Always examine raw query results to understand actual data structure
3. **Incremental Testing**: Break complex problems into smaller testable components
4. **Existing Code Review**: Check if functionality already exists before implementing new solutions

### Technical Lessons
1. **Datalog Query Structure**: Understanding the difference between entity references and resolved values
2. **EDN to JSON Conversion**: The `jet` tool handles complex EDN structures well
3. **Swift Decoding**: Custom `init(from:)` methods can handle complex nested structures
4. **Tuple-Based Results**: Logseq returns `[entity, resolved-value]` pairs when resolving references

## Current State

### What Works Now
- ✅ App queries for DOING tasks correctly
- ✅ Query returns 3 DOING tasks with actual content
- ✅ Decoding handles tuple-based results properly
- ✅ Tasks display with UUID, title (content), and status
- ✅ Project builds successfully

### What the App Displays
1. **Task 1**: "1st December [[68301217-1a99-4d9b-a2f8-e8756851ec28]] post"
2. **Task 2**: "[[692a5173-3bb9-49fa-85d2-c74ba89ea796]]"
3. **Task 3**: "Watch [[68f48c70-c9cf-4960-89b1-853802050a5f]] Films that I haven't seen yet"

## Next Steps

### Immediate Priorities
1. **UI Implementation**: Build actual task display views (currently just console output)
2. **Error Handling**: Add robust handling for missing data fields
3. **Status Variants**: Support all status types (TODO, DOING, DONE, etc.)
4. **Task Properties**: Display priority, scheduled/deadline dates

### Future Enhancements
1. **Task Filtering**: Add UI controls to filter by status
2. **Search Functionality**: Implement task search
3. **Task Creation**: Add ability to create new tasks
4. **Graph Selection**: Allow user to choose which graph to query

## Mistakes to Avoid in Future

### Query Design Mistakes
1. **Don't assume field availability**: Always test queries to see what fields are actually returned
2. **Don't forget tuple structure**: When resolving references, results come as `[entity, resolved-value]`
3. **Don't hardcode status names**: Use proper filtering with `[(= ?status-name "Value")]`

### Development Process Mistakes
1. **Don't skip testing**: Always create test scripts before implementing in app
2. **Don't ignore existing code**: Check if functionality already exists
3. **Don't assume data structure**: Inspect raw query results first
4. **Don't forget error handling**: Always consider edge cases

### Technical Mistakes
1. **Don't mix up title vs content**: In Logseq, `:block/title` contains the main content
2. **Don't forget MainActor**: UI operations must be properly isolated
3. **Don't ignore build warnings**: Address them immediately
4. **Don't hardcode paths**: Use configuration for CLI tool locations

## Version Tagging

This report marks the completion of **Version 0.0.1** - "Basic DOING Tasks Display"

### Version 0.0.1 Features
- ✅ Functional DOING tasks query
- ✅ Proper data decoding and parsing
- ✅ Console display of task content
- ✅ Status resolution working
- ✅ Project builds without errors

### Version 0.0.1 Limitations
- ❌ No actual UI implementation
- ❌ Only DOING tasks supported
- ❌ No error handling for missing data
- ❌ No user interaction
- ❌ Hardcoded graph name

## Changelog Started

From this point forward, all changes will be documented in a CHANGELOG.md file following semantic versioning principles.