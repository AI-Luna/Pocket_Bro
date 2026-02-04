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

    // UI Colors - Retro synthwave theme (purple/cyan)
    private let backgroundColor_ = SKColor(red: 0.15, green: 0.08, blue: 0.30, alpha: 1.0) // Deep purple
    private let cardColor = SKColor(red: 0.20, green: 0.12, blue: 0.35, alpha: 0.9) // Purple with slight transparency
    private let accentColor = SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0) // Bright cyan
    private let textColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) // Bright cyan text
    private let selectedBorderColor = SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0) // Cyan border
    private let purpleAccent = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0) // Bright purple

    // UI Elements
    private var contentNode: SKNode!
    private var nextButton: SKNode!
    private var titleLabel: SKLabelNode!

    // Selection tracking
    private var founderCards: [SKNode] = []
    private var cityCards: [SKNode] = []
    
    // Text input
    private var nameTextField: UITextField?

    init(size: CGSize, sceneManager: SceneManager) {
        self.sceneManager = sceneManager
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupGradientBackground()
        setupNextButton()
        showStep(currentStep)
    }
    
    // MARK: - Background Setup
    
    private func setupGradientBackground() {
        // Clean purple background - matching the design
        backgroundColor = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0)
        
        // Add perspective grid at the bottom
        setupGridPattern()
    }
    
    private func setupGridPattern() {
        // Create a clean perspective grid at the bottom of the screen
        let gridNode = SKNode()
        gridNode.zPosition = -97
        
        let lineColor = SKColor(red: 0.3, green: 0.25, blue: 0.5, alpha: 0.6)
        let gridStartY: CGFloat = size.height * 0.35 // Grid starts at 35% from bottom
        
        // Horizontal lines - perspective effect (lines get closer together toward horizon)
        let horizonY: CGFloat = gridStartY
        let bottomY: CGFloat = 0
        let numHorizontalLines = 12
        
        for i in 0..<numHorizontalLines {
            // Exponential spacing for perspective effect
            let t = CGFloat(i) / CGFloat(numHorizontalLines - 1)
            let y = bottomY + pow(t, 1.5) * (horizonY - bottomY)
            
            let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 1))
            line.fillColor = lineColor
            line.strokeColor = .clear
            line.position = CGPoint(x: size.width / 2, y: y)
            gridNode.addChild(line)
        }
        
        // Vertical lines converging to center horizon point
        let numVerticalLines = 14
        let vanishingPointX = size.width / 2
        let vanishingPointY = horizonY
        
        for i in 0...numVerticalLines {
            let xRatio = CGFloat(i) / CGFloat(numVerticalLines)
            let bottomX = size.width * xRatio
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bottomX, y: bottomY))
            path.addLine(to: CGPoint(x: vanishingPointX, y: vanishingPointY))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 1
            gridNode.addChild(line)
        }
        
        addChild(gridNode)
    }

    // MARK: - Setup

    private func setupNextButton() {
        let buttonWidth: CGFloat = 220
        let buttonHeight: CGFloat = 60

        let button = SKNode()
        button.name = "nextButton"
        button.position = CGPoint(x: size.width / 2, y: 120)
        button.zPosition = 100

        // Glowing shadow/outline effect
        let glow = SKShapeNode(rectOf: CGSize(width: buttonWidth + 8, height: buttonHeight + 8), cornerRadius: 16)
        glow.fillColor = .clear
        glow.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.6)
        glow.lineWidth = 3
        glow.glowWidth = 10
        button.addChild(glow)

        // Main button - bright cyan
        let bg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        bg.fillColor = accentColor
        bg.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.8)
        bg.lineWidth = 2
        bg.name = "nextButtonBg"
        button.addChild(bg)

        // Label - dark text on cyan button
        let label = SKLabelNode(text: "Next")
        label.fontName = PixelFont.name
        label.fontSize = PixelFont.large
        label.fontColor = SKColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0) // Dark purple text
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        // Pulsing glow animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        glow.run(SKAction.repeatForever(pulse))

        addChild(button)
        nextButton = button
    }

    private func showStep(_ step: OnboardingStep) {
        // Clean up text field if leaving name step
        if nameTextField != nil {
            nameTextField?.removeFromSuperview()
            nameTextField = nil
        }
        
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
        // Main logo/title - styled like "TECHBRO TAMAGOTCHI"
        let mainTitle = SKLabelNode(text: "TECHBRO\nTAMAGOTCHI")
        mainTitle.fontName = PixelFont.name
        mainTitle.fontSize = 40
        mainTitle.fontColor = textColor
        mainTitle.numberOfLines = 2
        mainTitle.horizontalAlignmentMode = .center
        mainTitle.verticalAlignmentMode = .center
        mainTitle.position = CGPoint(x: size.width / 2, y: size.height - 140)
        
        // Add subtle glow effect to title
        let titleGlow = mainTitle.copy() as! SKLabelNode
        titleGlow.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3)
        titleGlow.position = mainTitle.position
        titleGlow.zPosition = -1
        contentNode.addChild(titleGlow)
        
        // Animate glow
        let glowPulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        titleGlow.run(SKAction.repeatForever(glowPulse))
        
        contentNode.addChild(mainTitle)
        
        // Subtitle
        titleLabel = createTitle("Choose your founder")
        titleLabel.fontSize = PixelFont.medium
        titleLabel.position.y = size.height - 240
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
        
        // Update button text for first step
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Get Started"
        }
    }

    private func createFounderCard(archetype: Archetype, size: CGSize) -> SKNode {
        let card = SKNode()

        // Card background - dark purple, clean look
        let bg = SKShapeNode(rectOf: size, cornerRadius: 14)
        bg.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.35, green: 0.25, blue: 0.55, alpha: 0.8)
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection border - cyan glow (hidden by default)
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height + 10), cornerRadius: 18)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 3
        border.glowWidth = 8
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Character icon
        let iconSize: CGFloat = 55
        
        switch archetype {
        case .bro:
            let texture = SKTexture(imageNamed: "TechBroIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: 0, y: 10)
            card.addChild(iconSprite)
        case .gal:
            let texture = SKTexture(imageNamed: "TechGalIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: 0, y: 10)
            card.addChild(iconSprite)
        case .nonBinary:
            // Use emoji for non-binary (for now)
            let emojiLabel = SKLabelNode(text: "🧑‍💻")
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
        nameLabel.horizontalAlignmentMode = .center
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
        // Update button text
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Next"
        }
        
        // Title - "Name Your TechBro" style
        titleLabel = createTitle("Name Your TechBro")
        titleLabel.position.y = size.height - 160
        contentNode.addChild(titleLabel)

        // Character preview with glow effect
        let previewY = size.height / 2 + 100
        
        // Pink/magenta glow behind character
        let glowNode = SKShapeNode(circleOfRadius: 60)
        glowNode.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.6, alpha: 0.4)
        glowNode.strokeColor = .clear
        glowNode.position = CGPoint(x: size.width / 2, y: previewY)
        glowNode.glowWidth = 20
        contentNode.addChild(glowNode)
        
        // Glow pulse animation
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.8),
            SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(glowPulse))
        
        let preview: SKNode
        let iconSize: CGFloat = 100
        
        switch selectedArchetype {
        case .bro:
            let texture = SKTexture(imageNamed: "TechBroIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: size.width / 2, y: previewY)
            preview = iconSprite
        case .gal:
            let texture = SKTexture(imageNamed: "TechGalIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: size.width / 2, y: previewY)
            preview = iconSprite
        case .nonBinary:
            let emojiLabel = SKLabelNode(text: "🧑‍💻")
            emojiLabel.fontSize = 100
            emojiLabel.position = CGPoint(x: size.width / 2, y: previewY)
            preview = emojiLabel
        }
        contentNode.addChild(preview)

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.5),
            SKAction.moveBy(x: 0, y: -8, duration: 0.5)
        ])
        preview.run(SKAction.repeatForever(bounce))

        // Large text input field - matching the design
        let fieldWidth: CGFloat = size.width - 60
        let fieldHeight: CGFloat = 65
        let fieldY = size.height / 2 - 40

        // Field background - dark purple with pink/magenta border
        let fieldBg = SKShapeNode(rectOf: CGSize(width: fieldWidth, height: fieldHeight), cornerRadius: 20)
        fieldBg.fillColor = SKColor(red: 0.35, green: 0.15, blue: 0.45, alpha: 0.9)
        fieldBg.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.6, alpha: 0.8)
        fieldBg.lineWidth = 3
        fieldBg.position = CGPoint(x: size.width / 2, y: fieldY)
        fieldBg.name = "nameFieldBg"
        contentNode.addChild(fieldBg)

        // Name display text
        let nameDisplay = SKLabelNode(text: founderName.isEmpty ? "Tap to enter name" : founderName)
        nameDisplay.fontName = PixelFont.name
        nameDisplay.fontSize = PixelFont.large
        nameDisplay.fontColor = founderName.isEmpty ? SKColor(white: 0.7, alpha: 0.8) : .white
        nameDisplay.position = CGPoint(x: size.width / 2, y: fieldY)
        nameDisplay.horizontalAlignmentMode = .center
        nameDisplay.verticalAlignmentMode = .center
        nameDisplay.name = "nameDisplay"
        contentNode.addChild(nameDisplay)

        // Tap hint below field
        let tapHint = SKLabelNode(text: "Tap the field to type")
        tapHint.fontName = PixelFont.regularName
        tapHint.fontSize = PixelFont.small
        tapHint.fontColor = SKColor(red: 0.6, green: 0.5, blue: 0.7, alpha: 0.8)
        tapHint.position = CGPoint(x: size.width / 2, y: fieldY - 55)
        tapHint.horizontalAlignmentMode = .center
        tapHint.name = "tapHint"
        contentNode.addChild(tapHint)
    }

    // MARK: - Step 3: Choose City

    private func setupChooseLocationStep() {
        // Update button text
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Next"
        }
        
        // Title with name - centered
        let name = founderName.isEmpty ? "your founder" : founderName
        titleLabel = createTitle("Where will \(name)\nbuild their startup?")
        titleLabel.numberOfLines = 2
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.preferredMaxLayoutWidth = size.width - 40
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        contentNode.addChild(titleLabel)

        // Two city cards side by side
        let cardWidth: CGFloat = (size.width - 60) / 2
        let cardHeight: CGFloat = 280
        let spacing: CGFloat = 20
        let cardY = size.height / 2 + 20

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

        // Card background - dark purple, matching design
        let bg = SKShapeNode(rectOf: size, cornerRadius: 16)
        bg.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.35, green: 0.25, blue: 0.55, alpha: 0.8)
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection border - bright cyan glow
        let borderSize = CGSize(width: size.width + 12, height: size.height + 12)
        let border = SKShapeNode(rectOf: borderSize, cornerRadius: 20)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 4
        border.glowWidth = 8
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
        nameLabel.horizontalAlignmentMode = .center
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
        let name = founderName.isEmpty ? "Your TechBro" : founderName

        // iOS-style notification banner at top
        let bannerWidth = size.width - 32
        let bannerHeight: CGFloat = 90
        let bannerY = size.height - 80
        
        // Banner background - iOS style with blur effect simulation
        let banner = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 20)
        banner.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 0.95)
        banner.strokeColor = .clear
        banner.position = CGPoint(x: size.width / 2, y: bannerY)
        banner.zPosition = 10
        contentNode.addChild(banner)
        
        // Subtle shadow effect
        let shadowBanner = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 20)
        shadowBanner.fillColor = SKColor(white: 0, alpha: 0.15)
        shadowBanner.strokeColor = .clear
        shadowBanner.position = CGPoint(x: size.width / 2, y: bannerY - 4)
        shadowBanner.zPosition = 9
        contentNode.addChild(shadowBanner)

        // App icon - rounded square with app icon
        let iconSize: CGFloat = 44
        let iconX = -bannerWidth / 2 + 20 + iconSize / 2
        
        let iconBg = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: 10)
        iconBg.fillColor = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0) // Match app purple
        iconBg.strokeColor = .clear
        iconBg.position = CGPoint(x: iconX, y: 0)
        banner.addChild(iconBg)

        // Use tech bro icon or pixel character in app icon
        let iconEmoji = SKLabelNode(text: "👔")
        iconEmoji.fontSize = 24
        iconEmoji.position = CGPoint(x: iconX, y: 0)
        iconEmoji.verticalAlignmentMode = .center
        iconEmoji.horizontalAlignmentMode = .center
        banner.addChild(iconEmoji)

        // Text content area
        let textX = iconX + iconSize / 2 + 14
        
        // App name and time on same line
        let appName = SKLabelNode(text: "TechBro Tamagotchi")
        appName.fontName = "Helvetica-Bold"
        appName.fontSize = 14
        appName.fontColor = SKColor(white: 0.1, alpha: 1.0)
        appName.horizontalAlignmentMode = .left
        appName.position = CGPoint(x: textX, y: 20)
        banner.addChild(appName)

        let notifTime = SKLabelNode(text: "now")
        notifTime.fontName = "Helvetica"
        notifTime.fontSize = 13
        notifTime.fontColor = SKColor(white: 0.5, alpha: 1.0)
        notifTime.horizontalAlignmentMode = .right
        notifTime.position = CGPoint(x: bannerWidth / 2 - 20, y: 20)
        banner.addChild(notifTime)

        // Notification title
        let notifTitle = SKLabelNode(text: "\(name) is hungry! 🍕")
        notifTitle.fontName = "Helvetica-Bold"
        notifTitle.fontSize = 15
        notifTitle.fontColor = SKColor(white: 0.1, alpha: 1.0)
        notifTitle.horizontalAlignmentMode = .left
        notifTitle.position = CGPoint(x: textX, y: -2)
        banner.addChild(notifTitle)
        
        // Notification body
        let notifBody = SKLabelNode(text: "Feed \(name) before they get hangry!")
        notifBody.fontName = "Helvetica"
        notifBody.fontSize = 14
        notifBody.fontColor = SKColor(white: 0.3, alpha: 1.0)
        notifBody.horizontalAlignmentMode = .left
        notifBody.position = CGPoint(x: textX, y: -22)
        banner.addChild(notifBody)
        
        // Slide in animation for banner
        banner.position.y = size.height + bannerHeight
        shadowBanner.position.y = size.height + bannerHeight - 4
        let slideIn = SKAction.moveTo(y: bannerY, duration: 0.4)
        slideIn.timingMode = .easeOut
        banner.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), slideIn]))
        shadowBanner.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.moveTo(y: bannerY - 4, duration: 0.4)]))

        // Bell icon - closer to text
        let bell = SKLabelNode(text: "🔔")
        bell.fontSize = 60
        bell.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        bell.horizontalAlignmentMode = .center
        bell.verticalAlignmentMode = .center
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

        // Message - reduced gap from bell
        titleLabel = SKLabelNode(text: "\(name) will miss you!\nTurn on notifications to\nstay connected.")
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.medium
        titleLabel.fontColor = textColor
        titleLabel.numberOfLines = 3
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 10)
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

        // Check name field tap - larger touch area
        if currentStep == .nameFounder {
            let fieldWidth = size.width - 60
            let fieldHeight: CGFloat = 65
            let fieldY = size.height / 2 - 40
            let fieldArea = CGRect(x: (size.width - fieldWidth) / 2, y: fieldY - fieldHeight / 2, width: fieldWidth, height: fieldHeight)
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
        // Add a UITextField directly over the name field for inline editing
        guard let skView = self.view else { return }
        
        // Remove existing text field if any
        nameTextField?.removeFromSuperview()
        
        // Calculate position - convert SpriteKit coordinates to UIKit
        let fieldWidth = size.width - 60
        let fieldHeight: CGFloat = 65
        let fieldY = size.height / 2 - 40
        
        // Convert from SpriteKit coordinates (origin at bottom-left) to UIKit (origin at top-left)
        let uiFieldY = size.height - fieldY - fieldHeight / 2
        let uiFieldX = (size.width - fieldWidth) / 2
        
        // Create text field
        let textField = UITextField(frame: CGRect(
            x: uiFieldX,
            y: uiFieldY,
            width: fieldWidth,
            height: fieldHeight
        ))
        
        // Style the text field to match the game aesthetic
        textField.backgroundColor = UIColor(red: 0.35, green: 0.15, blue: 0.45, alpha: 0.95)
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor(red: 0.8, green: 0.2, blue: 0.6, alpha: 0.8).cgColor
        textField.textColor = .white
        textField.font = UIFont(name: PixelFont.name, size: PixelFont.large) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        textField.textAlignment = .center
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter name...",
            attributes: [.foregroundColor: UIColor(white: 0.7, alpha: 0.8)]
        )
        textField.text = founderName.isEmpty ? "" : founderName
        textField.tintColor = UIColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0)
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: fieldHeight))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: fieldHeight))
        textField.rightViewMode = .always
        
        // Add to view and make first responder
        skView.addSubview(textField)
        textField.delegate = self
        textField.becomeFirstResponder()
        
        nameTextField = textField
        
        // Hide the SpriteKit name display while editing
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") {
            nameDisplay.isHidden = true
        }
    }
    
    private func finishNameEditing() {
        guard let textField = nameTextField else { return }
        
        // Get the entered name
        if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            founderName = text.trimmingCharacters(in: .whitespaces)
        }
        
        // Remove text field
        textField.resignFirstResponder()
        textField.removeFromSuperview()
        nameTextField = nil
        
        // Show and update the SpriteKit name display
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") {
            nameDisplay.isHidden = false
        }
        updateNameDisplay()
    }
    
    private func updateNameDisplay() {
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") as? SKLabelNode {
            nameDisplay.text = founderName.isEmpty ? "Tap to enter name" : founderName
            nameDisplay.fontColor = founderName.isEmpty ? SKColor(white: 0.7, alpha: 0.8) : .white
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

// MARK: - UITextFieldDelegate

extension OnboardingScene: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishNameEditing()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        finishNameEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit name length to 20 characters
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 20
    }
}
