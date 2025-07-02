//
//  MarkedSlider.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct MarkedSlider: View {
    // A binding to the slider's current value (e.g., state.brightness)
    @Binding var value: Double
    // An array of strings for the labels we want to display
    let marks: [String]

    var body: some View {
        VStack(spacing: 2) {
            // The standard slider, configured to use the number of marks for its range
            Slider(
                value: $value,
                in: 0...Double(marks.count - 1), // e.g., 0 to 3 for 4 marks
                step: 1
            )
            
            // The labels displayed under the slider
            HStack {
                // We loop through the provided mark labels
                ForEach(marks.indices, id: \.self) { index in
                    Text(marks[index])
                        .font(.caption)
                        .foregroundColor(.secondary)
                        // This makes each label take up equal space,
                        // automatically aligning them under the slider track.
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}
