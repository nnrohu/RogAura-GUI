import SwiftUI

struct ContentView: View {
    @ObservedObject var state: KeyboardState
    @State private var isShowingSaveSheet = false

    let gridColumns: [GridItem] = [GridItem(.adaptive(minimum: 60))]

    var body: some View {
        // This is the main container for our view
        VStack {
            // NEW: We now check if the tool was found before showing anything
            if state.isCLIToolFound {
                // If the tool IS found, show the normal controls
                controlsView
            } else {
                // If the tool is NOT found, show the error screen
                ErrorView()
            }
        }
        .padding()
        .frame(width: 320)
        .background(.ultraThinMaterial.opacity(0.9))
        .sheet(isPresented: $isShowingSaveSheet) {
            SavePresetView(state: state, isPresented: $isShowingSaveSheet)
        }
    }

    private var controlsView: some View {
        VStack(spacing: 0) {  // Use spacing 0 for a tight layout
            // Header is always visible
            HeaderView().padding([.horizontal, .top])

            // This Picker acts as our Tab Bar
            Picker("View", selection: $state.selectedTab) {
                Text("Effects").tag(0)
                Text("Presets").tag(1)
                Text("Settings").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Use a switch statement to show the correct view for the selected tab
            switch state.selectedTab {
            case 0:
                // MARK: - Effects Tab Content
                EffectsTabView(state: state)

            case 1:
                // MARK: - Presets Tab Content
                PresetsTabView(state: state, isShowingSaveSheet: $isShowingSaveSheet)

            case 2:
                // MARK: - Settings Tab Content
                SettingsTabView(state:state)

            default:
                // This default case is required by the switch statement.
                EmptyView()
            }

            // Add a spacer at the bottom to push content up
            Spacer(minLength: 0)
        }
    }
}

struct EffectsTabView: View {
    @ObservedObject var state: KeyboardState
    let gridColumns: [GridItem] = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        VStack(spacing: 16) {
            ControlSectionView(title: "Brightness") {
                MarkedSlider(
                    value: $state.brightness,
                    marks: ["Off", "Low", "Med", "High"] // Provide descriptive labels
                )
            }
            ControlSectionView(title: "Speed") {
               
                HStack {
                    Picker("", selection: $state.effectSpeed) {
                        Text("Slow").tag(1)
                        Text("Medium").tag(2)
                        Text("Fast").tag(3)
                    }.pickerStyle(.segmented)
                }
            }

            ControlSectionView(title: "Preset Effects") {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ControlButtonView(
                        id: "rainbow",
                        isActive: state.activePresetID == "rainbow",
                        systemName: "paintpalette.fill",
                        title: "Rainbow"
                    ) { state.setPreset(id: "rainbow") }
                    ControlButtonView(
                        id: "single_colorcycle",
                        isActive: state.activePresetID
                            == "single_colorcycle",
                        systemName: "metronome.fill",
                        title: "Color Shift"
                    ) { state.setPreset(id: "single_colorcycle") }
                    ControlButtonView(
                        id: "strobe",
                        isActive: state.activePresetID == "strobe",
                        systemName: "bolt.fill", title: "Strobe"
                    ) { state.applyStrobeEffect() }
//                                ControlButtonView(
//                                    id: "power", isActive: false,
//                                    systemName: state.isOn
//                                        ? "power.circle.fill" : "power.circle",
//                                    title: state.isOn ? "Off" : "On"
//                                ) {
//                                    if state.isOn {
//                                        state.turnOff()
//                                    } else {
//                                        state.turnOn()
//                                    }
//                                }
                }
            }

            ControlSectionView(title: "Custom Static Color") {
                HStack {
                    ColorPicker(
                        "Color", selection: $state.activeColor,
                        supportsOpacity: false)
                    Button {
                        state.addActiveColorToFavorites()
                    } label: {
                        Image(systemName: "plus.circle.fill").font(
                            .title2)
                    }
                    .buttonStyle(.plain).help("Add to Favorites")
                }
                HStack(spacing: 10) {
                    if state.favoriteColors.isEmpty {
                        Text("Save colors with the (+) button.")
                            .font(.caption).foregroundColor(
                                .secondary)
                    } else {
                        ForEach(state.favoriteColors) { favorite in
                            let displayColor =
                                Color(hex: favorite.hex) ?? .white
                            Button {
                                state.setCustomColor(displayColor)
                            } label: {
                                Circle().fill(displayColor).frame(
                                    width: 28, height: 28
                                )
                                .overlay(
                                    Circle().stroke(
                                        Color.white.opacity(0.2),
                                        lineWidth: 2))
                            }.buttonStyle(.plain)
                        }
                    }
                    Spacer()
                }.frame(height: 30)
            }

            ControlSectionView(title: "Custom Breathing Effect") {
                HStack {
                    ColorPicker(
                        "From", selection: $state.breathingColor1)
                    ColorPicker(
                        "To", selection: $state.breathingColor2)
                }
                Button {
                    state.applyBreathingEffect()
                } label: {
                    Text("Apply Breathing Effect").frame(
                        maxWidth: .infinity)
                }
                .controlSize(.large)
            }
        }
        .padding(.horizontal)
        
    }
}

struct PresetsTabView: View {
    @ObservedObject var state: KeyboardState
    @Binding var isShowingSaveSheet: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ControlSectionView(title: "Multi-Zone Static") {
                    InteractiveKeyboardView(
                        colors: $state.multiZoneColors,
                        selectedZone: $state.selectedZone)
                    HStack {
                        Picker("Zone", selection: $state.selectedZone) {
                            Text("All").tag(SelectedZone.all)
                            Text("1").tag(SelectedZone.zone(0))
                            Text("2").tag(SelectedZone.zone(1))
                            Text("3").tag(SelectedZone.zone(2))
                            Text("4").tag(SelectedZone.zone(3))
                        }.pickerStyle(.segmented)
                        ColorPicker(
                            "Color",
                            selection: $state.activeColorForPicker,
                            supportsOpacity: false
                        ).labelsHidden()
                    }
                }

                ControlSectionView(title: "Multi-Zone Breathing") {
                    InteractiveKeyboardView(
                        colors: $state.multiBreathingColors,
                        selectedZone: $state.selectedZone
                    )
                    Button {
                        state.applyMultiBreathingEffect()
                    } label: {
                        Text("Apply Multi-Zone Breathing").frame(
                            maxWidth: .infinity)
                    }
                    .controlSize(.large)
                }

                ControlSectionView(title: "Saved Presets") {
                    if state.savedPresets.isEmpty {
                        Text(
                            "Save a configuration from the other tabs."
                        ).font(.caption).foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(state.savedPresets) { preset in
                                Button(preset.name) {
                                    state.applyPreset(preset)
                                }
                            }
                            .onDelete(perform: state.deletePreset)
                        }
                        .listStyle(.bordered).frame(maxHeight: 150)
                    }
                    Button {
                        isShowingSaveSheet = true
                    } label: {
                        Label(
                            "Save Current Effect",
                            systemImage: "plus.app.fill"
                        ).frame(maxWidth: .infinity)
                    }.controlSize(.large)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct SettingsTabView: View {
    @ObservedObject var state: KeyboardState // Assuming it needs state for toggle

    var body: some View {
        VStack(spacing: 16) {
            ControlSectionView(title: "Application") {
                Toggle(
                    "Launch at Login", isOn: $state.launchAtLoginEnabled
                )
                .onChange(of: state.launchAtLoginEnabled) { _ in
                    state.toggleLaunchAtLogin()
                }

                // Add a button to show the CLI tool in Finder
                Button("Reveal CLI Tool in Finder") {
                    NSWorkspace.shared.selectFile(
                        nil, inFileViewerRootedAtPath: "/usr/local/bin/"
                    )
                }
            }
            Spacer()
            Button("Quit Rog Aura") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain).font(.caption).foregroundColor(
                .secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView(state: KeyboardState())
}
