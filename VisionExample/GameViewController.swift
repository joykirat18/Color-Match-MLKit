//
//  GameViewController.swift
//  VisionExample
//
//  Created by Joykirat on 28/05/21.
//  Copyright © 2021 Google Inc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func loadView() {
        self.view = SKView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .red
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill

                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true

            view.allowsTransparency = true
            
            
        }
    }
    
}
