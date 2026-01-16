import CarPlay
import MediaPlayer

public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    private var channelListTemplate: CPListTemplate?

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        
        // Initialize AudioManager and configure audio session for CarPlay
        Task { @MainActor in
            AudioManager.shared.configureAudioSession()
        }
        
        setupCarPlayInterface()
        setupNowPlayingWithPlaceholder()
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

    /// Sets up Now Playing with placeholder data when CarPlay connects
    private func setupNowPlayingWithPlaceholder() {
        // Set placeholder now playing info to show "Now Playing" tab is active
        let placeholderInfo: [String: Any] = [
            MPMediaItemPropertyTitle: "Sound Factory",
            MPMediaItemPropertyArtist: "Select a channel to start",
            MPMediaItemPropertyAlbumTitle: "Live Streaming",
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: 0.0
        ]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = placeholderInfo
    }

    @MainActor
    private func playChannel(_ channel: DJChannel) {
        AudioManager.shared.play(channel: channel)
    }
}
