import CarPlay

public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    private var channelListTemplate: CPListTemplate?

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        setupCarPlayInterface()
    }

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }

    private func setupCarPlayInterface() {
        // Create channel list items
        let channelItems = DJChannel.allCases.map { channel -> CPListItem in
            let item = CPListItem(
                text: channel.displayName,
                detailText: channel.vibe
            )
            item.handler = { [weak self] _, completion in
                self?.playChannel(channel)
                completion()
            }
            return item
        }

        // Create list section
        let section = CPListSection(items: channelItems)

        // Create list template
        channelListTemplate = CPListTemplate(
            title: "Channels",
            sections: [section]
        )

        // Create tab bar with channels and now playing
        let tabBar = CPTabBarTemplate(templates: [
            channelListTemplate!,
            CPNowPlayingTemplate.shared
        ])

        interfaceController?.setRootTemplate(tabBar, animated: true, completion: nil)
    }

    @MainActor
    private func playChannel(_ channel: DJChannel) {
        AudioManager.shared.play(channel: channel)
    }
}
