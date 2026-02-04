//
//  StageIndicatorNode.swift
//  Pocket Bro
//

import SpriteKit

class StageIndicatorNode: SKNode {
    private var stageLabels: [SKLabelNode] = []
    private var progressBar: SKSpriteNode!
    private var progressFill: SKSpriteNode!
    private var currentStageLabel: SKLabelNode!

    private let totalWidth: CGFloat

    private var currentStage: StartupStage = .garage

    init(width: CGFloat = 300) {
        self.totalWidth = width
        super.init()
        setupIndicator()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupIndicator() {
        // Current stage display
        currentStageLabel = SKLabelNode(text: "🏠 Garage")
        currentStageLabel.fontName = "Menlo-Bold"
        currentStageLabel.fontSize = 16
        currentStageLabel.fontColor = .white
        currentStageLabel.horizontalAlignmentMode = .center
        currentStageLabel.position = CGPoint(x: 0, y: 20)
        addChild(currentStageLabel)

        // Progress bar background
        progressBar = SKSpriteNode(color: SKColor(white: 0.2, alpha: 1.0), size: CGSize(width: totalWidth, height: 8))
        progressBar.position = .zero
        addChild(progressBar)

        // Progress fill
        progressFill = SKSpriteNode(color: SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0), size: CGSize(width: 0, height: 6))
        progressFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressFill.position = CGPoint(x: -totalWidth / 2, y: 0)
        addChild(progressFill)

        // Stage markers
        let stages = StartupStage.allCases
        let segmentWidth = totalWidth / CGFloat(stages.count - 1)

        for (index, stage) in stages.enumerated() {
            let marker = SKSpriteNode(color: SKColor(white: 0.4, alpha: 1.0), size: CGSize(width: 4, height: 16))
            marker.position = CGPoint(x: -totalWidth / 2 + segmentWidth * CGFloat(index), y: 0)
            marker.name = "marker_\(index)"
            addChild(marker)

            let stageEmoji = stageEmoji(for: stage)
            let label = SKLabelNode(text: stageEmoji)
            label.fontSize = 12
            label.position = CGPoint(x: marker.position.x, y: -20)
            label.name = "label_\(index)"
            addChild(label)
            stageLabels.append(label)
        }
    }

    private func stageEmoji(for stage: StartupStage) -> String {
        switch stage {
        case .garage: return "🏠"
        case .preSeed: return "🌱"
        case .seed: return "🌿"
        case .seriesA: return "🌳"
        case .seriesB: return "🏢"
        case .unicorn: return "🦄"
        }
    }

    func update(stage: StartupStage, funding: Int, product: Int) {
        currentStage = stage

        let stageIndex = stage.rawValue
        currentStageLabel.text = "\(stageEmoji(for: stage)) \(stage.displayName)"

        // Calculate progress within current stage
        let baseProgress = CGFloat(stageIndex) / CGFloat(StartupStage.allCases.count - 1)

        var stageProgress: CGFloat = 0
        if let nextStage = stage.next {
            let fundingProgress = CGFloat(funding) / CGFloat(nextStage.fundingRequired)
            let productProgress = CGFloat(product) / CGFloat(nextStage.productRequired)
            stageProgress = min(1.0, (fundingProgress + productProgress) / 2)
        } else {
            stageProgress = 1.0 // At unicorn stage
        }

        let segmentWidth = 1.0 / CGFloat(StartupStage.allCases.count - 1)
        let totalProgress = baseProgress + (stageProgress * segmentWidth)
        let targetWidth = totalWidth * min(1.0, totalProgress)

        // Animate progress bar
        let resize = SKAction.resize(toWidth: targetWidth, duration: 0.5)
        resize.timingMode = .easeOut
        progressFill.run(resize)

        // Update markers
        for (index, _) in StartupStage.allCases.enumerated() {
            if let marker = childNode(withName: "marker_\(index)") as? SKSpriteNode {
                if index <= stageIndex {
                    marker.color = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
                } else {
                    marker.color = SKColor(white: 0.4, alpha: 1.0)
                }
            }
        }
    }

    func animateStageAdvance() {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        currentStageLabel.run(SKAction.repeat(pulse, count: 3))

        let flash = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.3)
        ])
        progressFill.run(flash)
    }
}
