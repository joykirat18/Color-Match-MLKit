//
//  GameScene.swift
//  VisionExample
//
//  Created by Joykirat on 28/05/21.
//  Copyright © 2021 Google Inc. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
        ]
}

enum SwitchState: Int {
    case red ,yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    var leftCounter = 0;
    var rightCounter = 0;
    
    override func didMove(to view: SKView) {
        layoutScene()
        setUpPhysics()
    }
    
    func setUpPhysics() {
        physicsWorld.gravity = CGVector(dx: -0.2 , dy: 0.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene(){
        self.backgroundColor = UIColor(red: 44/255, green:  62/255, blue: 80/255, alpha: 0.5)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        print(dimensions.width)
        print(dimensions.height)
  
        colorSwitch.size = CGSize(width: dimensions.width/3, height: dimensions.width/3)
        colorSwitch.position = CGPoint(x: colorSwitch.size.height - 50 , y: dimensions.midY)
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        colorSwitch.zRotation = (-1)*(.pi/2)
        addChild(colorSwitch)
        spawnBall()
        
        
    }
    
    func spawnBall(){
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 20.0, height: 20.0))
        
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: dimensions.midX + 150 , y: dimensions.midY)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        addChild(ball)
    }
    
    func turnWheelRight() {
        if let newState = SwitchState(rawValue: switchState.rawValue - 1){
            switchState = newState
        }else{
            switchState = .blue
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: (-1)*(.pi/2), duration: 0.25))
    }
    func turnWheelLeft() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1){
            switchState = newState
        }else{
            switchState = .red
        }
        colorSwitch.run(SKAction.rotate(byAngle: (.pi/2), duration: 0.25))
    }
    
    func GameOver() {
        print("Game Over")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if(flags.rightFlag && !flags.leftFlag && flags.rightCounter == 1){
            if(rightCounter == 0){
                turnWheelRight()
                rightCounter = 1
            }
        };
        if(!flags.rightFlag && flags.leftFlag && flags.leftCounter == 1){
            if(leftCounter == 0){
                turnWheelLeft()
                leftCounter = 1
            }
        };
        if(!flags.rightFlag && !flags.leftFlag){
            leftCounter = 0
            rightCounter = 0
        }
    }

}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as?
                SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                print(currentColorIndex)
                print(switchState.rawValue)
                if currentColorIndex == switchState.rawValue {
                    print("Correct")
                    ball.run(SKAction.fadeOut(withDuration: 0.35)) {
                        ball.removeFromParent()
                        self.spawnBall()
                    }
                }else{
                    GameOver()
                }
            }
        }
    }
}
                            
