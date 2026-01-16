import CarPlay

public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?
    private var streamsTemplate: CPListTemplate?
    private var chatTemplate: CPListTemplate?

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        
        Task { @MainActor in
            CarPlayManager.shared.didConnect(interfaceController: interfaceController)
        }
        
        setupCarPlayInterface()
    }

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
        
        Task { @MainActor in
            CarPlayManager.shared.didDisconnect()
        }
    }

    private func setupCarPlayInterface() {
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        streamsTemplate = createStreamsTemplate()
        chatTemplate = createChatTemplate()
        
        Task { @MainActor in
            CarPlayManager.shared.setStreamsTemplate(streamsTemplate!)
            CarPlayManager.shared.setChatTemplate(chatTemplate!)
        }
        
        let tabBar = CPTabBarTemplate(templates: [
            nowPlayingTemplate,
            streamsTemplate!,
            chatTemplate!
        ])
        
        interfaceController?.setRootTemplate(tabBar, animated: true, completion: nil)
    }
    
    private func createStreamsTemplate() -> CPListTemplate {
        let placeholderItem = CPListItem(
            text: "Loading streams...",
            detailText: "Please wait"
        )
        placeholderItem.isEnabled = false
        
        let section = CPListSection(items: [placeholderItem])
        let template = CPListTemplate(title: "Streams", sections: [section])
        template.tabSystemItem = .mostViewed
        
        return template
    }
    
    private func createChatTemplate() -> CPListTemplate {
        let placeholderItem = CPListItem(
            text: "Chat messages",
            detailText: "Coming soon"
        )
        placeholderItem.isEnabled = false
        
        let section = CPListSection(items: [placeholderItem])
        let template = CPListTemplate(title: "Chat", sections: [section])
        template.tabSystemItem = .contacts
        
        return template
    }
}
