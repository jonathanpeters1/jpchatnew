import Foundation

struct Message: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var attachments: [Attachment]?
    var metadata: MessageMetadata?
    
    init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date(),
        attachments: [Attachment]? = nil,
        metadata: MessageMetadata? = nil
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.attachments = attachments
        self.metadata = metadata
    }
}

struct Attachment: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let type: AttachmentType
    let url: String
    let name: String?
    let size: Int?
    
    enum AttachmentType: String, Codable, Sendable {
        case image
        case audio
        case video
        case file
    }
    
    init(
        id: UUID = UUID(),
        type: AttachmentType,
        url: String,
        name: String? = nil,
        size: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.name = name
        self.size = size
    }
}

struct MessageMetadata: Codable, Equatable, Sendable {
    let readAt: Date?
    let deliveredAt: Date?
    let editedAt: Date?
    let replyToMessageId: UUID?
    
    init(
        readAt: Date? = nil,
        deliveredAt: Date? = nil,
        editedAt: Date? = nil,
        replyToMessageId: UUID? = nil
    ) {
        self.readAt = readAt
        self.deliveredAt = deliveredAt
        self.editedAt = editedAt
        self.replyToMessageId = replyToMessageId
    }
}
