//
//  GameViewController.swift
//  Face It
//
//  Created by Etienne Denis on 5/21/15.
//  Copyright (c) 2015 Etienne Denis. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController,UIGestureRecognizerDelegate,SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    var scnView: SCNView!
    var scn: Primitive!
    var spheres:Array<SCNNode>!
    var count: Double!
    var maxCount: Double!
    var box: SCNNode!

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // retrieve the SCNView
        self.scn = Primitive()
        // set the scene to the view
        self.scnView = self.view as! SCNView
        self.scnView.scene = self.scn
        self.scnView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 250/255, alpha: 1.0)
        self.scnView.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        self.scnView.delegate = self
        self.spheres = []
        self.count = 0.0
        self.maxCount = 20.0
        self.box = self.scn.rootNode.childNodeWithName("box", recursively: true)

        // configure the vie
        // add a tap gesture recognizer
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
       
    }
    
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        print("octave est un gros pede")
        self.maxCount = self.maxCount - 0.01
        self.count = self.count + 1

        let colors = [UIColor(red: 250/255, green: 1, blue: 153/255, alpha: 1.0),UIColor(red: 174/255, green: 34/255, blue: 34/255, alpha: 1.0),UIColor(red: 92/255, green: 157/255, blue: 160/255, alpha: 1.0)]
        var position = [Float(0),Float(0),Float(0)]
        position[Int(arc4random_uniform(3))] = Float(10)
        if(self.count>=self.maxCount){
            print("ocatave le pede")
            self.addSphere(colors[Int(arc4random_uniform(3))], x: position[0], y: position[1], z: position[2])
            self.count = 0
        }
        
        for (var i = self.spheres.endIndex-1 ; i>0; i-- ){
            var position = self.spheres[i].position
            if(position.x + position.y + position.z == 10){
                self.spheres[i].removeFromParentNode()
                self.spheres.removeAtIndex(i)
            }
        }

    }
    
    func addSphere(color: UIColor, x:Float, y:Float, z:Float){
        let materialColor  = SCNMaterial()
        materialColor.diffuse.contents = color
        materialColor.locksAmbientWithDiffuse = true;
        
        let sphereGeometry = SCNSphere(radius:0.25)
        sphereGeometry.materials = [materialColor]
        
        let sphere = SCNNode(geometry: sphereGeometry)
        let sphereShape = SCNPhysicsShape(geometry: sphereGeometry, options: nil)
        let sphereBody = SCNPhysicsBody(type: .Kinematic, shape: sphereShape)
        
        sphere.position = SCNVector3Make(x,y,z)
        sphere.physicsBody = sphereBody;
        self.scn.rootNode.addChildNode(sphere)
        self.spheres.append(sphere)
        sphere.runAction(SCNAction.moveTo(SCNVector3(x:0,y:0,z:0), duration: NSTimeInterval(2)))
    }

    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
      
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        var location = sender.locationOfTouch(0, inView: self.scnView)
        var spin = CABasicAnimation(keyPath: "rotation")

        var x = Float(0.0), y = Float(0.0), z = Float(0.0)
        var halfWidth = Float(self.scnView.bounds.width/2)
        switch (sender.direction,Float(location.x)) {
        case (UISwipeGestureRecognizerDirection.Left,_):
            y = 1
        case (UISwipeGestureRecognizerDirection.Right,_):
            y = -1
        case let (UISwipeGestureRecognizerDirection.Up, xPos) where xPos <= halfWidth:
            x = 1
        case let (UISwipeGestureRecognizerDirection.Up, xPos) where xPos > halfWidth:
            z = -1
        case let (UISwipeGestureRecognizerDirection.Down, xPos) where xPos <= halfWidth:
            x = -1
        case let (UISwipeGestureRecognizerDirection.Down, xPos) where xPos > halfWidth:
            z = 1
        default:
            break
        }

        let action = SCNAction.rotateByAngle(CGFloat(0.5*M_PI), aroundAxis: SCNVector3(x: x, y: y, z: z), duration: NSTimeInterval(0.15))
        self.box?.runAction(action)
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
