//
//  MenuViewController.swift
//  Face It
//
//  Created by Etienne Denis on 1/26/16.
//  Copyright (c) 2016 Etienne Denis. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit


class MenuViewController: UIViewController, SCNSceneRendererDelegate {
    var scnView: SCNView!

    var score: String!
    
    @IBOutlet weak var scoreValue: UITextField!
    @IBOutlet weak var highScore: UITextField!
    
    override func viewDidLoad() {
       super.viewDidLoad()

        
        print("Menu Score = " + String(self.score))
        scoreValue.text = self.score
        highScore.text =  NSUserDefaults().stringForKey("highscore") 

        print("After Menu Score = " + String(self.score))

        
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
    }
    
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
        return orientation
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}

