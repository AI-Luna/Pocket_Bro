//
//  SettingsScene.swift
//  Pocket Bro
//

import SpriteKit

class SettingsScene: SKScene, CharacterSelectModalDelegate, CitySelectModalDelegate {
    weak var sceneManager: SceneManager?

    // Colors
    private let backgroundColor_ = SKColor(red: 0.85, green: 0.83, blue: 0.80, alpha: 1.0)
    private let cardColor = SKColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let accentColor = SKColor(red: 0.7, green: 0.3, blue: 0.7, alpha: 1.0)
    private let toggleOnColor = SKColor(red: 0.2, green: 0.7, blue: 0.5, alpha: 1.0)
    private let toggleOffColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

    // State
    private var notificationsEnabled = true
    private var soundEnabled = true
    private var activeModal: SKNode?

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
        setupSettingsSection()
        setupAboutSection()
        setupVersionLabel()
    }

    // MARK: - Header

    private func setupHeader() {
        // Title
        let title = SKLabelNode(text: "Settings")
        title.fontName = "Menlo-Bold"
        title.fontSize = 28
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: 30, y: size.height - 100)
        addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: size.width - 45, y: size.height - 95)
        closeButton.name = "closeButton"
        addChild(closeButton)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 4)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        let xLabel = SKLabelNode(text: "✕")
        xLabel.fontName = "Menlo-Bold"
        xLabel.fontSize = 18
        xLabel.fontColor = textColor
        xLabel.verticalAlignmentMode = .center
        button.addChild(xLabel)

        return button
    }

    // MARK: - Pro Banner

    private func setupProBanner() {
        let bannerWidth = size.width - 60
        let bannerHeight: CGFloat = 80

        let banner = SKNode()
        banner.position = CGPoint(x: size.width / 2, y: size.height - 180)
        banner.name = "proBanner"
        addChild(banner)

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 12)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        banner.addChild(bg)

        // Emojis
        let emojis = SKLabelNode(text: "🚀 💼 ⭐")
        emojis.fontSize = 24
        emojis.position = CGPoint(x: 0, y: 12)
        banner.addChild(emojis)

        // Text
        let text = SKLabelNode(text: "Unlock Pro Features!")
        text.fontName = "Menlo-Bold"
        text.fontSize = 16
        text.fontColor = .white
        text.position = CGPoint(x: 0, y: -18)
        banner.addChild(text)
    }

    // MARK: - Settings Section

    private func setupSettingsSection() {
        let sectionY = size.height - 310
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 60

        // Section background
        let section = createSectionBackground(rows: 4, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        // Rows
        let rows: [(String, SettingsRowType)] = [
            ("Notifications", .toggle("notifications", notificationsEnabled)),
            ("Sound Effects", .toggle("sound", soundEnabled)),
            ("Reset Progress", .arrow("reset")),
            ("Change Character", .arrow("character"))
        ]

        for (index, (title, rowType)) in rows.enumerated() {
            let rowY = sectionY + CGFloat(1 - index) * rowHeight + rowHeight / 2
            let row = createSettingsRow(title: title, type: rowType, width: sectionWidth)
            row.position = CGPoint(x: size.width / 2, y: rowY)
            addChild(row)

            // Divider (except last)
            if index < rows.count - 1 {
                let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.1),
                                           size: CGSize(width: sectionWidth - 30, height: 1))
                divider.position = CGPoint(x: size.width / 2, y: rowY - rowHeight / 2)
                addChild(divider)
            }
        }
    }

    // MARK: - About Section

    private func setupAboutSection() {
        let sectionY = size.height - 560
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 60

        // Section background
        let section = createSectionBackground(rows: 5, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        // Rows
        let rows: [(String, SettingsRowType)] = [
            ("Rate Us", .arrow("rate")),
            ("Share App", .arrow("share")),
            ("Feedback", .arrow("feedback")),
            ("Privacy Policy", .arrow("privacy")),
            ("Terms of Use", .arrow("terms"))
        ]

        for (index, (title, rowType)) in rows.enumerated() {
            let rowY = sectionY + CGFloat(2 - index) * rowHeight + rowHeight / 2
            let row = createSettingsRow(title: title, type: rowType, width: sectionWidth)
            row.position = CGPoint(x: size.width / 2, y: rowY)
            addChild(row)

            // Divider (except last)
            if index < rows.count - 1 {
                let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.1),
                                           size: CGSize(width: sectionWidth - 30, height: 1))
                divider.position = CGPoint(x: size.width / 2, y: rowY - rowHeight / 2)
                addChild(divider)
            }
        }
    }

    // MARK: - Version Label

    private func setupVersionLabel() {
        let version = SKLabelNode(text: "1.0.0 Version")
        version.fontName = "Menlo"
        version.fontSize = 12
        version.fontColor = textColor.withAlphaComponent(0.5)
        version.position = CGPoint(x: size.width / 2, y: 50)
        addChild(version)
    }

    // MARK: - Helpers

    private func createSectionBackground(rows: Int, rowHeight: CGFloat, width: CGFloat) -> SKNode {
        let height = CGFloat(rows) * rowHeight
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.1)
        bg.lineWidth = 1
        return bg
    }

    private enum SettingsRowType {
        case arrow(String)
        case toggle(String, Bool)
    }

    private func createSettingsRow(title: String, type: SettingsRowType, width: CGFloat) -> SKNode {
        let row = SKNode()

        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "Menlo-Bold"
        titleLabel.fontSize = 15
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        switch type {
        case .arrow(let id):
            let arrow = SKLabelNode(text: "↗")
            arrow.fontName = "Menlo-Bold"
            arrow.fontSize = 18
            arrow.fontColor = textColor.withAlphaComponent(0.5)
            arrow.horizontalAlignmentMode = .right
            arrow.verticalAlignmentMode = .center
            arrow.position = CGPoint(x: width / 2 - 20, y: 0)
            row.addChild(arrow)
            row.name = "row_\(id)"

        case .toggle(let id, let isOn):
            let toggle = createToggle(isOn: isOn)
            toggle.position = CGPoint(x: width / 2 - 40, y: 0)
            toggle.name = "toggle_\(id)"
            row.addChild(toggle)
            row.name = "row_\(id)"
        }

        return row
    }

    private func createToggle(isOn: Bool) -> SKNode {
        let toggle = SKNode()

        let width: CGFloat = 50
        let height: CGFloat = 28

        // Track
        let track = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        track.fillColor = isOn ? toggleOnColor : toggleOffColor
        track.strokeColor = .clear
        track.name = "track"
        toggle.addChild(track)

        // Thumb
        let thumbSize: CGFloat = height - 6
        let thumb = SKShapeNode(circleOfRadius: thumbSize / 2)
        thumb.fillColor = .white
        thumb.strokeColor = .clear
        thumb.position = CGPoint(x: isOn ? (width / 2 - thumbSize / 2 - 3) : (-width / 2 + thumbSize / 2 + 3), y: 0)
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
            animatePress(closeButton)
            sceneManager?.popToMainGame()
            return
        }

        // Pro banner
        if let banner = childNode(withName: "proBanner"), banner.contains(location) {
            animatePress(banner)
            // Show pro upgrade
            return
        }

        // Check all nodes for row interactions
        for node in children {
            guard let name = node.name, name.hasPrefix("row_") else { continue }

            if node.contains(location) {
                let id = String(name.dropFirst("row_".count))
                handleRowTap(id: id, node: node)
                return
            }
        }
    }

    private func handleRowTap(id: String, node: SKNode) {
        switch id {
        case "notifications":
            if let toggle = node.childNode(withName: "toggle_notifications") {
                toggleSwitch(toggle)
                notificationsEnabled.toggle()
            }

        case "sound":
            if let toggle = node.childNode(withName: "toggle_sound") {
                toggleSwitch(toggle)
                soundEnabled.toggle()
            }

        case "reset":
            showResetConfirmation()

        case "character":
            GameManager.shared.deleteGame()
            sceneManager?.presentScene(.onboarding)

        case "rate":
            // Open App Store rating
            break

        case "share":
            // Share sheet
            break

        case "feedback":
            // Feedback form
            break

        case "privacy":
            // Open privacy policy
            break

        case "terms":
            // Open terms
            break

        default:
            break
        }
    }

    private func toggleSwitch(_ toggle: SKNode) {
        guard let isOn = toggle.userData?["isOn"] as? Bool,
              let track = toggle.childNode(withName: "track") as? SKShapeNode,
              let thumb = toggle.childNode(withName: "thumb") as? SKShapeNode else { return }

        let newState = !isOn
        toggle.userData?["isOn"] = newState

        let width: CGFloat = 50
        let thumbSize: CGFloat = 22
        let newX = newState ? (width / 2 - thumbSize / 2 - 3) : (-width / 2 + thumbSize / 2 + 3)

        let moveThumb = SKAction.moveTo(x: newX, duration: 0.15)
        moveThumb.timingMode = .easeOut
        thumb.run(moveThumb)

        let colorChange = SKAction.customAction(withDuration: 0.15) { [weak self] node, time in
            guard let self = self, let shape = node as? SKShapeNode else { return }
            let progress = time / 0.15
            if newState {
                shape.fillColor = self.interpolateColor(from: self.toggleOffColor, to: self.toggleOnColor, progress: progress)
            } else {
                shape.fillColor = self.interpolateColor(from: self.toggleOnColor, to: self.toggleOffColor, progress: progress)
            }
        }
        track.run(colorChange)
    }

    private func interpolateColor(from: SKColor, to: SKColor, progress: CGFloat) -> SKColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        return SKColor(
            red: fromR + (toR - fromR) * progress,
            green: fromG + (toG - fromG) * progress,
            blue: fromB + (toB - fromB) * progress,
            alpha: fromA + (toA - fromA) * progress
        )
    }

    private func showResetConfirmation() {
        // Create overlay
        let overlay = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        overlay.name = "overlay"
        addChild(overlay)

        // Dialog
        let dialog = SKNode()
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dialog.zPosition = 101
        dialog.name = "resetDialog"
        addChild(dialog)

        let dialogBg = SKShapeNode(rectOf: CGSize(width: 280, height: 160), cornerRadius: 16)
        dialogBg.fillColor = cardColor
        dialogBg.strokeColor = .clear
        dialog.addChild(dialogBg)

        let title = SKLabelNode(text: "Reset Progress?")
        title.fontName = "Menlo-Bold"
        title.fontSize = 18
        title.fontColor = textColor
        title.position = CGPoint(x: 0, y: 40)
        dialog.addChild(title)

        let message = SKLabelNode(text: "This cannot be undone!")
        message.fontName = "Menlo"
        message.fontSize = 13
        message.fontColor = textColor.withAlphaComponent(0.7)
        message.position = CGPoint(x: 0, y: 10)
        dialog.addChild(message)

        // Cancel button
        let cancelBtn = createDialogButton(text: "Cancel", isPrimary: false)
        cancelBtn.position = CGPoint(x: -70, y: -45)
        cancelBtn.name = "cancelReset"
        dialog.addChild(cancelBtn)

        // Confirm button
        let confirmBtn = createDialogButton(text: "Reset", isPrimary: true)
        confirmBtn.position = CGPoint(x: 70, y: -45)
        confirmBtn.name = "confirmReset"
        dialog.addChild(confirmBtn)
    }

    private func createDialogButton(text: String, isPrimary: Bool) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 36), cornerRadius: 8)
        bg.fillColor = isPrimary ? SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0) : cardColor
        bg.strokeColor = isPrimary ? .clear : textColor.withAlphaComponent(0.3)
        bg.lineWidth = 1
        button.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "Menlo-Bold"
        label.fontSize = 14
        label.fontColor = isPrimary ? .white : textColor
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Handle dialog buttons
        if let dialog = childNode(withName: "resetDialog") {
            if let cancel = dialog.childNode(withName: "cancelReset"), cancel.contains(touch.location(in: dialog)) {
                childNode(withName: "overlay")?.removeFromParent()
                dialog.removeFromParent()
                return
            }

            if let confirm = dialog.childNode(withName: "confirmReset"), confirm.contains(touch.location(in: dialog)) {
                GameManager.shared.deleteGame()
                sceneManager?.presentScene(.onboarding)
                return
            }
        }
    }
}
