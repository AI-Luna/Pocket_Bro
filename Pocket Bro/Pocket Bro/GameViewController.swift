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

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else {
            fatalError("View is not an SKView")
        }

        // Configure view
        view.ignoresSiblingOrder = true
        // Debug info disabled
        view.showsFPS = false
        view.showsNodeCount = false

        // Initialize scene manager
        sceneManager = SceneManager(view: view)

        // Present initial scene
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
