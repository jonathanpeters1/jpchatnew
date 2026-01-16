import AVFoundation
import Observation
import MediaPlayer

@Observable
@MainActor
public final class AudioManager {
    public static let shared = AudioManager()

    public private(set) var currentChannel: DJChannel?
    public private(set) var isPlaying = false

    private var player: AVPlayer?

    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    public func play(channel: DJChannel) {
        currentChannel = channel
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

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
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
    }

    private func updateNowPlaying() {
        guard let channel = currentChannel else { return }

        let info: [String: Any] = [
            MPMediaItemPropertyTitle: channel.displayName,
            MPMediaItemPropertyArtist: "Sound Factory",
            MPMediaItemPropertyAlbumTitle: channel.vibe,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
