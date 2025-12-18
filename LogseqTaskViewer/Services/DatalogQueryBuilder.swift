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
            :logseq.property/status
            :logseq.property/priority
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

    /// Build query for all tasks with status (more flexible)
    static func allTasksQuery() -> String {
        return """
        [:find (pull ?b [
            :block/uuid
            :block/content
            :block/tags
            :block/properties
            :block/page
            {:block/page [:block/title :block/name]}
            :logseq.property/status
            :logseq.property/priority
            :logseq.property/scheduled
            :logseq.property/deadline
        ]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]]
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
        [:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) ?status-name
        :where
            [?b :block/tags ?t]
            [?t :block/title "Task"]
            [?b :logseq.property/status ?s]
            [?s :block/title ?status-name]
            [(= ?status-name "Doing")]]
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
