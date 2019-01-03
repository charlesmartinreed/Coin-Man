//
//  GameScene.swift
//  Coin Man
//
//  Created by Charles Martin Reed on 1/2/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
// IMAGE ATTRIBUTIONS: TODO: FORMAT THIS PROPERLY!
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
//<div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/"             title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"             title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
//<div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK:- Properties
    private var coinMan: SKSpriteNode!
    private var ground: SKSpriteNode!
    private var ceiling: SKSpriteNode!
    
    private var coinTimer: Timer?
    private var coinTimerInterval: Double = 1.0
    private var bombTimer: Timer?
    private var bombTimerInterval: Double = 2.0
    private var startTimer: Timer?
    private var startTimerInterval: Double = 3.0
    
    private var countdownLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var yourScoreLabel: SKLabelNode!
    private var finalScoreLabel: SKLabelNode!
    private var playButton: SKSpriteNode!
    
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
    
    var countdown: Int = 3 {
        didSet {
            countdownLabel.text = "\(countdown)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        //set up the contact delegate(s)
        physicsWorld.contactDelegate = self
        
        //startNewRoundCountdown()
        initalizePlayArea()
        initializeCoinMan()
        initializeCoinTimer()
        initializeBombTimer()
        
    }
    
    func initalizePlayArea() {
        scene?.isPaused = false
        
        //set up the label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = SKColor.white
        scoreLabel?.position = CGPoint(x: frame.minX * 0.5, y: frame.maxY - 150) //position at the top left
        addChild(scoreLabel)
        
        ground = SKSpriteNode(color: SKColor.green, size: CGSize(width: self.size.width, height: 140))
        //ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.position = CGPoint(x: 0, y: -598.375)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.categoryBitMask = boundingCategory
        ground.physicsBody?.collisionBitMask = coinManCategory
        addChild(ground)
        
        ceiling = SKSpriteNode(color: SKColor.blue, size: CGSize(width: self.size.width, height: 75))
        //ceiling = childNode(withName: "ceiling") as? SKSpriteNode
        ceiling.position = CGPoint(x: -0, y: 819.538)
        
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.affectedByGravity = false
        ceiling.physicsBody?.categoryBitMask = boundingCategory
        ceiling.physicsBody?.collisionBitMask = coinManCategory
        addChild(ceiling)
    }
    
    func initializeCoinMan() {
        //create a reference to the object created in sks
        //coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan = SKSpriteNode(color: SKColor.purple, size: CGSize(width: 100, height: 200))
        
        guard let groundPosition = ground?.position else { return }
        coinMan?.position = CGPoint(x: groundPosition.x, y: groundPosition.y + coinMan.size.height)
        
        addChild(coinMan)
        
        //contact/collision setup
        coinMan.physicsBody = SKPhysicsBody(rectangleOf: coinMan.size)
        coinMan.physicsBody?.isDynamic = true
        coinMan.physicsBody?.affectedByGravity = true
        coinMan.physicsBody?.categoryBitMask = coinManCategory
        coinMan.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan.physicsBody?.collisionBitMask = boundingCategory //coin man should only be able to "collide" with bounding areas
        
        
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
        
            //pause and fade the scene
            //grab the nodes in the scene
            scene?.children.forEach({ (node) in
                node.run(SKAction.fadeOut(withDuration: 1))
                node.removeFromParent()
                scene?.isPaused = true
            })
        
            //give the gameOver Label
            yourScoreLabel = SKLabelNode(text: "Your Score:")
            yourScoreLabel.position = CGPoint(x: 0, y: 200)
            yourScoreLabel.fontSize = 100
            addChild(yourScoreLabel)
        
            finalScoreLabel = SKLabelNode(text: "\(score)")
            finalScoreLabel.position = CGPoint(x: 0, y: 0)
            finalScoreLabel.fontSize = 200
            addChild(finalScoreLabel)
        
            //create the restart level button
            playButton = SKSpriteNode(imageNamed: "playButton")
            playButton.name = "play"
            playButton.position = CGPoint(x: 0, y: -200)
            addChild(playButton)
    }
    
    func startNewGame() {
        //reset the score
        score = 0
        
        //remove everything on the screen
        playButton.removeFromParent()
        yourScoreLabel.removeFromParent()
        finalScoreLabel.removeFromParent()
        
        //stop your timers
        bombTimer?.invalidate()
        coinTimer?.invalidate()
        
        //call your init functions again
        //initalizePlayArea()
        //initializeCoinMan()
        //initializeCoinTimer()
        //initializeBombTimer()
        
        //start the new round timer
        startNewRoundCountdown()
    }
    
    func startNewRoundCountdown() {
        startTimer = Timer.scheduledTimer(withTimeInterval: startTimerInterval, repeats: true, block: { [unowned self] (_) in
            
            while self.startTimerInterval > 0.0 {
                self.startTimerInterval -= 1.0
                //self.countdown -= 1
            }
            
            
            print(self.startTimerInterval)
            //create a countdown label and display it in the center of the view
//            self.countdownLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
//            self.countdownLabel.text = "\(self.countdown)"
//            self.countdownLabel.fontSize = 200
//            self.countdownLabel.fontColor = SKColor.red
//            self.countdownLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//            self.addChild(self.countdownLabel)
            
            if self.startTimerInterval == 0.0 {
                self.startTimer?.invalidate()
                //self.countdownLabel.removeFromParent()
                self.initalizePlayArea()
                self.initializeCoinMan()
                self.initializeCoinTimer()
                self.initializeBombTimer()
            }
            
            //reset the timer interval
            self.startTimerInterval = 3.0
            
        })
    }
    
    //MARK:- SK methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //make coinman jump
        coinMan.physicsBody?.applyForce(CGVector(dx: 0, dy: 20_000))
        
        //check whether the play button was touched
        let touch = touches.first
        if let location = touch?.location(in: self) {
            //check for nodes at a location
            let allNodes = nodes(at: location)
            
            //see if the node is the play button
            for node in allNodes {
                if node.name == "play" {
                    //start the game anew
                    startNewGame()
                }
            }
        }
        
        
        
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
            if contact.bodyA.categoryBitMask == scene.bombCategory {
                //remove the bomb, end the game
                contact.bodyA.node?.removeFromParent()
                scene.gameOver()
            }
            
            if contact.bodyB.categoryBitMask == scene.bombCategory {
                //remove the bomb, end the game
                contact.bodyB.node?.removeFromParent()
                scene.gameOver()
            }
            
        }
    }
}
