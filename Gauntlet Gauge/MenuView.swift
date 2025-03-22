//
//  ContentView.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/14/25.
//

import SwiftUI

struct PercentageView: View {
    let percent: Int
    let isUnknown: Bool

    var color: Color {
        switch percent {
        case 0..<30:
            return .red
        case 30..<70:
            return .orange
        default:
            return .green
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: CGFloat(percent) / 100)
                    .stroke(color, lineWidth: 10)
                    .rotationEffect(.degrees(-90))

                Text(isUnknown ? "??" : "\(percent)%")
                    .font(.headline)
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(10)
        }
    }
}

struct MenuView: View {
    var left: Int
    var right: Int
    var title: String?

    var body: some View {
        VStack {
            Text(title ?? "Gauntlet Gauge")
                .font(.headline)
                .padding(.top)
            HStack {
                PercentageView(percent: left, isUnknown: left == -1)
                PercentageView(percent: right, isUnknown: right == -1)
            }.padding(.leading)
                .padding(.trailing)
        }
        .frame(width: 225, height: 145)
    }
}

#Preview {
    return MenuView(left: 40, right: 70, title: "Corne")
}
