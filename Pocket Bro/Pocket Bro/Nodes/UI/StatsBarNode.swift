//
//  StatsBarNode.swift
//  Pocket Bro
//

import SpriteKit

class StatsBarNode: SKNode {
    private let statType: StatType
    private let barWidth: CGFloat
    private let barHeight: CGFloat = 12

    private var backgroundBar: SKSpriteNode!
    private var fillBar: SKSpriteNode!
    private var iconLabel: SKLabelNode!
    private var valueLabel: SKLabelNode!

    private var currentValue: Int = 0
    private var maxValue: Int = 100

    init(statType: StatType, width: CGFloat = 120) {
        self.statType = statType
        self.barWidth = width
        self.maxValue = statType.maxValue
        super.init()
        setupBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBar() {
        // Icon
        iconLabel = SKLabelNode(text: statType.emoji)
        iconLabel.fontSize = 14
        iconLabel.horizontalAlignmentMode = .left
        iconLabel.verticalAlignmentMode = .center
        iconLabel.position = CGPoint(x: 0, y: 0)
        addChild(iconLabel)

        // Background bar
        backgroundBar = SKSpriteNode(color: SKColor(white: 0.2, alpha: 1.0), size: CGSize(width: barWidth, height: barHeight))
        backgroundBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        backgroundBar.position = CGPoint(x: 24, y: 0)
        addChild(backgroundBar)

        // Fill bar
        fillBar = SKSpriteNode(color: colorForStat(), size: CGSize(width: barWidth, height: barHeight - 4))
        fillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillBar.position = CGPoint(x: 26, y: 0)
        addChild(fillBar)

        // Value label
        valueLabel = SKLabelNode(text: "0")
        valueLabel.fontName = "Menlo-Bold"
        valueLabel.fontSize = 10
        valueLabel.fontColor = .white
        valueLabel.horizontalAlignmentMode = .left
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: barWidth + 30, y: 0)
        addChild(valueLabel)
    }

    private func colorForStat() -> SKColor {
        switch statType {
        case .energy:
            return SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        case .health:
            return SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        case .happiness:
            return SKColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0)
        case .social:
            return SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        case .burnout:
            return SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)
        case .funding:
            return SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        case .product:
            return SKColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
        case .runway:
            return SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
        }
    }

    func setValue(_ value: Int, animated: Bool = true) {
        let clampedValue = max(0, min(value, maxValue))
        let previousValue = currentValue
        currentValue = clampedValue

        let percentage = CGFloat(clampedValue) / CGFloat(maxValue)
        let targetWidth = max(2, (barWidth - 4) * percentage)

        valueLabel.text = "\(clampedValue)"

        if animated {
            let resize = SKAction.resize(toWidth: targetWidth, duration: 0.3)
            resize.timingMode = .easeOut
            fillBar.run(resize)

            if clampedValue < previousValue {
                flashColor(.red)
            } else if clampedValue > previousValue {
                flashColor(.green)
            }
        } else {
            fillBar.size.width = targetWidth
        }

        updateBarColor(percentage: percentage)
    }

    private func updateBarColor(percentage: CGFloat) {
        let baseColor = colorForStat()

        if statType.isInverted {
            if percentage > 0.7 {
                fillBar.color = .red
            } else if percentage > 0.4 {
                fillBar.color = .orange
            } else {
                fillBar.color = baseColor
            }
        } else {
            if percentage < 0.2 {
                fillBar.color = .red
            } else if percentage < 0.4 {
                fillBar.color = .orange
            } else {
                fillBar.color = baseColor
            }
        }
    }

    private func flashColor(_ color: SKColor) {
        let flash = SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        ])
        fillBar.run(flash)
    }
}
