//
//  ActionSelectModal.swift
//  Pocket Bro
//

import SpriteKit

protocol ActionSelectModalDelegate: AnyObject {
    func actionSelectModal(_ modal: ActionSelectModal, didSelect action: GameAction)
    func actionSelectModalDidClose(_ modal: ActionSelectModal)
}

class ActionSelectModal: SKNode {
    weak var delegate: ActionSelectModalDelegate?

    // Colors
    private let overlayColor = SKColor.black.withAlphaComponent(0.4)
    private let modalBackground = SKColor(red: 0.82, green: 0.82, blue: 0.78, alpha: 1.0)
    private let cardColor = SKColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0)
    private let selectedCardColor = SKColor(red: 0.78, green: 0.82, blue: 0.75, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let disabledColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)

    private let category: ActionCategory
    private let sceneSize: CGSize
    private var actionCards: [SKNode] = []
    private var actions: [GameAction] = []

    // Category titles
    private var categoryTitle: String {
        switch category {
        case .feed: return "Select Fuel"
        case .work: return "Select Grind"
        case .selfCare: return "Select Recharge"
        case .social: return "Select Hangout"
        }
    }

    init(size: CGSize, category: ActionCategory) {
        self.sceneSize = size
        self.category = category
        super.init()

        self.actions = ActionCatalog.shared.actions(for: category)
        setupModal()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupModal() {
        // Overlay
        let overlay = SKSpriteNode(color: overlayColor, size: sceneSize)
        overlay.position = .zero
        overlay.zPosition = 0
        overlay.name = "overlay"
        addChild(overlay)

        // Modal container
        let modalWidth = sceneSize.width - 30
        let modalHeight: CGFloat = 540

        let modal = SKNode()
        modal.position = CGPoint(x: 0, y: 40)
        modal.zPosition = 1
        modal.name = "modalContainer"
        addChild(modal)

        // Modal background
        let bg = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight), cornerRadius: 16)
        bg.fillColor = modalBackground
        bg.strokeColor = .clear
        modal.addChild(bg)

        // Title
        let title = SKLabelNode(text: categoryTitle)
        title.fontName = "Menlo-Bold"
        title.fontSize = 22
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -modalWidth/2 + 20, y: modalHeight/2 - 45)
        modal.addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: modalWidth/2 - 30, y: modalHeight/2 - 40)
        closeButton.name = "closeButton"
        modal.addChild(closeButton)

        // Action grid
        setupActionGrid(in: modal, modalWidth: modalWidth, modalHeight: modalHeight)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 6)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        let x = SKLabelNode(text: "✕")
        x.fontName = "Menlo-Bold"
        x.fontSize = 18
        x.fontColor = textColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    private func setupActionGrid(in modal: SKNode, modalWidth: CGFloat, modalHeight: CGFloat) {
        let cols = 3
        let cardWidth: CGFloat = (modalWidth - 50) / 3
        let cardHeight: CGFloat = 140
        let spacingX: CGFloat = 8
        let spacingY: CGFloat = 10

        let gridWidth = CGFloat(cols) * cardWidth + CGFloat(cols - 1) * spacingX
        let startX = -gridWidth / 2 + cardWidth / 2
        let startY = modalHeight / 2 - 90 - cardHeight / 2

        for (index, action) in actions.enumerated() {
            let row = index / cols
            let col = index % cols

            let card = createActionCard(action: action, size: CGSize(width: cardWidth, height: cardHeight))
            card.position = CGPoint(
                x: startX + CGFloat(col) * (cardWidth + spacingX),
                y: startY - CGFloat(row) * (cardHeight + spacingY)
            )
            card.name = "action_\(action.id)"
            modal.addChild(card)
            actionCards.append(card)
        }
    }

    private func createActionCard(action: GameAction, size: CGSize) -> SKNode {
        let card = SKNode()

        let canPerform = GameManager.shared.canPerformAction(action)
        let cooldown = GameManager.shared.cooldownRemaining(for: action)
        let isOnCooldown = cooldown > 0

        // Card background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = cardColor
        bg.strokeColor = .clear
        bg.name = "cardBg"
        card.addChild(bg)

        // Effect indicator (top right)
        let effectEmoji = getEffectIndicator(for: action)
        if let emoji = effectEmoji {
            let indicator = SKLabelNode(text: emoji)
            indicator.fontSize = 16
            indicator.position = CGPoint(x: size.width/2 - 18, y: size.height/2 - 18)
            card.addChild(indicator)
        }

        // Action icon or emoji (large, center)
        if let iconIndex = action.foodIconIndex {
            // Use food sprite sheet icon
            let iconSprite = createFoodIcon(index: iconIndex, size: 55)
            iconSprite.position = CGPoint(x: 0, y: 15)
            if !canPerform || isOnCooldown {
                iconSprite.alpha = 0.4
            }
            card.addChild(iconSprite)
        } else {
            // Use emoji
            let emojiLabel = SKLabelNode(text: action.emoji)
            emojiLabel.fontSize = 50
            emojiLabel.position = CGPoint(x: 0, y: 15)
            emojiLabel.verticalAlignmentMode = .center
            if !canPerform || isOnCooldown {
                emojiLabel.alpha = 0.4
            }
            card.addChild(emojiLabel)
        }

        // Cooldown overlay
        if isOnCooldown {
            let cooldownBg = SKShapeNode(rectOf: CGSize(width: size.width - 10, height: size.height - 40), cornerRadius: 8)
            cooldownBg.fillColor = SKColor.black.withAlphaComponent(0.3)
            cooldownBg.strokeColor = .clear
            cooldownBg.position = CGPoint(x: 0, y: 10)
            card.addChild(cooldownBg)

            let cooldownLabel = SKLabelNode(text: "\(Int(cooldown))s")
            cooldownLabel.fontName = "Menlo-Bold"
            cooldownLabel.fontSize = 14
            cooldownLabel.fontColor = .white
            cooldownLabel.position = CGPoint(x: 0, y: 15)
            cooldownLabel.verticalAlignmentMode = .center
            card.addChild(cooldownLabel)
        }

        // Name and quantity/energy cost
        let nameText = action.name
        let energyCost = action.effects[.energy] ?? 0
        let costText = energyCost < 0 ? "⚡\(abs(energyCost))" : ""

        let nameLabel = SKLabelNode(text: nameText)
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 10
        nameLabel.fontColor = canPerform ? textColor : disabledColor
        nameLabel.position = CGPoint(x: 0, y: -size.height/2 + 28)
        card.addChild(nameLabel)

        if !costText.isEmpty {
            let costLabel = SKLabelNode(text: costText)
            costLabel.fontName = "Menlo"
            costLabel.fontSize = 9
            costLabel.fontColor = canPerform ? textColor.withAlphaComponent(0.6) : disabledColor
            costLabel.position = CGPoint(x: 0, y: -size.height/2 + 14)
            card.addChild(costLabel)
        }

        return card
    }

    private func createFoodIcon(index: Int, size: CGFloat) -> SKSpriteNode {
        // Food sprite sheet is 3 columns x 2 rows
        // Index: 0=energy drink, 1=shake, 2=ramen, 3=bag, 4=salad, 5=pizza
        let texture = SKTexture(imageNamed: "FoodIcons")

        // Calculate grid position
        let col = index % 3
        let row = index / 3

        // Each icon is roughly 1/3 width and 1/2 height of the sprite sheet
        let iconWidth: CGFloat = 1.0 / 3.0
        let iconHeight: CGFloat = 1.0 / 2.0

        // Create texture rect (in normalized coordinates, y is flipped)
        let rect = CGRect(
            x: CGFloat(col) * iconWidth,
            y: CGFloat(1 - row) * iconHeight - iconHeight,
            width: iconWidth,
            height: iconHeight
        )

        let croppedTexture = SKTexture(rect: rect, in: texture)
        croppedTexture.filteringMode = .nearest

        let sprite = SKSpriteNode(texture: croppedTexture)

        // Scale to desired size
        let scale = size / max(sprite.size.width, sprite.size.height)
        sprite.setScale(scale)

        return sprite
    }

    private func getEffectIndicator(for action: GameAction) -> String? {
        // Show primary effect as indicator
        if let health = action.effects[.health], health > 10 {
            return "❤️"
        }
        if let happiness = action.effects[.happiness], happiness > 15 {
            return "⭐"
        }
        if let social = action.effects[.social], social > 15 {
            return "👥"
        }
        if let burnout = action.effects[.burnout], burnout < -10 {
            return "🧘"
        }
        if let funding = action.effects[.funding], funding > 10 {
            return "💰"
        }
        if let product = action.effects[.product], product > 15 {
            return "🚀"
        }
        if action.triggersMinigame != nil {
            return "🎮"
        }
        return nil
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint) -> Bool {
        let localLocation = convert(location, from: parent!)

        // Check modal container
        if let modal = childNode(withName: "modalContainer") {
            // Check close button
            if let closeButton = modal.childNode(withName: "closeButton"),
               closeButton.contains(convert(localLocation, to: modal)) {
                animatePress(closeButton)
                dismiss()
                return true
            }

            // Check action cards
            for card in actionCards {
                if let name = card.name, name.hasPrefix("action_"),
                   card.contains(convert(localLocation, to: modal)) {
                    let actionId = String(name.dropFirst("action_".count))
                    if let action = actions.first(where: { $0.id == actionId }) {
                        handleActionTap(action, card: card)
                        return true
                    }
                }
            }
        }

        // Check overlay tap to dismiss
        if let overlay = childNode(withName: "overlay"), overlay.contains(localLocation) {
            dismiss()
            return true
        }

        return false
    }

    private func handleActionTap(_ action: GameAction, card: SKNode) {
        let canPerform = GameManager.shared.canPerformAction(action)

        guard canPerform else {
            // Shake if can't perform
            shakeCard(card)
            return
        }

        // Animate selection
        animatePress(card)

        // Notify delegate
        delegate?.actionSelectModal(self, didSelect: action)

        // Dismiss after short delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.run { [weak self] in
                self?.dismiss()
            }
        ]))
    }

    private func shakeCard(_ card: SKNode) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        card.run(shake)
    }

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }

    func dismiss() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        run(fadeOut) { [weak self] in
            guard let self = self else { return }
            self.delegate?.actionSelectModalDidClose(self)
            self.removeFromParent()
        }
    }

    func show() {
        alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        run(fadeIn)
    }
}
