//
//  CitySelectModal.swift
//  Pocket Bro
//

import SpriteKit

protocol CitySelectModalDelegate: AnyObject {
    func citySelectModal(_ modal: CitySelectModal, didSelect city: StartupCity)
    func citySelectModalDidClose(_ modal: CitySelectModal)
}

enum StartupCity: String, CaseIterable {
    case garage = "Garage"
    case sanFrancisco = "San Francisco"
    case austin = "Austin"
    case newYork = "New York"
    case seattle = "Seattle"
    case miami = "Miami"
    case losAngeles = "Los Angeles"
    case tokyo = "Tokyo"
    case london = "London"

    var emoji: String {
        switch self {
        case .garage: return "🏠"
        case .sanFrancisco: return "🌉"
        case .austin: return "🤠"
        case .newYork: return "🗽"
        case .seattle: return "☕"
        case .miami: return "🌴"
        case .losAngeles: return "🎬"
        case .tokyo: return "🗼"
        case .london: return "🎡"
        }
    }

    var color: SKColor {
        switch self {
        case .garage: return SKColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0)
        case .sanFrancisco: return SKColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0)
        case .austin: return SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1.0)
        case .newYork: return SKColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
        case .seattle: return SKColor(red: 0.4, green: 0.5, blue: 0.5, alpha: 1.0)
        case .miami: return SKColor(red: 0.3, green: 0.7, blue: 0.8, alpha: 1.0)
        case .losAngeles: return SKColor(red: 0.9, green: 0.6, blue: 0.5, alpha: 1.0)
        case .tokyo: return SKColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
        case .london: return SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        }
    }

    var isPremium: Bool {
        switch self {
        case .garage, .sanFrancisco, .austin: return false
        default: return true
        }
    }

    var isLocked: Bool {
        switch self {
        case .tokyo, .london: return true
        default: return false
        }
    }
}

class CitySelectModal: SKNode {
    weak var delegate: CitySelectModalDelegate?

    // Colors
    private let overlayColor = SKColor.black.withAlphaComponent(0.4)
    private let modalBackground = SKColor(red: 0.82, green: 0.82, blue: 0.78, alpha: 1.0)
    private let cardColor = SKColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0)
    private let selectedCardColor = SKColor(red: 0.78, green: 0.82, blue: 0.75, alpha: 1.0)
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

    private var selectedCity: StartupCity
    private let sceneSize: CGSize
    private var cityCards: [SKNode] = []

    init(size: CGSize, currentCity: StartupCity) {
        self.sceneSize = size
        self.selectedCity = currentCity
        super.init()
        setupModal()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupModal() {
        // Overlay
        let overlay = SKSpriteNode(color: overlayColor, size: sceneSize)
        overlay.position = .zero
        overlay.zPosition = 0
        overlay.name = "overlay"
        addChild(overlay)

        // Modal container
        let modalWidth = sceneSize.width - 40
        let modalHeight: CGFloat = 520

        let modal = SKNode()
        modal.position = CGPoint(x: 0, y: 50)
        modal.zPosition = 1
        modal.name = "modalContainer"
        addChild(modal)

        // Modal background
        let bg = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight), cornerRadius: 16)
        bg.fillColor = modalBackground
        bg.strokeColor = .clear
        modal.addChild(bg)

        // Title
        let title = SKLabelNode(text: "Change City")
        title.fontName = "Menlo-Bold"
        title.fontSize = 22
        title.fontColor = textColor
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -modalWidth/2 + 20, y: modalHeight/2 - 45)
        modal.addChild(title)

        // Close button
        let closeButton = createCloseButton()
        closeButton.position = CGPoint(x: modalWidth/2 - 30, y: modalHeight/2 - 40)
        closeButton.name = "closeButton"
        modal.addChild(closeButton)

        // City grid
        setupCityGrid(in: modal, modalWidth: modalWidth, modalHeight: modalHeight)
    }

    private func createCloseButton() -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 6)
        bg.fillColor = cardColor
        bg.strokeColor = textColor.withAlphaComponent(0.3)
        bg.lineWidth = 2
        button.addChild(bg)

        let x = SKLabelNode(text: "✕")
        x.fontName = "Menlo-Bold"
        x.fontSize = 18
        x.fontColor = textColor
        x.verticalAlignmentMode = .center
        button.addChild(x)

        return button
    }

    private func setupCityGrid(in modal: SKNode, modalWidth: CGFloat, modalHeight: CGFloat) {
        let cols = 3
        let rows = 3
        let cardWidth: CGFloat = (modalWidth - 50) / 3
        let cardHeight: CGFloat = 130
        let spacingX: CGFloat = 8
        let spacingY: CGFloat = 10

        let gridWidth = CGFloat(cols) * cardWidth + CGFloat(cols - 1) * spacingX
        let startX = -gridWidth / 2 + cardWidth / 2
        let startY = modalHeight / 2 - 90 - cardHeight / 2

        for (index, city) in StartupCity.allCases.enumerated() {
            let row = index / cols
            let col = index % cols

            let card = createCityCard(city: city, size: CGSize(width: cardWidth, height: cardHeight))
            card.position = CGPoint(
                x: startX + CGFloat(col) * (cardWidth + spacingX),
                y: startY - CGFloat(row) * (cardHeight + spacingY)
            )
            card.name = "city_\(city.rawValue)"
            modal.addChild(card)
            cityCards.append(card)
        }
    }

    private func createCityCard(city: StartupCity, size: CGSize) -> SKNode {
        let card = SKNode()

        let isSelected = city == selectedCity

        // Card background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = isSelected ? selectedCardColor : cardColor
        bg.strokeColor = .clear
        bg.name = "cardBg"
        card.addChild(bg)

        // Premium indicator
        if city.isPremium && !city.isLocked {
            let gem = SKLabelNode(text: "💎")
            gem.fontSize = 14
            gem.position = CGPoint(x: size.width/2 - 16, y: size.height/2 - 16)
            card.addChild(gem)
        }

        // Image area (colored placeholder with gradient effect)
        let imageHeight: CGFloat = size.height - 35
        let imageWidth: CGFloat = size.width - 12

        let imageArea = SKShapeNode(rectOf: CGSize(width: imageWidth, height: imageHeight), cornerRadius: 6)
        imageArea.position = CGPoint(x: 0, y: 10)

        if city.isLocked {
            imageArea.fillColor = textColor.withAlphaComponent(0.1)
        } else {
            imageArea.fillColor = city.color
        }
        imageArea.strokeColor = .clear
        card.addChild(imageArea)

        // City visual (emoji or locked)
        if city.isLocked {
            let lockEmoji = SKLabelNode(text: "?")
            lockEmoji.fontName = "Menlo-Bold"
            lockEmoji.fontSize = 36
            lockEmoji.fontColor = city == .tokyo ?
                SKColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0) :
                SKColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 1.0)
            lockEmoji.position = CGPoint(x: 0, y: 15)
            lockEmoji.verticalAlignmentMode = .center
            card.addChild(lockEmoji)
        } else {
            // City emoji
            let emoji = SKLabelNode(text: city.emoji)
            emoji.fontSize = 40
            emoji.position = CGPoint(x: 0, y: 20)
            emoji.verticalAlignmentMode = .center
            card.addChild(emoji)

            // Add some decorative elements based on city
            addCityDecoration(to: card, city: city, imageArea: imageArea)
        }

        // Name label
        let nameLabel = SKLabelNode(text: "\(city.emoji)\(city.rawValue)")
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 9
        nameLabel.fontColor = city.isLocked ? textColor.withAlphaComponent(0.5) : textColor
        nameLabel.position = CGPoint(x: 0, y: -size.height/2 + 14)

        // Truncate long names
        if city.rawValue.count > 10 {
            let shortName = String(city.rawValue.prefix(8)) + "..."
            nameLabel.text = "\(city.emoji)\(shortName)"
        }

        card.addChild(nameLabel)

        return card
    }

    private func addCityDecoration(to card: SKNode, city: StartupCity, imageArea: SKShapeNode) {
        // Add simple visual elements to make cards more interesting
        switch city {
        case .sanFrancisco:
            // Hills
            let hill = SKShapeNode(ellipseOf: CGSize(width: 60, height: 30))
            hill.fillColor = city.color.darker(by: 0.1)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: -20, y: -15)
            card.addChild(hill)

        case .newYork:
            // Buildings silhouette
            for i in 0..<3 {
                let building = SKSpriteNode(color: city.color.darker(by: 0.15),
                                            size: CGSize(width: 15, height: CGFloat(30 + i * 15)))
                building.position = CGPoint(x: CGFloat(-20 + i * 20), y: -10)
                building.anchorPoint = CGPoint(x: 0.5, y: 0)
                card.addChild(building)
            }

        case .miami:
            // Palm tree suggestion
            let palm = SKLabelNode(text: "🌊")
            palm.fontSize = 20
            palm.position = CGPoint(x: 25, y: -5)
            palm.alpha = 0.6
            card.addChild(palm)

        default:
            break
        }
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint) -> Bool {
        let localLocation = convert(location, from: parent!)

        // Check modal container
        if let modal = childNode(withName: "modalContainer") {
            // Check close button
            if let closeButton = modal.childNode(withName: "closeButton"),
               closeButton.contains(convert(localLocation, to: modal)) {
                animatePress(closeButton)
                dismiss()
                return true
            }

            // Check city cards
            for card in cityCards {
                if let name = card.name, name.hasPrefix("city_"),
                   card.contains(convert(localLocation, to: modal)) {
                    let cityName = String(name.dropFirst("city_".count))
                    if let city = StartupCity.allCases.first(where: { $0.rawValue == cityName }) {
                        handleCityTap(city, card: card)
                        return true
                    }
                }
            }
        }

        // Check overlay tap to dismiss
        if let overlay = childNode(withName: "overlay"), overlay.contains(localLocation) {
            dismiss()
            return true
        }

        return false
    }

    private func handleCityTap(_ city: StartupCity, card: SKNode) {
        guard !city.isLocked else {
            // Show locked animation
            shakeCard(card)
            return
        }

        guard !city.isPremium else {
            // Show premium required
            shakeCard(card)
            return
        }

        // Update selection
        selectedCity = city

        // Update card backgrounds
        for (index, c) in StartupCity.allCases.enumerated() {
            if let cardBg = cityCards[index].childNode(withName: "cardBg") as? SKShapeNode {
                let isSelected = c == selectedCity
                cardBg.fillColor = isSelected ? selectedCardColor : cardColor
            }
        }

        // Animate selection
        animatePress(card)

        // Notify delegate
        delegate?.citySelectModal(self, didSelect: city)
    }

    private func shakeCard(_ card: SKNode) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        card.run(shake)
    }

    private func animatePress(_ node: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(press)
    }

    func dismiss() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        run(fadeOut) { [weak self] in
            guard let self = self else { return }
            self.delegate?.citySelectModalDidClose(self)
            self.removeFromParent()
        }
    }

    func show() {
        alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        run(fadeIn)
    }
}

// Color extension for darker
extension SKColor {
    func darker(by percentage: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(
            red: max(red - percentage, 0),
            green: max(green - percentage, 0),
            blue: max(blue - percentage, 0),
            alpha: alpha
        )
    }
}
