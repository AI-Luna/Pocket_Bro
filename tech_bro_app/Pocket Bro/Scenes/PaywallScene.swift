//
//  PaywallScene.swift
//  Pocket Bro
//

import SpriteKit
import StoreKit
import RevenueCat

class PaywallScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors - Synthwave theme
    private let backgroundColor_ = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0)
    private let cardColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
    private let cyanColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0)
    private let pinkColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0)
    private let secondaryTextColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
    private let featureCardColor = SKColor(red: 0.18, green: 0.10, blue: 0.30, alpha: 1.0)
    private let darkPurple = SKColor(red: 0.18, green: 0.10, blue: 0.30, alpha: 1.0)

    private let cardHeight: CGFloat = 72

    private enum PricingPlan {
        case monthly
        case annual
    }

    private var selectedPlan: PricingPlan = .annual
    private var planCards: [PricingPlan: SKNode] = [:]
    private var packages: [PricingPlan: Package] = [:]

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
        fetchOfferings()
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

        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: 40, y: headerY)
        closeButton.name = "closeButton"
        addChild(closeButton)

        // App logo centered in header row
        let logoTexture = SKTexture(imageNamed: "TechBroLogo")
        let logo = SKSpriteNode(texture: logoTexture)
        let logoHeight: CGFloat = 26
        let logoScale = logoHeight / logoTexture.size().height
        logo.setScale(logoScale)
        logo.position = CGPoint(x: size.width / 2, y: headerY - 2)
        addChild(logo)

        let restoreLabel = SKLabelNode(text: "Restore")
        restoreLabel.fontName = PixelFont.name
        restoreLabel.fontSize = 16
        restoreLabel.fontColor = cyanColor
        restoreLabel.horizontalAlignmentMode = .right
        restoreLabel.position = CGPoint(x: size.width - 25, y: headerY - 8)
        restoreLabel.name = "restoreButton"
        addChild(restoreLabel)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 8)
        bg.fillColor = cardColor
        bg.strokeColor = cyanColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        let x = SKLabelNode(text: "✕")
        x.fontName = PixelFont.name
        x.fontSize = 18
        x.fontColor = cyanColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    // MARK: - Hero Section

    private func setupHeroSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let heroY = size.height - safeTop - 130

        let glow = SKShapeNode(circleOfRadius: 70)
        glow.fillColor = pinkColor.withAlphaComponent(0.15)
        glow.strokeColor = .clear
        glow.glowWidth = 30
        glow.position = CGPoint(x: size.width / 2, y: heroY)
        glow.zPosition = -1
        addChild(glow)

        let sparklePositions: [(CGFloat, CGFloat, CGFloat)] = [
            (-70, 45, 16), (75, 40, 14), (-50, -20, 12), (85, -15, 16), (0, 65, 18), (-90, 10, 10)
        ]
        for (index, pos) in sparklePositions.enumerated() {
            let sparkle = SKLabelNode(text: "✦")
            sparkle.fontSize = pos.2
            sparkle.fontColor = index % 2 == 0 ? cyanColor : pinkColor
            sparkle.position = CGPoint(x: size.width / 2 + pos.0, y: heroY + pos.1)
            let twinkle = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 0.4...0.7)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.4...0.7))
            ]))
            sparkle.run(twinkle)
            addChild(sparkle)
        }

        let leftChar = SKSpriteNode(imageNamed: "TechBroIcon")
        leftChar.texture?.filteringMode = .nearest
        let leftScale: CGFloat = 80 / max(leftChar.size.width, leftChar.size.height)
        leftChar.setScale(leftScale)
        leftChar.position = CGPoint(x: size.width / 2 - 60, y: heroY - 10)
        addChild(leftChar)

        let rightChar = SKSpriteNode(imageNamed: "TechGalIcon")
        rightChar.texture?.filteringMode = .nearest
        let rightScale: CGFloat = 80 / max(rightChar.size.width, rightChar.size.height)
        rightChar.setScale(rightScale)
        rightChar.position = CGPoint(x: size.width / 2 + 60, y: heroY - 10)
        addChild(rightChar)

        let floatUp = SKAction.moveBy(x: 0, y: 6, duration: 0.8)
        floatUp.timingMode = .easeInEaseOut
        let float = SKAction.repeatForever(SKAction.sequence([floatUp, floatUp.reversed()]))
        leftChar.run(float)
        rightChar.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), float]))
    }

    // MARK: - Feature Bullets

    private func setupFeatureWidget() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let widgetY = size.height - safeTop - 300
        let widgetWidth: CGFloat = size.width - 50
        let widgetHeight: CGFloat = 175

        let widget = SKShapeNode(rectOf: CGSize(width: widgetWidth, height: widgetHeight), cornerRadius: 16)
        widget.fillColor = featureCardColor
        widget.strokeColor = cyanColor.withAlphaComponent(0.15)
        widget.lineWidth = 1
        widget.position = CGPoint(x: size.width / 2, y: widgetY)
        addChild(widget)

        // Header — centered, larger, cyan
        let header = SKLabelNode(text: "TechBro Pro Features")
        header.fontName = PixelFont.name
        header.fontSize = 20
        header.fontColor = pinkColor
        header.horizontalAlignmentMode = .center
        header.verticalAlignmentMode = .center
        header.position = CGPoint(x: 0, y: 60)
        widget.addChild(header)

        // 5 bullet points with pixel art icons — tighter spacing
        let bullets: [(String, String)] = [
            ("paywall_bottle",   "Co-parent Bro with Friends"),
            ("paywall_chart",    "Enhanced Fundraising Mechanics"),
            ("paywall_rocket",   "Therapy & Advanced Burnout Recovery"),
            ("paywall_moneybag", "Premium Deep Work & Hustle Boosts"),
            ("paywall_heart",    "Support Indie Development")
        ]

        let bulletSpacing: CGFloat = 18
        let firstBulletY: CGFloat = 28
        let iconSize: CGFloat = 20

        for (index, bullet) in bullets.enumerated() {
            let y = firstBulletY - CGFloat(index) * bulletSpacing

            let icon = SKSpriteNode(imageNamed: bullet.0)
            icon.texture?.filteringMode = .nearest
            let scale = iconSize / max(icon.size.width, icon.size.height)
            icon.setScale(scale)
            icon.position = CGPoint(x: -widgetWidth / 2 + 30, y: y)
            widget.addChild(icon)

            let text = SKLabelNode(text: bullet.1)
            text.fontName = PixelFont.name
            text.fontSize = 13
            text.fontColor = secondaryTextColor
            text.horizontalAlignmentMode = .left
            text.verticalAlignmentMode = .center
            text.position = CGPoint(x: -widgetWidth / 2 + 50, y: y)
            widget.addChild(text)
        }
    }

    // MARK: - Title

    private func setupTitle() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20
        let continueButtonY = safeBottom + 100
        let cardGap: CGFloat = 12

        let monthlyY = continueButtonY + cardHeight + cardGap + 10
        let annualY = monthlyY + cardHeight + cardGap
        let annualTopEdge = annualY + cardHeight / 2

        let line2Y = annualTopEdge + 26
        let line1Y = line2Y + 24

        let line1 = SKLabelNode(text: "Unlock")
        line1.fontName = PixelFont.name
        line1.fontSize = 22
        line1.fontColor = cyanColor
        line1.position = CGPoint(x: size.width / 2, y: line1Y)
        addChild(line1)

        let line2 = SKLabelNode(text: "TechBro Pro")
        line2.fontName = PixelFont.name
        line2.fontSize = 24
        line2.fontColor = pinkColor
        line2.position = CGPoint(x: size.width / 2, y: line2Y)
        addChild(line2)
    }

    // MARK: - Pricing Options

    private func setupPricingOptions() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20
        let continueButtonY = safeBottom + 100
        let cardGap: CGFloat = 12

        let monthlyY = continueButtonY + cardHeight + cardGap + 10
        let annualY = monthlyY + cardHeight + cardGap

        let monthlyCard = createPricingCard(
            plan: .monthly,
            title: "Monthly",
            price: "—",
            subPrice: "billed monthly",
            badge: nil,
            isSelected: selectedPlan == .monthly
        )
        monthlyCard.position = CGPoint(x: size.width / 2, y: monthlyY)
        monthlyCard.name = "plan_monthly"
        addChild(monthlyCard)
        planCards[.monthly] = monthlyCard

        let annualCard = createPricingCard(
            plan: .annual,
            title: "Annual",
            price: "—",
            subPrice: "billed yearly",
            badge: "Best Value",
            isSelected: selectedPlan == .annual
        )
        annualCard.position = CGPoint(x: size.width / 2, y: annualY)
        annualCard.name = "plan_annual"
        addChild(annualCard)
        planCards[.annual] = annualCard
    }

    private func createPricingCard(plan: PricingPlan, title: String, price: String,
                                   subPrice: String, badge: String?, isSelected: Bool) -> SKNode {
        let card = SKNode()
        let cardWidth = size.width - 50

        if isSelected {
            let glow = SKShapeNode(rectOf: CGSize(width: cardWidth + 6, height: cardHeight + 6), cornerRadius: 18)
            glow.fillColor = cyanColor.withAlphaComponent(0.15)
            glow.strokeColor = .clear
            glow.glowWidth = 10
            glow.name = "glow"
            glow.zPosition = -1
            card.addChild(glow)
        }

        let bg = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 14)
        bg.fillColor = cardColor
        bg.strokeColor = isSelected ? cyanColor : secondaryTextColor.withAlphaComponent(0.2)
        bg.lineWidth = isSelected ? 2 : 1
        bg.name = "cardBg"
        card.addChild(bg)

        // Radio button
        let radioOuter = SKShapeNode(circleOfRadius: 11)
        radioOuter.fillColor = .clear
        radioOuter.strokeColor = isSelected ? cyanColor : secondaryTextColor
        radioOuter.lineWidth = 2
        radioOuter.position = CGPoint(x: -cardWidth / 2 + 28, y: 0)
        radioOuter.name = "radioOuter"
        card.addChild(radioOuter)

        if isSelected {
            let radioInner = SKShapeNode(circleOfRadius: 6)
            radioInner.fillColor = cyanColor
            radioInner.strokeColor = .clear
            radioInner.position = CGPoint(x: -cardWidth / 2 + 28, y: 0)
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
        titleLabel.position = CGPoint(x: -cardWidth / 2 + 52, y: 0)
        titleLabel.name = "titleLabel"
        card.addChild(titleLabel)

        // Price — right side, top half of card
        let priceLabel = SKLabelNode(text: price)
        priceLabel.fontName = PixelFont.name
        priceLabel.fontSize = 16
        priceLabel.fontColor = isSelected ? cyanColor : secondaryTextColor
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.verticalAlignmentMode = .center
        priceLabel.position = CGPoint(x: cardWidth / 2 - 14, y: 11)
        priceLabel.name = "priceLabel"
        card.addChild(priceLabel)

        // Sub price — right side, bottom half of card, smaller font
        let subPriceLabel = SKLabelNode(text: subPrice)
        subPriceLabel.fontName = PixelFont.regularName
        subPriceLabel.fontSize = 11
        subPriceLabel.fontColor = secondaryTextColor.withAlphaComponent(0.7)
        subPriceLabel.horizontalAlignmentMode = .right
        subPriceLabel.verticalAlignmentMode = .center
        subPriceLabel.position = CGPoint(x: cardWidth / 2 - 14, y: -10)
        subPriceLabel.name = "subPriceLabel"
        card.addChild(subPriceLabel)

        // Badge
        if let badge {
            let badgeNode = SKNode()
            badgeNode.name = "badgeNode"
            badgeNode.position = CGPoint(x: cardWidth / 2 - 46, y: cardHeight / 2)

            let badgeBg = SKShapeNode(rectOf: CGSize(width: CGFloat(badge.count) * 8 + 16, height: 24), cornerRadius: 12)
            badgeBg.fillColor = pinkColor
            badgeBg.strokeColor = .clear
            badgeBg.name = "badgeBg"
            badgeNode.addChild(badgeBg)

            let badgeLabel = SKLabelNode(text: badge)
            badgeLabel.fontName = PixelFont.name
            badgeLabel.fontSize = 11
            badgeLabel.fontColor = .white
            badgeLabel.verticalAlignmentMode = .center
            badgeLabel.horizontalAlignmentMode = .center
            badgeLabel.name = "badgeLabel"
            badgeNode.addChild(badgeLabel)

            card.addChild(badgeNode)
        }

        return card
    }

    private func updatePlanSelection() {
        let cardWidth = size.width - 50

        for (plan, card) in planCards {
            let isSelected = plan == selectedPlan

            card.childNode(withName: "glow")?.removeFromParent()
            if isSelected {
                let glow = SKShapeNode(rectOf: CGSize(width: cardWidth + 6, height: cardHeight + 6), cornerRadius: 18)
                glow.fillColor = cyanColor.withAlphaComponent(0.15)
                glow.strokeColor = .clear
                glow.glowWidth = 10
                glow.name = "glow"
                glow.zPosition = -1
                card.addChild(glow)
            }

            if let bg = card.childNode(withName: "cardBg") as? SKShapeNode {
                bg.strokeColor = isSelected ? cyanColor : secondaryTextColor.withAlphaComponent(0.2)
                bg.lineWidth = isSelected ? 2 : 1
            }
            if let radioOuter = card.childNode(withName: "radioOuter") as? SKShapeNode {
                radioOuter.strokeColor = isSelected ? cyanColor : secondaryTextColor
            }
            card.childNode(withName: "radioInner")?.removeFromParent()
            if isSelected {
                let radioInner = SKShapeNode(circleOfRadius: 6)
                radioInner.fillColor = cyanColor
                radioInner.strokeColor = .clear
                radioInner.position = CGPoint(x: -cardWidth / 2 + 28, y: 0)
                radioInner.name = "radioInner"
                card.addChild(radioInner)
            }
            if let titleLabel = card.childNode(withName: "titleLabel") as? SKLabelNode {
                titleLabel.fontColor = isSelected ? .white : secondaryTextColor
            }
            if let priceLabel = card.childNode(withName: "priceLabel") as? SKLabelNode {
                priceLabel.fontColor = isSelected ? cyanColor : secondaryTextColor
            }
        }
    }

    // MARK: - Continue Button

    private func setupContinueButton() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20
        let buttonY = safeBottom + 100
        let buttonWidth: CGFloat = size.width - 60
        let buttonHeight: CGFloat = 55

        let button = SKNode()
        button.position = CGPoint(x: size.width / 2, y: buttonY)
        button.name = "continueButton"
        addChild(button)

        let glow = SKShapeNode(rectOf: CGSize(width: buttonWidth + 10, height: buttonHeight + 10), cornerRadius: 18)
        glow.fillColor = cyanColor.withAlphaComponent(0.35)
        glow.strokeColor = .clear
        glow.glowWidth = 15
        glow.zPosition = -1
        button.addChild(glow)

        let bg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        bg.fillColor = cyanColor
        bg.strokeColor = .clear
        button.addChild(bg)

        let label = SKLabelNode(text: "Continue")
        label.fontName = PixelFont.name
        label.fontSize = 20
        label.fontColor = darkPurple
        label.verticalAlignmentMode = .center
        button.addChild(label)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ]))
        pulse.timingMode = .easeInEaseOut
        button.run(pulse)
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

    // MARK: - RevenueCat

    private func fetchOfferings() {
        PurchaseManager.shared.fetchOfferings { [weak self] offerings in
            guard let self, let offering = offerings?.current else { return }

            for package in offering.availablePackages {
                switch package.packageType {
                case .monthly:
                    self.packages[.monthly] = package
                    self.updateCardPrices(for: .monthly, package: package)

                case .annual:
                    self.packages[.annual] = package
                    self.updateCardPrices(for: .annual, package: package)

                default:
                    break
                }
            }
        }
    }

    private func updateCardPrices(for plan: PricingPlan, package: Package) {
        guard let card = planCards[plan] else { return }

        let price = package.localizedPriceString

        if let priceLabel = card.childNode(withName: "priceLabel") as? SKLabelNode {
            priceLabel.text = price
        }

        if let subPriceLabel = card.childNode(withName: "subPriceLabel") as? SKLabelNode {
            switch plan {
            case .monthly:
                subPriceLabel.text = "\(price)/mo"
            case .annual:
                let monthlyEquiv = package.storeProduct.localizedPricePerMonth ?? ""

                if let intro = package.storeProduct.introductoryDiscount, intro.price == 0 {
                    let trialStr = formatTrialPeriod(intro.subscriptionPeriod)
                    let perMonth = monthlyEquiv.isEmpty ? price : "\(monthlyEquiv)/mo"
                    subPriceLabel.text = "\(trialStr) • then \(perMonth)"
                    subPriceLabel.fontColor = cyanColor  // bright cyan — makes free trial obvious

                    updateBadge(on: card, text: "Free Trial")
                    updateContinueButtonLabel(to: "Start Free Trial")
                } else {
                    subPriceLabel.text = monthlyEquiv.isEmpty ? "billed yearly" : "\(monthlyEquiv)/mo"
                }
            }
        }
    }

    private func formatTrialPeriod(_ period: RevenueCat.SubscriptionPeriod) -> String {
        let value = period.value
        let unit: String
        switch period.unit {
        case .day:   unit = value == 1 ? "day" : "days"
        case .week:  unit = value == 1 ? "week" : "weeks"
        case .month: unit = value == 1 ? "month" : "months"
        case .year:  unit = value == 1 ? "year" : "years"
        @unknown default: unit = "period"
        }
        return "\(value) \(unit) free"
    }

    private func updateBadge(on card: SKNode, text: String) {
        guard let badgeNode = card.childNode(withName: "badgeNode") else { return }
        let isFreeTrial = text == "Free Trial"
        if let label = badgeNode.childNode(withName: "badgeLabel") as? SKLabelNode {
            label.text = text
            label.fontColor = isFreeTrial ? darkPurple : .white
        }
        if let bg = badgeNode.childNode(withName: "badgeBg") as? SKShapeNode {
            let newWidth = CGFloat(text.count) * 8 + 16
            bg.path = CGPath(roundedRect: CGRect(x: -newWidth/2, y: -12, width: newWidth, height: 24),
                             cornerWidth: 12, cornerHeight: 12, transform: nil)
            bg.fillColor = isFreeTrial ? cyanColor : pinkColor
        }
    }

    private func updateContinueButtonLabel(to text: String) {
        if let button = childNode(withName: "continueButton"),
           let label = button.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = text
        }
    }

    // MARK: - Purchase

    private func handlePurchase() {
        guard let package = packages[selectedPlan] else {
            showAlert(title: "Not Available", message: "Could not load pricing. Check your connection and try again.")
            return
        }

        guard let vc = self.view?.window?.rootViewController else { return }
        let loading = UIAlertController(title: "Processing...", message: "Please wait", preferredStyle: .alert)
        vc.present(loading, animated: true)

        PurchaseManager.shared.purchase(package: package) { [weak self] isPro, error in
            loading.dismiss(animated: true) {
                guard let self else { return }
                if let error {
                    self.showAlert(title: "Purchase Failed", message: error.localizedDescription)
                } else if isPro {
                    self.dismiss()
                }
            }
        }
    }

    private func restorePurchases() {
        guard let vc = self.view?.window?.rootViewController else { return }
        let loading = UIAlertController(title: "Restoring...", message: "Please wait", preferredStyle: .alert)
        vc.present(loading, animated: true)

        PurchaseManager.shared.restorePurchases { [weak self] isPro, error in
            loading.dismiss(animated: true) {
                guard let self else { return }
                if let error {
                    self.showAlert(title: "Restore Failed", message: error.localizedDescription)
                } else {
                    let msg = isPro ? "TechBro Pro restored successfully!" : "No active subscription found."
                    self.showAlert(title: "Restore Complete", message: msg) { [weak self] in
                        if isPro { self?.dismiss() }
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        guard let vc = self.view?.window?.rootViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        vc.present(alert, animated: true)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let closeButton = childNode(withName: "closeButton"), closeButton.contains(location) {
            animatePress(closeButton)
            dismiss()
            return
        }

        if let restore = childNode(withName: "restoreButton") as? SKLabelNode {
            if restore.frame.insetBy(dx: -20, dy: -15).contains(location) {
                restorePurchases()
                return
            }
        }

        if let monthlyCard = childNode(withName: "plan_monthly"), monthlyCard.contains(location) {
            selectedPlan = .monthly
            updatePlanSelection()
            return
        }

        if let annualCard = childNode(withName: "plan_annual"), annualCard.contains(location) {
            selectedPlan = .annual
            updatePlanSelection()
            return
        }

        if let continueButton = childNode(withName: "continueButton"), continueButton.contains(location) {
            animatePress(continueButton)
            handlePurchase()
            return
        }

        if let termsButton = childNode(withName: "termsButton") as? SKLabelNode {
            if termsButton.frame.insetBy(dx: -15, dy: -10).contains(location) {
                openURL("https://tiny-techbro.vercel.app/terms")
                return
            }
        }

        if let privacyButton = childNode(withName: "privacyButton") as? SKLabelNode {
            if privacyButton.frame.insetBy(dx: -15, dy: -10).contains(location) {
                openURL("https://tiny-techbro.vercel.app/privacy")
                return
            }
        }
    }

    private func animatePress(_ node: SKNode) {
        node.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func dismiss() {
        sceneManager?.popToMainGame()
    }
}
