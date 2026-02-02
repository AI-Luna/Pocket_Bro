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

// Using City enum from BroState.swift

class OnboardingScene: SKScene {
    weak var sceneManager: SceneManager?

    // Onboarding state
    private var currentStep: OnboardingStep = .chooseFounder
    private var selectedArchetype: Archetype = .bro
    private var selectedCity: City = .sanFrancisco
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
    private var cityCards: [SKNode] = []

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
        label.fontName = PixelFont.name
        label.fontSize = PixelFont.large
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
        cityCards.removeAll()

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

        // Character icon
        if archetype == .bro {
            // Use actual image for Tech Bro
            let texture = SKTexture(imageNamed: "TechBroIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let iconSize: CGFloat = 55
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: 0, y: 10)
            card.addChild(iconSprite)
        } else {
            // Use emoji for others (for now)
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
        }

        // Name label
        let nameLabel = SKLabelNode(text: archetype.rawValue)
        nameLabel.fontName = PixelFont.name
        nameLabel.fontSize = PixelFont.tiny
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
        let preview: SKNode
        if selectedArchetype == .bro {
            let texture = SKTexture(imageNamed: "TechBroIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let iconSize: CGFloat = 80
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
            preview = iconSprite
        } else {
            let emoji: String
            switch selectedArchetype {
            case .bro: emoji = "👨‍💻"
            case .gal: emoji = "👩‍💻"
            case .nonBinary: emoji = "🧑‍💻"
            }
            let emojiLabel = SKLabelNode(text: emoji)
            emojiLabel.fontSize = 80
            emojiLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
            preview = emojiLabel
        }
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
        nameDisplay.fontName = PixelFont.name
        nameDisplay.fontSize = PixelFont.medium
        nameDisplay.fontColor = founderName.isEmpty ? SKColor(white: 0.5, alpha: 1.0) : textColor
        nameDisplay.position = fieldBg.position
        nameDisplay.verticalAlignmentMode = .center
        nameDisplay.name = "nameDisplay"
        contentNode.addChild(nameDisplay)

        // Tap hint
        let tapHint = SKLabelNode(text: "Tap the field to type")
        tapHint.fontName = PixelFont.regularName
        tapHint.fontSize = PixelFont.small
        tapHint.fontColor = SKColor(white: 0.5, alpha: 1.0)
        tapHint.position = CGPoint(x: size.width / 2, y: size.height / 2 - 90)
        tapHint.name = "tapHint"
        contentNode.addChild(tapHint)
    }

    // MARK: - Step 3: Choose City

    private func setupChooseLocationStep() {
        // Title with name
        let name = founderName.isEmpty ? "your founder" : founderName
        titleLabel = createTitle("Where will \(name)\nbuild their startup?")
        titleLabel.numberOfLines = 2
        titleLabel.position.y = size.height - 120
        contentNode.addChild(titleLabel)

        // Two city cards side by side
        let cardWidth: CGFloat = (size.width - 60) / 2
        let cardHeight: CGFloat = 280
        let spacing: CGFloat = 20
        let cardY = size.height / 2 - 20

        let cities = City.allCases
        let totalWidth = CGFloat(cities.count) * cardWidth + spacing
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2

        for (index, city) in cities.enumerated() {
            let card = createCityCard(city: city, size: CGSize(width: cardWidth, height: cardHeight))
            let xPos = startX + CGFloat(index) * (cardWidth + spacing)
            card.position = CGPoint(x: xPos, y: cardY)
            card.name = "city_\(city.rawValue)"
            contentNode.addChild(card)
            cityCards.append(card)
        }

        updateCitySelection()
    }

    private func createCityCard(city: City, size: CGSize) -> SKNode {
        let card = SKNode()

        // Card background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        bg.fillColor = cardColor
        bg.strokeColor = .clear
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection border
        let borderSize = CGSize(width: size.width + 8, height: size.height + 8)
        let border = SKShapeNode(rectOf: borderSize, cornerRadius: 14)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 4
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Image preview area
        let imageWidth = size.width - 20
        let imageHeight = size.height - 60
        let imageY: CGFloat = 15

        // Clip mask for rounded corners on image
        let maskNode = SKShapeNode(rectOf: CGSize(width: imageWidth, height: imageHeight), cornerRadius: 8)
        maskNode.fillColor = .white
        maskNode.strokeColor = .clear
        maskNode.position = CGPoint(x: 0, y: imageY)

        // City preview image
        let texture = SKTexture(imageNamed: city.imageName)
        texture.filteringMode = .linear
        let imageSprite = SKSpriteNode(texture: texture)

        // Scale to fill the image area
        let scaleX = imageWidth / texture.size().width
        let scaleY = imageHeight / texture.size().height
        let scale = max(scaleX, scaleY)
        imageSprite.setScale(scale)
        imageSprite.position = CGPoint(x: 0, y: imageY)

        // Create crop node to clip the image
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.addChild(imageSprite)
        card.addChild(cropNode)

        // City name label
        let nameLabel = SKLabelNode(text: "\(city.emoji) \(city.rawValue)")
        nameLabel.fontName = PixelFont.name
        nameLabel.fontSize = PixelFont.body
        nameLabel.fontColor = textColor
        nameLabel.position = CGPoint(x: 0, y: -size.height / 2 + 22)
        nameLabel.verticalAlignmentMode = .center
        card.addChild(nameLabel)

        return card
    }

    private func updateCitySelection() {
        for card in cityCards {
            let isSelected = card.name == "city_\(selectedCity.rawValue)"
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
        appName.fontName = PixelFont.name
        appName.fontSize = PixelFont.body
        appName.fontColor = textColor
        appName.horizontalAlignmentMode = .left
        appName.position = CGPoint(x: -size.width / 2 + 95, y: 12)
        banner.addChild(appName)

        let notifTime = SKLabelNode(text: "now")
        notifTime.fontName = PixelFont.regularName
        notifTime.fontSize = PixelFont.small
        notifTime.fontColor = SKColor(white: 0.5, alpha: 1.0)
        notifTime.horizontalAlignmentMode = .right
        notifTime.position = CGPoint(x: size.width / 2 - 50, y: 12)
        banner.addChild(notifTime)

        let notifText = SKLabelNode(text: "🚀 \(name) needs your help!")
        notifText.fontName = PixelFont.regularName
        notifText.fontSize = PixelFont.small
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
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.medium
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
        label.fontName = PixelFont.name
        label.fontSize = PixelFont.title
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

        // Check city cards
        for card in cityCards {
            if card.contains(touch.location(in: contentNode)) {
                if let name = card.name, name.hasPrefix("city_") {
                    let cityName = String(name.dropFirst("city_".count))
                    if let city = City.allCases.first(where: { $0.rawValue == cityName }) {
                        selectedCity = city
                        updateCitySelection()
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
        // Show a native text input alert for name entry
        guard let viewController = self.view?.window?.rootViewController else {
            // Fallback to random name if no view controller
            let names = ["Chad", "Kyle", "Alex", "Sam", "Jordan", "Taylor", "Morgan", "Quinn"]
            founderName = names.randomElement() ?? "Founder"
            updateNameDisplay()
            return
        }
        
        let alert = UIAlertController(
            title: "Name Your Founder",
            message: "What should we call your character?",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter name..."
            textField.text = self.founderName.isEmpty ? "" : self.founderName
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            textField.clearButtonMode = .whileEditing
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let text = alert.textFields?.first?.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                self.founderName = text.trimmingCharacters(in: .whitespaces)
            } else {
                // Generate a random name if empty
                let names = ["Alex", "Jordan", "Sam", "Casey", "Riley", "Morgan", "Taylor", "Quinn"]
                self.founderName = names.randomElement() ?? "Founder"
            }
            self.updateNameDisplay()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func updateNameDisplay() {
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") as? SKLabelNode {
            nameDisplay.text = founderName
            nameDisplay.fontColor = textColor
        }

        if let hint = contentNode.childNode(withName: "tapHint") {
            hint.isHidden = !founderName.isEmpty
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
        GameManager.shared.newGame(name: founderName, archetype: selectedArchetype, city: selectedCity)

        // Fade out and transition
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        run(fadeOut) { [weak self] in
            self?.sceneManager?.presentScene(.mainGame)
        }
    }
}
