//
//  InteractiveKeyboardView.swift
//  RogAura
//
//  Created by Rohit on 02/07/25.
//
import SwiftUI

struct InteractiveKeyboardView: View {
    @Binding var colors: [Color]
    @Binding var selectedZone: SelectedZone

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Image("Keyboard")
                        .resizable()
                        .scaledToFit()

                    ZoneHotspotView(
                        color: colors[0],
                        isSelected: selectedZone == .zone(0)
                            || selectedZone == .all,
                        action: { selectedZone = .zone(0) }
                    )
                    .frame(
                        width: geometry.size.width * 0.77,
                        height: geometry.size.height * 0.65
                    )
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.43)

                    ZoneHotspotView(
                        color: colors[1],
                        isSelected: selectedZone == .zone(1)
                            || selectedZone == .all,
                        action: { selectedZone = .zone(1) }
                    )
                    .frame(
                        width: geometry.size.width * 0.74,
                        height: geometry.size.height * 0.12
                    )
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.85)

                    ZoneHotspotView(
                        color: colors[2],
                        isSelected: selectedZone == .zone(2)
                            || selectedZone == .all,
                        action: { selectedZone = .zone(2) }
                    )
                    .frame(
                        width: geometry.size.width * 0.07,
                        height: geometry.size.height * 0.64
                    )
                    .position(
                        x: geometry.size.width * 0.945,
                        y: geometry.size.height * 0.4)

                    ZoneHotspotView(
                        color: colors[3],
                        isSelected: selectedZone == .zone(3)
                            || selectedZone == .all,
                        action: { selectedZone = .zone(3) }
                    )
                    .frame(
                        width: geometry.size.width * 0.07,
                        height: geometry.size.height * 0.64
                    )
                    .position(
                        x: geometry.size.width * 0.05,
                        y: geometry.size.height * 0.4)
                }
            }
            .aspectRatio(1.6, contentMode: .fit)
        }
        .frame(minHeight: 150)
    }
}

