//
//  CountdownScene.swift
//  Coin Man
//
//  Created by Charles Martin Reed on 1/3/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit
import SpriteKit

class CountdownScene: SKScene {
    
    //MARK:- Properties
    private var countdownTimer: Timer!
    private var countdownLabel: SKLabelNode!
    private var countdown: Int = 3
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        self.isHidden = false
        self.isPaused = false
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            self.createCountdown()
            self.countdown -= 1
        }
        //self.view?.removeFromSuperview()
        //sendBackToGameScene()
    }
    
    func createCountdown() {
        
        if countdown > 0 {
            //create a countdown label and display it in the center of the view
            countdownLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
            countdownLabel.text = "\(countdown)"
            countdownLabel.fontSize = 100
            countdownLabel.fontColor = SKColor.red
            countdownLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(countdownLabel)
            
            countdownLabel.run(SKAction.fadeOut(withDuration: 1))
        } else {
            countdownTimer.invalidate()
            self.isHidden = true
            self.isPaused = true
            
            presentGameScene()
        }
    }
    
    func presentGameScene() {
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            view?.presentScene(scene)
        }
        
    }
    
    
    
}
