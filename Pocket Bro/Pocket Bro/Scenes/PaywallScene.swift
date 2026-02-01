//
//  PaywallScene.swift
//  Pocket Bro
//

import SpriteKit

class PaywallScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors
    private let backgroundColor_ = SKColor.white
    private let textColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    private let secondaryTextColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    private let accentColor = SKColor(red: 0.6, green: 0.35, blue: 0.75, alpha: 1.0)
    private let cardColor = SKColor(red: 0.95, green: 0.95, blue: 0.93, alpha: 1.0)
    private let selectedBorderColor = SKColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)

    // State
    private var selectedPlan: PricingPlan = .yearly

    private enum PricingPlan {
        case weekly
        case yearly
    }

    private var planCards: [PricingPlan: SKNode] = [:]

    init(size: CGSize, sceneManager: SceneManager) {
        self.sceneManager = sceneManager
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = backgroundColor_
        setupUI()
    }

    private func setupUI() {
        setupHeader()
        setupHeroSection()
        setupFeatureWidget()
        setupTitle()
        setupPricingOptions()
        setupContinueButton()
        setupFooter()
    }

    // MARK: - Header

    private func setupHeader() {
        let headerY = size.height - 60

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: 35, y: headerY)
        closeButton.name = "closeButton"
        addChild(closeButton)

        // Restore button
        let restoreLabel = SKLabelNode(text: "Restore")
        restoreLabel.fontName = "Menlo-Bold"
        restoreLabel.fontSize = 16
        restoreLabel.fontColor = secondaryTextColor
        restoreLabel.horizontalAlignmentMode = .right
        restoreLabel.position = CGPoint(x: size.width - 25, y: headerY - 8)
        restoreLabel.name = "restoreButton"
        addChild(restoreLabel)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 32, height: 32), cornerRadius: 4)
        bg.fillColor = .clear
        bg.strokeColor = secondaryTextColor.withAlphaComponent(0.5)
        bg.lineWidth = 2
        button.addChild(bg)

        let x = SKLabelNode(text: "✕")
        x.fontName = "Menlo-Bold"
        x.fontSize = 16
        x.fontColor = secondaryTextColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    // MARK: - Hero Section

    private func setupHeroSection() {
        let heroY = size.height - 220

        // Sunburst/glow background
        let glow = SKShapeNode(circleOfRadius: 100)
        glow.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.6)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: size.width / 2, y: heroY)
        glow.zPosition = -1
        addChild(glow)

        // Sparkles
        let sparklePositions: [(x: CGFloat, y: CGFloat)] = [
            (-60, 60), (70, 50), (-40, -20), (80, -10), (0, 80)
        ]

        for pos in sparklePositions {
            let sparkle = SKLabelNode(text: "✨")
            sparkle.fontSize = 20
            sparkle.position = CGPoint(x: size.width / 2 + pos.x, y: heroY + pos.y)

            // Twinkle animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])
            sparkle.run(SKAction.repeatForever(twinkle))
            addChild(sparkle)
        }

        // Characters
        let leftChar = SKLabelNode(text: "👨‍💻")
        leftChar.fontSize = 60
        leftChar.position = CGPoint(x: size.width / 2 - 80, y: heroY - 20)
        addChild(leftChar)

        let rightChar = SKLabelNode(text: "👩‍💻")
        rightChar.fontSize = 60
        rightChar.position = CGPoint(x: size.width / 2 + 80, y: heroY - 10)
        addChild(rightChar)

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.5),
            SKAction.moveBy(x: 0, y: -8, duration: 0.5)
        ])
        leftChar.run(SKAction.repeatForever(bounce))

        let bounceDelayed = SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.repeatForever(bounce)
        ])
        rightChar.run(bounceDelayed)
    }

    // MARK: - Feature Widget

    private func setupFeatureWidget() {
        let widgetY = size.height - 380
        let widgetWidth: CGFloat = size.width - 80
        let widgetHeight: CGFloat = 120

        // Dark rounded container
        let widget = SKShapeNode(rectOf: CGSize(width: widgetWidth, height: widgetHeight), cornerRadius: 20)
        widget.fillColor = SKColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
        widget.strokeColor = .clear
        widget.position = CGPoint(x: size.width / 2, y: widgetY)
        addChild(widget)

        // Title
        let title = SKLabelNode(text: "Pro Features")
        title.fontName = "Menlo-Bold"
        title.fontSize = 16
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 25)
        widget.addChild(title)

        // Feature icons
        let features: [(emoji: String, color: SKColor)] = [
            ("🚀", SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)),  // Unlimited actions
            ("🎮", SKColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0)),   // Minigames
            ("💎", SKColor(red: 0.95, green: 0.5, blue: 0.7, alpha: 1.0)), // Premium characters
            ("🌆", SKColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 1.0))   // All cities
        ]

        let iconSize: CGFloat = 50
        let spacing: CGFloat = 15
        let totalWidth = CGFloat(features.count) * iconSize + CGFloat(features.count - 1) * spacing
        let startX = -totalWidth / 2 + iconSize / 2

        for (index, feature) in features.enumerated() {
            let iconBg = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: 10)
            iconBg.fillColor = feature.color
            iconBg.strokeColor = .clear
            iconBg.position = CGPoint(x: startX + CGFloat(index) * (iconSize + spacing), y: -20)
            widget.addChild(iconBg)

            let emoji = SKLabelNode(text: feature.emoji)
            emoji.fontSize = 24
            emoji.position = CGPoint(x: startX + CGFloat(index) * (iconSize + spacing), y: -20)
            emoji.verticalAlignmentMode = .center
            widget.addChild(emoji)
        }

        // Character decorations on sides
        let leftCat = SKLabelNode(text: "🧑‍💻")
        leftCat.fontSize = 30
        leftCat.position = CGPoint(x: -widgetWidth/2 + 30, y: 20)
        widget.addChild(leftCat)

        let rightCat = SKLabelNode(text: "💼")
        rightCat.fontSize = 30
        rightCat.position = CGPoint(x: widgetWidth/2 - 30, y: 20)
        widget.addChild(rightCat)
    }

    // MARK: - Title

    private func setupTitle() {
        let titleY = size.height - 480

        let title = SKLabelNode(text: "Unlock Pro with")
        title.fontName = "Menlo-Bold"
        title.fontSize = 24
        title.fontColor = textColor
        title.position = CGPoint(x: size.width / 2, y: titleY)
        addChild(title)

        let subtitle = SKLabelNode(text: "Pocket Bro!")
        subtitle.fontName = "Menlo-Bold"
        subtitle.fontSize = 24
        subtitle.fontColor = textColor
        subtitle.position = CGPoint(x: size.width / 2, y: titleY - 32)
        addChild(subtitle)
    }

    // MARK: - Pricing Options

    private func setupPricingOptions() {
        let optionsY = size.height - 590

        // Weekly option
        let weeklyCard = createPricingCard(
            plan: .weekly,
            title: "Weekly $1.99",
            price: "$1.99/wk",
            isSelected: selectedPlan == .weekly
        )
        weeklyCard.position = CGPoint(x: size.width / 2, y: optionsY)
        weeklyCard.name = "plan_weekly"
        addChild(weeklyCard)
        planCards[.weekly] = weeklyCard

        // Yearly option
        let yearlyCard = createPricingCard(
            plan: .yearly,
            title: "Yearly $12.99",
            price: "$0.25/wk",
            isSelected: selectedPlan == .yearly
        )
        yearlyCard.position = CGPoint(x: size.width / 2, y: optionsY - 60)
        yearlyCard.name = "plan_yearly"
        addChild(yearlyCard)
        planCards[.yearly] = yearlyCard

        // Lifetime option (text link)
        let lifetime = SKLabelNode(text: "Lifetime $17.99")
        lifetime.fontName = "Menlo"
        lifetime.fontSize = 14
        lifetime.fontColor = secondaryTextColor

        // Underline effect
        let underline = SKSpriteNode(color: secondaryTextColor, size: CGSize(width: lifetime.frame.width, height: 1))
        underline.position = CGPoint(x: 0, y: -10)
        lifetime.addChild(underline)

        lifetime.position = CGPoint(x: size.width / 2, y: optionsY - 115)
        lifetime.name = "plan_lifetime"
        addChild(lifetime)
    }

    private func createPricingCard(plan: PricingPlan, title: String, price: String, isSelected: Bool) -> SKNode {
        let card = SKNode()
        let cardWidth = size.width - 60
        let cardHeight: CGFloat = 50

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 8)
        bg.fillColor = cardColor
        bg.strokeColor = isSelected ? selectedBorderColor : .clear
        bg.lineWidth = isSelected ? 2 : 0
        bg.name = "cardBg"
        card.addChild(bg)

        // Radio button
        let radioOuter = SKShapeNode(circleOfRadius: 10)
        radioOuter.fillColor = .clear
        radioOuter.strokeColor = isSelected ? selectedBorderColor : secondaryTextColor
        radioOuter.lineWidth = 2
        radioOuter.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
        card.addChild(radioOuter)

        if isSelected {
            let radioInner = SKShapeNode(circleOfRadius: 5)
            radioInner.fillColor = selectedBorderColor
            radioInner.strokeColor = .clear
            radioInner.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
            radioInner.name = "radioInner"
            card.addChild(radioInner)
        }

        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "Menlo-Bold"
        titleLabel.fontSize = 15
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -cardWidth/2 + 55, y: -6)
        card.addChild(titleLabel)

        // Price per week
        let priceLabel = SKLabelNode(text: price)
        priceLabel.fontName = "Menlo"
        priceLabel.fontSize = 14
        priceLabel.fontColor = secondaryTextColor
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.position = CGPoint(x: cardWidth/2 - 20, y: -6)
        card.addChild(priceLabel)

        return card
    }

    private func updatePlanSelection() {
        for (plan, card) in planCards {
            let isSelected = plan == selectedPlan

            if let bg = card.childNode(withName: "cardBg") as? SKShapeNode {
                bg.strokeColor = isSelected ? selectedBorderColor : .clear
                bg.lineWidth = isSelected ? 2 : 0
            }

            // Update radio button
            card.childNode(withName: "radioInner")?.removeFromParent()

            if isSelected {
                let radioInner = SKShapeNode(circleOfRadius: 5)
                radioInner.fillColor = selectedBorderColor
                radioInner.strokeColor = .clear
                let cardWidth = size.width - 60
                radioInner.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
                radioInner.name = "radioInner"
                card.addChild(radioInner)
            }
        }
    }

    // MARK: - Continue Button

    private func setupContinueButton() {
        let buttonY = size.height - 730
        let buttonWidth: CGFloat = 220
        let buttonHeight: CGFloat = 55

        let button = SKNode()
        button.position = CGPoint(x: size.width / 2, y: buttonY)
        button.name = "continueButton"
        addChild(button)

        // Shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        shadow.fillColor = accentColor.withAlphaComponent(0.5)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        button.addChild(shadow)

        // Main button
        let bg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        button.addChild(bg)

        // Label
        let label = SKLabelNode(text: "Continue")
        label.fontName = "Menlo-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    // MARK: - Footer

    private func setupFooter() {
        let footerY: CGFloat = 50

        let terms = SKLabelNode(text: "Terms of Use | Privacy Policy")
        terms.fontName = "Menlo"
        terms.fontSize = 12
        terms.fontColor = secondaryTextColor
        terms.position = CGPoint(x: size.width / 2, y: footerY)
        terms.name = "footer"
        addChild(terms)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Close button
        if let closeButton = childNode(withName: "closeButton"), closeButton.contains(location) {
            animatePress(closeButton)
            dismiss()
            return
        }

        // Restore button
        if let restore = childNode(withName: "restoreButton"), restore.contains(location) {
            // Handle restore purchases
            return
        }

        // Plan selection
        if let weeklyCard = childNode(withName: "plan_weekly"), weeklyCard.contains(location) {
            selectedPlan = .weekly
            updatePlanSelection()
            return
        }

        if let yearlyCard = childNode(withName: "plan_yearly"), yearlyCard.contains(location) {
            selectedPlan = .yearly
            updatePlanSelection()
            return
        }

        if let lifetime = childNode(withName: "plan_lifetime"), lifetime.contains(location) {
            // Handle lifetime purchase
            return
        }

        // Continue button
        if let continueButton = childNode(withName: "continueButton"), continueButton.contains(location) {
            animatePress(continueButton)
            handlePurchase()
            return
        }
    }

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }

    private func handlePurchase() {
        // In a real app, this would trigger StoreKit purchase
        print("Purchase \(selectedPlan)")
        dismiss()
    }

    private func dismiss() {
        sceneManager?.popToMainGame()
    }
}
