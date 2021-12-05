import Foundation

public struct Reminder: Equatable, Identifiable {
    public let id: UUID
    public var title = ""
    public var notes = ""
    public var isCompleted = false
    public var date: Date? = nil
    
    public init(id: UUID, title: String = "", notes: String = "", isCompleted: Bool = false, date: Date? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.date = date
    }
}
