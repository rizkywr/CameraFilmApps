//
//  CrosshairReticle.swift
//  CameraFilmApps
//

import SwiftUI

/// Center target crosshair as seen on professional compact digital cameras.
struct CrosshairReticle: View {
    var body: some View {
        ZStack {
            // White crosshair with thin dark drop shadow
            CrosshairShape()
                .stroke(Color.black.opacity(0.4), lineWidth: 2.5)
            CrosshairShape()
                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
        }
        .frame(width: 32, height: 32)
        .allowsHitTesting(false)
    }
}

private struct CrosshairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY
        let arm: CGFloat = 10
        let gap: CGFloat = 3

        // Horizontal arms
        path.move(to: CGPoint(x: midX - arm, y: midY))
        path.addLine(to: CGPoint(x: midX - gap, y: midY))
        path.move(to: CGPoint(x: midX + gap, y: midY))
        path.addLine(to: CGPoint(x: midX + arm, y: midY))

        // Vertical arms
        path.move(to: CGPoint(x: midX, y: midY - arm))
        path.addLine(to: CGPoint(x: midX, y: midY - gap))
        path.move(to: CGPoint(x: midX, y: midY + gap))
        path.addLine(to: CGPoint(x: midX, y: midY + arm))

        return path
    }
}
