//
//  PixelFont.swift
//  Pocket Bro
//
//  Centralized pixel-style font configuration for consistent retro aesthetic
//

import SpriteKit

/// Font configuration for consistent pixel-art styling throughout the app
struct PixelFont {
    /// Primary font name - Courier is more pixelated/retro than Menlo
    /// Using Courier New for sharper edges that feel more pixel-like
    static let name = "Courier-Bold"
    static let regularName = "Courier"
    
    /// Alternative fonts if Courier isn't available
    static let fallbackName = "Menlo-Bold"
    static let fallbackRegularName = "Menlo"
    
    // Standard sizes that work well with pixel aesthetic
    static let tiny: CGFloat = 10
    static let small: CGFloat = 12
    static let body: CGFloat = 14
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let title: CGFloat = 24
    static let huge: CGFloat = 32
    
    /// Creates a pixel-styled label with consistent font settings
    static func label(
        text: String,
        size: CGFloat = body,
        color: SKColor = .black,
        bold: Bool = true
    ) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bold ? name : regularName
        label.fontSize = size
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
    
    /// Creates a multi-line pixel label
    static func multilineLabel(
        text: String,
        size: CGFloat = body,
        color: SKColor = .black,
        bold: Bool = true,
        lines: Int = 0
    ) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bold ? name : regularName
        label.fontSize = size
        label.fontColor = color
        label.numberOfLines = lines
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.preferredMaxLayoutWidth = 280
        return label
    }
}

// MARK: - SKLabelNode Extension for Easy Pixel Styling

extension SKLabelNode {
    /// Applies pixel font styling to an existing label
    func applyPixelStyle(size: CGFloat? = nil, bold: Bool = true) {
        self.fontName = bold ? PixelFont.name : PixelFont.regularName
        if let size = size {
            self.fontSize = size
        }
    }
    
    /// Creates a pixel-styled label
    static func pixelLabel(
        _ text: String,
        size: CGFloat = PixelFont.body,
        color: SKColor = .black
    ) -> SKLabelNode {
        return PixelFont.label(text: text, size: size, color: color)
    }
}
