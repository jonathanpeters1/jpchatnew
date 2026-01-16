import AVFoundation
import Observation
import MediaPlayer

@Observable
@MainActor
public final class AudioManager {
    public static let shared = AudioManager()

    public private(set) var currentChannel: DJChannel?
    public private(set) var isPlaying = false
    public private(set) var currentStreamURL: URL?
    public private(set) var currentTrackTitle: String?

    private var player: AVPlayer?

    private init() {
        configureAudioSession()
        setupRemoteCommands()
    }

    /// Configures the AVAudioSession for playback with voice chat support
    public func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
            )
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    public func play(channel: DJChannel) {
        currentChannel = channel
        currentStreamURL = channel.streamURL
        currentTrackTitle = channel.displayName
        
        let item = AVPlayerItem(url: channel.streamURL)

        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    public func resume() {
        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    /// Skip to next track/channel (stub for future implementation)
    public func skip() {
        // TODO: Implement skip to next channel logic
        // For now, this is a stub that will be implemented when channel queue is added
        print("Skip requested - not yet implemented")
    }

    /// Skip to previous track/channel (stub for future implementation)
    public func skipToPrevious() {
        // TODO: Implement skip to previous channel logic
        // For now, this is a stub that will be implemented when channel queue is added
        print("Skip to previous requested - not yet implemented")
    }

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.togglePlayPause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.skip()
            }
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.skipToPrevious()
            }
            return .success
        }
    }

    private func updateNowPlaying() {
        let title = currentTrackTitle ?? "Sound Factory"
        let artist = currentChannel?.vibe ?? "Live Stream"

        let info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: "Sound Factory",
            MPMediaItemPropertyAlbumTitle: artist,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
