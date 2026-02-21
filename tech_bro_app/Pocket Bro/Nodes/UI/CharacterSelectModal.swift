//
//  CharacterSelectModal.swift
//  Pocket Bro
//

import SpriteKit

protocol CharacterSelectModalDelegate: AnyObject {
    func characterSelectModal(_ modal: CharacterSelectModal, didSelect archetype: Archetype)
    func characterSelectModalDidClose(_ modal: CharacterSelectModal)
}

class CharacterSelectModal: SKNode {
    weak var delegate: CharacterSelectModalDelegate?

    // Colors
    private let overlayColor = SKColor.black.withAlphaComponent(0.4)
    private let modalBackground = SKColor(red: 0.82, green: 0.82, blue: 0.78, alpha: 1.0)
    private let cardColor = SKColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0)
    private let selectedCardColor = SKColor(red: 0.78, green: 0.82, blue: 0.75, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let premiumColor = SKColor(red: 0.95, green: 0.85, blue: 0.3, alpha: 1.0)

    private var selectedArchetype: Archetype
    private let sceneSize: CGSize

    // Character data
    private struct CharacterData {
        let id: String
        let name: String
        let emoji: String
        let archetype: Archetype?
        let isPremium: Bool
        let isLocked: Bool
    }

    private let characters: [CharacterData] = [
        // Row 1 - Free characters
        CharacterData(id: "bro", name: "Tech Bro", emoji: "👨‍💻", archetype: .bro, isPremium: false, isLocked: false),
        CharacterData(id: "gal", name: "Tech Gal", emoji: "👩‍💻", archetype: .gal, isPremium: false, isLocked: false),

        // Row 2 - Premium characters
        CharacterData(id: "hacker", name: "Hacker", emoji: "🥷", archetype: .bro, isPremium: true, isLocked: false),
        CharacterData(id: "designer", name: "Designer", emoji: "🎨", archetype: .gal, isPremium: true, isLocked: false),
        CharacterData(id: "pm", name: "PM", emoji: "📋", archetype: .bro, isPremium: true, isLocked: false),

        // Row 3 - Locked/Coming soon
        CharacterData(id: "vc", name: "VC", emoji: "💰", archetype: nil, isPremium: true, isLocked: true),
        CharacterData(id: "ceo", name: "CEO", emoji: "?", archetype: nil, isPremium: true, isLocked: true),
        CharacterData(id: "founder", name: "Unicorn", emoji: "?", archetype: nil, isPremium: true, isLocked: true)
    ]

    private var characterCards: [SKNode] = []

    init(size: CGSize, currentArchetype: Archetype) {
        self.sceneSize = size
        self.selectedArchetype = currentArchetype
        super.init()
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

        // Modal container - centered on screen
        let modalWidth = sceneSize.width - 30
        let modalHeight: CGFloat = 420

        let modal = SKNode()
        modal.position = CGPoint(x: 0, y: 0) // Centered
        modal.zPosition = 1
        addChild(modal)

        // Modal background with pixelated border
        let bg = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight), cornerRadius: 16)
        bg.fillColor = modalBackground
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 3
        modal.addChild(bg)

        // Title - using PixelFont
        let title = SKLabelNode(text: "Change Character")
        title.fontName = PixelFont.name
        title.fontSize = PixelFont.title
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -modalWidth/2 + 20, y: modalHeight/2 - 45)
        modal.addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: modalWidth/2 - 30, y: modalHeight/2 - 40)
        closeButton.name = "closeButton"
        modal.addChild(closeButton)

        // Character grid
        setupCharacterGrid(in: modal, modalWidth: modalWidth, modalHeight: modalHeight)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 6)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        // Pixelated X using font
        let x = SKLabelNode(text: "X")
        x.fontName = PixelFont.name
        x.fontSize = 20
        x.fontColor = textColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    private func setupCharacterGrid(in modal: SKNode, modalWidth: CGFloat, modalHeight: CGFloat) {
        let cols = 3
        let rows = 3
        let cardWidth: CGFloat = (modalWidth - 60) / 3
        let cardHeight: CGFloat = 115
        let spacingX: CGFloat = 10
        let spacingY: CGFloat = 10

        let gridWidth = CGFloat(cols) * cardWidth + CGFloat(cols - 1) * spacingX
        _ = CGFloat(rows) * cardHeight + CGFloat(rows - 1) * spacingY // gridHeight unused
        let startX = -gridWidth / 2 + cardWidth / 2
        let startY = modalHeight / 2 - 90 - cardHeight / 2

        for (index, character) in characters.enumerated() {
            let row = index / cols
            let col = index % cols

            let card = createCharacterCard(character: character, size: CGSize(width: cardWidth, height: cardHeight))
            card.position = CGPoint(
                x: startX + CGFloat(col) * (cardWidth + spacingX),
                y: startY - CGFloat(row) * (cardHeight + spacingY)
            )
            card.name = "character_\(character.id)"
            modal.addChild(card)
            characterCards.append(card)
        }
    }

    private func createCharacterCard(character: CharacterData, size: CGSize) -> SKNode {
        let card = SKNode()

        // Determine if selected
        let isSelected = character.archetype == selectedArchetype && !character.isLocked

        // Card background with pixelated border
        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = isSelected ? selectedCardColor : cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.2)
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        // Premium indicator
        if character.isPremium && !character.isLocked {
            let gem = SKLabelNode(text: "💎")
            gem.fontSize = 16
            gem.position = CGPoint(x: size.width/2 - 18, y: size.height/2 - 18)
            card.addChild(gem)
        }

        // Character emoji or locked state
        if character.isLocked {
            // Locked overlay
            let lockEmoji = SKLabelNode(text: "?")
            lockEmoji.fontName = "Menlo-Bold"
            lockEmoji.fontSize = 40
            lockEmoji.fontColor = character.id == "ceo" ? SKColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0) :
                                   character.id == "founder" ? SKColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0) :
                                   textColor.withAlphaComponent(0.3)
            lockEmoji.position = CGPoint(x: 0, y: 15)
            lockEmoji.verticalAlignmentMode = .center
            card.addChild(lockEmoji)

            // Faded placeholder
            let placeholder = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 8)
            placeholder.fillColor = textColor.withAlphaComponent(0.05)
            placeholder.strokeColor = .clear
            placeholder.position = CGPoint(x: 0, y: 15)
            placeholder.zPosition = -1
            card.addChild(placeholder)
        } else {
            let emoji = SKLabelNode(text: character.emoji)
            emoji.fontSize = 50
            emoji.position = CGPoint(x: 0, y: 15)
            emoji.verticalAlignmentMode = .center
            card.addChild(emoji)
        }

        // Name label
        let nameLabel = SKLabelNode(text: character.name)
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 11
        nameLabel.fontColor = character.isLocked ? textColor.withAlphaComponent(0.5) : textColor
        nameLabel.position = CGPoint(x: 0, y: -size.height/2 + 18)
        card.addChild(nameLabel)

        return card
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint) -> Bool {
        let localLocation = convert(location, from: parent!)

        // Check close button
        for child in children {
            for node in child.children {
                if node.name == "closeButton" && node.contains(convert(localLocation, to: child)) {
                    animatePress(node)
                    dismiss()
                    return true
                }
            }
        }

        // Check character cards
        for card in characterCards {
            if let name = card.name, name.hasPrefix("character_"),
               card.contains(convert(localLocation, to: card.parent!)) {
                let id = String(name.dropFirst("character_".count))
                if let character = characters.first(where: { $0.id == id }) {
                    handleCharacterTap(character, card: card)
                    return true
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

    private func handleCharacterTap(_ character: CharacterData, card: SKNode) {
        guard !character.isLocked else {
            // Show locked animation
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            card.run(shake)
            return
        }

        guard !character.isPremium || PurchaseManager.shared.isProActive else {
            // Show shake + coming soon overlay
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            card.run(shake)
            showComingSoon()
            return
        }

        guard let archetype = character.archetype else { return }

        // Update selection
        selectedArchetype = archetype

        // Update card backgrounds
        for (index, c) in characters.enumerated() {
            if let cardBg = characterCards[index].childNode(withName: "cardBg") as? SKShapeNode {
                let isSelected = c.archetype == selectedArchetype && !c.isLocked
                cardBg.fillColor = isSelected ? selectedCardColor : cardColor
            }
        }

        // Animate selection
        animatePress(card)

        // Notify delegate
        delegate?.characterSelectModal(self, didSelect: archetype)
    }

    private func showComingSoon() {
        guard let scene = self.scene else { return }
        ComingSoonOverlay(sceneSize: scene.size).show(in: scene)
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
            self.delegate?.characterSelectModalDidClose(self)
            self.removeFromParent()
        }
    }

    func show() {
        alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        run(fadeIn)
    }
}
