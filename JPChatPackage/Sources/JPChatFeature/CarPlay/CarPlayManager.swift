import CarPlay
import Foundation

public extension Notification.Name {
    static let carPlayDidConnect = Notification.Name("carPlayDidConnect")
    static let carPlayDidDisconnect = Notification.Name("carPlayDidDisconnect")
}

@MainActor
public final class CarPlayManager {
    public static let shared = CarPlayManager()
    
    public private(set) var isConnected: Bool = false
    public private(set) var interfaceController: CPInterfaceController?
    
    private var streamsTemplate: CPListTemplate?
    private var chatTemplate: CPListTemplate?
    
    private init() {}
    
    func didConnect(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        self.isConnected = true
        
        NotificationCenter.default.post(name: .carPlayDidConnect, object: nil)
    }
    
    func didDisconnect() {
        self.interfaceController = nil
        self.isConnected = false
        
        NotificationCenter.default.post(name: .carPlayDidDisconnect, object: nil)
    }
    
    public func updateStreamsTemplate(with items: [CPListItem]) {
        let section = CPListSection(items: items)
        streamsTemplate?.updateSections([section])
    }
    
    public func updateChatTemplate(with items: [CPListItem]) {
        let section = CPListSection(items: items)
        chatTemplate?.updateSections([section])
    }
    
    func setStreamsTemplate(_ template: CPListTemplate) {
        self.streamsTemplate = template
    }
    
    func setChatTemplate(_ template: CPListTemplate) {
        self.chatTemplate = template
    }
}
