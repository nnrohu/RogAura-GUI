import SwiftUI
import Foundation
import ServiceManagement

//// MARK: - Data Model for Presets
//// We make it Codable to easily save/load from JSON, and Hashable/Identifiable to use in lists.
//struct EffectPreset: Codable, Hashable, Identifiable {
//    var id: UUID = UUID()
//    var name: String
//    var effectID: String // e.g., "breathing", "rainbow", "static"
//    var colors: [CodableColor] // We use a helper struct to save colors
//    var speed: Int
//    
//    // Helper to get SwiftUI Colors
//    var swiftUIColors: [Color] {
//        colors.compactMap { Color(hex: $0.hex) }
//    }
//}
//
//// Helper struct to make SwiftUI's Color Codable by storing its hex string.
//struct CodableColor: Codable, Hashable {
//    var hex: String
//}


//// MARK: - The "Brain" of our App (State Model)
//class KeyboardState: ObservableObject {
//    // --- Published Properties ---
//    @Published var isOn: Bool = true
//    @Published var brightness: Double = 3.0
//    @Published var activeColor: Color = .red
//    @Published var favoriteColors: [Color] = []
//    @Published var breathingColor1: Color = .cyan
//    @Published var breathingColor2: Color = .purple
//    @Published var effectSpeed: Int = 2
//    @Published var launchAtLoginEnabled: Bool = false
//    @Published var activePresetID: String? = "rainbow"
//    
//    // NEW: The array of saved user presets
//    @Published var savedPresets: [EffectPreset] = []
//
//    private let favoritesKey = "AuraController.favoriteColors"
//    private let launchAtLoginKey = "AuraController.launchAtLogin"
//
//    init() {
//        loadFavorites()
//        loadLaunchAtLoginPreference()
//        // NEW: Load saved presets when the app starts
//        loadPresetsFromDisk()
//    }
//    
//    // --- Logic for Presets ---
//    
//    func saveCurrentStateAsPreset(name: String) {
//        let effectID = activePresetID ?? "static"
//        var presetColors: [CodableColor] = []
//
//        // Capture the relevant colors based on the active effect
//        if effectID == "breathing" {
//            presetColors = [breathingColor1, breathingColor2].compactMap { CodableColor(hex: $0.toHex() ?? "") }
//        } else {
//            presetColors = [activeColor].compactMap { CodableColor(hex: $0.toHex() ?? "") }
//        }
//        
//        let newPreset = EffectPreset(name: name, effectID: effectID, colors: presetColors, speed: self.effectSpeed)
//        
//        savedPresets.append(newPreset)
//        savePresetsToDisk()
//    }
//    
//    func applyPreset(_ preset: EffectPreset) {
//        // Update the app's state from the preset
//        self.effectSpeed = preset.speed
//        self.activePresetID = preset.effectID
//        
//        // Apply the effect
//        switch preset.effectID {
//        case "breathing":
//            // Ensure there are enough colors to apply
//            if preset.colors.count >= 2 {
//                self.breathingColor1 = preset.swiftUIColors[0]
//                self.breathingColor2 = preset.swiftUIColors[1]
//                applyBreathingEffect()
//            }
//        case "rainbow", "single_colorcycle":
//            setPreset(command: [preset.effectID])
//        default: // "static"
//            if let color = preset.swiftUIColors.first {
//                setCustomColor(color)
//            }
//        }
//    }
//    
//    func deletePreset(at offsets: IndexSet) {
//        savedPresets.remove(atOffsets: offsets)
//        savePresetsToDisk()
//    }
//
//    private func presetsFileURL() throws -> URL {
//        let fileManager = FileManager.default
//        let supportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let appDirectoryURL = supportURL.appendingPathComponent("AuraController")
//        try fileManager.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true, attributes: nil)
//        return appDirectoryURL.appendingPathComponent("presets.json")
//    }
//
//    private func savePresetsToDisk() {
//        do {
//            let url = try presetsFileURL()
//            let data = try JSONEncoder().encode(savedPresets)
//            try data.write(to: url, options: [.atomic, .completeFileProtection])
//            print("Successfully saved presets to \(url.path)")
//        } catch {
//            print("Error saving presets: \(error.localizedDescription)")
//        }
//    }
//
//    private func loadPresetsFromDisk() {
//        do {
//            let url = try presetsFileURL()
//            let data = try Data(contentsOf: url)
//            self.savedPresets = try JSONDecoder().decode([EffectPreset].self, from: data)
//            print("Successfully loaded \(savedPresets.count) presets.")
//        } catch {
//            // It's normal for this to fail on first launch if the file doesn't exist yet.
//            print("Could not load presets from disk (may be first launch): \(error.localizedDescription)")
//        }
//    }
//
//    func toggleLaunchAtLogin() {
//        let newStatus = !launchAtLoginEnabled
//
//        guard let bundleID = Bundle.main.bundleIdentifier else {
//            print("Error: Could not get bundle identifier.")
//            return
//        }
//
//        if SMLoginItemSetEnabled(bundleID as CFString, newStatus) {
//            UserDefaults.standard.set(newStatus, forKey: launchAtLoginKey)
//            self.launchAtLoginEnabled = newStatus
//            print("Successfully set launch at login status to \(newStatus).")
//        } else {
//            print("Error: Failed to set launch at login status.")
//            self.launchAtLoginEnabled = !newStatus
//        }
//    }
//
//    private func loadLaunchAtLoginPreference() {
//        self.launchAtLoginEnabled = UserDefaults.standard.bool(
//            forKey: launchAtLoginKey)
//    }
//
//    // --- Methods to Change State AND Run Commands ---
//
//    func turnOn() {
//        guard !isOn else { return }
//        isOn = true
//        brightness = 3.0
//        runCommand(with: ["on"])
//        runCommand(with: ["brightness", "3"])
//        // When turning on, let's default to the rainbow effect.
//        setPreset(command: ["rainbow"])
//    }
//
//    func turnOff() {
//        guard isOn else { return }
//        isOn = false
//        brightness = 0.0
//        activePresetID = nil
//        runCommand(with: ["off"])
//    }
//
//    func setBrightness(_ level: Double) {
//        self.brightness = level
//        if brightness > 0 && !isOn {
//            self.isOn = true
//        } else if brightness == 0 && isOn {
//            self.isOn = false
//        }
//        runCommand(with: ["brightness", "\(Int(level))"])
//    }
//
//    func setCustomColor(_ newColor: Color) {
//        self.activeColor = newColor
//        activePresetID = nil
//        guard let hex = newColor.toHex() else { return }
//        if !isOn { turnOn() }
//        runCommand(with: ["single_static", hex])
//    }
//
//    // MODIFIED: This method now reads the effectSpeed state
//    func applyBreathingEffect() {
//        activePresetID = "breathing"
//        guard let hex1 = breathingColor1.toHex(),
//            let hex2 = breathingColor2.toHex()
//        else { return }
//        if !isOn { turnOn() }
//
//        // Pass the speed as the final argument
//        runCommand(with: ["single_breathing", hex1, hex2, "\(effectSpeed)"])
//    }
//
//    // MODIFIED: This method can now pass a speed argument
//    func setPreset(command: [String]) {
//        if !isOn { turnOn() }
//
//        // Get the first part of the command to identify the effect type
//        let effectName = command.first ?? ""
//        activePresetID = effectName
//        // Check if the command is one that uses speed
//        if ["single_colorcycle", "rainbow"].contains(effectName) {
//            // Append the speed argument to the existing command array
//            runCommand(with: command + ["\(effectSpeed)"])
//        } else {
//            // Otherwise, run the command as is
//            runCommand(with: command)
//        }
//    }
//
//    // --- Favorite Colors Logic ---
//
//    func addActiveColorToFavorites() {
//        // Avoid adding duplicate colors
//        guard !favoriteColors.contains(activeColor) else { return }
//
//        favoriteColors.append(activeColor)
//
//        // Keep the list limited to 5 favorites, removing the oldest if full.
//        if favoriteColors.count > 5 {
//            favoriteColors.removeFirst()
//        }
//
//        saveFavorites()
//    }
//
//    private func saveFavorites() {
//        let hexArray = favoriteColors.compactMap { $0.toHex() }
//        UserDefaults.standard.set(hexArray, forKey: favoritesKey)
//    }
//
//    private func loadFavorites() {
//        guard
//            let hexArray = UserDefaults.standard.array(forKey: favoritesKey)
//                as? [String]
//        else { return }
//        self.favoriteColors = hexArray.compactMap { Color(hex: $0) }
//    }
//
//    /// This helper function runs our command-line tool.
//    private func runCommand(with arguments: [String]) {
//        print(
//            "Running command: /usr/local/bin/macRogAuraCore \(arguments.joined(separator: " "))"
//        )
//        let process = Process()
//        process.launchPath = "/usr/local/bin/macRogAuraCore"
//        process.arguments = arguments
//        do { try process.run() } catch {
//            print("Error: Failed to run command.")
//        }
//    }
//}

@main
struct RogAuraApp: App {  // Changed name to match your project
    // @StateObject creates and manages the single instance of our "brain"
    @StateObject private var keyboardState = KeyboardState()

    var body: some Scene {
        MenuBarExtra {
            // This is the content of the window when you click the icon
            ContentView(state: keyboardState)
        } label: {
            // This is the label shown in the menu bar itself.
            // We now use an Image view referencing our new asset.
            Image("MenuBarIcon")
        }
        .menuBarExtraStyle(.window)
    }
}
