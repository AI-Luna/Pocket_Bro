//
//  PaywallScene.swift
//  Pocket Bro

import SpriteKit
import StoreKit

class PaywallScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors - Synthwave theme
    private let backgroundColor_ = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0) // Deep purple
    private let cardColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
    private let textColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) // Bright cyan
    private let secondaryTextColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
    private let accentColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Hot pink
    private let featureCardColor = SKColor(red: 0.18, green: 0.10, blue: 0.30, alpha: 1.0)

    // State
    private var selectedPlan: PricingPlan = .yearly

    private enum PricingPlan {
        case weekly
        case yearly
        case lifetime
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
        let safeTop = view?.safeAreaInsets.top ?? 50
        let headerY = size.height - safeTop - 30

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: 40, y: headerY)
        closeButton.name = "closeButton"
        addChild(closeButton)

        // Restore button
        let restoreLabel = SKLabelNode(text: "Restore")
        restoreLabel.fontName = PixelFont.name
        restoreLabel.fontSize = 16
        restoreLabel.fontColor = textColor
        restoreLabel.horizontalAlignmentMode = .right
        restoreLabel.position = CGPoint(x: size.width - 25, y: headerY - 8)
        restoreLabel.name = "restoreButton"
        addChild(restoreLabel)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 8)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        let x = SKLabelNode(text: "✕")
        x.fontName = PixelFont.name
        x.fontSize = 18
        x.fontColor = textColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    // MARK: - Hero Section

    private func setupHeroSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let heroY = size.height - safeTop - 140

        // Glow background circle
        let glow = SKShapeNode(circleOfRadius: 80)
        glow.fillColor = accentColor.withAlphaComponent(0.15)
        glow.strokeColor = .clear
        glow.glowWidth = 30
        glow.position = CGPoint(x: size.width / 2, y: heroY)
        glow.zPosition = -1
        addChild(glow)

        // Inner glow
        let innerGlow = SKShapeNode(circleOfRadius: 50)
        innerGlow.fillColor = accentColor.withAlphaComponent(0.2)
        innerGlow.strokeColor = .clear
        innerGlow.position = CGPoint(x: size.width / 2, y: heroY)
        innerGlow.zPosition = -1
        addChild(innerGlow)

        // Sparkles with cyan/pink colors
        let sparklePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
            (-70, 50, 16), (75, 45, 14), (-50, -25, 12), (85, -15, 16), (0, 70, 18), (-90, 10, 10)
        ]

        for (index, pos) in sparklePositions.enumerated() {
            let sparkle = SKLabelNode(text: "✦")
            sparkle.fontSize = pos.size
            sparkle.fontColor = index % 2 == 0 ? textColor : accentColor
            sparkle.position = CGPoint(x: size.width / 2 + pos.x, y: heroY + pos.y)

            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 0.4...0.7)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.4...0.7))
            ])
            sparkle.run(SKAction.repeatForever(twinkle))
            addChild(sparkle)
        }

        // Use actual character sprites - preserve original aspect ratios
        let leftChar = SKSpriteNode(imageNamed: "TechBroIcon")
        leftChar.texture?.filteringMode = .nearest  // Pixel art style
        // Scale uniformly based on original texture size
        let leftScale: CGFloat = 90 / max(leftChar.size.width, leftChar.size.height)
        leftChar.setScale(leftScale)
        leftChar.position = CGPoint(x: size.width / 2 - 70, y: heroY - 10)
        addChild(leftChar)

        let rightChar = SKSpriteNode(imageNamed: "TechGalIcon")
        rightChar.texture?.filteringMode = .nearest  // Pixel art style
        // Scale uniformly based on original texture size
        let rightScale: CGFloat = 90 / max(rightChar.size.width, rightChar.size.height)
        rightChar.setScale(rightScale)
        rightChar.position = CGPoint(x: size.width / 2 + 70, y: heroY - 10)
        addChild(rightChar)

        // Gentle float animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.8),
            SKAction.moveBy(x: 0, y: -6, duration: 0.8)
        ])
        float.timingMode = .easeInEaseOut
        leftChar.run(SKAction.repeatForever(float))

        let floatDelayed = SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.repeatForever(float)
        ])
        rightChar.run(floatDelayed)
    }

    // MARK: - Feature Widget

    private func setupFeatureWidget() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let widgetY = size.height - safeTop - 280
        let widgetWidth: CGFloat = size.width - 50
        let widgetHeight: CGFloat = 110

        // Dark rounded container
        let widget = SKShapeNode(rectOf: CGSize(width: widgetWidth, height: widgetHeight), cornerRadius: 16)
        widget.fillColor = featureCardColor
        widget.strokeColor = textColor.withAlphaComponent(0.15)
        widget.lineWidth = 1
        widget.position = CGPoint(x: size.width / 2, y: widgetY)
        addChild(widget)

        // Title
        let title = SKLabelNode(text: "Pro Features")
        title.fontName = PixelFont.name
        title.fontSize = 16
        title.fontColor = textColor
        title.position = CGPoint(x: 0, y: 25)
        widget.addChild(title)

        // Feature icons with synthwave colors
        let features: [(emoji: String, color: SKColor)] = [
            ("🚀", SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)),
            ("🎮", SKColor(red: 0.2, green: 0.85, blue: 0.7, alpha: 1.0)),
            ("💎", accentColor),
            ("🌆", SKColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 1.0))
        ]

        let iconSize: CGFloat = 48
        let spacing: CGFloat = 12
        let totalWidth = CGFloat(features.count) * iconSize + CGFloat(features.count - 1) * spacing
        let startX = -totalWidth / 2 + iconSize / 2
        let iconsY: CGFloat = -22  // Vertical center for icons row

        for (index, feature) in features.enumerated() {
            let xPos = startX + CGFloat(index) * (iconSize + spacing)

            let iconBg = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: 12)
            iconBg.fillColor = feature.color
            iconBg.strokeColor = .clear
            iconBg.position = CGPoint(x: xPos, y: iconsY)
            widget.addChild(iconBg)

            let emoji = SKLabelNode(text: feature.emoji)
            emoji.fontSize = 22
            emoji.position = CGPoint(x: xPos, y: iconsY)  // Same position as background
            emoji.verticalAlignmentMode = .center
            emoji.horizontalAlignmentMode = .center
            widget.addChild(emoji)
        }
    }

    // MARK: - Title

    private func setupTitle() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let titleY = size.height - safeTop - 365

        let title = SKLabelNode(text: "Unlock Pro with")
        title.fontName = PixelFont.name
        title.fontSize = 22
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: titleY)
        addChild(title)

        let subtitle = SKLabelNode(text: "Pocket Bro!")
        subtitle.fontName = PixelFont.name
        subtitle.fontSize = 22
        subtitle.fontColor = accentColor
        subtitle.position = CGPoint(x: size.width / 2, y: titleY - 30)
        addChild(subtitle)
    }

    // MARK: - Pricing Options

    private func setupPricingOptions() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let optionsY = size.height - safeTop - 450

        // Weekly option
        let weeklyCard = createPricingCard(
            plan: .weekly,
            title: "Weekly",
            price: "$1.99",
            subPrice: "$1.99/wk",
            isSelected: selectedPlan == .weekly
        )
        weeklyCard.position = CGPoint(x: size.width / 2, y: optionsY)
        weeklyCard.name = "plan_weekly"
        addChild(weeklyCard)
        planCards[.weekly] = weeklyCard

        // Yearly option
        let yearlyCard = createPricingCard(
            plan: .yearly,
            title: "Yearly",
            price: "$12.99",
            subPrice: "$0.25/wk",
            isSelected: selectedPlan == .yearly
        )
        yearlyCard.position = CGPoint(x: size.width / 2, y: optionsY - 65)
        yearlyCard.name = "plan_yearly"
        addChild(yearlyCard)
        planCards[.yearly] = yearlyCard

        // Lifetime option
        let lifetimeCard = createPricingCard(
            plan: .lifetime,
            title: "Lifetime",
            price: "$17.99",
            subPrice: "One-time",
            isSelected: selectedPlan == .lifetime
        )
        lifetimeCard.position = CGPoint(x: size.width / 2, y: optionsY - 130)
        lifetimeCard.name = "plan_lifetime"
        addChild(lifetimeCard)
        planCards[.lifetime] = lifetimeCard
    }

    private func createPricingCard(plan: PricingPlan, title: String, price: String, subPrice: String, isSelected: Bool) -> SKNode {
        let card = SKNode()
        let cardWidth = size.width - 50
        let cardHeight: CGFloat = 55

        // Glow for selected
        if isSelected {
            let glow = SKShapeNode(rectOf: CGSize(width: cardWidth + 6, height: cardHeight + 6), cornerRadius: 16)
            glow.fillColor = accentColor.withAlphaComponent(0.3)
            glow.strokeColor = .clear
            glow.glowWidth = 8
            glow.name = "glow"
            glow.zPosition = -1
            card.addChild(glow)
        }

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 14)
        bg.fillColor = cardColor
        bg.strokeColor = isSelected ? accentColor : textColor.withAlphaComponent(0.2)
        bg.lineWidth = isSelected ? 2 : 1
        bg.name = "cardBg"
        card.addChild(bg)

        // Radio button
        let radioOuter = SKShapeNode(circleOfRadius: 11)
        radioOuter.fillColor = .clear
        radioOuter.strokeColor = isSelected ? accentColor : secondaryTextColor
        radioOuter.lineWidth = 2
        radioOuter.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
        radioOuter.name = "radioOuter"
        card.addChild(radioOuter)

        if isSelected {
            let radioInner = SKShapeNode(circleOfRadius: 6)
            radioInner.fillColor = accentColor
            radioInner.strokeColor = .clear
            radioInner.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
            radioInner.name = "radioInner"
            card.addChild(radioInner)
        }

        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = 16
        titleLabel.fontColor = isSelected ? .white : secondaryTextColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -cardWidth/2 + 55, y: 0)
        titleLabel.name = "titleLabel"
        card.addChild(titleLabel)

        // Price
        let priceLabel = SKLabelNode(text: price)
        priceLabel.fontName = PixelFont.name
        priceLabel.fontSize = 16
        priceLabel.fontColor = isSelected ? accentColor : secondaryTextColor
        priceLabel.horizontalAlignmentMode = .left
        priceLabel.verticalAlignmentMode = .center
        priceLabel.position = CGPoint(x: -cardWidth/2 + 140, y: 0)
        priceLabel.name = "priceLabel"
        card.addChild(priceLabel)

        // Sub price (per week)
        let subPriceLabel = SKLabelNode(text: subPrice)
        subPriceLabel.fontName = PixelFont.regularName
        subPriceLabel.fontSize = 14
        subPriceLabel.fontColor = secondaryTextColor.withAlphaComponent(0.7)
        subPriceLabel.horizontalAlignmentMode = .right
        subPriceLabel.verticalAlignmentMode = .center
        subPriceLabel.position = CGPoint(x: cardWidth/2 - 20, y: 0)
        card.addChild(subPriceLabel)

        return card
    }

    private func updatePlanSelection() {
        for (plan, card) in planCards {
            let isSelected = plan == selectedPlan
            let cardWidth = size.width - 50

            // Update glow
            card.childNode(withName: "glow")?.removeFromParent()
            if isSelected {
                let glow = SKShapeNode(rectOf: CGSize(width: cardWidth + 6, height: 61), cornerRadius: 16)
                glow.fillColor = accentColor.withAlphaComponent(0.3)
                glow.strokeColor = .clear
                glow.glowWidth = 8
                glow.name = "glow"
                glow.zPosition = -1
                card.addChild(glow)
            }

            // Update background
            if let bg = card.childNode(withName: "cardBg") as? SKShapeNode {
                bg.strokeColor = isSelected ? accentColor : textColor.withAlphaComponent(0.2)
                bg.lineWidth = isSelected ? 2 : 1
            }

            // Update radio outer
            if let radioOuter = card.childNode(withName: "radioOuter") as? SKShapeNode {
                radioOuter.strokeColor = isSelected ? accentColor : secondaryTextColor
            }

            // Update radio inner
            card.childNode(withName: "radioInner")?.removeFromParent()
            if isSelected {
                let radioInner = SKShapeNode(circleOfRadius: 6)
                radioInner.fillColor = accentColor
                radioInner.strokeColor = .clear
                radioInner.position = CGPoint(x: -cardWidth/2 + 30, y: 0)
                radioInner.name = "radioInner"
                card.addChild(radioInner)
            }

            // Update title color
            if let titleLabel = card.childNode(withName: "titleLabel") as? SKLabelNode {
                titleLabel.fontColor = isSelected ? .white : secondaryTextColor
            }

            // Update price color
            if let priceLabel = card.childNode(withName: "priceLabel") as? SKLabelNode {
                priceLabel.fontColor = isSelected ? accentColor : secondaryTextColor
            }
        }
    }

    // MARK: - Continue Button

    private func setupContinueButton() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20
        let buttonY = safeBottom + 100
        let buttonWidth: CGFloat = size.width - 100
        let buttonHeight: CGFloat = 55

        let button = SKNode()
        button.position = CGPoint(x: size.width / 2, y: buttonY)
        button.name = "continueButton"
        addChild(button)

        // Glow
        let glow = SKShapeNode(rectOf: CGSize(width: buttonWidth + 10, height: buttonHeight + 10), cornerRadius: 18)
        glow.fillColor = accentColor.withAlphaComponent(0.4)
        glow.strokeColor = .clear
        glow.glowWidth = 15
        glow.zPosition = -1
        button.addChild(glow)

        // Main button
        let bg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        button.addChild(bg)

        // Label
        let label = SKLabelNode(text: "Continue")
        label.fontName = PixelFont.name
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        pulse.timingMode = .easeInEaseOut
        button.run(SKAction.repeatForever(pulse))
    }

    // MARK: - Footer

    private func setupFooter() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20
        let footerY = safeBottom + 35

        let termsButton = SKLabelNode(text: "Terms of Use")
        termsButton.fontName = PixelFont.regularName
        termsButton.fontSize = 12
        termsButton.fontColor = secondaryTextColor.withAlphaComponent(0.6)
        termsButton.position = CGPoint(x: size.width / 2 - 70, y: footerY)
        termsButton.name = "termsButton"
        addChild(termsButton)

        let divider = SKLabelNode(text: "|")
        divider.fontName = PixelFont.regularName
        divider.fontSize = 12
        divider.fontColor = secondaryTextColor.withAlphaComponent(0.4)
        divider.position = CGPoint(x: size.width / 2, y: footerY)
        addChild(divider)

        let privacyButton = SKLabelNode(text: "Privacy Policy")
        privacyButton.fontName = PixelFont.regularName
        privacyButton.fontSize = 12
        privacyButton.fontColor = secondaryTextColor.withAlphaComponent(0.6)
        privacyButton.position = CGPoint(x: size.width / 2 + 70, y: footerY)
        privacyButton.name = "privacyButton"
        addChild(privacyButton)
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
        if let restore = childNode(withName: "restoreButton") as? SKLabelNode {
            let expandedFrame = restore.frame.insetBy(dx: -20, dy: -15)
            if expandedFrame.contains(location) {
                restorePurchases()
                return
            }
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

        if let lifetimeCard = childNode(withName: "plan_lifetime"), lifetimeCard.contains(location) {
            selectedPlan = .lifetime
            updatePlanSelection()
            return
        }

        // Continue button
        if let continueButton = childNode(withName: "continueButton"), continueButton.contains(location) {
            animatePress(continueButton)
            handlePurchase()
            return
        }

        // Terms button
        if let termsButton = childNode(withName: "termsButton") as? SKLabelNode {
            let expandedFrame = termsButton.frame.insetBy(dx: -15, dy: -10)
            if expandedFrame.contains(location) {
                openURL("https://example.com/terms")
                return
            }
        }

        // Privacy button
        if let privacyButton = childNode(withName: "privacyButton") as? SKLabelNode {
            let expandedFrame = privacyButton.frame.insetBy(dx: -15, dy: -10)
            if expandedFrame.contains(location) {
                openURL("https://example.com/privacy")
                return
            }
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

        // Show loading then dismiss
        guard let viewController = self.view?.window?.rootViewController else {
            dismiss()
            return
        }

        let alert = UIAlertController(
            title: "Processing...",
            message: "Please wait",
            preferredStyle: .alert
        )

        viewController.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true) {
                    self.dismiss()
                }
            }
        }
    }

    private func restorePurchases() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Restoring Purchases",
            message: "Please wait...",
            preferredStyle: .alert
        )

        viewController.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true) {
                    let resultAlert = UIAlertController(
                        title: "Restore Complete",
                        message: "Your purchases have been restored.",
                        preferredStyle: .alert
                    )
                    resultAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(resultAlert, animated: true)
                }
            }
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func dismiss() {
        sceneManager?.popToMainGame()
    }
}
