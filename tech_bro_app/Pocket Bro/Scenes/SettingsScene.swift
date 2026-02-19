//
//  SettingsScene.swift
//  Pocket Bro

import SpriteKit
import StoreKit
import MessageUI

class SettingsScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors - Synthwave theme to match onboarding
    private let backgroundColor_ = SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0) // Deep purple
    private let cardColor = SKColor(red: 0.28, green: 0.18, blue: 0.45, alpha: 1.0)
    private let textColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0) // Bright cyan
    private let secondaryTextColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
    private let accentColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0) // Hot pink
    private let cofounderColor = SKColor(red: 0.0, green: 0.55, blue: 1.0, alpha: 1.0) // Electric blue
    private let toggleOnColor = SKColor(red: 0.0, green: 0.85, blue: 0.85, alpha: 1.0) // Cyan
    private let toggleOffColor = SKColor(red: 0.35, green: 0.25, blue: 0.50, alpha: 1.0)


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
        setupProBanner()
        setupProfileSection()
        setupCofounderBanner()
        setupLinksSection()
        setupVersionLabel()
    }

    // MARK: - Header

    private func setupHeader() {
        let safeTop = view?.safeAreaInsets.top ?? 50

        // Title
        let title = SKLabelNode(text: "Settings")
        title.fontName = PixelFont.name
        title.fontSize = 32
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: 25, y: size.height - safeTop - 50)
        addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: size.width - 45, y: size.height - safeTop - 45)
        closeButton.name = "closeButton"
        addChild(closeButton)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 8)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        // X label
        let xLabel = SKLabelNode(text: "✕")
        xLabel.fontName = PixelFont.name
        xLabel.fontSize = 20
        xLabel.fontColor = textColor
        xLabel.verticalAlignmentMode = .center
        xLabel.horizontalAlignmentMode = .center
        button.addChild(xLabel)

        return button
    }

    // MARK: - Pro Banner

    private func setupProBanner() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let bannerWidth = size.width - 50
        let bannerHeight: CGFloat = 60

        let banner = SKNode()
        banner.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 115)
        banner.name = "proBanner"
        addChild(banner)

        // Background with glow
        let glowBg = SKShapeNode(rectOf: CGSize(width: bannerWidth + 8, height: bannerHeight + 8), cornerRadius: 16)
        glowBg.fillColor = accentColor.withAlphaComponent(0.3)
        glowBg.strokeColor = .clear
        glowBg.glowWidth = 10
        glowBg.zPosition = -1
        banner.addChild(glowBg)

        let bg = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 12)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        banner.addChild(bg)

        // Text only - no emojis
        let text = SKLabelNode(text: "Get Full Access Now!")
        text.fontName = PixelFont.name
        text.fontSize = 18
        text.fontColor = .white
        text.verticalAlignmentMode = .center
        text.horizontalAlignmentMode = .center
        banner.addChild(text)
    }

    // MARK: - Co-Founder Banner

    private func setupCofounderBanner() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let bannerWidth = size.width - 50
        let bannerHeight: CGFloat = 60

        let banner = SKNode()
        // Sits directly below the pro banner (pro center -115, height 60, bottom -145, +12 gap)
        banner.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 187)
        banner.name = "cofounderBanner"
        addChild(banner)

        let glowBg = SKShapeNode(rectOf: CGSize(width: bannerWidth + 8, height: bannerHeight + 8), cornerRadius: 16)
        glowBg.fillColor = cofounderColor.withAlphaComponent(0.3)
        glowBg.strokeColor = .clear
        glowBg.glowWidth = 10
        glowBg.zPosition = -1
        banner.addChild(glowBg)

        let bg = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 12)
        bg.fillColor = cofounderColor
        bg.strokeColor = .clear
        banner.addChild(bg)

        let text = SKLabelNode(text: "Text a Co-Founder")
        text.fontName = PixelFont.name
        text.fontSize = 18
        text.fontColor = .white
        text.verticalAlignmentMode = .center
        text.horizontalAlignmentMode = .center
        banner.addChild(text)
    }

    // MARK: - Profile Section (Name & City)

    private func setupProfileSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 282
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 50

        // Section background
        let section = createSectionBackground(rows: 2, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        // Row 1: Change Name
        let currentName = GameManager.shared.state?.name ?? "Founder"
        let row1 = createValueRow(title: "Name", value: currentName, id: "name", width: sectionWidth)
        row1.position = CGPoint(x: size.width / 2, y: sectionY + rowHeight / 2)
        addChild(row1)

        // Divider
        let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.2), size: CGSize(width: sectionWidth - 32, height: 1))
        divider.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(divider)

        // Row 2: Change City
        let currentCity = GameManager.shared.state?.city.rawValue ?? "San Francisco"
        let row2 = createValueRow(title: "City", value: currentCity, id: "city", width: sectionWidth)
        row2.position = CGPoint(x: size.width / 2, y: sectionY - rowHeight / 2)
        addChild(row2)
    }

    // MARK: - Preferences Section

    // MARK: - Links Section

    private func setupLinksSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 472
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 50

        let rows = ["Rate Us", "Share App", "Restore", "Privacy Policy", "Terms of Use"]
        let ids = ["rate", "share", "restore", "privacy", "terms"]

        // Section background
        let section = createSectionBackground(rows: rows.count, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        let totalHeight = CGFloat(rows.count) * rowHeight
        let startY = sectionY + totalHeight / 2 - rowHeight / 2

        for (index, title) in rows.enumerated() {
            let rowY = startY - CGFloat(index) * rowHeight
            let row = createArrowRow(title: title, id: ids[index], width: sectionWidth)
            row.position = CGPoint(x: size.width / 2, y: rowY)
            addChild(row)

            if index < rows.count - 1 {
                let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.2), size: CGSize(width: sectionWidth - 32, height: 1))
                divider.position = CGPoint(x: size.width / 2, y: rowY - rowHeight / 2)
                addChild(divider)
            }
        }
    }

    // MARK: - Version Label

    private func setupVersionLabel() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 20

        // Reset onboarding button (faint, for dev use)
        let resetButton = SKLabelNode(text: "Reset Onboarding")
        resetButton.fontName = PixelFont.regularName
        resetButton.fontSize = 12
        resetButton.fontColor = textColor.withAlphaComponent(0.25)
        resetButton.position = CGPoint(x: size.width / 2, y: safeBottom + 55)
        resetButton.name = "resetOnboarding"
        addChild(resetButton)

        let version = SKLabelNode(text: "Version 1.0.0")
        version.fontName = PixelFont.regularName
        version.fontSize = 14
        version.fontColor = textColor.withAlphaComponent(0.4)
        version.position = CGPoint(x: size.width / 2, y: safeBottom + 25)
        addChild(version)
    }

    // MARK: - Helpers

    private func createSectionBackground(rows: Int, rowHeight: CGFloat, width: CGFloat) -> SKNode {
        let height = CGFloat(rows) * rowHeight
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.15)
        bg.lineWidth = 1
        return bg
    }

    private func createValueRow(title: String, value: String, id: String, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = 18
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        let valueLabel = SKLabelNode(text: value)
        valueLabel.fontName = PixelFont.regularName
        valueLabel.fontSize = 16
        valueLabel.fontColor = secondaryTextColor
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: width / 2 - 40, y: 0)
        row.addChild(valueLabel)

        let arrow = SKLabelNode(text: "›")
        arrow.fontName = PixelFont.name
        arrow.fontSize = 24
        arrow.fontColor = textColor.withAlphaComponent(0.5)
        arrow.horizontalAlignmentMode = .right
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: width / 2 - 18, y: 0)
        row.addChild(arrow)

        return row
    }

    private func createToggleRow(title: String, id: String, isOn: Bool, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = 18
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        let toggle = createToggle(isOn: isOn)
        toggle.position = CGPoint(x: width / 2 - 40, y: 0)
        toggle.name = "toggle_\(id)"
        row.addChild(toggle)

        return row
    }

    private func createArrowRow(title: String, id: String, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = 18
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        let arrow = SKLabelNode(text: "↗")
        arrow.fontName = PixelFont.name
        arrow.fontSize = 18
        arrow.fontColor = textColor.withAlphaComponent(0.5)
        arrow.horizontalAlignmentMode = .right
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: width / 2 - 18, y: 0)
        row.addChild(arrow)

        return row
    }

    private func createToggle(isOn: Bool) -> SKNode {
        let toggle = SKNode()

        let width: CGFloat = 50
        let height: CGFloat = 30

        let track = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        track.fillColor = isOn ? toggleOnColor : toggleOffColor
        track.strokeColor = .clear
        track.name = "track"
        toggle.addChild(track)

        let thumbSize: CGFloat = height - 4
        let thumb = SKShapeNode(circleOfRadius: thumbSize / 2)
        thumb.fillColor = .white
        thumb.strokeColor = .clear
        let thumbX = isOn ? (width / 2 - thumbSize / 2 - 2) : (-width / 2 + thumbSize / 2 + 2)
        thumb.position = CGPoint(x: thumbX, y: 0)
        thumb.name = "thumb"
        toggle.addChild(thumb)

        toggle.userData = ["isOn": isOn]
        return toggle
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Close button
        if let closeButton = childNode(withName: "closeButton"), closeButton.contains(location) {
            Haptics.selection()
            animatePress(closeButton)
            sceneManager?.popToMainGame()
            return
        }

        // Pro banner
        if let banner = childNode(withName: "proBanner"), banner.contains(location) {
            Haptics.confirm()
            animatePress(banner)
            sceneManager?.presentScene(.paywall)
            return
        }

        // Co-founder banner
        if let banner = childNode(withName: "cofounderBanner"), banner.contains(location) {
            Haptics.confirm()
            animatePress(banner)
            shareWithCofounder()
            return
        }

        // Reset onboarding button
        if let resetButton = childNode(withName: "resetOnboarding") as? SKLabelNode {
            let expandedFrame = resetButton.frame.insetBy(dx: -20, dy: -15)
            if expandedFrame.contains(location) {
                Haptics.selection()
                resetOnboarding()
                return
            }
        }

        // Check rows
        for node in children {
            guard let name = node.name, name.hasPrefix("row_") else { continue }

            if node.contains(location) {
                let id = String(name.dropFirst("row_".count))
                Haptics.selection()
                animatePress(node)
                handleRowTap(id: id, node: node)
                return
            }
        }
    }

    private func handleRowTap(id: String, node: SKNode) {
        switch id {
        case "name":
            promptForName()

        case "city":
            showCityPicker()

        case "rate":
            requestAppReview()

        case "share":
            shareApp()

        case "restore":
            restorePurchases()

        case "privacy":
            openURL("https://tiny-techbro.vercel.app/privacy")

        case "terms":
            openURL("https://tiny-techbro.vercel.app/terms")

        default:
            break
        }
    }

    // MARK: - Actions

    private func requestAppReview() {
        if let windowScene = view?.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func shareApp() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let appURL = "https://apps.apple.com/app/idYOURAPPID" // Replace with actual App Store URL
        let message = "Check out TechBro Tamagotchi! Raise your own startup founder! 🚀👨‍💻"

        let activityVC = UIActivityViewController(
            activityItems: [message, appURL],
            applicationActivities: nil
        )

        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        viewController.present(activityVC, animated: true, completion: nil)
    }

    private func shareWithCofounder() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let appURL = "https://apps.apple.com/app/idYOURAPPID"
        let message = "okay you NEED to download this app rn 👇\n\nit's called Pocket Bro — you raise a tamagotchi-style startup founder, grind through pitch decks, survive investor meetings, avoid burnout... it's unhinged and weirdly accurate 💀🚀\n\nwe should both be playing this → \(appURL)"

        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = message
            messageVC.messageComposeDelegate = CofounderMessageDelegate.shared
            viewController.present(messageVC, animated: true)
        } else {
            // Fallback to share sheet on simulator / devices without SMS
            let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            viewController.present(activityVC, animated: true)
        }
    }

    private func restorePurchases() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let loading = UIAlertController(title: "Restoring Purchases", message: "Please wait...", preferredStyle: .alert)
        viewController.present(loading, animated: true) {
            PurchaseManager.shared.restorePurchases { isPro, error in
                loading.dismiss(animated: true) {
                    let title = error != nil ? "Restore Failed" : "Restore Complete"
                    let message: String
                    if let error {
                        message = error.localizedDescription
                    } else {
                        message = isPro ? "Your Pro access has been restored!" : "No active purchases found."
                    }
                    let result = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    result.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(result, animated: true)
                }
            }
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func resetOnboarding() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Reset Onboarding",
            message: "This will clear all data and restart the onboarding process. Are you sure?",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            // Clear all saved data
            GameManager.shared.resetAllData()

            // Navigate to onboarding
            self?.sceneManager?.presentScene(.onboarding)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }

    private func promptForName() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Change Name",
            message: "Enter a new name for your founder",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter name..."
            textField.text = GameManager.shared.state?.name ?? ""
            textField.autocapitalizationType = .words
        }

        let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                GameManager.shared.updateName(text.trimmingCharacters(in: .whitespaces))
                // Refresh the scene
                self.sceneManager?.presentScene(.settings)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true, completion: nil)
    }

    private func showCityPicker() {
        guard let viewController = self.view?.window?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Change City",
            message: "Select your startup location",
            preferredStyle: .actionSheet
        )

        for city in City.allCases {
            let action = UIAlertAction(title: "\(city.emoji) \(city.rawValue)", style: .default) { _ in
                GameManager.shared.updateCity(city)
                // Refresh the scene
                self.sceneManager?.presentScene(.settings)
            }
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        viewController.present(alert, animated: true, completion: nil)
    }

    private func toggleSwitch(_ toggle: SKNode) {
        guard let isOn = toggle.userData?["isOn"] as? Bool,
              let track = toggle.childNode(withName: "track") as? SKShapeNode,
              let thumb = toggle.childNode(withName: "thumb") as? SKShapeNode else { return }

        let newState = !isOn
        toggle.userData?["isOn"] = newState

        let width: CGFloat = 50
        let thumbSize: CGFloat = 26
        let newX = newState ? (width / 2 - thumbSize / 2 - 2) : (-width / 2 + thumbSize / 2 + 2)

        let moveThumb = SKAction.moveTo(x: newX, duration: 0.15)
        moveThumb.timingMode = .easeOut
        thumb.run(moveThumb)

        let newColor = newState ? toggleOnColor : toggleOffColor
        track.run(SKAction.customAction(withDuration: 0.15) { node, _ in
            guard let shape = node as? SKShapeNode else { return }
            shape.fillColor = newColor
        })
    }

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }
}

// MARK: - SMS Delegate

private class CofounderMessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    static let shared = CofounderMessageDelegate()

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
