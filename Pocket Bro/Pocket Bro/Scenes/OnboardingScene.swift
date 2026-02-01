//
//  OnboardingScene.swift
//  Pocket Bro
//

import SpriteKit
import UserNotifications

enum OnboardingStep: Int, CaseIterable {
    case chooseFounder = 0
    case nameFounder = 1
    case chooseLocation = 2
    case notifications = 3
}

enum StartupLocation: String, CaseIterable {
    case garage = "Garage"
    case parentBasement = "Parent's Basement"
    case coffeeShop = "Coffee Shop"
    case weWork = "WeWork"
    case sfApartment = "SF Studio"
    case hacker = "Hacker House"

    var emoji: String {
        switch self {
        case .garage: return "🏠"
        case .parentBasement: return "🏡"
        case .coffeeShop: return "☕"
        case .weWork: return "🏢"
        case .sfApartment: return "🌉"
        case .hacker: return "💻"
        }
    }

    var color: SKColor {
        switch self {
        case .garage: return SKColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0)
        case .parentBasement: return SKColor(red: 0.5, green: 0.6, blue: 0.5, alpha: 1.0)
        case .coffeeShop: return SKColor(red: 0.6, green: 0.4, blue: 0.3, alpha: 1.0)
        case .weWork: return SKColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
        case .sfApartment: return SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0)
        case .hacker: return SKColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        }
    }
}

class OnboardingScene: SKScene {
    weak var sceneManager: SceneManager?

    // Onboarding state
    private var currentStep: OnboardingStep = .chooseFounder
    private var selectedArchetype: Archetype = .bro
    private var selectedLocation: StartupLocation = .garage
    private var founderName: String = ""

    // UI Colors - warm beige theme
    private let backgroundColor_ = SKColor(red: 0.96, green: 0.91, blue: 0.82, alpha: 1.0)
    private let cardColor = SKColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0)
    private let accentColor = SKColor(red: 1.0, green: 0.55, blue: 0.25, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0)
    private let selectedBorderColor = SKColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)

    // UI Elements
    private var contentNode: SKNode!
    private var nextButton: SKNode!
    private var titleLabel: SKLabelNode!

    // Selection tracking
    private var founderCards: [SKNode] = []
    private var locationCards: [SKNode] = []

    init(size: CGSize, sceneManager: SceneManager) {
        self.sceneManager = sceneManager
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = backgroundColor_
        setupNextButton()
        showStep(currentStep)
    }

    // MARK: - Setup

    private func setupNextButton() {
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 55

        let button = SKNode()
        button.name = "nextButton"
        button.position = CGPoint(x: size.width / 2, y: 100)
        button.zPosition = 100

        // Shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        shadow.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.15, alpha: 1.0)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        button.addChild(shadow)

        // Main button
        let bg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        bg.name = "nextButtonBg"
        button.addChild(bg)

        // Label
        let label = SKLabelNode(text: "Next")
        label.fontName = "Menlo-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)

        addChild(button)
        nextButton = button
    }

    private func showStep(_ step: OnboardingStep) {
        // Clear previous content
        contentNode?.removeFromParent()
        contentNode = SKNode()
        addChild(contentNode)

        founderCards.removeAll()
        locationCards.removeAll()

        switch step {
        case .chooseFounder:
            setupChooseFounderStep()
        case .nameFounder:
            setupNameFounderStep()
        case .chooseLocation:
            setupChooseLocationStep()
        case .notifications:
            setupNotificationsStep()
        }
    }

    // MARK: - Step 1: Choose Founder

    private func setupChooseFounderStep() {
        // Title
        titleLabel = createTitle("Choose your founder")
        contentNode.addChild(titleLabel)

        let archetypes = Archetype.allCases
        let cardSize = CGSize(width: 100, height: 120)
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(archetypes.count) * cardSize.width + CGFloat(archetypes.count - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + cardSize.width / 2
        let cardY = size.height / 2 + 30

        for (index, archetype) in archetypes.enumerated() {
            let card = createFounderCard(archetype: archetype, size: cardSize)
            card.position = CGPoint(x: startX + CGFloat(index) * (cardSize.width + spacing), y: cardY)
            card.name = "founder_\(archetype.rawValue)"
            contentNode.addChild(card)
            founderCards.append(card)
        }

        updateFounderSelection()
    }

    private func createFounderCard(archetype: Archetype, size: CGSize) -> SKNode {
        let card = SKNode()

        // Card background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        bg.fillColor = cardColor
        bg.strokeColor = .clear
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection border (hidden by default)
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 6, height: size.height + 6), cornerRadius: 14)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 3
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Character emoji
        let emoji: String
        switch archetype {
        case .bro: emoji = "👨‍💻"
        case .gal: emoji = "👩‍💻"
        case .nonBinary: emoji = "🧑‍💻"
        }

        let emojiLabel = SKLabelNode(text: emoji)
        emojiLabel.fontSize = 50
        emojiLabel.position = CGPoint(x: 0, y: 10)
        emojiLabel.verticalAlignmentMode = .center
        card.addChild(emojiLabel)

        // Name label
        let nameLabel = SKLabelNode(text: archetype.rawValue)
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 11
        nameLabel.fontColor = textColor
        nameLabel.position = CGPoint(x: 0, y: -size.height / 2 + 20)
        nameLabel.verticalAlignmentMode = .center
        card.addChild(nameLabel)

        return card
    }

    private func updateFounderSelection() {
        for card in founderCards {
            let isSelected = card.name == "founder_\(selectedArchetype.rawValue)"
            if let border = card.childNode(withName: "selectionBorder") {
                border.isHidden = !isSelected
            }
        }
    }

    // MARK: - Step 2: Name Founder

    private func setupNameFounderStep() {
        // Title
        titleLabel = createTitle("Name your founder")
        titleLabel.position.y = size.height / 2 + 20
        contentNode.addChild(titleLabel)

        // Character preview
        let emoji: String
        switch selectedArchetype {
        case .bro: emoji = "👨‍💻"
        case .gal: emoji = "👩‍💻"
        case .nonBinary: emoji = "🧑‍💻"
        }

        let preview = SKLabelNode(text: emoji)
        preview.fontSize = 80
        preview.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
        contentNode.addChild(preview)

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.4),
            SKAction.moveBy(x: 0, y: -8, duration: 0.4)
        ])
        preview.run(SKAction.repeatForever(bounce))

        // Text field background
        let fieldWidth: CGFloat = 250
        let fieldHeight: CGFloat = 50

        let fieldBg = SKShapeNode(rectOf: CGSize(width: fieldWidth, height: fieldHeight), cornerRadius: 8)
        fieldBg.fillColor = SKColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
        fieldBg.strokeColor = SKColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1.0)
        fieldBg.lineWidth = 2
        fieldBg.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        contentNode.addChild(fieldBg)

        // Name display
        let nameDisplay = SKLabelNode(text: founderName.isEmpty ? "Tap to enter name" : founderName)
        nameDisplay.fontName = "Menlo-Bold"
        nameDisplay.fontSize = 18
        nameDisplay.fontColor = founderName.isEmpty ? SKColor(white: 0.5, alpha: 1.0) : textColor
        nameDisplay.position = fieldBg.position
        nameDisplay.verticalAlignmentMode = .center
        nameDisplay.name = "nameDisplay"
        contentNode.addChild(nameDisplay)

        // Tap hint
        let tapHint = SKLabelNode(text: "Tap the field to type")
        tapHint.fontName = "Menlo"
        tapHint.fontSize = 12
        tapHint.fontColor = SKColor(white: 0.5, alpha: 1.0)
        tapHint.position = CGPoint(x: size.width / 2, y: size.height / 2 - 90)
        tapHint.name = "tapHint"
        contentNode.addChild(tapHint)
    }

    // MARK: - Step 3: Choose Location

    private func setupChooseLocationStep() {
        // Title with name
        let name = founderName.isEmpty ? "your founder" : founderName
        titleLabel = createTitle("Where will \(name)\nbuild their startup?")
        titleLabel.numberOfLines = 2
        titleLabel.position.y = size.height - 150
        contentNode.addChild(titleLabel)

        let locations = StartupLocation.allCases
        let cardSize = CGSize(width: 100, height: 100)
        let cols = 3
        let rows = 2
        let spacingX: CGFloat = 15
        let spacingY: CGFloat = 20

        let totalWidth = CGFloat(cols) * cardSize.width + CGFloat(cols - 1) * spacingX
        let totalHeight = CGFloat(rows) * cardSize.height + CGFloat(rows - 1) * spacingY
        let startX = (size.width - totalWidth) / 2 + cardSize.width / 2
        let startY = size.height / 2 + totalHeight / 2 - cardSize.height / 2 - 30

        for (index, location) in locations.enumerated() {
            let row = index / cols
            let col = index % cols

            let card = createLocationCard(location: location, size: cardSize)
            card.position = CGPoint(
                x: startX + CGFloat(col) * (cardSize.width + spacingX),
                y: startY - CGFloat(row) * (cardSize.height + spacingY)
            )
            card.name = "location_\(location.rawValue)"
            contentNode.addChild(card)
            locationCards.append(card)
        }

        updateLocationSelection()
    }

    private func createLocationCard(location: StartupLocation, size: CGSize) -> SKNode {
        let card = SKNode()

        // Card background with image area
        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = cardColor
        bg.strokeColor = .clear
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection border
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 6, height: size.height + 6), cornerRadius: 12)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 3
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Image area (colored placeholder)
        let imageSize = CGSize(width: size.width - 16, height: size.height - 36)
        let imageArea = SKShapeNode(rectOf: imageSize, cornerRadius: 6)
        imageArea.fillColor = location.color
        imageArea.strokeColor = .clear
        imageArea.position = CGPoint(x: 0, y: 10)
        card.addChild(imageArea)

        // Location emoji on image
        let emoji = SKLabelNode(text: location.emoji)
        emoji.fontSize = 30
        emoji.position = CGPoint(x: 0, y: 10)
        emoji.verticalAlignmentMode = .center
        card.addChild(emoji)

        // Label
        let label = SKLabelNode(text: location.rawValue)
        label.fontName = "Menlo-Bold"
        label.fontSize = 9
        label.fontColor = textColor
        label.position = CGPoint(x: 0, y: -size.height / 2 + 14)
        label.verticalAlignmentMode = .center
        card.addChild(label)

        return card
    }

    private func updateLocationSelection() {
        for card in locationCards {
            let isSelected = card.name == "location_\(selectedLocation.rawValue)"
            if let border = card.childNode(withName: "selectionBorder") {
                border.isHidden = !isSelected
            }
        }
    }

    // MARK: - Step 4: Notifications

    private func setupNotificationsStep() {
        let name = founderName.isEmpty ? "Your founder" : founderName

        // Mock notification banner at top
        let bannerHeight: CGFloat = 80
        let banner = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: bannerHeight), cornerRadius: 16)
        banner.fillColor = SKColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)
        banner.strokeColor = .clear
        banner.position = CGPoint(x: size.width / 2, y: size.height - 120)
        contentNode.addChild(banner)

        // App icon in banner
        let iconBg = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 8)
        iconBg.fillColor = accentColor
        iconBg.strokeColor = .clear
        iconBg.position = CGPoint(x: -size.width / 2 + 60, y: 0)
        banner.addChild(iconBg)

        let iconEmoji = SKLabelNode(text: "💼")
        iconEmoji.fontSize = 20
        iconEmoji.position = CGPoint(x: -size.width / 2 + 60, y: 0)
        iconEmoji.verticalAlignmentMode = .center
        banner.addChild(iconEmoji)

        // Banner text
        let appName = SKLabelNode(text: "Pocket Bro")
        appName.fontName = "Menlo-Bold"
        appName.fontSize = 14
        appName.fontColor = textColor
        appName.horizontalAlignmentMode = .left
        appName.position = CGPoint(x: -size.width / 2 + 95, y: 12)
        banner.addChild(appName)

        let notifTime = SKLabelNode(text: "now")
        notifTime.fontName = "Menlo"
        notifTime.fontSize = 12
        notifTime.fontColor = SKColor(white: 0.5, alpha: 1.0)
        notifTime.horizontalAlignmentMode = .right
        notifTime.position = CGPoint(x: size.width / 2 - 50, y: 12)
        banner.addChild(notifTime)

        let notifText = SKLabelNode(text: "🚀 \(name) needs your help!")
        notifText.fontName = "Menlo"
        notifText.fontSize = 13
        notifText.fontColor = textColor
        notifText.horizontalAlignmentMode = .left
        notifText.position = CGPoint(x: -size.width / 2 + 95, y: -12)
        banner.addChild(notifText)

        // Bell icon
        let bell = SKLabelNode(text: "🔔")
        bell.fontSize = 70
        bell.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        contentNode.addChild(bell)

        // Wiggle animation
        let wiggle = SKAction.sequence([
            SKAction.rotate(toAngle: 0.15, duration: 0.1),
            SKAction.rotate(toAngle: -0.15, duration: 0.1),
            SKAction.rotate(toAngle: 0.1, duration: 0.1),
            SKAction.rotate(toAngle: -0.1, duration: 0.1),
            SKAction.rotate(toAngle: 0, duration: 0.1),
            SKAction.wait(forDuration: 2.0)
        ])
        bell.run(SKAction.repeatForever(wiggle))

        // Message
        titleLabel = SKLabelNode(text: "\(name) will miss you.\nTurn on notifications to\nreceive messages from\n\(name).")
        titleLabel.fontName = "Menlo-Bold"
        titleLabel.fontSize = 18
        titleLabel.fontColor = textColor
        titleLabel.numberOfLines = 4
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        contentNode.addChild(titleLabel)

        // Update button text
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Let's Go!"
        }
    }

    // MARK: - Helpers

    private func createTitle(_ text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo-Bold"
        label.fontSize = 24
        label.fontColor = textColor
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height - 180)
        return label
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check next button
        if nextButton.contains(location) {
            animateButtonPress(nextButton)
            handleNextButton()
            return
        }

        // Check founder cards
        for card in founderCards {
            if card.contains(touch.location(in: contentNode)) {
                if let name = card.name, name.hasPrefix("founder_") {
                    let archetypeName = String(name.dropFirst("founder_".count))
                    if let archetype = Archetype.allCases.first(where: { $0.rawValue == archetypeName }) {
                        selectedArchetype = archetype
                        updateFounderSelection()
                    }
                }
                return
            }
        }

        // Check location cards
        for card in locationCards {
            if card.contains(touch.location(in: contentNode)) {
                if let name = card.name, name.hasPrefix("location_") {
                    let locationName = String(name.dropFirst("location_".count))
                    if let location = StartupLocation.allCases.first(where: { $0.rawValue == locationName }) {
                        selectedLocation = location
                        updateLocationSelection()
                    }
                }
                return
            }
        }

        // Check name field tap
        if currentStep == .nameFounder {
            let fieldArea = CGRect(x: size.width / 2 - 125, y: size.height / 2 - 65, width: 250, height: 50)
            if fieldArea.contains(location) {
                promptForName()
            }
        }
    }

    private func animateButtonPress(_ button: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        button.run(press)
    }

    private func handleNextButton() {
        switch currentStep {
        case .chooseFounder:
            currentStep = .nameFounder
            showStep(currentStep)

        case .nameFounder:
            if founderName.isEmpty {
                // Auto-generate a name if empty
                let names = ["Alex", "Jordan", "Sam", "Casey", "Riley", "Morgan", "Taylor", "Quinn"]
                founderName = names.randomElement() ?? "Founder"
            }
            currentStep = .chooseLocation
            showStep(currentStep)

        case .chooseLocation:
            currentStep = .notifications
            showStep(currentStep)

        case .notifications:
            requestNotificationsAndStart()
        }
    }

    private func promptForName() {
        // Generate a random tech bro name for now
        // In a full implementation, this would show a UITextField
        let names = ["Chad", "Kyle", "Elon", "Zuck", "Satya", "Sundar", "Travis", "Adam", "Jack", "Brian"]
        founderName = names.randomElement() ?? "Founder"

        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") as? SKLabelNode {
            nameDisplay.text = founderName
            nameDisplay.fontColor = textColor
        }

        if let hint = contentNode.childNode(withName: "tapHint") {
            hint.isHidden = true
        }
    }

    private func requestNotificationsAndStart() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async { [weak self] in
                self?.startGame()
            }
        }
    }

    private func startGame() {
        GameManager.shared.newGame(name: founderName, archetype: selectedArchetype)

        // Fade out and transition
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        run(fadeOut) { [weak self] in
            self?.sceneManager?.presentScene(.mainGame)
        }
    }
}
