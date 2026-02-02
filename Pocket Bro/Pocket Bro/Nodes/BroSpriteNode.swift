//
//  BroSpriteNode.swift
//  Pocket Bro
//

import SpriteKit

class BroSpriteNode: SKNode {
    private var bodySprite: SKSpriteNode!
    private var accessorySprite: SKSpriteNode?

    private let pixelScale: CGFloat = 4.0

    // Sprite sheet layout: 5 columns x 4 rows
    private let columns = 5
    private let rows = 4

    // Frame textures sliced from the sprite sheet
    private var allFrames: [[SKTexture]] = []

    // Eating/drinking sprite sheet layout: 5 columns x 4 rows
    private var eatingFrames: [[SKTexture]] = []

    // Animation frame groups
    private var idleFrames: [SKTexture] = []
    private var walkFrames: [SKTexture] = []
    private var workFrames: [SKTexture] = []
    private var jumpFrame: SKTexture?
    private var eatDrinkFrames: [SKTexture] = []

    var archetype: Archetype = .bro {
        didSet { updateAppearance() }
    }

    var mood: BroMood = .neutral {
        didSet { }
    }

    override init() {
        super.init()
        loadSpriteSheet()
        loadEatingDrinkingSpriteSheet()
        setupSprites()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sprite Sheet Loading

    private func loadSpriteSheet() {
        let sheetTexture = SKTexture(imageNamed: "BroSpriteSheet")
        sheetTexture.filteringMode = .nearest

        let frameWidth = 1.0 / CGFloat(columns)
        let frameHeight = 1.0 / CGFloat(rows)

        // Slice the sheet into a 2D array of textures
        // SKTexture rect origin is bottom-left, so row 0 in the image (top) = row index (rows-1) in texture coords
        for row in 0..<rows {
            var rowFrames: [SKTexture] = []
            for col in 0..<columns {
                let x = CGFloat(col) * frameWidth
                let y = CGFloat(rows - 1 - row) * frameHeight
                let rect = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
                let frame = SKTexture(rect: rect, in: sheetTexture)
                frame.filteringMode = .nearest
                rowFrames.append(frame)
            }
            allFrames.append(rowFrames)
        }

        // Assign animation groups based on the sprite sheet layout:
        // Row 0: idle/standing (0-2), walk start (3), run (4)
        // Row 1: walk cycle (0-3), jump/excited (4)
        // Row 2: walk variants (0-3), sitting at desk (4)
        // Row 3: idle variations (0-3), sitting at desk typing (4)

        idleFrames = [
            allFrames[0][0], allFrames[0][1], allFrames[0][2],
            allFrames[0][1], allFrames[0][0],
            allFrames[3][0], allFrames[3][1], allFrames[3][2], allFrames[3][3],
            allFrames[3][2], allFrames[3][1], allFrames[3][0]
        ]

        walkFrames = [
            allFrames[1][0], allFrames[1][1], allFrames[1][2], allFrames[1][3],
            allFrames[2][0], allFrames[2][1], allFrames[2][2], allFrames[2][3]
        ]

        workFrames = [
            allFrames[2][4], allFrames[3][4]
        ]

        jumpFrame = allFrames[1][4]
    }

    private func loadEatingDrinkingSpriteSheet() {
        let sheetTexture = SKTexture(imageNamed: "EatingDrinkingSpriteSheet")
        sheetTexture.filteringMode = .nearest

        let frameWidth = 1.0 / CGFloat(columns)
        let frameHeight = 1.0 / CGFloat(rows)

        // Inset each texture rect by half a pixel to prevent SpriteKit sampling bleed
        let insetX = 0.5 / 400.0  // sheet is 400px wide
        let insetY = 0.5 / 384.0  // sheet is 384px tall

        for row in 0..<rows {
            var rowFrames: [SKTexture] = []
            for col in 0..<columns {
                let x = CGFloat(col) * frameWidth + insetX
                let y = CGFloat(rows - 1 - row) * frameHeight + insetY
                let rect = CGRect(x: x, y: y, width: frameWidth - 2 * insetX, height: frameHeight - 2 * insetY)
                let frame = SKTexture(rect: rect, in: sheetTexture)
                frame.filteringMode = .nearest
                rowFrames.append(frame)
            }
            eatingFrames.append(rowFrames)
        }

        // Build eating/drinking animation sequence from the sprite sheet
        // Row 0: reaching for food / holding (5 frames)
        // Row 1: bringing to mouth / eating (5 frames)
        // Row 2: chewing / drinking (5 frames)
        // Row 3: finishing up / satisfied (4 frames, [3][4] is empty)
        eatDrinkFrames = [
            eatingFrames[0][0], eatingFrames[0][1], eatingFrames[0][2], eatingFrames[0][3], eatingFrames[0][4],
            eatingFrames[1][0], eatingFrames[1][1], eatingFrames[1][2], eatingFrames[1][3], eatingFrames[1][4],
            eatingFrames[2][0], eatingFrames[2][1], eatingFrames[2][2], eatingFrames[2][3], eatingFrames[2][4],
            eatingFrames[3][0], eatingFrames[3][1], eatingFrames[3][2], eatingFrames[3][3]
        ]
    }

    // MARK: - Setup

    private func setupSprites() {
        guard !allFrames.isEmpty else { return }

        bodySprite = SKSpriteNode(texture: allFrames[0][0])
        bodySprite.texture?.filteringMode = .nearest
        bodySprite.setScale(pixelScale)
        bodySprite.position = .zero
        addChild(bodySprite)

        startIdleAnimation()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // The sprite sheet has a single character design;
        // archetype could tint or swap sheets in the future.
        // For now, apply a subtle color blend to differentiate archetypes.
        let blendColor: SKColor
        let blendFactor: CGFloat

        switch archetype {
        case .bro:
            blendColor = .clear
            blendFactor = 0.0
        case .gal:
            blendColor = SKColor(red: 0.85, green: 0.3, blue: 0.55, alpha: 1.0)
            blendFactor = 0.2
        case .nonBinary:
            blendColor = SKColor(red: 0.6, green: 0.35, blue: 0.85, alpha: 1.0)
            blendFactor = 0.2
        }

        bodySprite.color = blendColor
        bodySprite.colorBlendFactor = blendFactor
    }

    // MARK: - Animations

    func startIdleAnimation() {
        guard !idleFrames.isEmpty else { return }

        bodySprite.removeAction(forKey: "idle")
        bodySprite.removeAction(forKey: "idleBounce")

        // Frame animation: cycle through idle poses
        let animateFrames = SKAction.animate(with: idleFrames, timePerFrame: 0.2, resize: false, restore: false)
        let idleLoop = SKAction.repeatForever(animateFrames)
        bodySprite.run(idleLoop, withKey: "idle")

        // Subtle bounce
        let moveUp = SKAction.moveBy(x: 0, y: 3, duration: 0.6)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let bounce = SKAction.sequence([moveUp, moveDown])
        bodySprite.run(SKAction.repeatForever(bounce), withKey: "idleBounce")
    }

    func stopIdleAnimation() {
        bodySprite.removeAction(forKey: "idle")
        bodySprite.removeAction(forKey: "idleBounce")
        bodySprite.position = .zero
    }

    func startWalkAnimation() {
        guard !walkFrames.isEmpty else { return }

        stopAllAnimations()

        let animateFrames = SKAction.animate(with: walkFrames, timePerFrame: 0.12, resize: false, restore: false)
        let walkLoop = SKAction.repeatForever(animateFrames)
        bodySprite.run(walkLoop, withKey: "walk")
    }

    func stopWalkAnimation() {
        bodySprite.removeAction(forKey: "walk")
    }

    func startWorkAnimation() {
        guard !workFrames.isEmpty else { return }

        stopAllAnimations()

        let animateFrames = SKAction.animate(with: workFrames, timePerFrame: 0.5, resize: false, restore: false)
        let workLoop = SKAction.repeatForever(animateFrames)
        bodySprite.run(workLoop, withKey: "work")
    }

    func stopWorkAnimation() {
        bodySprite.removeAction(forKey: "work")
    }

    func stopAllAnimations() {
        bodySprite.removeAllActions()
        bodySprite.position = .zero
    }

    func playActionAnimation() {
        stopAllAnimations()

        // Show jump frame, then bounce back to idle
        if let jumpTexture = jumpFrame {
            bodySprite.texture = jumpTexture
            bodySprite.texture?.filteringMode = .nearest
        }

        let jump = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.15),
            SKAction.moveBy(x: 0, y: -20, duration: 0.15)
        ])

        bodySprite.run(jump) { [weak self] in
            self?.startIdleAnimation()
        }
    }

    func playEatingDrinkingAnimation() {
        guard !eatDrinkFrames.isEmpty else {
            playActionAnimation()
            return
        }

        stopAllAnimations()

        // Play through all eating/drinking frames once, then loop the middle
        // section a couple times to show sustained eating, then return to idle
        let fullCycle = SKAction.animate(with: eatDrinkFrames, timePerFrame: 0.15, resize: false, restore: false)

        // Loop the chewing/drinking frames (rows 1-2, indices 5-14) for a second pass
        let chewingFrames = Array(eatDrinkFrames[5...14])
        let chewLoop = SKAction.animate(with: chewingFrames, timePerFrame: 0.12, resize: false, restore: false)

        let sequence = SKAction.sequence([fullCycle, chewLoop])

        bodySprite.run(sequence) { [weak self] in
            self?.startIdleAnimation()
        }
    }

    func playHappyAnimation() {
        let originalScale = bodySprite.xScale

        let grow = SKAction.scale(to: originalScale * 1.2, duration: 0.1)
        let shrink = SKAction.scale(to: originalScale, duration: 0.1)
        let pulse = SKAction.sequence([grow, shrink])
        let happy = SKAction.repeat(pulse, count: 3)

        bodySprite.run(happy)
    }

    func playSadAnimation() {
        let tiltLeft = SKAction.rotate(toAngle: -0.1, duration: 0.2)
        let tiltRight = SKAction.rotate(toAngle: 0.1, duration: 0.2)
        let center = SKAction.rotate(toAngle: 0, duration: 0.2)
        let shake = SKAction.sequence([tiltLeft, tiltRight, tiltLeft, tiltRight, center])

        bodySprite.run(shake)
    }

    func update(with state: BroState) {
        archetype = state.archetype
        mood = state.mood
    }
}
