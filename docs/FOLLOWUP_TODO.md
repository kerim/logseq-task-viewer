# Logseq Task Viewer - Follow-up TODO

## 🔴 Critical Issues (High Priority)

### 1. Double-Click / Window Focus Issue
**Problem**: First click brings window to front, second click registers. Dropdown menu not launching in front.

**Current Behavior**:
- Click menu bar icon → window comes to front but doesn't register click
- Second click required to actually open dropdown
- Dropdown appears behind other windows

**Root Cause**:
- `NSApp.activate(ignoringOtherApps: true)` may not be sufficient
- Popover presentation timing issue
- Window focus not properly handled

**Solution Approach**:
```swift
// Option 1: Ensure app activation before showing popover
NSApp.activate(ignoringOtherApps: true)
DispatchQueue.main.async {
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
}

// Option 2: Use different activation approach
if let window = NSApp.windows.first {
    window.makeKeyAndOrderFront(nil)
}

// Option 3: Check popover behavior and presentation
popover.behavior = .transient
popover.animates = true
```

**Files to Modify**:
- `LogseqTaskViewer/App/AppDelegate.swift` - `togglePopover()` method

**Testing**:
- Test with different window focus scenarios
- Verify single-click operation
- Check dropdown z-order

---

### 2. Link Resolution in Custom Queries
**Problem**: Links show UUIDs instead of resolved references when using "Doing" query from selector.

**Current Behavior**:
- Built-in DOING query: Links resolve correctly (show page names)
- Custom "Doing" query: Links show UUIDs (e.g., `[[692a5173-3bb9-49fa-85d2-c74ba89ea796]]`)

**Root Cause**:
- Different query structure between built-in and custom queries
- Missing reference resolution step in custom query execution
- Block reference format mismatch

**Debugging Steps**:
1. Compare query structures:
   - Built-in: `DatalogQueryBuilder.doingTasksQuery()`
   - Custom: Sample query from SettingsView

2. Check JSON decoding:
   - Verify `LogseqBlock` decoding handles references correctly
   - Ensure `BlockReference` properties are populated

3. Examine link resolution:
   - `ClickableTextView` should handle both UUID and name formats
   - Check if `task.title` vs `task.content` affects resolution

**Solution Approach**:
```swift
// Option 1: Ensure consistent query structure
static func doingTasksQuery() -> String {
    return """
    [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties 
                     :logseq.property/status :logseq.property/priority 
                     :logseq.property/scheduled :logseq.property/deadline]) ?status-name
    :where
        [?b :block/tags ?t]
        [?t :block/title "Task"]
        [?b :logseq.property/status ?s]
        [?s :block/title ?status-name]
        [(= ?status-name "Doing")]]
    """
}

// Option 2: Enhance reference resolution in ClickableTextView
private func resolveBlockReference(_ text: String) -> String {
    // Convert [[uuid]] to [[page-name]] if possible
    // Use properties or additional queries to resolve
}
```

**Files to Modify**:
- `LogseqTaskViewer/Services/DatalogQueryBuilder.swift` - Query consistency
- `LogseqTaskViewer/Views/TaskListView.swift` - ClickableTextView resolution
- `LogseqTaskViewer/Models/LogseqBlock.swift` - Reference handling

**Testing**:
- Compare raw query results (built-in vs custom)
- Verify block reference decoding
- Test link resolution with different formats

---

## 🟡 Functionality Improvements

### 3. TODO Query Performance Optimization
**Problem**: TODO sample query doesn't work (likely returns too many tasks).

**Current Query**:
```clojure
[:find (pull ?b [...]) 
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "TODO")]]
```

**Improved Query** (TODO + Priority):
```clojure
[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties 
                 :logseq.property/status :logseq.property/priority 
                 :logseq.property/scheduled :logseq.property/deadline]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "TODO")]
   [?b :logseq.property/priority ?p]]  ; Only TODO tasks with priority
```

**Implementation**:
1. Update `DatalogQueryBuilder.todoTasksQuery()`
2. Add parameter for priority filtering
3. Update sample queries in SettingsView

**Files to Modify**:
- `LogseqTaskViewer/Services/DatalogQueryBuilder.swift`
- `LogseqTaskViewer/Views/TaskListView.swift` - SettingsView sample queries

**Testing**:
- Verify query returns reasonable number of tasks
- Test with different priority filters
- Check performance impact

---

### 4. Loading Text Dynamic Update
**Problem**: Loading text still says "Loading DOING..." regardless of query type.

**Current Behavior**:
- Success state: Shows correct dynamic title (e.g., "TODO Tasks")
- Loading state: Always shows "Loading DOING tasks..."

**Root Cause**:
- LoadingView not using `viewModel.currentQueryType`
- Static text instead of dynamic binding

**Solution**:
```swift
// Update LoadingView to use dynamic query type
struct LoadingView: View {
    let viewModel: TaskViewModel  // Add viewModel parameter
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Loading \{viewModel.currentQueryType} tasks...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Fetching data from Logseq...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// Update TaskListView to pass viewModel
if viewModel.isLoading {
    LoadingView(viewModel: viewModel)  // Pass viewModel
}
```

**Files to Modify**:
- `LogseqTaskViewer/Views/TaskListView.swift` - LoadingView and usage

**Testing**:
- Verify loading text updates for different query types
- Check that viewModel binding works correctly

---

## 🟢 Completed Features (Working)

### Working Components
- ✅ Live DOING query with real Logseq data
- ✅ Timestamp to date conversion (milliseconds → YYYYMMDD)
- ✅ Loading, error, and empty states
- ✅ Settings UI with sample queries
- ✅ Custom query editor and execution
- ✅ Dynamic title for success states
- ✅ Basic query management framework

### Tested Scenarios
- ✅ Initial app launch with live data
- ✅ DOING query execution (built-in)
- ✅ Custom query execution
- ✅ Error handling and display
- ✅ Empty state handling
- ✅ Date display for tasks with timestamps

---

## 📋 Implementation Plan

### Phase 1: Critical Fixes (Next Session)
1. **Fix double-click issue** - Window activation and focus
2. **Debug link resolution** - Compare query structures and reference handling
3. **Update TODO query** - Add priority filtering
4. **Fix loading text** - Dynamic query type in LoadingView

### Phase 2: UI/UX Improvements
1. **Compact settings UI** - Dropdown menu instead of full sheet
2. **Query management** - Save, delete, and organize queries
3. **Query history** - Recent queries list
4. **Graph selection** - Choose which Logseq graph to query

### Phase 3: Advanced Features
1. **Query templates** - Predefined query patterns
2. **Query validation** - Syntax checking before execution
3. **Query sharing** - Export/import queries
4. **Performance metrics** - Query execution time tracking

---

## 🧪 Testing Checklist

### Regression Testing
- [ ] Built-in DOING query still works
- [ ] Custom queries execute correctly
- [ ] Date display works for all formats
- [ ] Error handling shows proper messages
- [ ] Empty state handling works

### New Feature Testing
- [ ] Single-click operation (no double-click)
- [ ] Link resolution in custom queries
- [ ] TODO + Priority query performance
- [ ] Dynamic loading text
- [ ] Dropdown menu UI

### Edge Cases
- [ ] No network connection
- [ ] Invalid query syntax
- [ ] Empty query results
- [ ] Very large query results
- [ ] Rapid query switching

---

## 📚 Documentation Updates Needed

1. **Update CHANGELOG.md** - Document known issues and current state
2. **Create USER_GUIDE.md** - User-facing documentation
3. **Update README.md** - Reflect current functionality
4. **Add QUERY_EXAMPLES.md** - Example queries and patterns

---

## 🎯 Success Criteria

### Minimum Viable Product (MVP)
- [x] Show DOING tasks with real data
- [x] Display dates correctly
- [x] Handle loading/error states
- [x] Execute custom queries
- [ ] Single-click operation
- [ ] Consistent link resolution
- [ ] Reasonable query performance

### Polished Product
- [ ] Intuitive UI/UX
- [ ] Query management
- [ ] Graph selection
- [ ] Comprehensive error handling
- [ ] Performance optimization
- [ ] User documentation

---

**Last Updated**: 2025-12-18
**Status**: Active development with known issues documented
**Next Steps**: Address critical issues in next development session