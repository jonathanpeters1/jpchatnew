import Foundation

public enum DJChannel: String, CaseIterable, Codable, Sendable, Identifiable {
    case deep, house, techno, melodic, funky, jackin
    case tech, afro, soulful, indie, classics, producer
    case vocal, minimal, breaks, chill

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }

    public var vibe: String {
        switch self {
        case .deep: return "The foundation"
        case .house: return "The heartbeat"
        case .techno: return "The pulse"
        case .melodic: return "The feeling"
        case .funky: return "The groove"
        case .jackin: return "The bounce"
        case .tech: return "The edge"
        case .afro: return "The spirit"
        case .soulful: return "The heart"
        case .indie: return "The underground"
        case .classics: return "The legacy"
        case .producer: return "The craft"
        case .vocal: return "The voice"
        case .minimal: return "The space"
        case .breaks: return "The rhythm"
        case .chill: return "The calm"
        }
    }

    public var streamURL: URL {
        // Placeholder - replace with real Cloudflare URLs
        URL(string: "https://example.com/stream/\(rawValue)")!
    }
}
