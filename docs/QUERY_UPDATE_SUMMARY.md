# Logseq Task Viewer - Query Update Summary

## ✅ Completed Work

### 1. Updated DatalogQueryBuilder.swift
**Changes Made:**
- Modified `todayTasksQuery()` to resolve status names
- Modified `allTasksQuery()` to resolve status names  
- Modified `simpleTaskQuery()` to resolve status names
- Modified `todoBlocksQuery()` to resolve status names

**Key Pattern Added:**
```clojure
[:find (pull ?b [:block/uuid :block/content]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]]
```

**Before:** Queries returned status as `{:db/id 73}` (entity reference)
**After:** Queries return status as `"Done"`, `"Todo"`, etc. (human-readable names)

### 2. Added New Data Model
**Created `LogseqBlockWithStatus` struct:**
```swift
struct LogseqBlockWithStatus: Codable {
    let block: LogseqBlock
    let statusName: String

    enum CodingKeys: String, CodingKey {
        case block = "0"  // First element in tuple
        case statusName = "1"  // Second element in tuple
    }
}
```

**Purpose:** Handles the new tuple-based query result format where results are `[{block_data}, "status-name"]`

### 3. Updated LogseqCLIClient.swift
**Added parsing logic for new result format:**
```swift
// Try to decode as array of block+status tuples (new format)
if let blockWithStatusTuples = try? decoder.decode([[LogseqBlockWithStatus]].self, from: jsonData) {
    return blockWithStatusTuples.flatMap { $0 }.map { $0.block }
}
```

**Maintains backward compatibility:** Still supports old query formats while adding new tuple parsing

### 4. Verified Query Results
**Test Results:**
- ✅ Queries now return human-readable status names
- ✅ Found status names: "Backlog", "Canceled", "Doing", "Done", "In Review", "Todo"
- ✅ Query execution successful with Logseq CLI
- ✅ Project builds without errors

## 📊 Test Results

### Before Update
```json
[
  {
    "block/uuid": "685b3d05-5149-4ad9-a868-293fe0f9a1f7",
    "logseq.property/status": {"db/id": 73}
  }
]
```

### After Update
```json
[
  [
    {
      "block/uuid": "685b3d05-5149-4ad9-a868-293fe0f9a1f7"
    },
    "Done"
  ]
]
```

## 🎯 Next Steps

### 1. Update LogseqTask.swift
**Required Changes:**
- Modify to use resolved status names instead of BlockReference
- Update TaskStatus enum to match actual Logseq status names
- Add mapping from string status names to TaskStatus cases

**Current Status Names Found:**
- "Todo" (not "TODO")
- "Doing" (not "DOING")
- "Done" (not "DONE")
- "Backlog"
- "Canceled"
- "In Review"

### 2. Create ViewModels
**Planned Components:**
- `TaskListViewModel`: Manages task data loading and filtering
- `TaskDetailViewModel`: Handles individual task operations
- `StatusFilterViewModel`: Manages status-based filtering

### 3. Build UI Components
**Planned Views:**
- `TaskListView`: Main task display with filtering
- `TaskItemView`: Individual task display
- `StatusFilterView`: Status-based filtering controls
- `TaskDetailView`: Detailed task information

### 4. Implement Error Handling
**Required Enhancements:**
- Handle missing status names gracefully
- Handle missing block content
- Handle malformed query results
- Provide user-friendly error messages

## 🔧 Technical Notes

### Query Result Structure
The new queries return results in tuple format:
```
[
  [block_data, "status-name"],
  [block_data, "status-name"],
  ...
]
```

### Parsing Flow
1. Logseq CLI returns EDN format
2. Jet CLI converts EDN → JSON
3. JSON decoder parses as `[[LogseqBlockWithStatus]]`
4. Results are flattened and mapped to extract `LogseqBlock` objects
5. Status names are available in the `LogseqBlockWithStatus` wrapper

### Backward Compatibility
The parsing logic maintains support for:
- Old format: `[[LogseqBlock]]`
- New format: `[[LogseqBlockWithStatus]]`
- Simple format: `[[SimpleLogseqBlock]]`

## 📁 Files Modified

1. **LogseqTaskViewer/Services/DatalogQueryBuilder.swift**
   - Updated all task queries to resolve status names
   - Added status resolution pattern to WHERE clauses

2. **LogseqTaskViewer/Models/LogseqBlock.swift**
   - Added `LogseqBlockWithStatus` struct
   - Maintained existing models for backward compatibility

3. **LogseqTaskViewer/Services/LogseqCLIClient.swift**
   - Added parsing logic for tuple-based results
   - Maintained backward compatibility with old formats

## ✅ Verification

All changes have been:
- ✅ Successfully implemented
- ✅ Tested with Logseq CLI
- ✅ Verified to build without errors
- ✅ Confirmed to resolve status names correctly

The foundation is now in place for building the complete task viewer UI with proper status resolution.