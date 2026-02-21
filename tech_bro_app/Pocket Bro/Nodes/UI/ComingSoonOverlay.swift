//
//  ComingSoonOverlay.swift
//  Pocket Bro
//
//  Non-blocking "Coming Soon" overlay for pro-gated features.
//  Add to the current scene; dismisses on any tap.
//

import SpriteKit

class ComingSoonOverlay: SKNode {

    static let nodeName = "comingSoonOverlay"

    init(sceneSize: CGSize) {
        super.init()
        name = Self.nodeName
        zPosition = 900
        setupUI(size: sceneSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(size: CGSize) {
        let cx = size.width / 2
        let cy = size.height / 2

        // Full-screen dim background
        let dim = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.55), size: size)
        dim.position = CGPoint(x: cx, y: cy)
        addChild(dim)

        // Card
        let cardW: CGFloat = 280
        let cardH: CGFloat = 148
        let card = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 16)
        card.fillColor = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0)
        card.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 0.7)
        card.lineWidth = 2
        card.position = CGPoint(x: cx, y: cy)
        addChild(card)

        // Title
        let title = SKLabelNode(text: "Coming Soon")
        title.fontName = PixelFont.name
        title.fontSize = PixelFont.title
        title.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0)
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: cx, y: cy + 28)
        addChild(title)

        // Subtitle
        let sub = SKLabelNode(text: "This feature is in the works!")
        sub.fontName = PixelFont.regularName
        sub.fontSize = PixelFont.body
        sub.fontColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
        sub.horizontalAlignmentMode = .center
        sub.verticalAlignmentMode = .center
        sub.position = CGPoint(x: cx, y: cy - 4)
        addChild(sub)

        // Dismiss hint
        let hint = SKLabelNode(text: "Tap anywhere to close")
        hint.fontName = PixelFont.regularName
        hint.fontSize = PixelFont.small
        hint.fontColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 0.5)
        hint.horizontalAlignmentMode = .center
        hint.verticalAlignmentMode = .center
        hint.position = CGPoint(x: cx, y: cy - 40)
        addChild(hint)
    }

    func show(in scene: SKScene) {
        guard scene.childNode(withName: Self.nodeName) == nil else { return }
        alpha = 0
        scene.addChild(self)
        run(SKAction.fadeIn(withDuration: 0.2))
    }

    func dismiss() {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))
    }
}
