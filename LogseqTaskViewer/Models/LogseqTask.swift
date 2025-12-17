import Foundation
import SwiftUI

/// App's domain model for a task (converted from LogseqBlock)
struct LogseqTask: Identifiable {
    let id: String                    // block UUID
    let title: String                 // cleaned content
    let status: TaskStatus
    let priority: TaskPriority?
    let scheduledDate: Date?
    let deadlineDate: Date?
    let tags: [String]
    let page: String?                 // parent page name

    enum TaskStatus: String, CaseIterable, Identifiable {
        case todo = "TODO"
        case doing = "DOING"
        case waiting = "WAITING"
        case later = "LATER"
        case done = "DONE"

        var id: String { rawValue }

        var displayName: String { rawValue }

        var icon: String {
            switch self {
            case .todo: return "circle"
            case .doing: return "arrow.clockwise.circle.fill"
            case .waiting: return "clock"
            case .later: return "calendar.badge.clock"
            case .done: return "checkmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .todo: return .blue
            case .doing: return .orange
            case .waiting: return .yellow
            case .later: return .gray
            case .done: return .green
            }
        }
    }

    enum TaskPriority: String, CaseIterable, Identifiable {
        case a = "A"
        case b = "B"
        case c = "C"

        var id: String { rawValue }

        var displayName: String { rawValue }

        var color: Color {
            switch self {
            case .a: return .red
            case .b: return .orange
            case .c: return .yellow
            }
        }

        var sortOrder: Int {
            switch self {
            case .a: return 0
            case .b: return 1
            case .c: return 2
            }
        }
    }
}
