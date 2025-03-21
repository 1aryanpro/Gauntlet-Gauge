//
//  HandView.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/15/25.
//

import SwiftUI

struct InvertColorsForDarkMode: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content.colorInvert()
        } else {
            content
        }
    }
}

extension View {
    func invertOnDarkMode() -> some View {
        self.modifier(InvertColorsForDarkMode())
    }
}

struct HandView: View {
    var left: Int = -1
    var right: Int = -1

    var body: some View {
        HStack {
            if left == -1 && right == -1 {
                Text("GG")
            } else {
                Image("L\(percentToFingers(left))").resizable().scaledToFit().invertOnDarkMode()
                Image("L\(percentToFingers(right))")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: -1, y: 1)
                    .invertOnDarkMode()
            }
        }
    }
}

func percentToFingers(_ percent: Int) -> Int {
    return Int(round(CGFloat(percent) / 20))
}

#Preview {
    return HandView(left: 1, right: 2).frame(width: 60, height: 22)
}
