//
//  DialogueBubbleNode.swift
//  Pocket Bro
//

import SpriteKit

class DialogueBubbleNode: SKNode {
    private var bubble: SKSpriteNode!
    private var label: SKLabelNode!
    private var emojiLabel: SKLabelNode?

    private let padding: CGFloat = 16
    private let maxWidth: CGFloat

    init(maxWidth: CGFloat = 280) {
        self.maxWidth = maxWidth
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(text: String, emoji: String? = nil, duration: TimeInterval = 2.5) {
        removeAllChildren()

        // Create label first to measure
        label = SKLabelNode(text: text)
        label.fontName = "Menlo"
        label.fontSize = 14
        label.fontColor = .black
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = maxWidth - padding * 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        let labelSize = label.frame.size
        let bubbleWidth = min(maxWidth, labelSize.width + padding * 2)
        let bubbleHeight = labelSize.height + padding * 2

        // Create bubble background
        bubble = SKSpriteNode(color: .white, size: CGSize(width: bubbleWidth, height: bubbleHeight))
        bubble.position = .zero
        addChild(bubble)

        // Add tail
        let tail = createTail()
        tail.position = CGPoint(x: 0, y: -bubbleHeight / 2 - 8)
        addChild(tail)

        // Position label
        label.position = .zero
        addChild(label)

        // Add emoji if provided
        if let emoji = emoji {
            emojiLabel = SKLabelNode(text: emoji)
            emojiLabel?.fontSize = 20
            emojiLabel?.position = CGPoint(x: 0, y: bubbleHeight / 2 + 16)
            addChild(emojiLabel!)
        }

        // Animate in
        self.alpha = 0
        self.setScale(0.5)

        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        let showAnimation = SKAction.group([fadeIn, scaleUp])

        let wait = SKAction.wait(forDuration: duration)

        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let hideAnimation = SKAction.group([fadeOut, scaleDown])

        let sequence = SKAction.sequence([showAnimation, wait, hideAnimation, SKAction.removeFromParent()])
        run(sequence)
    }

    private func createTail() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -8, y: 8))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y: 8))
        path.closeSubpath()

        let tail = SKShapeNode(path: path)
        tail.fillColor = .white
        tail.strokeColor = .white
        tail.lineWidth = 0
        return tail
    }

    func showEvent(_ event: RandomEvent, duration: TimeInterval = 4.0) {
        removeAllChildren()

        let bubbleColor = event.isPositive ?
            SKColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0) :
            SKColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)

        // Title
        let titleLabel = SKLabelNode(text: "\(event.emoji) \(event.title)")
        titleLabel.fontName = "Menlo-Bold"
        titleLabel.fontSize = 14
        titleLabel.fontColor = .black

        // Description
        label = SKLabelNode(text: event.description)
        label.fontName = "Menlo"
        label.fontSize = 12
        label.fontColor = SKColor(white: 0.2, alpha: 1.0)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = maxWidth - padding * 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        let totalHeight = titleLabel.frame.height + label.frame.height + padding * 3
        let bubbleWidth = maxWidth
        let bubbleHeight = totalHeight

        bubble = SKSpriteNode(color: bubbleColor, size: CGSize(width: bubbleWidth, height: bubbleHeight))
        addChild(bubble)

        titleLabel.position = CGPoint(x: 0, y: bubbleHeight / 4)
        addChild(titleLabel)

        label.position = CGPoint(x: 0, y: -bubbleHeight / 6)
        addChild(label)

        // Animate
        self.alpha = 0
        self.setScale(0.8)

        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        let wait = SKAction.wait(forDuration: duration)
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.8, duration: 0.3)
        ])

        run(SKAction.sequence([appear, wait, disappear, SKAction.removeFromParent()]))
    }
}
