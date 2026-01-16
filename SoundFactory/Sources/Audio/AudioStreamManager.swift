import AVFoundation
import Combine

@MainActor
class AudioStreamManager: ObservableObject {
    static let shared = AudioStreamManager()
    
    @Published var isStreaming = false
    @Published var currentStreamURL: String?
    @Published var bufferProgress: Double = 0
    @Published var streamQuality: StreamQuality = .high
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var cancellables = Set<AnyCancellable>()
    
    enum StreamQuality: String, CaseIterable {
        case low = "64kbps"
        case medium = "128kbps"
        case high = "256kbps"
        case lossless = "FLAC"
    }
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try session.setActive(true)
        } catch {
            print("AudioStreamManager: Failed to setup audio session: \(error)")
        }
    }
    
    func startStream(url: String) {
        guard let streamURL = URL(string: url) else {
            print("AudioStreamManager: Invalid URL")
            return
        }
        
        stopStream()
        
        currentStreamURL = url
        playerItem = AVPlayerItem(url: streamURL)
        player = AVPlayer(playerItem: playerItem)
        
        setupBufferObserver()
        
        player?.play()
        isStreaming = true
    }
    
    func stopStream() {
        player?.pause()
        player = nil
        playerItem = nil
        isStreaming = false
        currentStreamURL = nil
        bufferProgress = 0
    }
    
    func pauseStream() {
        player?.pause()
        isStreaming = false
    }
    
    func resumeStream() {
        player?.play()
        isStreaming = true
    }
    
    func setQuality(_ quality: StreamQuality) {
        streamQuality = quality
        if let url = currentStreamURL {
            startStream(url: url)
        }
    }
    
    private func setupBufferObserver() {
        playerItem?.publisher(for: \.loadedTimeRanges)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRanges in
                guard let self = self,
                      let timeRange = timeRanges.first?.timeRangeValue,
                      let duration = self.playerItem?.duration.seconds,
                      duration > 0 else { return }
                
                let bufferedTime = timeRange.start.seconds + timeRange.duration.seconds
                self.bufferProgress = bufferedTime / duration
            }
            .store(in: &cancellables)
        
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    print("AudioStreamManager: Ready to play")
                case .failed:
                    print("AudioStreamManager: Failed to load stream")
                    self?.isStreaming = false
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
