//
//  SKColor+Adjustments.swift
//  Pocket Bro
//

import SpriteKit

extension SKColor {
    func lighter(by percentage: CGFloat) -> SKColor {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat) -> SKColor {
        return self.adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: min(max(red + percentage, 0), 1.0),
                       green: min(max(green + percentage, 0), 1.0),
                       blue: min(max(blue + percentage, 0), 1.0),
                       alpha: alpha)
    }
}
