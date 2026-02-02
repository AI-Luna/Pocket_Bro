//
//  SettingsScene.swift
//  Pocket Bro
//

import SpriteKit

class SettingsScene: SKScene {
    weak var sceneManager: SceneManager?

    // Colors
    private let backgroundColor_ = SKColor(red: 0.85, green: 0.83, blue: 0.80, alpha: 1.0)
    private let cardColor = SKColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let accentColor = SKColor(red: 0.7, green: 0.3, blue: 0.7, alpha: 1.0)
    private let toggleOnColor = SKColor(red: 0.2, green: 0.7, blue: 0.5, alpha: 1.0)
    private let toggleOffColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

    // State
    private var liveActivitiesEnabled = true
    private var showSecondPet = false

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
        setupFirstSection()
        setupSecondSection()
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
        title.position = CGPoint(x: 30, y: size.height - safeTop - 50)
        addChild(title)

        // Close button (pixelated X)
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: size.width - 45, y: size.height - safeTop - 45)
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

        // Pixel X
        let xNode = drawPixelX()
        button.addChild(xNode)

        return button
    }

    private func drawPixelX() -> SKNode {
        let node = SKNode()
        let pixelSize: CGFloat = 2
        let color = textColor

        // Simple X pattern
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
        let bannerWidth = size.width - 60
        let bannerHeight: CGFloat = 70

        let banner = SKNode()
        banner.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 130)
        banner.name = "proBanner"
        addChild(banner)

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: bannerWidth, height: bannerHeight), cornerRadius: 12)
        bg.fillColor = accentColor
        bg.strokeColor = .clear
        banner.addChild(bg)

        // Emojis
        let emojis = SKLabelNode(text: "🥦 😊 💗")
        emojis.fontSize = 22
        emojis.position = CGPoint(x: 0, y: 10)
        banner.addChild(emojis)

        // Text
        let text = SKLabelNode(text: "Get full access Now!")
        text.fontName = PixelFont.name
        text.fontSize = PixelFont.body
        text.fontColor = .white
        text.position = CGPoint(x: 0, y: -16)
        banner.addChild(text)
    }

    // MARK: - First Section (Toggles)

    private func setupFirstSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 230
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 60

        // Section background
        let section = createSectionBackground(rows: 2, rowHeight: rowHeight, width: sectionWidth)
        section.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(section)

        // Row 1: Live Activities
        let row1 = createToggleRow(title: "Live Activities", id: "liveActivities", isOn: liveActivitiesEnabled, width: sectionWidth)
        row1.position = CGPoint(x: size.width / 2, y: sectionY + rowHeight / 2)
        addChild(row1)

        // Divider
        let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.1), size: CGSize(width: sectionWidth - 30, height: 1))
        divider.position = CGPoint(x: size.width / 2, y: sectionY)
        addChild(divider)

        // Row 2: Show Second Pet
        let row2 = createToggleRow(title: "Show Second Pet", id: "secondPet", isOn: showSecondPet, width: sectionWidth)
        row2.position = CGPoint(x: size.width / 2, y: sectionY - rowHeight / 2)
        addChild(row2)
    }

    // MARK: - Second Section (Links)

    private func setupSecondSection() {
        let safeTop = view?.safeAreaInsets.top ?? 50
        let sectionY = size.height - safeTop - 420
        let rowHeight: CGFloat = 50
        let sectionWidth = size.width - 60

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

            // Divider (except last)
            if index < rows.count - 1 {
                let divider = SKSpriteNode(color: textColor.withAlphaComponent(0.1), size: CGSize(width: sectionWidth - 30, height: 1))
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
        version.position = CGPoint(x: size.width / 2, y: 40)
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

    private func createToggleRow(title: String, id: String, isOn: Bool, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.body
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        // Toggle
        let toggle = createToggle(isOn: isOn)
        toggle.position = CGPoint(x: width / 2 - 40, y: 0)
        toggle.name = "toggle_\(id)"
        row.addChild(toggle)

        return row
    }

    private func createArrowRow(title: String, id: String, width: CGFloat) -> SKNode {
        let row = SKNode()
        row.name = "row_\(id)"

        // Title
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontSize = PixelFont.body
        titleLabel.fontColor = textColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2 + 20, y: 0)
        row.addChild(titleLabel)

        // Arrow
        let arrow = SKLabelNode(text: "↗")
        arrow.fontName = PixelFont.name
        arrow.fontSize = PixelFont.medium
        arrow.fontColor = textColor.withAlphaComponent(0.5)
        arrow.horizontalAlignmentMode = .right
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: width / 2 - 20, y: 0)
        row.addChild(arrow)

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
        let thumbX = isOn ? (width / 2 - thumbSize / 2 - 3) : (-width / 2 + thumbSize / 2 + 3)
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
        case "liveActivities":
            if let toggle = node.childNode(withName: "toggle_liveActivities") {
                toggleSwitch(toggle)
                liveActivitiesEnabled.toggle()
            }

        case "secondPet":
            if let toggle = node.childNode(withName: "toggle_secondPet") {
                toggleSwitch(toggle)
                showSecondPet.toggle()
            }

        case "rate":
            // Open App Store rating
            break

        case "share":
            // Share sheet
            break

        case "restore":
            // Restore purchases
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

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }
}
