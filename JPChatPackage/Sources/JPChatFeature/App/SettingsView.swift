import SwiftUI

public struct SettingsView: View {
    @State private var audioQuality = "High"
    @State private var autoPlay = true

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Playback") {
                    Picker("Audio Quality", selection: $audioQuality) {
                        Text("Low").tag("Low")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                    }

                    Toggle("Auto-play on Launch", isOn: $autoPlay)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Sound Factory")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Link(destination: URL(string: "https://soundfactory.fm")!) {
                        HStack {
                            Text("Visit Sound Factory")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }

                Section("Legal") {
                    NavigationLink("Terms of Service") {
                        LegalTextView(title: "Terms of Service")
                    }
                    NavigationLink("Privacy Policy") {
                        LegalTextView(title: "Privacy Policy")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LegalTextView: View {
    let title: String

    var body: some View {
        ScrollView {
            Text("Legal content for \(title) will be displayed here.")
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
