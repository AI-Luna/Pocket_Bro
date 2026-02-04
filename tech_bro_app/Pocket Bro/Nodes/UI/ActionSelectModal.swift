//
//  ActionSelectModal.swift
//  Pocket Bro

import SpriteKit

protocol ActionSelectModalDelegate: AnyObject {
    func actionSelectModal(_ modal: ActionSelectModal, didSelect action: GameAction)
    func actionSelectModalDidClose(_ modal: ActionSelectModal)
    func actionSelectModalDidSelectPremium(_ modal: ActionSelectModal)
}

class ActionSelectModal: SKNode {
    weak var delegate: ActionSelectModalDelegate?

    // Colors - Synthwave theme
    private let overlayColor = SKColor.black.withAlphaComponent(0.5)
    private let modalBackground = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0) // Deep purple
    private let cardColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
    private let selectedCardColor = SKColor(red: 0.35, green: 0.22, blue: 0.55, alpha: 1.0)
    private let textColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) // Bright cyan
    private let secondaryTextColor = SKColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 1.0)
    private let accentColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Hot pink
    private let disabledColor = SKColor(red: 0.5, green: 0.45, blue: 0.6, alpha: 1.0)

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
        let modalHeight: CGFloat = 450

        let modal = SKNode()
        modal.position = CGPoint(x: 0, y: 0)
        modal.zPosition = 1
        modal.name = "modalContainer"
        addChild(modal)

        // Modal background with pixelated border effect
        let bg = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight), cornerRadius: 8)
        bg.fillColor = modalBackground
        bg.strokeColor = .clear
        bg.lineWidth = 0
        modal.addChild(bg)

        // Pixelated border - outer edge
        let borderOuter = SKShapeNode(rectOf: CGSize(width: modalWidth + 6, height: modalHeight + 6), cornerRadius: 10)
        borderOuter.fillColor = .clear
        borderOuter.strokeColor = textColor.withAlphaComponent(0.5)
        borderOuter.lineWidth = 3
        borderOuter.zPosition = -1
        modal.addChild(borderOuter)

        // Pixelated border - inner highlight
        let borderInner = SKShapeNode(rectOf: CGSize(width: modalWidth - 4, height: modalHeight - 4), cornerRadius: 6)
        borderInner.fillColor = .clear
        borderInner.strokeColor = textColor.withAlphaComponent(0.15)
        borderInner.lineWidth = 2
        modal.addChild(borderInner)

        // Title
        let title = SKLabelNode(text: categoryTitle)
        title.fontName = PixelFont.name
        title.fontSize = 24
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -modalWidth/2 + 25, y: modalHeight/2 - 50)
        modal.addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: modalWidth/2 - 35, y: modalHeight/2 - 45)
        closeButton.name = "closeButton"
        modal.addChild(closeButton)

        // Action grid
        setupActionGrid(in: modal, modalWidth: modalWidth, modalHeight: modalHeight)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        // Pixelated button style
        let bg = SKShapeNode(rectOf: CGSize(width: 38, height: 38), cornerRadius: 4)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.4)
        bg.lineWidth = 2
        button.addChild(bg)

        // Inner highlight for depth
        let highlight = SKShapeNode(rectOf: CGSize(width: 34, height: 34), cornerRadius: 3)
        highlight.fillColor = .clear
        highlight.strokeColor = textColor.withAlphaComponent(0.15)
        highlight.lineWidth = 1
        button.addChild(highlight)

        let x = SKLabelNode(text: "X")
        x.fontName = PixelFont.name
        x.fontSize = 18
        x.fontColor = textColor
        x.verticalAlignmentMode = .center
        x.horizontalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    private func setupActionGrid(in modal: SKNode, modalWidth: CGFloat, modalHeight: CGFloat) {
        let cols = 3
        let cardSize: CGFloat = (modalWidth - 60) / 3  // Square cards
        let spacingX: CGFloat = 10
        let spacingY: CGFloat = 12

        let gridWidth = CGFloat(cols) * cardSize + CGFloat(cols - 1) * spacingX
        let startX = -gridWidth / 2 + cardSize / 2
        let startY = modalHeight / 2 - 95 - cardSize / 2

        // Text sits below the card, so account for text height
        let textHeight: CGFloat = 35

        for (index, action) in actions.enumerated() {
            let row = index / cols
            let col = index % cols

            let cardContainer = SKNode()
            cardContainer.position = CGPoint(
                x: startX + CGFloat(col) * (cardSize + spacingX),
                y: startY - CGFloat(row) * (cardSize + spacingY + textHeight)
            )
            cardContainer.name = "action_\(action.id)"
            modal.addChild(cardContainer)

            // Create the card (image cell only)
            let card = createActionCard(action: action, size: cardSize)
            cardContainer.addChild(card)

            // Create text label below the card
            let textNode = createActionLabel(action: action, cardSize: cardSize)
            textNode.position = CGPoint(x: 0, y: -cardSize/2 - 18)
            cardContainer.addChild(textNode)

            actionCards.append(cardContainer)
        }
    }

    private func createActionCard(action: GameAction, size: CGFloat) -> SKNode {
        let card = SKNode()

        let canPerform = GameManager.shared.canPerformAction(action)
        let cooldown = GameManager.shared.cooldownRemaining(for: action)
        let isOnCooldown = cooldown > 0

        // Card background - square with pixelated corners
        // Use faint pink for premium cells
        let bg = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 6)
        if action.isPremium {
            bg.fillColor = SKColor(red: 0.45, green: 0.20, blue: 0.40, alpha: 1.0)  // Faint pink/purple tint
            bg.strokeColor = accentColor.withAlphaComponent(0.3)  // Pink border for premium
        } else {
            bg.fillColor = cardColor
            bg.strokeColor = textColor.withAlphaComponent(0.2)
        }
        bg.lineWidth = 2
        bg.name = "cardBg"
        bg.zPosition = 0
        card.addChild(bg)

        // Icon - centered in the card, preserving aspect ratio
        let iconTargetSize = size * 0.75  // Target size for scaling
        var iconSprite: SKSpriteNode?
        var iconYOffset: CGFloat = 0  // Offset to correct for uncentered sprites

        if let iconIndex = action.foodIconIndex {
            iconSprite = createIconFromSheet(sheetName: "FoodIcons", index: iconIndex, targetSize: iconTargetSize)
        } else if let iconIndex = action.socialIconIndex {
            iconSprite = createIconFromSheet(sheetName: "SocialIcons", index: iconIndex, targetSize: iconTargetSize)
        } else if let iconIndex = action.workIconIndex {
            iconSprite = createIconFromSheet(sheetName: "WorkIcons", index: iconIndex, targetSize: iconTargetSize)
            // Work sprite sheet - icons sit slightly high, move them down
            iconYOffset = -5
        } else if let iconIndex = action.selfCareIconIndex {
            iconSprite = createIconFromSheet(sheetName: "SelfCareIcons", index: iconIndex, targetSize: iconTargetSize)
            // SelfCare sprite sheet has uneven icon positioning - apply corrections
            // Index: 0=sleep mask, 1=lotus, 2=mountain, 3=dumbbell, 4=couch, 5=bed
            let selfCareOffsets: [Int: CGFloat] = [
                0: -5,   // Sleep mask - move down
                1: -3,   // Lotus - move down slightly
                2: -3,   // Mountain - move down slightly
                3: 0,    // Dumbbell - centered
                4: -5,   // Couch/therapy - move down
                5: -3    // Bed - move down slightly
            ]
            iconYOffset = selfCareOffsets[iconIndex] ?? 0
        }

        if let sprite = iconSprite {
            // Center icon exactly in the middle of the card with offset correction
            sprite.position = CGPoint(x: 0, y: iconYOffset)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)  // Ensure centered anchor
            sprite.zPosition = 2
            if !canPerform {
                sprite.alpha = 0.4
            }
            card.addChild(sprite)
        } else {
            // Fallback to emoji
            let emojiLabel = SKLabelNode(text: action.emoji)
            emojiLabel.fontSize = iconTargetSize * 0.6
            emojiLabel.position = CGPoint(x: 0, y: 0)
            emojiLabel.verticalAlignmentMode = .center
            emojiLabel.horizontalAlignmentMode = .center
            emojiLabel.zPosition = 2
            if !canPerform {
                emojiLabel.alpha = 0.4
            }
            card.addChild(emojiLabel)
        }

        // Premium crown indicator (skip for self-care/recharge)
        if action.isPremium && category != .selfCare {
            let crown = SKLabelNode(text: "👑")
            crown.fontSize = 18
            crown.position = CGPoint(x: 0, y: 0)  // Centered in cell
            crown.verticalAlignmentMode = .center
            crown.horizontalAlignmentMode = .center
            crown.zPosition = 5
            card.addChild(crown)
        }

        // Cooldown overlay
        if isOnCooldown {
            let cooldownBg = SKShapeNode(rectOf: CGSize(width: size - 4, height: size - 4), cornerRadius: 12)
            cooldownBg.fillColor = SKColor.black.withAlphaComponent(0.5)
            cooldownBg.strokeColor = .clear
            cooldownBg.zPosition = 3
            card.addChild(cooldownBg)

            let cooldownLabel = SKLabelNode(text: "\(Int(cooldown))s")
            cooldownLabel.fontName = PixelFont.name
            cooldownLabel.fontSize = 18
            cooldownLabel.fontColor = .white
            cooldownLabel.position = CGPoint(x: 0, y: 0)
            cooldownLabel.verticalAlignmentMode = .center
            cooldownLabel.horizontalAlignmentMode = .center
            cooldownLabel.zPosition = 4
            card.addChild(cooldownLabel)
        }

        return card
    }

    private func createActionLabel(action: GameAction, cardSize: CGFloat) -> SKNode {
        let labelContainer = SKNode()

        let canPerform = GameManager.shared.canPerformAction(action)

        // Action name - larger, more readable
        let nameLabel = SKLabelNode(text: action.name)
        nameLabel.fontName = PixelFont.name
        nameLabel.fontSize = 12
        nameLabel.fontColor = canPerform ? secondaryTextColor : disabledColor
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .top
        nameLabel.position = CGPoint(x: 0, y: 0)

        // Wrap long names if needed
        if action.name.count > 14 {
            nameLabel.fontSize = 10
        }

        labelContainer.addChild(nameLabel)

        return labelContainer
    }

    private func createIconFromSheet(sheetName: String, index: Int, targetSize: CGFloat) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: sheetName)

        // Calculate grid position (3 columns x 2 rows)
        let col = index % 3
        let row = index / 3

        let iconWidth: CGFloat = 1.0 / 3.0
        let iconHeight: CGFloat = 1.0 / 2.0

        let rectY = 1.0 - CGFloat(row + 1) * iconHeight
        let rect = CGRect(
            x: CGFloat(col) * iconWidth,
            y: rectY,
            width: iconWidth,
            height: iconHeight
        )

        let croppedTexture = SKTexture(rect: rect, in: texture)
        croppedTexture.filteringMode = .nearest  // Pixel art style

        let sprite = SKSpriteNode(texture: croppedTexture)

        // Scale proportionally - fit within targetSize while preserving aspect ratio
        let originalWidth = texture.size().width * iconWidth
        let originalHeight = texture.size().height * iconHeight
        
        // Calculate scale factor to fit within targetSize
        let scale = targetSize / max(originalWidth, originalHeight)
        
        sprite.size = CGSize(width: originalWidth * scale, height: originalHeight * scale)

        return sprite
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
        // Check if premium action - open paywall instead
        if action.isPremium {
            animatePress(card)
            delegate?.actionSelectModalDidSelectPremium(self)
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.run { [weak self] in
                    self?.dismiss()
                }
            ]))
            return
        }

        let canPerform = GameManager.shared.canPerformAction(action)

        guard canPerform else {
            shakeCard(card)
            return
        }

        animatePress(card)
        delegate?.actionSelectModal(self, didSelect: action)

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
