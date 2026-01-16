import Foundation

struct User: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let username: String
    let displayName: String
    let email: String?
    let avatarURL: String?
    let createdAt: Date
    var preferences: UserPreferences?
    var subscription: SubscriptionInfo?
    
    init(
        id: String,
        username: String,
        displayName: String,
        email: String? = nil,
        avatarURL: String? = nil,
        createdAt: Date = Date(),
        preferences: UserPreferences? = nil,
        subscription: SubscriptionInfo? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.preferences = preferences
        self.subscription = subscription
    }
}

struct UserPreferences: Codable, Equatable, Sendable {
    var audioQuality: AudioQuality
    var autoPlay: Bool
    var notifications: NotificationSettings
    var theme: AppTheme
    
    init(
        audioQuality: AudioQuality = .high,
        autoPlay: Bool = true,
        notifications: NotificationSettings = NotificationSettings(),
        theme: AppTheme = .system
    ) {
        self.audioQuality = audioQuality
        self.autoPlay = autoPlay
        self.notifications = notifications
        self.theme = theme
    }
    
    enum AudioQuality: String, Codable, CaseIterable, Sendable {
        case low = "64kbps"
        case medium = "128kbps"
        case high = "256kbps"
        case lossless = "FLAC"
    }
    
    enum AppTheme: String, Codable, CaseIterable, Sendable {
        case light
        case dark
        case system
    }
}

struct NotificationSettings: Codable, Equatable, Sendable {
    var pushEnabled: Bool
    var chatNotifications: Bool
    var newMusicAlerts: Bool
    var marketingEmails: Bool
    
    init(
        pushEnabled: Bool = true,
        chatNotifications: Bool = true,
        newMusicAlerts: Bool = true,
        marketingEmails: Bool = false
    ) {
        self.pushEnabled = pushEnabled
        self.chatNotifications = chatNotifications
        self.newMusicAlerts = newMusicAlerts
        self.marketingEmails = marketingEmails
    }
}

struct SubscriptionInfo: Codable, Equatable, Sendable {
    let tier: SubscriptionTier
    let startDate: Date
    let expirationDate: Date?
    let isActive: Bool
    
    enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
        case free
        case premium
        case family
        case artist
    }
    
    init(
        tier: SubscriptionTier,
        startDate: Date = Date(),
        expirationDate: Date? = nil,
        isActive: Bool = true
    ) {
        self.tier = tier
        self.startDate = startDate
        self.expirationDate = expirationDate
        self.isActive = isActive
    }
}
