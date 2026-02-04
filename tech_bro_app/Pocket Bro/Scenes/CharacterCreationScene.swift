//
//  CharacterCreationScene.swift
//  Pocket Bro
//

import SpriteKit

class CharacterCreationScene: BaseGameScene {
    private var titleLabel: SKLabelNode!
    private var nameLabel: SKLabelNode!
    private var nameField: String = ""
    private var archetypeButtons: [PixelButtonNode] = []
    private var selectedArchetype: Archetype = .bro
    private var previewSprite: BroSpriteNode!
    private var startButton: PixelButtonNode!
    private var cursorVisible = true
    private var cursorTimer: Timer?

    override func setupScene() {
        setupTitle()
        setupNameInput()
        setupArchetypeSelection()
        setupPreview()
        setupStartButton()
        startCursorBlink()
    }

    private func setupTitle() {
        titleLabel = createLabel(text: "Create Your Tech Bro", fontSize: 28)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 60)
        addChild(titleLabel)

        let subtitleLabel = createLabel(text: "Begin your startup journey", fontSize: 14)
        subtitleLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: titleLabel.position.y - 30)
        addChild(subtitleLabel)
    }

    private func setupNameInput() {
        let promptLabel = createLabel(text: "Enter Name:", fontSize: 16)
        promptLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 140)
        addChild(promptLabel)

        // Name field background
        let fieldBg = SKSpriteNode(color: SKColor(white: 0.15, alpha: 1.0),
                                    size: CGSize(width: 250, height: 44))
        fieldBg.position = CGPoint(x: size.width / 2, y: promptLabel.position.y - 40)
        addChild(fieldBg)

        nameLabel = createLabel(text: "_", fontSize: 20)
        nameLabel.position = fieldBg.position
        addChild(nameLabel)

        // Keyboard hint
        let hintLabel = createLabel(text: "Tap to type", fontSize: 12)
        hintLabel.fontColor = SKColor(white: 0.4, alpha: 1.0)
        hintLabel.position = CGPoint(x: size.width / 2, y: fieldBg.position.y - 35)
        hintLabel.name = "hint"
        addChild(hintLabel)
    }

    private func setupArchetypeSelection() {
        let labelY = size.height / 2 + 40

        let selectLabel = createLabel(text: "Choose Your Character:", fontSize: 16)
        selectLabel.position = CGPoint(x: size.width / 2, y: labelY)
        addChild(selectLabel)

        let archetypes = Archetype.allCases
        let buttonWidth: CGFloat = 100
        let spacing: CGFloat = 15
        let totalWidth = CGFloat(archetypes.count) * buttonWidth + CGFloat(archetypes.count - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + buttonWidth / 2

        for (index, archetype) in archetypes.enumerated() {
            let emoji: String
            switch archetype {
            case .bro: emoji = "👨‍💻"
            case .gal: emoji = "👩‍💻"
            case .nonBinary: emoji = "🧑‍💻"
            }

            let button = PixelButtonNode(text: archetype.rawValue, icon: emoji,
                                          size: CGSize(width: buttonWidth, height: 50))
            button.position = CGPoint(x: startX + CGFloat(index) * (buttonWidth + spacing),
                                       y: labelY - 50)

            button.onTap = { [weak self] in
                self?.selectArchetype(archetype)
            }

            addChild(button)
            archetypeButtons.append(button)
        }

        selectArchetype(.bro)
    }

    private func selectArchetype(_ archetype: Archetype) {
        selectedArchetype = archetype
        previewSprite?.archetype = archetype

        // Update button appearances
        for (index, button) in archetypeButtons.enumerated() {
            let isSelected = Archetype.allCases[index] == archetype
            button.setScale(isSelected ? 1.1 : 1.0)
        }
    }

    private func setupPreview() {
        previewSprite = BroSpriteNode()
        previewSprite.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        previewSprite.setScale(1.5)
        addChild(previewSprite)
    }

    private func setupStartButton() {
        startButton = PixelButtonNode(text: "Start Journey 🚀", size: CGSize(width: 200, height: 50))
        startButton.position = CGPoint(x: size.width / 2, y: safeAreaInsets().bottom + 80)
        startButton.setEnabled(false)

        startButton.onTap = { [weak self] in
            self?.startGame()
        }

        addChild(startButton)
    }

    private func startCursorBlink() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.cursorVisible.toggle()
            self?.updateNameDisplay()
        }
    }

    private func updateNameDisplay() {
        let cursor = cursorVisible ? "_" : " "
        nameLabel.text = nameField.isEmpty ? cursor : nameField + cursor

        startButton.setEnabled(!nameField.isEmpty)

        if let hint = childNode(withName: "hint") as? SKLabelNode {
            hint.isHidden = !nameField.isEmpty
        }
    }

    private func startGame() {
        guard !nameField.isEmpty else { return }

        cursorTimer?.invalidate()

        GameManager.shared.newGame(name: nameField, archetype: selectedArchetype)

        // Animate transition
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        run(fadeOut) { [weak self] in
            self?.sceneManager?.presentScene(.mainGame)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Show keyboard when tapping name field area
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nameFieldArea = CGRect(x: size.width / 2 - 125,
                                        y: size.height - safeAreaInsets().top - 200,
                                        width: 250, height: 60)
            if nameFieldArea.contains(location) {
                showKeyboard()
            }
        }
    }

    private func showKeyboard() {
        // In a real implementation, this would present a UITextField
        // For now, we'll use a simple approach with predefined names
        let names = ["Alex", "Jordan", "Sam", "Casey", "Riley", "Morgan", "Taylor", "Quinn"]
        nameField = names.randomElement() ?? "Founder"
        updateNameDisplay()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        cursorTimer?.invalidate()
    }
}
