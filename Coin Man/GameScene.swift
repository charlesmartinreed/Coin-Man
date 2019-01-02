//
//  GameScene.swift
//  Coin Man
//
//  Created by Charles Martin Reed on 1/2/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
// IMAGE ATTRIBUTIONS: TODO: FORMAT THIS PROPERLY!
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var coinMan: SKSpriteNode?
    private var coinTimer: Timer?
    private var coinTimerInterval: Double = 1.0
    
    override func didMove(to view: SKView) {
        
        //create a reference to the object created in sks
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        
        initializeCoinTimer()
        
    }
    
    func initializeCoinTimer() {
        coinTimer = Timer.scheduledTimer(withTimeInterval: coinTimerInterval, repeats: true, block: { (_) in
            self.createCoin()
        })
    }
    
    //MARK:- Coin creation function
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        addChild(coin)
        
        
        //position the coin, according to the scene
        let maxY = (size.height / 2) - (coin.size.height / 2)
        let minY = (-size.height / 2) + (coin.size.height / 2)
        let coinY = CGFloat.random(in: minY...maxY)
        
        coin.position = CGPoint(x: (self.size.width / 2) + (coin.size.width / 2), y: coinY)
        
        //coin actions
        let actions = [
            SKAction.moveBy(x: -self.size.width - coin.size.width, y: 0, duration: 4),
            SKAction.removeFromParent()
        ]
        coin.run(SKAction.sequence(actions))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //make coinman jump
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
