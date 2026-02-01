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

    override func setupScene() {
        setupUI()
        showNextRound()
    }

    private func setupUI() {
        // Title
        let titleLabel = createLabel(text: "❤️ Dating Minigame", fontSize: 24)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 60)
        addChild(titleLabel)

        // Score
        scoreLabel = createLabel(text: "Vibe: 💕💕💕", fontSize: 16)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 95)
        addChild(scoreLabel)

        // Dialogue
        dialogueLabel = SKLabelNode(text: "")
        dialogueLabel.fontName = "Menlo"
        dialogueLabel.fontSize = 16
        dialogueLabel.fontColor = .white
        dialogueLabel.numberOfLines = 3
        dialogueLabel.preferredMaxLayoutWidth = size.width - 60
        dialogueLabel.horizontalAlignmentMode = .center
        dialogueLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 180)
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
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 15
        let startY = size.height / 2 + 20

        for (index, choice) in shuffledChoices.enumerated() {
            let button = PixelButtonNode(text: choice.text, size: CGSize(width: size.width - 60, height: buttonHeight))
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

        // Show feedback
        let feedback: String
        let color: SKColor
        if choiceScore >= 3 {
            feedback = "Perfect! 💕"
            color = .green
        } else if choiceScore >= 1 {
            feedback = "Not bad! 💛"
            color = .yellow
        } else if choiceScore == 0 {
            feedback = "Awkward... 😐"
            color = .orange
        } else {
            feedback = "Yikes! 💔"
            color = .red
        }

        let feedbackLabel = createLabel(text: feedback, fontSize: 24)
        feedbackLabel.fontColor = color
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        addChild(feedbackLabel)

        // Update vibe meter
        updateScore()

        // Disable buttons
        for button in choiceButtons {
            button.setEnabled(false)
        }

        // Next round after delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in
                feedbackLabel.removeFromParent()
                self?.showNextRound()
            }
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
        let resultLabel = createLabel(text: resultTitle, fontSize: 28)
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(resultLabel)

        let message = success ?
            "You made a real connection!\nBonus social and happiness!" :
            "Well, at least you tried.\nSmall social boost."

        let messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = "Menlo"
        messageLabel.fontSize = 14
        messageLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        messageLabel.numberOfLines = 2
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
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
