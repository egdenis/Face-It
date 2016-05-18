//
//  GameOverlay.swift
//  Face It
//
//  Created by Etienne Denis on 7/19/15.
//  Copyright (c) 2015 Etienne Denis. All rights reserved.
//

import SceneKit
import SpriteKit

class GameOverlay: SKScene {
    var scoreNode: SKLabelNode!
    
    override init(size:CGSize){
        super.init(size:size)
        self.scaleMode = .ResizeFill
        self.scoreNode = SKLabelNode(fontNamed: "helvetica")
        self.scoreNode.position = CGPoint(x:  size.width - 20, y: size.height - 40)
        self.scoreNode.fontColor = .blackColor()
      //  self.scoreNode.fontColor = UIColor(red: 128, green: 128, blue: 128, alpha: 1.0)
        self.scoreNode.fontSize = 72.0
        self.addChild(self.scoreNode)
    }
    func drawScore(score:Int){

        self.scoreNode.text = String(score)
    }
    
    func eraseOverlay(){
        self.scoreNode.text = ""
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}