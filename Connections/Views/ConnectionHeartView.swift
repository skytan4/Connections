//
//  ConnectionHeartView.swift
//  Connections
//

import SwiftUI

struct ConnectionHeartView: View {
    let fillAmount: Double
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            // Outline
            Image(systemName: "heart")
                .font(.system(size: size, weight: .light))
                .foregroundStyle(Color.primary.opacity(0.12))

            // Fill
            Image(systemName: "heart.fill")
                .font(.system(size: size, weight: .light))
                .foregroundStyle(fillColor)
                .opacity(fillAmount > 0 ? 1 : 0)
                .mask(alignment: .bottom) {
                    Rectangle()
                        .frame(height: size * 1.2 * fillAmount)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
        }
        .frame(width: size * 1.2, height: size * 1.2)
        .animation(.easeInOut(duration: 0.6), value: fillAmount)
    }

    private var fillColor: Color {
        // Warm progression: light gray → warm gray → muted rose → deeper muted red
        let t = fillAmount
        if t < 0.25 {
            return Color(red: 0.68, green: 0.66, blue: 0.64)       // warm light gray
        } else if t < 0.5 {
            return Color(red: 0.62, green: 0.52, blue: 0.50)       // warm gray-rose
        } else if t < 0.75 {
            return Color(red: 0.60, green: 0.38, blue: 0.36)       // muted rose
        } else {
            return Color(red: 0.55, green: 0.25, blue: 0.25)       // deep muted red
        }
    }
}

// MARK: - Large variant for session complete

struct ConnectionHeartLargeView: View {
    let fillAmount: Double
    let connectionLevel: ConnectionLevel

    @State private var animate = false

    var body: some View {
        VStack(spacing: 16) {
            ConnectionHeartView(fillAmount: fillAmount, size: 56)
                .scaleEffect(animate ? 1.0 : 0.85)
                .opacity(animate ? 1.0 : 0.0)

            Text(connectionLevel.localizedTitle)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .opacity(animate ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animate = true
            }
        }
    }
}

#Preview("Small") {
    HStack(spacing: 20) {
        ConnectionHeartView(fillAmount: 0.0)
        ConnectionHeartView(fillAmount: 0.3)
        ConnectionHeartView(fillAmount: 0.6)
        ConnectionHeartView(fillAmount: 1.0)
    }
}

#Preview("Large - Connected") {
    ConnectionHeartLargeView(fillAmount: 0.55, connectionLevel: .connected)
}

#Preview("Large - Deeply Connected") {
    ConnectionHeartLargeView(fillAmount: 0.9, connectionLevel: .deeplyConnected)
}
