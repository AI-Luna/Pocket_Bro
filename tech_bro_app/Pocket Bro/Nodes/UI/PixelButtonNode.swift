//
//  PixelButtonNode.swift
//  Pocket Bro
//

import SpriteKit

class PixelButtonNode: SKNode {
    private var background: SKSpriteNode!
    private var label: SKLabelNode!
    private var iconLabel: SKLabelNode?

    private let buttonSize: CGSize
    private var isEnabled: Bool = true
    private var isPressed: Bool = false

    var onTap: (() -> Void)?

    private let enabledColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
    private let disabledColor = SKColor(white: 0.25, alpha: 1.0)
    private let pressedColor = SKColor(red: 0.20, green: 0.10, blue: 0.35, alpha: 1.0)

    init(text: String, icon: String? = nil, size: CGSize = CGSize(width: 120, height: 44)) {
        self.buttonSize = size
        super.init()
        setupButton(text: text, icon: icon)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton(text: String, icon: String?) {
        // Background shape with rounded corners
        let shape = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        shape.fillColor = enabledColor
        shape.strokeColor = SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 0.6)
        shape.lineWidth = 2
        shape.name = "buttonShape"
        addChild(shape)

        // Use a transparent sprite for touch detection (same size as shape)
        background = SKSpriteNode(color: .clear, size: buttonSize)
        background.position = .zero
        addChild(background)

        // Label
        label = SKLabelNode(text: text)
        label.fontName = PixelFont.name
        label.fontSize = 17
        label.fontColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = buttonSize.width - 24

        if let icon = icon {
            iconLabel = SKLabelNode(text: icon)
            iconLabel?.fontSize = 18
            iconLabel?.horizontalAlignmentMode = .center
            iconLabel?.verticalAlignmentMode = .center
            iconLabel?.position = CGPoint(x: -buttonSize.width/4, y: 0)
            addChild(iconLabel!)

            label.position = CGPoint(x: 10, y: 0)
        } else {
            label.position = .zero
        }

        addChild(label)
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        let shape = children.first(where: { $0.name == "buttonShape" }) as? SKShapeNode
        shape?.fillColor = enabled ? enabledColor : disabledColor
        shape?.strokeColor = enabled ? SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 0.6) : .clear
        label.fontColor = enabled ? SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) : SKColor(white: 0.4, alpha: 1.0)
        iconLabel?.fontColor = label.fontColor
    }

    func setText(_ text: String) {
        label.text = text
    }

    func setIcon(_ icon: String) {
        iconLabel?.text = icon
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        isPressed = true
        animatePress()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let wasPressed = isPressed
        isPressed = background.contains(location)

        if wasPressed != isPressed {
            if isPressed {
                animatePress()
            } else {
                animateRelease()
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }

        if isPressed {
            animateRelease()
            onTap?()
        }
        isPressed = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPressed {
            animateRelease()
        }
        isPressed = false
    }

    private func animatePress() {
        let shape = children.first(where: { $0.name == "buttonShape" }) as? SKShapeNode
        shape?.fillColor = pressedColor
        run(SKAction.scale(to: 0.95, duration: 0.05))
    }

    private func animateRelease() {
        let shape = children.first(where: { $0.name == "buttonShape" }) as? SKShapeNode
        shape?.fillColor = enabledColor
        run(SKAction.scale(to: 1.0, duration: 0.05))
    }
}

// MARK: - Category Button

class CategoryButtonNode: PixelButtonNode {
    let category: ActionCategory

    init(category: ActionCategory) {
        self.category = category
        super.init(text: category.displayName, icon: category.emoji, size: CGSize(width: 140, height: 50))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action Button

class ActionButtonNode: PixelButtonNode {
    let action: GameAction

    private var cooldownLabel: SKLabelNode?
    private var cooldownOverlay: SKSpriteNode?

    init(action: GameAction, size: CGSize = CGSize(width: 280, height: 60)) {
        self.action = action
        super.init(text: action.name, icon: action.emoji, size: size)
        setupCooldownOverlay(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCooldownOverlay(size: CGSize) {
        cooldownOverlay = SKSpriteNode(color: SKColor(white: 0, alpha: 0.6), size: size)
        cooldownOverlay?.isHidden = true
        cooldownOverlay?.zPosition = 10
        addChild(cooldownOverlay!)

        cooldownLabel = SKLabelNode(text: "")
        cooldownLabel?.fontName = "Menlo-Bold"
        cooldownLabel?.fontSize = 12
        cooldownLabel?.fontColor = .white
        cooldownLabel?.zPosition = 11
        cooldownLabel?.isHidden = true
        addChild(cooldownLabel!)
    }

    func updateCooldown(remaining: TimeInterval) {
        if remaining > 0 {
            cooldownOverlay?.isHidden = false
            cooldownLabel?.isHidden = false
            cooldownLabel?.text = "\(Int(remaining))s"
            setEnabled(false)
        } else {
            cooldownOverlay?.isHidden = true
            cooldownLabel?.isHidden = true
        }
    }

    func updateAvailability(canPerform: Bool, reason: String? = nil) {
        setEnabled(canPerform)
    }
}
