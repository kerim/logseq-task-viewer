# Query Update Summary

## Comprehensive TODO Query Implementation

### What Was Added

1. **New Query Method**: Added `comprehensiveTodoTasksQuery()` to `DatalogQueryBuilder.swift`
   - Location: `LogseqTaskViewer/Services/DatalogQueryBuilder.swift`
   - Function: Finds TODO tasks with priority, supporting both traditional `#Task` tags and class-based task systems

2. **Sample Query Integration**: Added "Comprehensive TODO" to the sample queries in SettingsView
   - Location: `LogseqTaskViewer/Views/TaskListView.swift`
   - Users can now select this query from the sample queries list

3. **Documentation Updates**: Updated CHANGELOG.md to reflect the new query
   - Added to sample query list in version 0.0.6
   - Documented technical details about the comprehensive query

### Query Details

The comprehensive TODO query uses an `or-join` to handle two different ways tasks can be identified:

```clojure
[:find (pull ?b [
    :block/uuid
    :block/title
    :block/content
    :block/tags
    :block/properties
    :logseq.property/status
    :logseq.property/priority
    :logseq.property/scheduled
    :logseq.property/deadline
])
:where
    (or-join [?b]
        (and [?b :block/tags ?t]
            [?t :block/title "Task"])
        (and [?b :block/tags ?child]
            [?child :logseq.property.class/extends ?parent]
            [?parent :block/title "Task"]))
    [?b :logseq.property/status ?s]
    [?s :block/title "Todo"]
    [?b :logseq.property/priority ?p]]
```

### Key Features

- **Dual Task Identification**: Finds tasks that are either:
  - Directly tagged with `#Task`
  - Have tags that extend a "Task" class (class-based inheritance)
- **Status Filtering**: Only returns tasks with "Todo" status
- **Priority Support**: Requires tasks to have a priority property
- **Comprehensive Data**: Returns full task data including UUID, title, content, tags, properties, and timestamps

### Testing Results

✅ **Query Validation**: Successfully tested with Logseq CLI
✅ **Build Success**: App builds without errors with the new query
✅ **Integration**: Query appears in SettingsView sample queries
✅ **Functionality**: Returns expected TODO tasks with priority data

### Usage

Users can access this query in two ways:

1. **From Settings**: Click the gear icon → Select "Comprehensive TODO" from sample queries
2. **Direct Execution**: The query is available as `DatalogQueryBuilder.comprehensiveTodoTasksQuery()`

### Benefits

- **Backward Compatibility**: Works with traditional `#Task` tagging systems
- **Future-Proof**: Supports modern class-based task systems
- **Performance**: Efficiently filters for only relevant task data
- **User Choice**: Provides an alternative to the standard TODO query

This implementation addresses the need for a more sophisticated task query that can handle both traditional and modern Logseq task management approaches.