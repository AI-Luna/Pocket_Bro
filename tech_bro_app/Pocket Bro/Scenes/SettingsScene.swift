//
//  SettingsScene.swift
//  Pocket Bro
//

import SpriteKit

class SettingsScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors - LCD green theme to match app
    private let backgroundColor_ = SKColor(red: 0.45, green: 0.55, blue: 0.45, alpha: 1.0)
    private let cardColor = SKColor(red: 0.52, green: 0.62, blue: 0.52, alpha: 1.0)
    private let textColor = SKColor(red: 0.15, green: 0.20, blue: 0.15, alpha: 1.0)
    private let accentColor = SKColor(red: 0.7, green: 0.3, blue: 0.7, alpha: 1.0)
    private let toggleOnColor = SKColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1.0)
    private let toggleOffColor = SKColor(red: 0.35, green: 0.45, blue: 0.35, alpha: 1.0)

    // State
    private var liveActivitiesEnabled = true

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
        setupPreferencesSection()
        setupLinksSection()
        setupVersionLabel()
    }

    // MARK: - Header

    private func setupHeader() {
        let safeTop = view?.safeAreaInsets.top ?? 50

        // Title
        let title = SKLabelNode(text: "Settings")
        title.fontName = PixelFont.name
        title.fontSize = PixelFont.huge
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: 25, y: size.height - safeTop - 45)
        addChild(title)

        // Close button (pixelated X)
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: size.width - 40, y: size.height - safeTop - 40)
        closeButton.name = "closeButton"
        addChild(closeButton)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 32, height: 32), cornerRadius: 4)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        // Pixel X
        let xNode = drawPixelX()
        button.addChild(xNode)

        return button
    }

    private func drawPixelX() -> SKNode {
        let node = SKNode()
        let pixelSize: CGFloat = 2
        let color = textColor

        let pattern: [[Int]] = [
            [1,0,0,0,0,0,1],
            [0,1,0,0,0,1,0],
            [0,0,1,0,1,0,0],
            [0,0,0,1,0,0,0],
            [0,0,1,0,1,0,0],
            [0,1,0,0,0,1,0],
            [1,0,0,0,0,0,1]
        ]

        let rows = pattern.count
        let cols = pattern[0].count
        let totalW = CGFloat(cols) * pixelSize
        let totalH = CGFloat(rows) * pixelSize

        for (rowIdx, row) in pattern.enumerated() {
            for (colIdx, pixel) in row.enumerated() {
                if pixel == 1 {
                    let px = SKSpriteNode(color: color, size: CGSize(width: pixelSize, height: pixelSize))
                    let xPos = CGFloat(colIdx) * pixelSize - totalW / 2 + pixelSize / 2
                    let yPos = CGFloat(rows - 1 - rowIdx) * pixelSize - totalH / 2 + pixelSize / 2
                    px.position = CGPoint(x: xPos, y: yPos)
                    node.addChild(px)
                }
            }
        }

        return node
    }

    // MARK: - Pro Banner

    private func setupProBanner() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let bannerWidth = size.width - 50
        let bannerHeight: CGFloat = 60

        let banner = SKNode()
        banner.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 105)
        banner.name = "proBanner"
        addChild(banner)

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 10)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        banner.addChild(bg)

        // Emojis and text on same line
        let text = SKLabelNode(text: "🥦 😊 💗  Get full access Now!")
        text.fontName = PixelFont.name
        text.fontSize = PixelFont.body
        text.fontColor = .white
        text.verticalAlignmentMode = .center
        banner.addChild(text)
    }

    // MARK: - Profile Section (Name & City)

    private func setupProfileSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 185
        let rowHeight: CGFloat = 44
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
        let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.15), size: CGSize(width: sectionWidth - 24, height: 1))
        divider.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(divider)

        // Row 2: Change City
        let currentCity = GameManager.shared.state?.city.rawValue ?? "San Francisco"
        let row2 = createValueRow(title: "City", value: currentCity, id: "city", width: sectionWidth)
        row2.position = CGPoint(x: size.width / 2, y: sectionY - rowHeight / 2)
        addChild(row2)
    }

    // MARK: - Preferences Section

    private func setupPreferencesSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 305
        let rowHeight: CGFloat = 44
        let sectionWidth = size.width - 50

        // Section background
        let section = createSectionBackground(rows: 1, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        // Row: Live Activities
        let row = createToggleRow(title: "Live Activities", id: "liveActivities", isOn: liveActivitiesEnabled, width: sectionWidth)
        row.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(row)
    }

    // MARK: - Links Section

    private func setupLinksSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 450
        let rowHeight: CGFloat = 44
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
                let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.15), size: CGSize(width: sectionWidth - 24, height: 1))
                divider.position = CGPoint(x: size.width / 2, y: rowY - rowHeight / 2)
                addChild(divider)
            }
        }
    }

    // MARK: - Version Label

    private func setupVersionLabel() {
        let version = SKLabelNode(text: "1.0.0 Version")
        version.fontName = PixelFont.regularName
        version.fontSize = PixelFont.small
        version.fontColor = textColor.withAlphaComponent(0.5)
        version.position = CGPoint(x: size.width / 2, y: 35)
        addChild(version)
    }

    // MARK: - Helpers

    private func createSectionBackground(rows: Int, rowHeight: CGFloat, width: CGFloat) -> SKNode {
        let height = CGFloat(rows) * rowHeight
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.1)
        bg.lineWidth = 1
        return bg
    }

    private func createValueRow(title: String, value: String, id: String, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.body
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 16, y: 0)
        row.addChild(titleLabel)

        let valueLabel = SKLabelNode(text: value)
        valueLabel.fontName = PixelFont.regularName
        valueLabel.fontSize = PixelFont.small
        valueLabel.fontColor = textColor.withAlphaComponent(0.7)
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: width / 2 - 35, y: 0)
        row.addChild(valueLabel)

        let arrow = SKLabelNode(text: "›")
        arrow.fontName = PixelFont.name
        arrow.fontSize = PixelFont.large
        arrow.fontColor = textColor.withAlphaComponent(0.4)
        arrow.horizontalAlignmentMode = .right
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: width / 2 - 16, y: 0)
        row.addChild(arrow)

        return row
    }

    private func createToggleRow(title: String, id: String, isOn: Bool, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.body
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 16, y: 0)
        row.addChild(titleLabel)

        let toggle = createToggle(isOn: isOn)
        toggle.position = CGPoint(x: width / 2 - 35, y: 0)
        toggle.name = "toggle_\(id)"
        row.addChild(toggle)

        return row
    }

    private func createArrowRow(title: String, id: String, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.body
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 16, y: 0)
        row.addChild(titleLabel)

        let arrow = SKLabelNode(text: "↗")
        arrow.fontName = PixelFont.name
        arrow.fontSize = PixelFont.medium
        arrow.fontColor = textColor.withAlphaComponent(0.4)
        arrow.horizontalAlignmentMode = .right
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: width / 2 - 16, y: 0)
        row.addChild(arrow)

        return row
    }

    private func createToggle(isOn: Bool) -> SKNode {
        let toggle = SKNode()

        let width: CGFloat = 46
        let height: CGFloat = 26

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
            animatePress(closeButton)
            sceneManager?.popToMainGame()
            return
        }

        // Pro banner
        if let banner = childNode(withName: "proBanner"), banner.contains(location) {
            animatePress(banner)
            sceneManager?.presentScene(.paywall)
            return
        }

        // Check rows
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
        case "name":
            promptForName()

        case "city":
            showCityPicker()

        case "liveActivities":
            if let toggle = node.childNode(withName: "toggle_liveActivities") {
                toggleSwitch(toggle)
                liveActivitiesEnabled.toggle()
            }

        case "rate", "share", "restore", "privacy", "terms":
            // Handle external links
            break

        default:
            break
        }
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

        viewController.present(alert, animated: true, completion: nil)
    }

    private func toggleSwitch(_ toggle: SKNode) {
        guard let isOn = toggle.userData?["isOn"] as? Bool,
              let track = toggle.childNode(withName: "track") as? SKShapeNode,
              let thumb = toggle.childNode(withName: "thumb") as? SKShapeNode else { return }

        let newState = !isOn
        toggle.userData?["isOn"] = newState

        let width: CGFloat = 46
        let thumbSize: CGFloat = 22
        let newX = newState ? (width / 2 - thumbSize / 2 - 2) : (-width / 2 + thumbSize / 2 + 2)

        let moveThumb = SKAction.moveTo(x: newX, duration: 0.15)
        moveThumb.timingMode = .easeOut
        thumb.run(moveThumb)

        let newColor = newState ? toggleOnColor : toggleOffColor
        track.run(SKAction.customAction(withDuration: 0.15) { node, time in
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
