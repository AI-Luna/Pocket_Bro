//
//  OnboardingScene.swift
//  Pocket Bro
//

import SpriteKit
import UserNotifications

enum OnboardingStep: Int, CaseIterable {
    case chooseFounder = 0
    case chooseStartupType = 1
    case nameFounder = 2
    case chooseLocation = 3
    case notifications = 4
}

// Using City enum from BroState.swift

class OnboardingScene: SKScene {
    weak var sceneManager: SceneManager?

    // Onboarding state
    private var currentStep: OnboardingStep = .chooseFounder
    private var selectedArchetype: Archetype = .bro
    private var selectedCity: City = .sanFrancisco
    private var founderName: String = ""

    // UI Colors - Retro synthwave theme (purple/cyan/pink)
    private let backgroundColor_ = SKColor(red: 0.15, green: 0.08, blue: 0.30, alpha: 1.0) // Deep purple
    private let cardColor = SKColor(red: 0.20, green: 0.12, blue: 0.35, alpha: 0.9) // Purple with slight transparency
    private let accentColor = SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0) // Bright cyan
    private let textColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) // Bright cyan text
    private let selectedBorderColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Hot pink for selection
    private let pinkAccent = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Hot pink (matching logo)

    // UI Elements
    private var contentNode: SKNode!
    private var nextButton: SKNode!
    private var titleLabel: SKLabelNode!

    // Selection tracking
    private var founderCards: [SKNode] = []
    private var startupTypeCards: [SKNode] = []
    private var cityCards: [SKNode] = []
    private var selectedStartupType: StartupType = .ai
    
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
        startupTypeCards.removeAll()
        cityCards.removeAll()

        switch step {
        case .chooseFounder:
            setupChooseFounderStep()
        case .chooseStartupType:
            setupChooseStartupTypeStep()
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
        // Main logo image - Tiny TechBro
        let logoTexture = SKTexture(imageNamed: "TechBroLogo")
        let logo = SKSpriteNode(texture: logoTexture)
        
        // Scale logo to fit nicely
        let targetWidth = size.width * 1.1
        let scale = targetWidth / logoTexture.size().width
        logo.setScale(scale)
        logo.position = CGPoint(x: size.width / 2 + 5, y: size.height - 180)
        logo.zPosition = 10

        // Add pink/magenta glow behind logo
        let glowNode = SKShapeNode(rectOf: CGSize(width: logo.size.width * 0.7, height: logo.size.height * 0.8), cornerRadius: 20)
        glowNode.fillColor = pinkAccent.withAlphaComponent(0.2)
        glowNode.strokeColor = .clear
        glowNode.position = CGPoint(x: size.width / 2, y: size.height - 180)
        glowNode.zPosition = 9
        glowNode.glowWidth = 30
        contentNode.addChild(glowNode)
        
        // Animate glow
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.2),
            SKAction.fadeAlpha(to: 0.2, duration: 1.2)
        ])
        glowNode.run(SKAction.repeatForever(glowPulse))
        
        contentNode.addChild(logo)
        
        // Subtitle - positioned closer to cards below
        titleLabel = createTitle("Choose your founder")
        titleLabel.fontSize = PixelFont.medium
        titleLabel.position.y = size.height - 355
        contentNode.addChild(titleLabel)

        // Larger cards with bigger character icons
        let archetypes = Archetype.allCases
        let cardSize = CGSize(width: 130, height: 175)
        let spacing: CGFloat = 28
        let totalWidth = CGFloat(archetypes.count) * cardSize.width + CGFloat(archetypes.count - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + cardSize.width / 2
        let cardY = size.height / 2 - 50  // Moved up, closer to title

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

        // Card background - dark purple with faint cyan outline
        let bg = SKShapeNode(rectOf: size, cornerRadius: 14)
        bg.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
        bg.strokeColor = accentColor.withAlphaComponent(0.3) // Faint cyan outline
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection glow - pink halo effect (hidden by default)
        let glowBg = SKShapeNode(rectOf: CGSize(width: size.width + 16, height: size.height + 16), cornerRadius: 20)
        glowBg.fillColor = selectedBorderColor.withAlphaComponent(0.15)
        glowBg.strokeColor = .clear
        glowBg.glowWidth = 15
        glowBg.name = "selectionGlow"
        glowBg.isHidden = true
        glowBg.zPosition = -2
        card.addChild(glowBg)
        
        // Selection border - pink with glow (hidden by default)
        let border = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height + 10), cornerRadius: 18)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 3
        border.glowWidth = 12
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Character icon - larger size
        let iconSize: CGFloat = 140
        
        switch archetype {
        case .bro:
            let texture = SKTexture(imageNamed: "TechBroIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: 0, y: 12)
            card.addChild(iconSprite)
        case .gal:
            let texture = SKTexture(imageNamed: "TechGalIcon")
            let iconSprite = SKSpriteNode(texture: texture)
            let scale = iconSize / max(texture.size().width, texture.size().height)
            iconSprite.setScale(scale)
            iconSprite.position = CGPoint(x: 0, y: 12)
            card.addChild(iconSprite)
        }

        // Name label - custom display names with larger font
        let displayName: String
        switch archetype {
        case .bro: displayName = "Tech Bro"
        case .gal: displayName = "Tech Babe"
        }
        
        let nameLabel = SKLabelNode(text: displayName)
        nameLabel.fontName = PixelFont.name
        nameLabel.fontSize = PixelFont.body  // Larger font for readability
        nameLabel.fontColor = textColor
        nameLabel.position = CGPoint(x: 0, y: -size.height / 2 + 22)
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
            if let glow = card.childNode(withName: "selectionGlow") {
                glow.isHidden = !isSelected
                // Add pulsing animation when selected
                if isSelected {
                    glow.removeAllActions()
                    let pulse = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                        SKAction.fadeAlpha(to: 0.15, duration: 0.8)
                    ])
                    glow.run(SKAction.repeatForever(pulse))
                }
            }
        }
    }

    // MARK: - Step 2: Choose Startup Type

    private func setupChooseStartupTypeStep() {
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Next"
        }

        titleLabel = createTitle("What are you building?")
        titleLabel.fontSize = PixelFont.medium
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        contentNode.addChild(titleLabel)

        let types = StartupType.allCases
        let cols = 3
        let cardW: CGFloat = (size.width - 50) / CGFloat(cols)
        let cardH: CGFloat = cardW * 0.95
        let spacingX: CGFloat = 10
        let spacingY: CGFloat = 14
        let labelH: CGFloat = 30

        let totalW = CGFloat(cols) * cardW + CGFloat(cols - 1) * spacingX
        let startX = (size.width - totalW) / 2 + cardW / 2
        let startY = size.height / 2 + cardH / 2 + spacingY + labelH

        for (index, type) in types.enumerated() {
            let row = index / cols
            let col = index % cols
            let x = startX + CGFloat(col) * (cardW + spacingX)
            let y = startY - CGFloat(row) * (cardH + spacingY + labelH)

            let card = createStartupTypeCard(type: type, size: CGSize(width: cardW, height: cardH))
            card.position = CGPoint(x: x, y: y)
            card.name = "startup_\(type.rawValue)"
            contentNode.addChild(card)
            startupTypeCards.append(card)
        }

        updateStartupTypeSelection()
    }

    private func createStartupTypeCard(type: StartupType, size: CGSize) -> SKNode {
        let card = SKNode()

        let bg = SKShapeNode(rectOf: size, cornerRadius: 14)
        bg.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
        bg.strokeColor = accentColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        let glowBg = SKShapeNode(rectOf: CGSize(width: size.width + 16, height: size.height + 16), cornerRadius: 20)
        glowBg.fillColor = selectedBorderColor.withAlphaComponent(0.15)
        glowBg.strokeColor = .clear
        glowBg.glowWidth = 15
        glowBg.name = "selectionGlow"
        glowBg.isHidden = true
        glowBg.zPosition = -2
        card.addChild(glowBg)

        let border = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height + 10), cornerRadius: 18)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 3
        border.glowWidth = 12
        border.name = "selectionBorder"
        border.isHidden = true
        card.addChild(border)

        // Large emoji centered in card
        let emojiLabel = SKLabelNode(text: type.emoji)
        emojiLabel.fontSize = size.height * 0.48
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.horizontalAlignmentMode = .center
        emojiLabel.position = CGPoint(x: 0, y: 8)
        card.addChild(emojiLabel)

        // Name label below card
        let nameLabel = SKLabelNode(text: type.rawValue)
        nameLabel.fontName = PixelFont.name
        nameLabel.fontSize = PixelFont.small
        nameLabel.fontColor = textColor
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: -size.height / 2 - 14)
        card.addChild(nameLabel)

        return card
    }

    private func updateStartupTypeSelection() {
        for card in startupTypeCards {
            let isSelected = card.name == "startup_\(selectedStartupType.rawValue)"
            if let border = card.childNode(withName: "selectionBorder") {
                border.isHidden = !isSelected
            }
            if let glow = card.childNode(withName: "selectionGlow") {
                glow.isHidden = !isSelected
                if isSelected {
                    glow.removeAllActions()
                    let pulse = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                        SKAction.fadeAlpha(to: 0.15, duration: 0.8)
                    ])
                    glow.run(SKAction.repeatForever(pulse))
                }
            }
        }
    }

    // MARK: - Step 3: Name Founder

    private func setupNameFounderStep() {
        // Update button text
        if let label = nextButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "Next"
        }
        
        // Title - "Name Your TechBro" style
        titleLabel = createTitle("Name Your TechBro")
        let titleY = size.height - 160
        titleLabel.position.y = titleY
        contentNode.addChild(titleLabel)

        // Input field position
        let fieldY = size.height / 2 - 60
        
        // Character preview centered between title and input field
        let previewY = (titleY + fieldY) / 2
        
        // Larger pink glow circle behind character
        let glowNode = SKShapeNode(circleOfRadius: 85)
        glowNode.fillColor = pinkAccent.withAlphaComponent(0.35)
        glowNode.strokeColor = .clear
        glowNode.position = CGPoint(x: size.width / 2, y: previewY)
        glowNode.glowWidth = 30
        contentNode.addChild(glowNode)
        
        // Glow pulse animation
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            SKAction.fadeAlpha(to: 0.25, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(glowPulse))
        
        let preview: SKNode
        let iconSize: CGFloat = 140 // Larger character
        
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
        
        // Glow behind field
        let fieldGlow = SKShapeNode(rectOf: CGSize(width: fieldWidth + 10, height: fieldHeight + 10), cornerRadius: 24)
        fieldGlow.fillColor = pinkAccent.withAlphaComponent(0.15)
        fieldGlow.strokeColor = .clear
        fieldGlow.glowWidth = 15
        fieldGlow.position = CGPoint(x: size.width / 2, y: fieldY)
        fieldGlow.zPosition = -1
        fieldGlow.name = "nameFieldGlow"
        contentNode.addChild(fieldGlow)

        // Field background - dark purple with pink border
        let fieldBg = SKShapeNode(rectOf: CGSize(width: fieldWidth, height: fieldHeight), cornerRadius: 20)
        fieldBg.fillColor = SKColor(red: 0.35, green: 0.15, blue: 0.45, alpha: 0.9)
        fieldBg.strokeColor = pinkAccent
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
        
        // Title with name - centered at top
        let name = founderName.isEmpty ? "your founder" : founderName
        titleLabel = createTitle("Where will \(name)\nbuild their startup?")
        titleLabel.numberOfLines = 2
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.preferredMaxLayoutWidth = size.width - 40
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        contentNode.addChild(titleLabel)

        // Two city cards side by side - centered on screen
        let cardWidth: CGFloat = (size.width - 60) / 2
        let cardHeight: CGFloat = 280
        let spacing: CGFloat = 20
        let cardY = size.height / 2 + 20  // Moved up to be more centered

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

        // Card background - dark purple with faint cyan outline
        let bg = SKShapeNode(rectOf: size, cornerRadius: 16)
        bg.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
        bg.strokeColor = accentColor.withAlphaComponent(0.3) // Faint cyan outline
        bg.lineWidth = 2
        bg.name = "cardBg"
        card.addChild(bg)

        // Selection glow - pink halo effect (hidden by default)
        let glowSize = CGSize(width: size.width + 20, height: size.height + 20)
        let glowBg = SKShapeNode(rectOf: glowSize, cornerRadius: 24)
        glowBg.fillColor = selectedBorderColor.withAlphaComponent(0.15)
        glowBg.strokeColor = .clear
        glowBg.glowWidth = 20
        glowBg.name = "selectionGlow"
        glowBg.isHidden = true
        glowBg.zPosition = -2
        card.addChild(glowBg)
        
        // Selection border - pink with glow
        let borderSize = CGSize(width: size.width + 12, height: size.height + 12)
        let border = SKShapeNode(rectOf: borderSize, cornerRadius: 20)
        border.fillColor = .clear
        border.strokeColor = selectedBorderColor
        border.lineWidth = 4
        border.glowWidth = 12
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
            if let glow = card.childNode(withName: "selectionGlow") {
                glow.isHidden = !isSelected
                // Add pulsing animation when selected
                if isSelected {
                    glow.removeAllActions()
                    let pulse = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                        SKAction.fadeAlpha(to: 0.15, duration: 0.8)
                    ])
                    glow.run(SKAction.repeatForever(pulse))
                }
            }
        }
    }

    // MARK: - Step 4: Notifications

    private func setupNotificationsStep() {
        let name = founderName.isEmpty ? "Your TechBro" : founderName
        let safeTop = safeAreaInsets().top

        // MARK: - iOS Notification Banner
        let bannerWidth = size.width - 32
        let bannerHeight: CGFloat = 94
        let bannerY = size.height - safeTop - 56 - bannerHeight / 2

        // Drop shadow
        let shadowBanner = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 20)
        shadowBanner.fillColor = SKColor(white: 0, alpha: 0.18)
        shadowBanner.strokeColor = .clear
        shadowBanner.position = CGPoint(x: size.width / 2, y: bannerY - 3)
        shadowBanner.zPosition = 9
        contentNode.addChild(shadowBanner)

        // Banner background - frosted glass look
        let banner = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 20)
        banner.fillColor = SKColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 0.96)
        banner.strokeColor = SKColor(white: 0.85, alpha: 0.6)
        banner.lineWidth = 0.5
        banner.position = CGPoint(x: size.width / 2, y: bannerY)
        banner.zPosition = 10
        contentNode.addChild(banner)

        // App icon - actual app icon with rounded corners via crop node
        let iconSize: CGFloat = 46
        let iconX: CGFloat = -bannerWidth / 2 + 16 + iconSize / 2

        let appIconTexture = SKTexture(imageNamed: "PocketBroAppIcon")
        let appIconSprite = SKSpriteNode(texture: appIconTexture)
        appIconSprite.size = CGSize(width: iconSize, height: iconSize)

        let maskShape = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: 11)
        maskShape.fillColor = .white
        maskShape.strokeColor = .clear
        let cropNode = SKCropNode()
        cropNode.maskNode = maskShape
        cropNode.addChild(appIconSprite)
        cropNode.position = CGPoint(x: iconX, y: 2)
        banner.addChild(cropNode)

        // Text content starts after icon
        let textX: CGFloat = iconX + iconSize / 2 + 10

        // App name (small caps) + time on same row
        let appNameLabel = SKLabelNode(text: "Pocket Bro")
        appNameLabel.fontName = "Helvetica-Bold"
        appNameLabel.fontSize = 13
        appNameLabel.fontColor = SKColor(white: 0.15, alpha: 1.0)
        appNameLabel.horizontalAlignmentMode = .left
        appNameLabel.verticalAlignmentMode = .center
        appNameLabel.position = CGPoint(x: textX, y: 30)
        banner.addChild(appNameLabel)

        let notifTime = SKLabelNode(text: "now")
        notifTime.fontName = "Helvetica"
        notifTime.fontSize = 13
        notifTime.fontColor = SKColor(white: 0.55, alpha: 1.0)
        notifTime.horizontalAlignmentMode = .right
        notifTime.verticalAlignmentMode = .center
        notifTime.position = CGPoint(x: bannerWidth / 2 - 16, y: 30)
        banner.addChild(notifTime)

        // Notification title
        let notifTitle = SKLabelNode(text: "\(name) is burning out! 🔥")
        notifTitle.fontName = "Helvetica-Bold"
        notifTitle.fontSize = 15
        notifTitle.fontColor = SKColor(white: 0.08, alpha: 1.0)
        notifTitle.horizontalAlignmentMode = .left
        notifTitle.verticalAlignmentMode = .center
        notifTitle.position = CGPoint(x: textX, y: 10)
        banner.addChild(notifTitle)

        // Notification body
        let notifBody = SKLabelNode(text: "Take a break before it's too late!")
        notifBody.fontName = "Helvetica"
        notifBody.fontSize = 14
        notifBody.fontColor = SKColor(white: 0.35, alpha: 1.0)
        notifBody.horizontalAlignmentMode = .left
        notifBody.verticalAlignmentMode = .center
        notifBody.position = CGPoint(x: textX, y: -10)
        banner.addChild(notifBody)

        // Slide in from top
        let finalBannerY = bannerY
        banner.position.y = size.height + bannerHeight
        shadowBanner.position.y = size.height + bannerHeight - 3
        let slideIn = SKAction.moveTo(y: finalBannerY, duration: 0.45)
        slideIn.timingMode = .easeOut
        banner.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), slideIn]))
        shadowBanner.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.moveTo(y: finalBannerY - 3, duration: 0.45)]))

        // MARK: - Bell icon with wiggle
        let bellTexture = SKTexture(imageNamed: "Bell")
        bellTexture.filteringMode = .nearest
        let bell = SKSpriteNode(texture: bellTexture)
        bell.size = CGSize(width: 110, height: 110)
        bell.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        contentNode.addChild(bell)

        let wiggle = SKAction.sequence([
            SKAction.rotate(toAngle: 0.18, duration: 0.08),
            SKAction.rotate(toAngle: -0.18, duration: 0.08),
            SKAction.rotate(toAngle: 0.12, duration: 0.08),
            SKAction.rotate(toAngle: -0.12, duration: 0.08),
            SKAction.rotate(toAngle: 0.06, duration: 0.08),
            SKAction.rotate(toAngle: 0, duration: 0.08),
            SKAction.wait(forDuration: 2.0)
        ])
        bell.run(SKAction.repeatForever(wiggle))

        // MARK: - Message label
        titleLabel = SKLabelNode(text: "\(name) will miss you!\nTurn on notifications to\nstay connected.")
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.large
        titleLabel.fontColor = textColor
        titleLabel.numberOfLines = 3
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
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
    
    private func safeAreaInsets() -> UIEdgeInsets {
        view?.safeAreaInsets ?? .zero
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check next button
        if nextButton.contains(location) {
            Haptics.confirm()
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
                        Haptics.selection()
                        selectedArchetype = archetype
                        updateFounderSelection()
                    }
                }
                return
            }
        }

        // Check startup type cards
        for card in startupTypeCards {
            if card.contains(touch.location(in: contentNode)) {
                if let name = card.name, name.hasPrefix("startup_") {
                    let typeName = String(name.dropFirst("startup_".count))
                    if let type = StartupType.allCases.first(where: { $0.rawValue == typeName }) {
                        Haptics.selection()
                        selectedStartupType = type
                        updateStartupTypeSelection()
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
                        Haptics.selection()
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
            let fieldY = size.height / 2 - 60  // Same as setupNameFounderStep
            let fieldArea = CGRect(x: (size.width - fieldWidth) / 2, y: fieldY - fieldHeight / 2, width: fieldWidth, height: fieldHeight)
            if fieldArea.contains(location) {
                Haptics.selection()
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
            currentStep = .chooseStartupType
            showStep(currentStep)

        case .chooseStartupType:
            currentStep = .nameFounder
            showStep(currentStep)

        case .nameFounder:
            if founderName.isEmpty {
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
        
        // Calculate position - must match setupNameFounderStep() exactly
        let fieldWidth = size.width - 60
        let fieldHeight: CGFloat = 65
        let fieldY = size.height / 2 - 60  // Same as setupNameFounderStep
        
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
        
        // Style the text field to match the game aesthetic (pink theme)
        textField.backgroundColor = UIColor(red: 0.35, green: 0.15, blue: 0.45, alpha: 0.95)
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0).cgColor // Hot pink
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
        textField.tintColor = UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Pink cursor
        
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
        
        // Hide ALL SpriteKit name field elements while editing
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") {
            nameDisplay.isHidden = true
        }
        if let fieldBg = contentNode.childNode(withName: "nameFieldBg") {
            fieldBg.isHidden = true
        }
        if let fieldGlow = contentNode.childNode(withName: "nameFieldGlow") {
            fieldGlow.isHidden = true
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
        
        // Show ALL SpriteKit name field elements
        if let nameDisplay = contentNode.childNode(withName: "nameDisplay") {
            nameDisplay.isHidden = false
        }
        if let fieldBg = contentNode.childNode(withName: "nameFieldBg") {
            fieldBg.isHidden = false
        }
        if let fieldGlow = contentNode.childNode(withName: "nameFieldGlow") {
            fieldGlow.isHidden = false
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
        GameManager.shared.newGame(name: founderName, archetype: selectedArchetype, city: selectedCity, startupType: selectedStartupType)

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
