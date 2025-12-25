import Foundation

class DatalogQueryBuilder {
    /// Build query for today's tasks (scheduled or deadline = today)
    static func todayTasksQuery() -> String {
        let today = formatDateForQuery(Date())

        return """
        [:find (pull ?b [
            :block/uuid
            :block/content
            :block/tags
            :block/properties
            :block/page
            {:block/page [:block/title :block/name]}
            {:logseq.property/status [:block/title]}
            {:logseq.property/priority [:block/title :block/name]}
            :logseq.property/scheduled
            :logseq.property/deadline
        ]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            (or
                [?b :logseq.property/scheduled \(today)]
                [?b :logseq.property/deadline \(today)]
            )]
        """
    }

    /// Build query for active tasks (non-Done/Cancelled) - more focused than "all"
    static func allTasksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(not= ?status-name "Done")]
            [(not= ?status-name "Cancelled")]]
        """
    }

    /// Query for tasks with any status (to see what statuses exist)
    static func tasksWithStatusQuery() -> String {
        return """
        [:find ?b ?status
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status]]
        """
    }

    /// Simple test query to get any blocks with Task tag (for debugging)
    static func simpleTaskQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/content])
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]]
        """
    }

    /// Very broad query to test if graph has any blocks at all
    static func anyBlocksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/content])
        :where [?b :block/uuid]]
        """
    }

    /// Test query to find blocks with TODO status (should find tasks)
    static func todoBlocksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/content :block/tags]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "TODO")]]
        """
    }

    /// Query for tasks with "doing" status only
    static func doingTasksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "Doing")]]
        """
    }

    /// Query for tasks with "Todo" status only (note: capital T, not TODO)
    static func todoTasksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "Todo")]]
        """
    }

    /// Query for TODO tasks with priority only (for performance)
    static func todoTasksWithPriorityQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "Todo")]
            [?b :logseq.property/priority ?p]]
        """
    }

    /// Query to check if there are any TODO tasks (for performance checking)
    static func todoTasksCountQuery() -> String {
        return """
        [:find (count ?b)
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title "TODO"]]
        """
    }

    /// Query for all TODO tasks (fallback when priority query returns empty)
    static func allTodoTasksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "TODO")]]
        """
    }

    /// Query for high priority tasks (High and Urgent priorities for DB graphs, excluding Done/Cancelled)
    static func highPriorityTasksQuery() -> String {
        return """
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties {:logseq.property/status [:block/title]} {:logseq.property/priority [:block/title :block/name]} :logseq.property/scheduled :logseq.property/deadline])
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(not= ?status-name "Done")]
            [(not= ?status-name "Cancelled")]
            [?b :logseq.property/priority ?p]
            (or-join [?b ?p]
                (and [?p :block/title "High"])
                (and [?p :block/title "Urgent"]))]
        """
    }

    /// Comprehensive TODO query that handles both direct task tags and class-based task inheritance
    /// This query finds TODO tasks with priority, supporting both traditional #Task tags and
    /// class-based task systems where blocks extend a "Task" class
    static func comprehensiveTodoTasksQuery() -> String {
        return """
        [:find (pull ?b [
            :block/uuid
            :block/title
            :block/content
            :block/tags
            :block/properties
            {:logseq.property/status [:block/title]}
            {:logseq.property/priority [:block/title :block/name]}
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
        """
    }

    /// Format date for Logseq queries (YYYYMMDD integer)
    private static func formatDateForQuery(_ date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: date)
        return Int(dateString) ?? 0
    }
}
