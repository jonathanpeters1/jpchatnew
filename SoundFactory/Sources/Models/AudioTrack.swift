import Foundation

struct AudioTrack: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let streamURL: String
    let artworkURL: String?
    let genre: String?
    let releaseDate: Date?
    var isLiked: Bool
    var playCount: Int
    
    init(
        id: String,
        title: String,
        artist: String,
        album: String? = nil,
        duration: TimeInterval,
        streamURL: String,
        artworkURL: String? = nil,
        genre: String? = nil,
        releaseDate: Date? = nil,
        isLiked: Bool = false,
        playCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.streamURL = streamURL
        self.artworkURL = artworkURL
        self.genre = genre
        self.releaseDate = releaseDate
        self.isLiked = isLiked
        self.playCount = playCount
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct Playlist: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let description: String?
    let coverImageURL: String?
    let createdBy: String
    let createdAt: Date
    var tracks: [AudioTrack]
    var isPublic: Bool
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        coverImageURL: String? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        tracks: [AudioTrack] = [],
        isPublic: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.coverImageURL = coverImageURL
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.tracks = tracks
        self.isPublic = isPublic
    }
    
    var totalDuration: TimeInterval {
        tracks.reduce(0) { $0 + $1.duration }
    }
    
    var formattedTotalDuration: String {
        let totalMinutes = Int(totalDuration) / 60
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return "\(hours) hr \(minutes) min"
        }
        return "\(totalMinutes) min"
    }
}

struct Album: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: String?
    let releaseDate: Date
    let genre: String?
    var tracks: [AudioTrack]
    
    init(
        id: String,
        title: String,
        artist: String,
        artworkURL: String? = nil,
        releaseDate: Date,
        genre: String? = nil,
        tracks: [AudioTrack] = []
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.releaseDate = releaseDate
        self.genre = genre
        self.tracks = tracks
    }
    
    var totalDuration: TimeInterval {
        tracks.reduce(0) { $0 + $1.duration }
    }
}
