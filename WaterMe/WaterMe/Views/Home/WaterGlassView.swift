//
//  WaterGlassView.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI

    // Animated water glass visualization showing hydration progress
struct WaterGlassView: View {
    let progress: Double // 0.0 to 1.0
    let isCompleted: Bool

    @State private var animatedProgress: Double = 0
    @State private var waveOffset: CGFloat = 0

    private let glassWidth: CGFloat = 180
    private let glassHeight: CGFloat = 280

    var body: some View {
        ZStack {
            // ...existing code...
            glassShape
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )

            // Water fill with wave animation
            waterFill
                .clipShape(glassShape)

            // Shimmer effect on glass
            glassShimmer

            // Percentage label
            percentageLabel
        }
        .frame(width: glassWidth, height: glassHeight)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
            startWaveAnimation()
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }

    // MARK: - Glass Shape

    private var glassShape: some Shape {
        TrapezoidShape()
    }

    // MARK: - Water Fill

    private var waterFill: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Base water color
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.7),
                                Color.cyan.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * animatedProgress)

                // Animated wave effect
                WaveShape(offset: waveOffset, percent: animatedProgress)
                    .fill(
                        Color.blue.opacity(0.3)
                    )
                    .frame(height: geometry.size.height * animatedProgress + 20)
                    .offset(y: -10)
            }
        }
    }

    // MARK: - Glass Shimmer

    private var glassShimmer: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.0),
                Color.white.opacity(0.2),
                Color.white.opacity(0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .clipShape(glassShape)
        .offset(x: -20)
    }

    // MARK: - Percentage Label

    private var percentageLabel: some View {
        VStack(spacing: 4) {
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(animatedProgress > 0.5 ? .white : .primary)

            if isCompleted {
                HStack(spacing: 4) {
                    Image(systemName: Constants.Symbols.checkmark)
                        .font(.caption)
                    Text("Goal Reached!")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(animatedProgress > 0.5 ? .white : .green)
            }
        }
    }

    // MARK: - Wave Animation

    private func startWaveAnimation() {
        withAnimation(
            Animation.linear(duration: 2)
                .repeatForever(autoreverses: false)
        ) {
            waveOffset = glassWidth
        }
    }
}

// MARK: - Trapezoid Shape (Glass)

/// Custom shape for the water glass
struct TrapezoidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topWidth = rect.width * 0.75
        let bottomWidth = rect.width
        let height = rect.height

        // Start at top-left
        path.move(to: CGPoint(x: (rect.width - topWidth) / 2, y: 0))

        // Top-right
        path.addLine(to: CGPoint(x: (rect.width + topWidth) / 2, y: 0))

        // Bottom-right
        path.addLine(to: CGPoint(x: rect.width, y: height))

        // Bottom-left
        path.addLine(to: CGPoint(x: 0, y: height))

        // Close path back to top-left
        path.closeSubpath()

        return path
    }
}

// MARK: - Wave Shape

/// Animated wave shape for water effect
struct WaveShape: Shape {
    var offset: CGFloat
    var percent: Double

    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(offset, percent) }
        set {
            offset = newValue.first
            percent = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let waveHeight: CGFloat = 10
        let wavelength = rect.width

        path.move(to: CGPoint(x: 0, y: 0))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset / wavelength) * 2 * .pi)
            let y = waveHeight * sine

            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        WaterGlassView(progress: 0.3, isCompleted: false)
        WaterGlassView(progress: 0.7, isCompleted: false)
        WaterGlassView(progress: 1.0, isCompleted: true)
    }
    .padding()
}
