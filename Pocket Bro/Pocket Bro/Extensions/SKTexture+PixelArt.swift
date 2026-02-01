//
//  SKTexture+PixelArt.swift
//  Pocket Bro
//

import SpriteKit

extension SKTexture {
    static func pixelTexture(color: SKColor, size: CGSize = CGSize(width: 1, height: 1)) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        return texture
    }

    func pixelPerfect() -> SKTexture {
        self.filteringMode = .nearest
        return self
    }
}

extension SKSpriteNode {
    static func pixelSprite(color: SKColor, pixelSize: CGSize, scale: CGFloat = 4.0) -> SKSpriteNode {
        let texture = SKTexture.pixelTexture(color: color, size: pixelSize)
        let sprite = SKSpriteNode(texture: texture)
        sprite.setScale(scale)
        return sprite
    }

    func makePixelPerfect() {
        texture?.filteringMode = .nearest
    }
}

extension SKColor {
    static let pixelBlack = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    static let pixelWhite = SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    static let pixelRed = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
    static let pixelGreen = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
    static let pixelBlue = SKColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
    static let pixelYellow = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
    static let pixelPurple = SKColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0)
    static let pixelOrange = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
    static let pixelPink = SKColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
    static let pixelCyan = SKColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0)

    // UI Colors
    static let uiBackground = SKColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1.0)
    static let uiPanelBackground = SKColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0)
    static let uiButtonNormal = SKColor(red: 0.25, green: 0.45, blue: 0.7, alpha: 1.0)
    static let uiButtonPressed = SKColor(red: 0.2, green: 0.35, blue: 0.55, alpha: 1.0)
    static let uiButtonDisabled = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
}
