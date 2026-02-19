//
//  DatingMinigameScene.swift
//  Pocket Bro
//

import SpriteKit

class DatingMinigameScene: BaseGameScene {
    private var dialogueLabel: SKLabelNode!
    private var choiceButtons: [PixelButtonNode] = []
    private var scoreLabel: SKLabelNode!
    private var score: Int = 0
    private var currentRound: Int = 0
    private let maxRounds = 3

    private let scenarios: [(prompt: String, choices: [(text: String, score: Int)])] = [
        (
            prompt: "Your date asks about your startup...",
            choices: [
                ("Talk passionately but listen too", 3),
                ("Explain every technical detail", 1),
                ("Change the subject to them", 2),
                ("Check your phone for emails", -1)
            ]
        ),
        (
            prompt: "The restaurant is really loud...",
            choices: [
                ("Suggest moving somewhere quieter", 3),
                ("Talk louder about your pitch deck", 0),
                ("Order more drinks", 1),
                ("Start a Slack huddle instead", -1)
            ]
        ),
        (
            prompt: "Your date mentions they have a dog...",
            choices: [
                ("Ask to see pictures!", 3),
                ("Pitch them your pet-tech startup idea", 1),
                ("Say you're more of a cat person", 0),
                ("Check if your AWS bill notification came", -1)
            ]
        ),
        (
            prompt: "The bill arrives...",
            choices: [
                ("Offer to split or pay, be chill", 3),
                ("Expense it to the company", 1),
                ("Explain your runway situation", 0),
                ("Mention you only have crypto", -1)
            ]
        ),
        (
            prompt: "They ask about work-life balance...",
            choices: [
                ("Be honest about improving it", 3),
                ("'I'll sleep when I'm funded'", 0),
                ("Quickly pivot the conversation", 1),
                ("Show them your calendar", -1)
            ]
        )
    ]

    private var currentScenario: (prompt: String, choices: [(text: String, score: Int)])?

    private let cyanColor = SKColor(red: 0.0, green: 0.95, blue: 0.95, alpha: 1.0)
    private let pinkColor = SKColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0)

    override var backgroundColor_: SKColor {
        SKColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1.0)
    }

    override func setupScene() {
        setupUI()
        showNextRound()
    }

    private func setupUI() {
        let safeTop = safeAreaInsets().top

        // Title
        let titleLabel = createLabel(text: "❤️ Dating Minigame", fontSize: 28)
        titleLabel.fontName = PixelFont.name
        titleLabel.fontColor = cyanColor
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 65)
        addChild(titleLabel)

        // Score
        scoreLabel = createLabel(text: "Vibe: 💕💕💕", fontSize: 20)
        scoreLabel.fontName = PixelFont.name
        scoreLabel.fontColor = cyanColor
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - safeTop - 105)
        addChild(scoreLabel)

        // Dialogue label - no box, plain text so it clearly reads as the question
        let boxW = size.width - 60
        let boxY = size.height - safeTop - 210
        dialogueLabel = SKLabelNode(text: "")
        dialogueLabel.fontName = PixelFont.name
        dialogueLabel.fontSize = 20
        dialogueLabel.fontColor = .white
        dialogueLabel.numberOfLines = 3
        dialogueLabel.preferredMaxLayoutWidth = boxW
        dialogueLabel.horizontalAlignmentMode = .center
        dialogueLabel.verticalAlignmentMode = .center
        dialogueLabel.position = CGPoint(x: size.width / 2, y: boxY)
        addChild(dialogueLabel)
    }

    private func showNextRound() {
        clearChoices()

        if currentRound >= maxRounds {
            endMinigame()
            return
        }

        currentScenario = scenarios.randomElement()
        guard let scenario = currentScenario else { return }

        dialogueLabel.text = scenario.prompt

        let shuffledChoices = scenario.choices.shuffled()
        let buttonHeight: CGFloat = 58
        let spacing: CGFloat = 14
        // Anchor buttons below the dialogue box (center: safeTop+210, height: 110 → bottom: safeTop+265)
        let boxBottom = size.height - safeAreaInsets().top - 265
        let gap: CGFloat = 28
        let startY = boxBottom - gap - buttonHeight / 2

        for (index, choice) in shuffledChoices.enumerated() {
            let button = PixelButtonNode(text: choice.text, size: CGSize(width: size.width - 50, height: buttonHeight))
            button.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * (buttonHeight + spacing))

            let choiceScore = choice.score
            button.onTap = { [weak self] in
                self?.selectChoice(choiceScore)
            }

            addChild(button)
            choiceButtons.append(button)
        }

        currentRound += 1
    }

    private func selectChoice(_ choiceScore: Int) {
        score += choiceScore

        // Feedback popup
        let isGood = choiceScore >= 3
        let isOkay = choiceScore >= 1
        let feedbackText: String
        let accentColor: SKColor
        if isGood {
            feedbackText = "PERFECT! 💕"
            accentColor = SKColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1.0)   // pixel green
        } else if isOkay {
            feedbackText = "NOT BAD! 💛"
            accentColor = SKColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1.0)   // also green
        } else {
            feedbackText = "MISS! 💔"
            accentColor = SKColor(red: 0.95, green: 0.2, blue: 0.3, alpha: 1.0)   // pixel red
        }

        showFeedbackPopup(text: feedbackText, color: accentColor)

        // Update vibe meter
        updateScore()

        // Disable buttons
        for button in choiceButtons {
            button.setEnabled(false)
        }

        // Next round after delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.run { [weak self] in
                self?.childNode(withName: "feedbackPopup")?.removeFromParent()
                self?.showNextRound()
            }
        ]))
    }

    private func showFeedbackPopup(text: String, color: SKColor) {
        let popup = SKNode()
        popup.name = "feedbackPopup"
        popup.zPosition = 300
        popup.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(popup)

        let panelW: CGFloat = 260
        let panelH: CGFloat = 90

        // Outer pixel border (2px offset for chunky look)
        let border = SKShapeNode(rectOf: CGSize(width: panelW + 8, height: panelH + 8), cornerRadius: 6)
        border.fillColor = color
        border.strokeColor = .clear
        popup.addChild(border)

        // Dark inner panel
        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 4)
        panel.fillColor = SKColor(red: 0.12, green: 0.08, blue: 0.22, alpha: 1.0)
        panel.strokeColor = .clear
        popup.addChild(panel)

        // Feedback text
        let label = SKLabelNode(text: text)
        label.fontName = PixelFont.name
        label.fontSize = 22
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        popup.addChild(label)

        // Animate: pop in, hold, fade out handled by caller
        popup.setScale(0.6)
        popup.alpha = 0
        popup.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ]))
    }

    private func updateScore() {
        let hearts = max(0, min(5, 3 + score / 2))
        let heartString = String(repeating: "💕", count: hearts) + String(repeating: "🖤", count: 5 - hearts)
        scoreLabel.text = "Vibe: \(heartString)"
    }

    private func clearChoices() {
        for button in choiceButtons {
            button.removeFromParent()
        }
        choiceButtons.removeAll()
    }

    private func endMinigame() {
        clearChoices()

        let success = score >= 5

        let resultTitle = success ? "Great Date! 💕" : "Awkward Date 😅"
        let resultLabel = createLabel(text: resultTitle, fontSize: 32)
        resultLabel.fontName = PixelFont.name
        resultLabel.fontColor = cyanColor
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        addChild(resultLabel)

        let message = success ?
            "You made a real connection!\nBonus social and happiness!" :
            "Well, at least you tried.\nSmall social boost."

        let messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = PixelFont.name
        messageLabel.fontSize = 18
        messageLabel.fontColor = cyanColor.withAlphaComponent(0.8)
        messageLabel.numberOfLines = 2
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.preferredMaxLayoutWidth = size.width - 60
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
        addChild(messageLabel)

        // Apply bonus effects
        if var state = GameManager.shared.state {
            if success {
                state.stats.social = min(100, state.stats.social + 15)
                state.stats.happiness = min(100, state.stats.happiness + 10)
            } else {
                state.stats.social = min(100, state.stats.social + 5)
            }
            // Note: In a full implementation, we'd save this through GameManager
        }

        // Return button
        let returnButton = PixelButtonNode(text: "Continue", size: CGSize(width: 150, height: 50))
        returnButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)

        returnButton.onTap = { [weak self] in
            self?.sceneManager?.popToMainGame()
        }

        addChild(returnButton)
    }
}
