//
//  GameScene.swift
//  Coin Man
//
//  Created by Charles Martin Reed on 1/2/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
// IMAGE ATTRIBUTIONS: TODO: FORMAT THIS PROPERLY!
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
//<div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/"             title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"             title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK:- Properties
    private var coinMan: SKSpriteNode?
    private var ground: SKSpriteNode?
    private var ceiling: SKSpriteNode?
    
    private var coinTimer: Timer?
    private var coinTimerInterval: Double = 1.0
    private var bombTimer: Timer?
    private var bombTimerInterval: Double = 2.0
    
    private var scoreLabel: SKLabelNode!
    
    //MARK:- Contact/Collision Properties
    let coinManCategory: UInt32 = 0x1 << 1 //1
    let coinCategory: UInt32 = 0x1 << 2 //2
    let bombCategory: UInt32 = 0x1 << 3 //4
    let boundingCategory: UInt32 = 0x1 << 4 //8
    
    //MARK:- Round properties
    var score: Int = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        //set up the contact delegate(s)
        physicsWorld.contactDelegate = self
        
        initalizePlayArea()
        initializeCoinMan()
        initializeCoinTimer()
        initializeBombTimer()
        
    }
    
    func initalizePlayArea() {
        //set up the label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = SKColor.white
        scoreLabel?.position = CGPoint(x: frame.minX * 0.5, y: frame.maxY - 150) //position at the top left
        addChild(scoreLabel)
        
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = boundingCategory
        ground?.physicsBody?.collisionBitMask = coinManCategory
        
        ceiling = childNode(withName: "ceiling") as? SKSpriteNode
        ceiling?.physicsBody?.categoryBitMask = boundingCategory
        ceiling?.physicsBody?.collisionBitMask = coinManCategory
    }
    
    func initializeCoinMan() {
        //create a reference to the object created in sks
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        
        //contact/collision setup
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = boundingCategory //coin man should only be able to "collide" with bounding areas
        
        
    }
    
    func initializeCoinTimer() {
        coinTimer = Timer.scheduledTimer(withTimeInterval: coinTimerInterval, repeats: true, block: { (_) in
            self.createCoins()
        })
    }
    
    func initializeBombTimer() {
        bombTimer = Timer.scheduledTimer(withTimeInterval: bombTimerInterval, repeats: true, block: { (_) in
            self.createBombs()
        })
    }
    
    //MARK:- Object creation functions
    func createCoins() {
        let coin = SKSpriteNode(imageNamed: "coin")
        
        //physicsBody setups
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        
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
    
    func createBombs() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        //addChild(bomb)
        
        //bomb positioning
        let maxY = (size.height / 2) - (bomb.size.height / 2)
        let minY = (-size.height / 2) + (bomb.size.height / 2)
        let bombY = CGFloat.random(in: minY...maxY)
        
        bomb.position = CGPoint(x: (self.size.width / 2 + (bomb.size.width / 2)), y: bombY)
        
        //check for valid positioning
        if !checkForOverlappingNodes(node: bomb) {
            addChild(bomb)
        } else {
            createBombs()
        }
        
        let actions = [
            SKAction.moveBy(x: -self.size.width - bomb.size.width, y: 0, duration: 4),
            SKAction.removeFromParent()
        ]
        bomb.run(SKAction.sequence(actions))
    }
    
    func checkForOverlappingNodes(node: SKSpriteNode) -> Bool {
        //grab the list of current nodes
        let visibleNodes = self.children
        var nodeIsOccupied = false
        
        visibleNodes.forEach { (existingNode) in
            if node.position == existingNode.position {
                nodeIsOccupied = true
            }
        }
        
        return nodeIsOccupied
    }
    
    //MARK:- Game end logic
    func gameOver() {
        print("Game is over!")
    }
    
    //MARK:- SK methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //make coinman jump
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

extension SKScene: SKPhysicsContactDelegate {
    //MARK:- Contact detection
    public func didBegin(_ contact: SKPhysicsContact) {
        //fired off when objects "hit" one another
        if let scene = self as? GameScene {
            
            //MARK:- was contactA or B a coin?
            //if the first body is the coin...
            if contact.bodyA.categoryBitMask == scene.coinCategory {
                //...remove the coin
                contact.bodyA.node?.removeFromParent()
                scene.score += 1
            }
            
            if contact.bodyB.categoryBitMask == scene.coinCategory {
                contact.bodyB.node?.removeFromParent()
                scene.score += 1
            }
            
            //MARK:- //was contactA or B a bomb?
            if contact.bodyA.categoryBitMask == scene.bombCategory || contact.bodyB.categoryBitMask == scene.bombCategory {
                //scene.score -= 1
                scene.gameOver()
            }
        }
    }
}
