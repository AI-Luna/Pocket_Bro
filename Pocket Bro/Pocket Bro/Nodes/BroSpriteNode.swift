//
//  BroSpriteNode.swift
//  Pocket Bro
//

import SpriteKit

class BroSpriteNode: SKNode {
    private var bodySprite: SKSpriteNode!
    private var faceSprite: SKSpriteNode!
    private var accessorySprite: SKSpriteNode?

    private let pixelScale: CGFloat = 4.0
    private let spriteSize = CGSize(width: 32, height: 32)

    var archetype: Archetype = .bro {
        didSet { updateAppearance() }
    }

    var mood: BroMood = .neutral {
        didSet { updateFace() }
    }

    override init() {
        super.init()
        setupSprites()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSprites() {
        bodySprite = createPlaceholderSprite(color: .systemBlue)
        bodySprite.position = .zero
        addChild(bodySprite)

        faceSprite = createFaceSprite()
        faceSprite.position = CGPoint(x: 0, y: 20)
        addChild(faceSprite)

        startIdleAnimation()
    }

    private func createPlaceholderSprite(color: SKColor) -> SKSpriteNode {
        let size = CGSize(width: spriteSize.width, height: spriteSize.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Body
            color.setFill()
            let bodyRect = CGRect(x: 8, y: 0, width: 16, height: 24)
            context.fill(bodyRect)

            // Head
            let headColor = SKColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1.0)
            headColor.setFill()
            let headRect = CGRect(x: 6, y: 16, width: 20, height: 16)
            context.fill(headRect)

            // Legs
            SKColor.darkGray.setFill()
            context.fill(CGRect(x: 10, y: 0, width: 5, height: 8))
            context.fill(CGRect(x: 17, y: 0, width: 5, height: 8))
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: texture)
        sprite.setScale(pixelScale)
        return sprite
    }

    private func createFaceSprite() -> SKSpriteNode {
        let label = SKLabelNode(text: mood.emoji)
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let sprite = SKSpriteNode(color: .clear, size: CGSize(width: 40, height: 40))
        label.position = .zero
        sprite.addChild(label)
        return sprite
    }

    private func updateAppearance() {
        let color: SKColor
        switch archetype {
        case .bro:
            color = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        case .gal:
            color = SKColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0)
        case .nonBinary:
            color = SKColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        }

        bodySprite.removeFromParent()
        bodySprite = createPlaceholderSprite(color: color)
        addChild(bodySprite)
    }

    private func updateFace() {
        if let label = faceSprite.children.first as? SKLabelNode {
            label.text = mood.emoji
        }
    }

    func startIdleAnimation() {
        let moveUp = SKAction.moveBy(x: 0, y: 4, duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let bounce = SKAction.sequence([moveUp, moveDown])
        let idle = SKAction.repeatForever(bounce)
        bodySprite.run(idle, withKey: "idle")
    }

    func stopIdleAnimation() {
        bodySprite.removeAction(forKey: "idle")
    }

    func playActionAnimation() {
        stopIdleAnimation()

        let jump = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.15),
            SKAction.moveBy(x: 0, y: -20, duration: 0.15)
        ])

        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)

        bodySprite.run(SKAction.group([jump, spin])) { [weak self] in
            self?.startIdleAnimation()
        }
    }

    func playHappyAnimation() {
        let originalScale = bodySprite.xScale

        let grow = SKAction.scale(to: originalScale * 1.2, duration: 0.1)
        let shrink = SKAction.scale(to: originalScale, duration: 0.1)
        let pulse = SKAction.sequence([grow, shrink])
        let happy = SKAction.repeat(pulse, count: 3)

        bodySprite.run(happy)
    }

    func playSadAnimation() {
        let tiltLeft = SKAction.rotate(toAngle: -0.1, duration: 0.2)
        let tiltRight = SKAction.rotate(toAngle: 0.1, duration: 0.2)
        let center = SKAction.rotate(toAngle: 0, duration: 0.2)
        let shake = SKAction.sequence([tiltLeft, tiltRight, tiltLeft, tiltRight, center])

        bodySprite.run(shake)
    }

    func update(with state: BroState) {
        archetype = state.archetype
        mood = state.mood
    }
}
