//
//  KeyboardState.swift
//  RogAura
//
//  Created by Rohit on 01/07/25.
//

import Foundation
import ServiceManagement
import SwiftUI

// At the top of KeyboardState.swift
enum SelectedZone: Hashable {
    case all
    case zone(Int)  // We'll use index 0-3
}

class KeyboardState: ObservableObject {
    // --- Published Properties ---
    @Published var isCLIToolFound: Bool = false
    @Published var selectedTab: Int = 0
    
    @Published var isOn: Bool = true
    @Published var brightness: Double = 3.0 {
        didSet {
            if Int(brightness) != Int(oldValue) {
                setBrightness(brightness)
            }
        }
    }

    @Published var activeColor: Color = .red {
        didSet {
            if activeColor != oldValue {
                setCustomColor(activeColor)
            }
        }
    }

    var activeColorForPicker: Color {
        get {
            // When the picker asks for the color, give it the color of the selected zone.
            // If 'all' is selected, we can just show the color of the first zone as a reference.
            switch selectedZone {
            case .all:
                return multiZoneColors.first ?? .white
            case .zone(let index):
                // Ensure index is safe
                guard multiZoneColors.indices.contains(index) else {
                    return .white
                }
                return multiZoneColors[index]
            }
        }
        set(newColor) {
            // When the picker is changed, this 'set' block runs.
            // It updates the correct zone(s) with the new color.
            switch selectedZone {
            case .all:
                // Set all four zones to the new color
                for i in 0..<multiZoneColors.count {
                    multiZoneColors[i] = newColor
                }
            case .zone(let index):
                // Set only the selected zone to the new color
                guard multiZoneColors.indices.contains(index) else { return }
                multiZoneColors[index] = newColor
            }
            // Apply the change to the real keyboard immediately!
            applyMultiZoneEffect()
        }
    }

    @Published var favoriteColors: [CodableColor] = []
    @Published var breathingColor1: Color = .cyan
    @Published var breathingColor2: Color = .purple
    @Published var multiZoneColors: [Color] = [
        Color(hex: "FF0000")!,  // Zone 1: Red
        Color(hex: "00FF00")!,  // Zone 2: Green
        Color(hex: "0000FF")!,  // Zone 3: Blue
        Color(hex: "FFFF00")!,  // Zone 4: Yellow
    ]
    @Published var selectedZone: SelectedZone = .all
    @Published var effectSpeed: Int = 2
    @Published var multiBreathingColors: [Color] = [
        .cyan, .purple, .orange, .green,
    ]

    @Published var launchAtLoginEnabled: Bool = false
    @Published var activePresetID: String? = "rainbow"
    @Published var savedPresets: [EffectPreset] = []

    private let favoritesKey = "AuraController.favoriteColors"
    private let launchAtLoginKey = "AuraController.launchAtLogin"

    init() {
        loadFavorites()
        loadLaunchAtLoginPreference()
        loadPresetsFromDisk()
        checkCLIToolExists()
    }

    // --- Methods to Control the Keyboard ---
    private func checkCLIToolExists() {
        let path = "/usr/local/bin/macRogAuraCore"
        let fileManager = FileManager.default
        // The fileExists method returns true or false
        self.isCLIToolFound = fileManager.fileExists(atPath: path)
    }

    func turnOn() {
        guard !isOn else { return }
        isOn = true
        brightness = 3.0
        setPreset(id: "rainbow")
    }

    func turnOff() {
        guard isOn else { return }
        isOn = false
        brightness = 0.0
        activePresetID = nil
        runCommand(with: ["off"])
    }

    func setBrightness(_ level: Double) {
        let newLevel = Int(level)
        if newLevel > 0 && !isOn {
            self.isOn = true
        } else if newLevel == 0 && isOn {
            self.isOn = false
        }
        runCommand(with: ["brightness", "\(newLevel)"])
    }

    func setCustomColor(_ newColor: Color) {
        if self.activeColor != newColor { self.activeColor = newColor }
        activePresetID = nil
        if !isOn { turnOn() }
        guard let hex = newColor.toHex() else { return }
        runCommand(with: ["single_static", hex])
    }

    func setPreset(id: String) {
        if !isOn { self.isOn = true }
        activePresetID = id

        if ["single_colorcycle", "rainbow"].contains(id) {
            runCommand(with: [id, "\(effectSpeed)"])
        } else {
            runCommand(with: [id])
        }
    }

    func applyBreathingEffect() {
        activePresetID = "breathing"
        if !isOn { self.isOn = true }
        guard let hex1 = breathingColor1.toHex(),
            let hex2 = breathingColor2.toHex()
        else { return }
        runCommand(with: ["single_breathing", hex1, hex2, "\(effectSpeed)"])
    }

    func applyMultiBreathingEffect() {
        activePresetID = "multi_breathing"
        if !isOn { turnOn() }

        let hexColors = multiBreathingColors.compactMap { $0.toHex() }
        guard hexColors.count == 4 else { return }

        var arguments = ["multi_breathing"]
        arguments.append(contentsOf: hexColors)
        arguments.append("\(effectSpeed)")

        runCommand(with: arguments)
    }

    func applyMultiZoneEffect() {
        activePresetID = "multi_static"
        if !isOn { self.isOn = true }

        // Convert the four Colors to hex strings
        let hexColors = multiZoneColors.compactMap { $0.toHex() }

        // Ensure we have exactly 4 colors before proceeding
        guard hexColors.count == 4 else {
            print("Error: Multi-zone effect requires exactly 4 colors.")
            return
        }

        // Construct the arguments for the command line tool
        let arguments = ["multi_static"] + hexColors

        runCommand(with: arguments)
    }

    func applyStrobeEffect() {
        activePresetID = "strobe"  // Give it a unique ID for the UI
        if !isOn { turnOn() }

        // Strobe uses the main "Custom Color" for a consistent UI
        guard let hex = activeColor.toHex() else { return }

        // Call the new command with the color and the current speed setting
        runCommand(with: ["strobe", hex, "\(effectSpeed)"])
    }

    // --- Logic for Favorites & Presets ---

    func addActiveColorToFavorites() {
        guard let newHex = activeColor.toHex(),
            !favoriteColors.contains(where: { $0.hex == newHex })
        else { return }
        favoriteColors.append(CodableColor(hex: newHex))
        if favoriteColors.count > 5 { favoriteColors.removeFirst() }
        saveFavorites()
    }

    private func saveFavorites() {
        let hexArray = favoriteColors.map { $0.hex }
        UserDefaults.standard.set(hexArray, forKey: favoritesKey)
    }

    private func loadFavorites() {
        guard
            let hexArray = UserDefaults.standard.array(forKey: favoritesKey)
                as? [String]
        else { return }
        self.favoriteColors = hexArray.map { CodableColor(hex: $0) }
    }

    func saveCurrentStateAsPreset(name: String) {
        let effectID = activePresetID ?? "static"
        var presetColors: [CodableColor] = []
        if effectID == "breathing" {
            presetColors = [breathingColor1, breathingColor2].compactMap {
                CodableColor(hex: $0.toHex() ?? "")
            }
        } else if effectID == "multi_static" {
            presetColors = self.multiZoneColors.compactMap {
                CodableColor(hex: $0.toHex() ?? "")
            }
        } else if effectID == "multi_breathing" {
            presetColors = self.multiBreathingColors.compactMap {
                CodableColor(hex: $0.toHex() ?? "")
            }
        } else {
            presetColors = [activeColor].compactMap {
                CodableColor(hex: $0.toHex() ?? "")
            }
        }
        let newPreset = EffectPreset(
            name: name, effectID: effectID, colors: presetColors,
            speed: self.effectSpeed)
        savedPresets.append(newPreset)
        savePresetsToDisk()
    }

    func applyPreset(_ preset: EffectPreset) {
        self.effectSpeed = preset.speed
        self.activePresetID = preset.effectID
        switch preset.effectID {
        case "breathing":
            if preset.colors.count >= 2 {
                self.breathingColor1 = preset.swiftUIColors[0]
                self.breathingColor2 = preset.swiftUIColors[1]
                applyBreathingEffect()
            }
        case "multi_static":
            if preset.colors.count >= 4 {
                self.multiZoneColors = preset.swiftUIColors
                applyMultiZoneEffect()
            }
        case "multi_breathing":  // Added missing case
            if preset.colors.count >= 4 {
                self.multiBreathingColors = preset.swiftUIColors
                applyMultiBreathingEffect()
            }
        case "strobe":  // Added missing case
            if let color = preset.swiftUIColors.first {
                self.activeColor = color
                applyStrobeEffect()
            }
        case "rainbow", "single_colorcycle":
            setPreset(id: preset.effectID)
        default:  // static
            if let color = preset.swiftUIColors.first { setCustomColor(color) }
        }
    }

    func deletePreset(at offsets: IndexSet) {
        savedPresets.remove(atOffsets: offsets)
        savePresetsToDisk()
    }

    // ... File & Login Item helpers are unchanged ...
    private func presetsFileURL() throws -> URL {
        let fileManager = FileManager.default
        let supportURL = try fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
        let appDirectoryURL = supportURL.appendingPathComponent(
            "AuraController")
        try fileManager.createDirectory(
            at: appDirectoryURL, withIntermediateDirectories: true,
            attributes: nil)
        return appDirectoryURL.appendingPathComponent("presets.json")
    }

    private func savePresetsToDisk() {
        do {
            let url = try presetsFileURL()
            let data = try JSONEncoder().encode(savedPresets)
            try data.write(
                to: url, options: [.atomic, .completeFileProtection])
            print("Successfully saved presets to \(url.path)")
        } catch {
            print("Error saving presets: \(error.localizedDescription)")
        }
    }
    private func loadPresetsFromDisk() {
        do {
            let url = try presetsFileURL()
            let data = try Data(contentsOf: url)
            self.savedPresets = try JSONDecoder().decode(
                [EffectPreset].self, from: data)
            print("Successfully loaded \(savedPresets.count) presets.")
        } catch {
            // It's normal for this to fail on first launch if the file doesn't exist yet.
            print(
                "Could not load presets from disk (may be first launch): \(error.localizedDescription)"
            )
        }
    }

    func toggleLaunchAtLogin() {
        let newStatus = !launchAtLoginEnabled

        guard let bundleID = Bundle.main.bundleIdentifier else {
            print("Error: Could not get bundle identifier.")
            return
        }

        if SMLoginItemSetEnabled(bundleID as CFString, newStatus) {
            UserDefaults.standard.set(newStatus, forKey: launchAtLoginKey)
            self.launchAtLoginEnabled = newStatus
            print("Successfully set launch at login status to \(newStatus).")
        } else {
            print("Error: Failed to set launch at login status.")
            self.launchAtLoginEnabled = !newStatus
        }
    }

    private func loadLaunchAtLoginPreference() {
        self.launchAtLoginEnabled = UserDefaults.standard.bool(
            forKey: launchAtLoginKey)
    }

    private func runCommand(with arguments: [String]) {
        guard isCLIToolFound else {
            print("Command blocked because CLI tool was not found.")
            return
        }
        print(
            "Running command: /usr/local/bin/macRogAuraCore \(arguments.joined(separator: " "))"
        )
        let process = Process()
        process.launchPath = "/usr/local/bin/macRogAuraCore"
        process.arguments = arguments
        do { try process.run() } catch {
            print("Error: Failed to run command.")
        }
    }
}
