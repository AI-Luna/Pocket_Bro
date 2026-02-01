//
//  BaseGameScene.swift
//  Pocket Bro
//

import SpriteKit

class BaseGameScene: SKScene {
    weak var sceneManager: SceneManager?

    let pixelScale: CGFloat = 4.0

    var backgroundColor_: SKColor {
        SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
    }

    init(size: CGSize, sceneManager: SceneManager) {
        self.sceneManager = sceneManager
        super.init(size: size)
        self.backgroundColor = backgroundColor_
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        subscribeToNotifications()
        setupScene()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        unsubscribeFromNotifications()
    }

    func setupScene() {
        // Override in subclasses
    }

    // MARK: - Notifications

    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGameStateUpdate(_:)),
            name: .gameStateDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGameEnd(_:)),
            name: .gameDidEnd,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEventTrigger(_:)),
            name: .eventDidTrigger,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStageAdvance(_:)),
            name: .stageDidAdvance,
            object: nil
        )
    }

    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleGameStateUpdate(_ notification: Notification) {
        // Override in subclasses
    }

    @objc func handleGameEnd(_ notification: Notification) {
        guard let info = notification.object as? [String: Any] else { return }

        if let _ = info["victory"] as? Bool {
            sceneManager?.presentScene(.victory)
        } else if let reason = info["reason"] as? GameOverReason {
            sceneManager?.presentScene(.gameOver(reason))
        }
    }

    @objc func handleEventTrigger(_ notification: Notification) {
        // Override in subclasses
    }

    @objc func handleStageAdvance(_ notification: Notification) {
        // Override in subclasses
    }

    // MARK: - Pixel Art Helpers

    func createPixelTexture(color: SKColor, size: CGSize = CGSize(width: 1, height: 1)) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        return texture
    }

    func createPixelSprite(color: SKColor, pixelSize: CGSize) -> SKSpriteNode {
        let texture = createPixelTexture(color: color, size: pixelSize)
        let sprite = SKSpriteNode(texture: texture)
        sprite.setScale(pixelScale)
        return sprite
    }

    func pixelPosition(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: round(point.x / pixelScale) * pixelScale,
            y: round(point.y / pixelScale) * pixelScale
        )
    }

    // MARK: - UI Helpers

    func createLabel(text: String, fontSize: CGFloat = 16) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo-Bold"
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    func safeAreaInsets() -> UIEdgeInsets {
        view?.safeAreaInsets ?? .zero
    }
}
