import SwiftUI

public struct StreamsView: View {
    @State private var audioManager = AudioManager.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List(DJChannel.allCases) { channel in
                Button {
                    if audioManager.currentChannel == channel && audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play(channel: channel)
                    }
                } label: {
                    HStack(spacing: 16) {
                        ChannelIcon(channel: channel, isPlaying: audioManager.currentChannel == channel && audioManager.isPlaying)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(channel.displayName)
                                .font(.headline)
                                .foregroundStyle(Color.sfWhite)
                            Text(channel.vibe)
                                .font(.subheadline)
                                .foregroundStyle(Color.sfSilver)
                        }

                        Spacer()

                        if audioManager.currentChannel == channel {
                            Image(systemName: audioManager.isPlaying ? "speaker.wave.3.fill" : "pause.fill")
                                .font(.title3)
                                .foregroundStyle(Color.sfSilver)
                                .symbolEffect(.variableColor.iterative, isActive: audioManager.isPlaying)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(
                    audioManager.currentChannel == channel
                    ? Color.sfDarkGray
                    : Color.clear
                )
            }
            .listStyle(.plain)
            .navigationTitle("Channels")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.sfBlack)
            .scrollContentBackground(.hidden)
        }
    }
}

struct ChannelIcon: View {
    let channel: DJChannel
    let isPlaying: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.sfDarkGray)
                .frame(width: 44, height: 44)

            Image(systemName: "radio")
                .font(.title2)
                .foregroundStyle(isPlaying ? Color.sfSilver : Color.gray)
        }
    }
}

#Preview {
    StreamsView()
        .preferredColorScheme(.dark)
}
