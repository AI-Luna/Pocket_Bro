//
//  BroSpriteNode.swift
//  Pocket Bro
//

import SpriteKit

// MARK: - Sprite Sheet Config

struct SpriteSheetConfig {
    let sheetName: String
    let columns: Int
    let rows: Int
    let sheetPixelWidth: CGFloat
    let sheetPixelHeight: CGFloat

    /// Per-row Y pixel offsets for non-uniform grids. When nil, rows are evenly spaced.
    let rowYOffsets: [Int]?
    /// Explicit frame height in pixels (required when rowYOffsets is set).
    let framePixelHeight: Int?

    // Frame index mappings as (row, col) tuples
    let idleFrameSequence: [(row: Int, col: Int)]
    let walkFrameIndices: [(row: Int, col: Int)]
    let workFrameIndices: [(row: Int, col: Int)]
    let jumpFrameIndex: (row: Int, col: Int)

    static let broConfig = SpriteSheetConfig(
        sheetName: "BroSpriteSheet",
        columns: 5,
        rows: 4,
        sheetPixelWidth: 400,
        sheetPixelHeight: 384,
        rowYOffsets: nil,
        framePixelHeight: nil,
        idleFrameSequence: [
            (0, 0), (0, 1), (0, 2), (0, 1), (0, 0),
            (3, 0), (3, 1), (3, 2), (3, 3), (3, 2), (3, 1), (3, 0)
        ],
        walkFrameIndices: [
            (1, 0), (1, 1), (1, 2), (1, 3),
            (2, 0), (2, 1), (2, 2), (2, 3)
        ],
        workFrameIndices: [(2, 4), (3, 4)],
        jumpFrameIndex: (1, 4)
    )

    // Babe sprite sheet was rebuilt with uniform 80x92 grid (400x552).
    // Each sprite is centered in its cell with transparent padding.
    static let galConfig = SpriteSheetConfig(
        sheetName: "BabeSpriteSheet",
        columns: 5,
        rows: 6,
        sheetPixelWidth: 400,
        sheetPixelHeight: 552,
        rowYOffsets: nil,
        framePixelHeight: nil,
        idleFrameSequence: [
            (0, 0), (0, 1), (0, 2), (0, 1), (0, 0),
            (0, 2), (0, 1), (0, 0), (0, 1), (0, 2)
        ],
        walkFrameIndices: [
            (1, 0), (1, 1), (1, 2), (1, 3),
            (2, 0), (2, 1), (2, 2), (2, 3)
        ],
        workFrameIndices: [(2, 4), (3, 3)],
        jumpFrameIndex: (1, 4)
    )
}

// MARK: - BroSpriteNode

class BroSpriteNode: SKNode {
    private var bodySprite: SKSpriteNode!
    private var accessorySprite: SKSpriteNode?

    private let pixelScale: CGFloat = 3.4

    // Frame textures sliced from the main sprite sheet
    private var allFrames: [[SKTexture]] = []
    private var loadedSheetName: String?

    // Eating/drinking sprite sheet layout: 5 columns x 4 rows
    private var eatingFrames: [[SKTexture]] = []

    // Typing sprite sheet layout: 5 columns x 4 rows (7 frames used)
    private var typingSheetFrames: [[SKTexture]] = []

    // Sleeping sprite sheet layout: 3 columns x 1 row (3 frames)
    private var sleepingSheetFrames: [SKTexture] = []

    // Animation frame groups
    private var idleFrames: [SKTexture] = []
    private var walkFrames: [SKTexture] = []
    private var workFrames: [SKTexture] = []
    private var jumpFrame: SKTexture?
    private var eatDrinkFrames: [SKTexture] = []
    private var typingFrames: [SKTexture] = []
    private var sleepingFrames: [SKTexture] = []

    var archetype: Archetype = .bro {
        didSet { updateAppearance() }
    }

    var mood: BroMood = .neutral {
        didSet { }
    }

    private var currentConfig: SpriteSheetConfig {
        archetype == .gal ? .galConfig : .broConfig
    }

    init(archetype: Archetype = .bro) {
        super.init()
        self.archetype = archetype
        loadSpriteSheet()
        loadEatingDrinkingSpriteSheet()
        loadTypingSpriteSheet()
        loadSleepingSpriteSheet()
        setupSprites()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sprite Sheet Loading

    /// Crop a single frame from a CGImage sprite sheet into its own standalone SKTexture.
    /// This eliminates atlas-based bleed entirely since each texture is independent.
    private static func cropFrame(from cgImage: CGImage, x: Int, y: Int, w: Int, h: Int) -> SKTexture {
        let cropRect = CGRect(x: x, y: y, width: w, height: h)
        guard let cropped = cgImage.cropping(to: cropRect) else {
            return SKTexture()
        }
        let tex = SKTexture(cgImage: cropped)
        tex.filteringMode = .nearest
        return tex
    }

    private func loadSpriteSheet() {
        let config = currentConfig

        // Skip reload if already loaded this sheet
        guard loadedSheetName != config.sheetName else { return }

        allFrames = []

        // Load the sheet as a CGImage so we can crop individual frames.
        // Standalone textures eliminate SpriteKit sub-texture bleed completely.
        guard let uiImage = UIImage(named: config.sheetName),
              let cgImage = uiImage.cgImage else { return }

        let frameW = Int(config.sheetPixelWidth) / config.columns
        let frameH = config.framePixelHeight ?? (Int(config.sheetPixelHeight) / config.rows)

        for row in 0..<config.rows {
            var rowFrames: [SKTexture] = []
            let py = config.rowYOffsets?[row] ?? (row * frameH)
            for col in 0..<config.columns {
                let px = col * frameW
                let tex = Self.cropFrame(from: cgImage, x: px, y: py, w: frameW, h: frameH)
                rowFrames.append(tex)
            }
            allFrames.append(rowFrames)
        }

        // Map animation groups from config indices
        idleFrames = config.idleFrameSequence.map { allFrames[$0.row][$0.col] }
        walkFrames = config.walkFrameIndices.map { allFrames[$0.row][$0.col] }
        workFrames = config.workFrameIndices.map { allFrames[$0.row][$0.col] }
        jumpFrame = allFrames[config.jumpFrameIndex.row][config.jumpFrameIndex.col]

        loadedSheetName = config.sheetName
    }

    private func loadEatingDrinkingSpriteSheet() {
        // Eating/drinking always uses the bro-format sheet (5x4, 400x384)
        let columns = 5
        let rows = 4

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

    private func loadTypingSpriteSheet() {
        // Typing always uses the bro-format sheet (5x4, 400x384)
        let columns = 5
        let rows = 4

        let sheetTexture = SKTexture(imageNamed: "TypingSpriteSheet")
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
            typingSheetFrames.append(rowFrames)
        }

        // Build typing animation sequence from the sprite sheet
        // Row 0: 4 typing frames (hands on keyboard poses)
        // Row 1: 3 typing frames (leaning forward poses)
        typingFrames = [
            typingSheetFrames[0][0], typingSheetFrames[0][1], typingSheetFrames[0][2], typingSheetFrames[0][3],
            typingSheetFrames[1][0], typingSheetFrames[1][1], typingSheetFrames[1][2]
        ]
    }

    private func loadSleepingSpriteSheet() {
        let sheetTexture = SKTexture(imageNamed: "SleepingSpriteSheet")
        sheetTexture.filteringMode = .nearest

        let sleepColumns = 3
        let frameWidth = 1.0 / CGFloat(sleepColumns)

        // Inset each texture rect by half a pixel to prevent SpriteKit sampling bleed
        let insetX = 0.5 / 480.0  // sheet is 480px wide
        let insetY = 0.5 / 128.0  // sheet is 128px tall

        for col in 0..<sleepColumns {
            let x = CGFloat(col) * frameWidth + insetX
            let y = insetY
            let rect = CGRect(x: x, y: y, width: frameWidth - 2 * insetX, height: 1.0 - 2 * insetY)
            let frame = SKTexture(rect: rect, in: sheetTexture)
            frame.filteringMode = .nearest
            sleepingSheetFrames.append(frame)
        }

        // Build sleeping animation: 3 frames showing sleeping with Zzz
        sleepingFrames = sleepingSheetFrames
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
        let config = currentConfig

        // Only reload if the archetype's sheet actually changed
        guard loadedSheetName != config.sheetName else { return }

        loadSpriteSheet()

        // Remove any legacy color blend
        bodySprite.color = .clear
        bodySprite.colorBlendFactor = 0.0

        // Update texture to first idle frame and restart animation
        if !idleFrames.isEmpty {
            bodySprite.texture = idleFrames[0]
            bodySprite.texture?.filteringMode = .nearest
        }

        startIdleAnimation()
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

    func playTypingAnimation() {
        guard !typingFrames.isEmpty else {
            playActionAnimation()
            return
        }

        stopAllAnimations()

        // Play through all typing frames, then loop the main typing cycle
        let fullCycle = SKAction.animate(with: typingFrames, timePerFrame: 0.18, resize: false, restore: false)

        // Loop the hand-movement frames (row 0, indices 0-3) for sustained typing
        let keystrokeFrames = Array(typingFrames[0...3])
        let keystrokeLoop = SKAction.repeat(
            SKAction.animate(with: keystrokeFrames, timePerFrame: 0.15, resize: false, restore: false),
            count: 3
        )

        let sequence = SKAction.sequence([fullCycle, keystrokeLoop])

        bodySprite.run(sequence) { [weak self] in
            self?.startIdleAnimation()
        }
    }

    func playSleepingAnimation() {
        guard !sleepingFrames.isEmpty else {
            playActionAnimation()
            return
        }

        stopAllAnimations()

        // Scale down to 75% for the sleeping pose
        let originalScale = bodySprite.xScale
        let sleepScale = originalScale * 0.60
        let shrink = SKAction.scale(to: sleepScale, duration: 0.2)

        // Cycle through the 3 sleeping frames (Zzz poses) in a loop,
        // play a few cycles then return to idle
        let sleepCycle = SKAction.animate(with: sleepingFrames, timePerFrame: 0.6, resize: false, restore: false)
        let sleepLoop = SKAction.repeat(sleepCycle, count: 5)

        let sequence = SKAction.sequence([shrink, sleepLoop])

        bodySprite.run(sequence) { [weak self] in
            guard let self = self else { return }
            self.bodySprite.setScale(originalScale)
            self.startIdleAnimation()
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
