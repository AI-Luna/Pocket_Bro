//
//  GameViewController.swift
//  Pocket Bro
//
//  Created by Luna Bitar on 1/30/26.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    private var sceneManager: SceneManager?
    private var didPresentInitialScene = false

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }

        // Configure view
        skView.ignoresSiblingOrder = true
        skView.isAsynchronous = false
        skView.showsFPS = false
        skView.showsNodeCount = false

        // Initialize scene manager only — do NOT present here (bounds may be zero)
        sceneManager = SceneManager(view: skView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didPresentInitialScene else { return }
        guard let skView = self.view as? SKView, skView.bounds.width > 0, skView.bounds.height > 0 else { return }

        didPresentInitialScene = true
        sceneManager?.presentInitialScene()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .bottom
    }
}
