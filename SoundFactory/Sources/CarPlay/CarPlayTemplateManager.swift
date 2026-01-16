import CarPlay

class CarPlayTemplateManager {
    
    private weak var interfaceController: CPInterfaceController?
    
    func configure(with interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
    }
    
    func disconnect() {
        self.interfaceController = nil
    }
    
    func createRootTemplate() -> CPTemplate {
        let tabBarTemplate = CPTabBarTemplate(templates: [
            createNowPlayingTab(),
            createBrowseTab(),
            createChatTab()
        ])
        return tabBarTemplate
    }
    
    private func createNowPlayingTab() -> CPTemplate {
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        nowPlayingTemplate.updateNowPlayingButtons([
            CPNowPlayingShuffleButton(handler: { [weak self] button in
                self?.handleShuffle()
            }),
            CPNowPlayingRepeatButton(handler: { [weak self] button in
                self?.handleRepeat()
            })
        ])
        return nowPlayingTemplate
    }
    
    private func createBrowseTab() -> CPTemplate {
        let items = createBrowseItems()
        let listTemplate = CPListTemplate(
            title: "Browse",
            sections: [CPListSection(items: items)]
        )
        listTemplate.tabImage = UIImage(systemName: "music.note.list")
        return listTemplate
    }
    
    private func createChatTab() -> CPTemplate {
        let chatItem = CPListItem(
            text: "Voice Chat",
            detailText: "Tap to start voice chat"
        )
        chatItem.handler = { [weak self] item, completion in
            self?.handleVoiceChat()
            completion()
        }
        
        let listTemplate = CPListTemplate(
            title: "Chat",
            sections: [CPListSection(items: [chatItem])]
        )
        listTemplate.tabImage = UIImage(systemName: "message.fill")
        return listTemplate
    }
    
    private func createBrowseItems() -> [CPListItem] {
        let categories = [
            ("Playlists", "music.note.list"),
            ("Artists", "person.2.fill"),
            ("Albums", "square.stack.fill"),
            ("Genres", "guitars.fill")
        ]
        
        return categories.map { name, icon in
            let item = CPListItem(
                text: name,
                detailText: nil,
                image: UIImage(systemName: icon)
            )
            item.handler = { [weak self] item, completion in
                self?.handleBrowseSelection(category: name)
                completion()
            }
            return item
        }
    }
    
    private func handleShuffle() {
        print("CarPlay: Shuffle toggled")
    }
    
    private func handleRepeat() {
        print("CarPlay: Repeat toggled")
    }
    
    private func handleVoiceChat() {
        print("CarPlay: Voice chat started")
    }
    
    private func handleBrowseSelection(category: String) {
        print("CarPlay: Selected category: \(category)")
    }
}
