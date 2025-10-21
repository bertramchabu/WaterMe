//
//  QuickAddButtonView.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI

/// Quick add button for predefined water amounts
struct QuickAddButtonView: View {
    let amount: Double
    let unit: WaterUnit
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.medium.generate()
            action()
            animatePress()
        }) {
            VStack(spacing: 8) {
                // Water drop icon
                Image(systemName: Constants.Symbols.drop)
                    .font(.system(size: 24))
                    .foregroundColor(Constants.Design.primaryColor)

                // Amount text
                Text(formattedAmount)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Constants.Design.mediumCornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isPressed ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isPressed ? 8 : 4,
                        x: 0,
                        y: isPressed ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Design.mediumCornerRadius)
                    .stroke(
                        isPressed ? Constants.Design.primaryColor.opacity(0.5) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Formatted Amount

    private var formattedAmount: String {
        let converted = unit.convert(from: amount)
        return String(format: "%.0f %@", converted, unit.rawValue)
    }

    // MARK: - Animation

    private func animatePress() {
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            QuickAddButtonView(amount: 250, unit: .milliliters) {}
            QuickAddButtonView(amount: 500, unit: .milliliters) {}
        }

        HStack(spacing: 12) {
            QuickAddButtonView(amount: 237, unit: .fluidOunces) {}
            QuickAddButtonView(amount: 355, unit: .fluidOunces) {}
        }
    }
    .padding()
}
