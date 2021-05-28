//
//  MenuScene.swift
//  Color Match
//
//  Created by Joykirat on 28/05/21.
//  Copyright © 2021 Google Inc. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    func layoutScene() {
        self.backgroundColor = UIColor(red: 44/255, green:  62/255, blue: 80/255, alpha: 0.5)
        addLabels()
    }
    
    func addLabels(){
        let playLabel = SKLabelNode(text: "Tap to play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 60.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: dimensions.midX + 30, y: dimensions.midY)
        playLabel.zRotation = (-1)*(.pi/2)
        addChild(playLabel)
        animate(label: playLabel)
        
        let highScoreLabel = SKLabelNode(text: "Highscore: \(UserDefaults.standard.integer(forKey: "HighScore"))")
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.fontSize = 40.0
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.position = CGPoint(x: dimensions.midX - highScoreLabel.frame.size.height * 4, y: dimensions.midY )
        highScoreLabel.zRotation = (-1)*(.pi/2)
        addChild(highScoreLabel)
        
        let recentScoreLab = SKLabelNode(text: "Recent score: \(UserDefaults.standard.integer(forKey: "RecentScore"))")
        recentScoreLab.fontName = "AvenirNext-Bold"
        recentScoreLab.fontSize = 40.0
        recentScoreLab.fontColor = UIColor.white
        recentScoreLab.position = CGPoint(x: dimensions.midX - recentScoreLab.frame.size.height * 2, y: dimensions.midY)
        recentScoreLab.zRotation = (-1)*(.pi/2)
        addChild(recentScoreLab)
    }
    func animate(label: SKLabelNode) {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        label.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: view!.bounds.size)
        view!.presentScene(gameScene)
    }
}
