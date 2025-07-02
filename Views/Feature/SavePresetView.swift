//
//  SavePresetView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI


struct SavePresetView: View {
    @ObservedObject var state: KeyboardState
    @Binding var isPresented: Bool
    @State private var presetName: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Save Preset")
                .font(.title)

            TextField("Enter preset name...", text: $presetName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    if !presetName.isEmpty {
                        state.saveCurrentStateAsPreset(name: presetName)
                        isPresented = false
                    }
                }
                .disabled(presetName.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}




