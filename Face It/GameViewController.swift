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
import SpriteKit
import AVFoundation
import Social
import GameKit

class GameViewController: UIViewController,UIGestureRecognizerDelegate,SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    var scnView: SCNView!
    var scn: Primitive!
    var spheres:Array<SCNNode> = []
    var counted:Array<Int> = []
    var count: Double!
    var maxCount: Double!
    var colorOrder:Array<String>!
    var score = 0
    var overlay: GameOverlay!
    var gameState = "menu"
    var gameoverSubview: GameoverOverlay?
    var menuSubview: menuOverlay?
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String()

    var sounds: [String:AVAudioPlayer] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the SCNView
        self.scn = Primitive()
        // set the scene to the view
        self.colorOrder = ["blue","red","yellow"]
        self.scnView = self.view as! SCNView
        self.scnView.scene = self.scn
        self.scnView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 247/255, alpha: 1.0)
        self.scnView.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        self.scnView.delegate = self
        // configure the view
        // add a tap gesture recognizer
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe) //gesture added
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        if let pop = self.setupAudioPlayerWithFile("pop1", type:"wav") { //sounds
            self.sounds["red"] = pop
        }
        if let pop = self.setupAudioPlayerWithFile("pop2", type:"wav") { //sounds
            self.sounds["blue"] = pop
        }

        if let pop = self.setupAudioPlayerWithFile("pop3", type:"wav") { //sounds
            self.sounds["yellow"] = pop
        }
        
        self.overlay = GameOverlay(size: view.bounds.size)
        scnView.showsStatistics = true
        scnView.overlaySKScene = self.overlay;
        
        //self.authenticateLocalPlayer()

        setUpGameMenu()
        print("game loaded")
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.authenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }
            
        }
        
    }
    
    private func showFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let mySLComposerSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            mySLComposerSheet.setInitialText("Check out my high score")
            mySLComposerSheet.addURL(NSURL(string: "http://mysite.com")!)
            presentViewController(mySLComposerSheet, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            // TODO: Alert user that they do not have a facebook account set up on their device
        }
    }
    func share(){
        let alert = UIAlertController(title: "Share", message: "Where do you want to share?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: {(alert: UIAlertAction!) in
            print("facebook")
            self.showFacebook()
        }))
        alert.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: {(alert: UIAlertAction!) in
            print("twitter")
            
            self.showTwitter()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            self.presentViewController(tweetShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    func instantiateGameVars(){
        self.colorOrder = ["blue","red","yellow"]
        self.count = 48.0//probabilit of a spher spawning
        self.maxCount = 45.0//hardest setting
        self.spheres = []
        self.score = 0
    }
    
     func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        if self.gameState == "play" { //is the gameover?? if not process game loop
            print("play")
            var isGameover = false
            if(self.maxCount>35){
                self.maxCount = self.maxCount - 0.01
            }
            self.count = self.count + 1

           
            
            if(self.count>=self.maxCount){  //generate sphere
                if((Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX))*self.maxCount<5){ //generate 3 sphere
                   createThreeSpheres()

                }
                else {
                    self.addSphere() //single sphere
                }
                self.count = 0
            }
            
            for (var i = self.spheres.endIndex-1 ; i>=0; i-- ){
                let position = self.spheres[i].position

                if(position.x > 1.15 && position.x<1.3 && self.counted[i] == 0){
                    
                    if(self.colorOrder[1]==self.spheres[i].name!){
                        self.score++
                        self.counted[i] = 1
                        self.sounds[self.spheres[i].name!]?.play()

                    }
                    else{
                        isGameover = true

                    }
                }
                else if(position.y > 1.15 && position.y<1.3 && self.counted[i] == 0){
                    
                    
                    if(self.colorOrder[0]==self.spheres[i].name!){
                        self.score++
                        self.counted[i] = 1
                        self.sounds[self.spheres[i].name!]?.play()
                    }
                    else{
                        isGameover = true
                        
                    }
                }
                else if(position.z > 1.15 && position.z<1.3 && self.counted[i] == 0){
                    
                    
                    if(self.colorOrder[2]==self.spheres[i].name!){
                        self.score++
                        self.counted[i] = 1
                        self.sounds[self.spheres[i].name!]?.play()
                    }
                    else{
                        isGameover = true
                    }
                }
                else if(position.x + position.y + position.z == 0){
                    self.spheres[i].geometry = nil
                    self.counted.removeAtIndex(i)
                    self.spheres.removeAtIndex(i)
                }
                
            }
            
            
            
            self.overlay.drawScore(self.score)
            
            if isGameover {
                gameOver()
            }
        }
        else if self.gameState == "gameover" {
            checkGameoverButtons()
        }
        else if self.gameState == "menu" {
            checkMenuButtons()
        }
    }
    

    
    func checkGameoverButtons(){
        print(self.gameoverSubview!.buttons)
        if(self.gameoverSubview!.buttons[0]){
            self.gameoverSubview!.buttons[0] = false
            
        }
        else if(self.gameoverSubview!.buttons[1]){
            self.gameoverSubview!.buttons[1] = false
        }
        else if(self.gameoverSubview!.buttons[2]){
            self.instantiateGameVars()
            self.gameState = "play"
            let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
            box?.removeActionForKey("rotate")
            dispatch_async(dispatch_get_main_queue(), {
                box?.runAction(SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.5, shortestUnitArc: true))
                
                self.view.subviews[0].removeFromSuperview()
            })
            self.gameoverSubview!.buttons[2] = false
            
        }
        else if(self.gameoverSubview!.buttons[3]){
            
        }
        else if(self.gameoverSubview!.buttons[4]){
            
            self.gameoverSubview!.buttons[4] = false
            print("shar")
            dispatch_async(dispatch_get_main_queue(), {
                
                self.share()
            })
            
        }

    }
    
    func checkMenuButtons(){
        
            if(self.menuSubview!.buttons[0]){
                self.menuSubview!.buttons[0] = false
                
            }
            else if(self.menuSubview!.buttons[1]){
                self.menuSubview!.buttons[1] = false
            }
            else if(self.menuSubview!.buttons[2]){
                self.instantiateGameVars()
                self.gameState = "play"
                let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
                box?.removeActionForKey("rotate")
                dispatch_async(dispatch_get_main_queue(), {
                box?.runAction(SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.5, shortestUnitArc: true))
                
                self.view.subviews[0].removeFromSuperview()
                    })
                self.menuSubview!.buttons[2] = false
            }
            else if(self.menuSubview!.buttons[3]){
                
            }
            else if(self.menuSubview!.buttons[4]){

                self.menuSubview!.buttons[4] = false
                print("shar")
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.share()
                })

            }
        }
    
    func createThreeSpheres(){
        let firstSphereColor = Int(arc4random_uniform(3))
        var secondSphereColor = 1
        if (firstSphereColor == 0) {
            secondSphereColor = Int(arc4random_uniform(2))+1
        }
        else if (firstSphereColor == 2){
            secondSphereColor = Int(arc4random_uniform(2))
        }
        else {
            secondSphereColor = Int(arc4random_uniform(1))*2
        }
        self.addSphere(firstSphereColor,positionIndex: 0)
        self.addSphere(secondSphereColor,positionIndex: 1)
        self.addSphere((3 - firstSphereColor - secondSphereColor) ,positionIndex: 2)
    }
    
    func setUpGameMenu(){
        let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
        box?.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0.5, y: 0, z: 0.0, duration: 1)), forKey: "rotate")
        dispatch_async(dispatch_get_main_queue(), { //make ui changes in main thread to avoid "this application is modifying the autolayout engine from a background thread"
            self.menuSubview = menuOverlay(frame: CGRect(x: 0, y: 0, width: self.scnView.bounds.width, height: self.scnView.bounds.height)) //instatiate ui
            self.scnView.addSubview(self.menuSubview!)
        })
    }
    
    func gameOver(){
        let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
        self.gameState = "gameover"
        for (var i = self.spheres.endIndex-1 ; i>=0; i-- ){
            self.spheres[i].removeFromParentNode()
            self.counted.removeAtIndex(i)
            self.spheres.removeAtIndex(i)
        }
        
        self.overlay.eraseOverlay()
        box?.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0.5, y: 0, z: 0.0, duration: 1)), forKey: "rotate")
        let userDefaults=NSUserDefaults()
        let highscore=userDefaults.integerForKey("highscore")
        
        if(self.score>highscore)
        {
            userDefaults.setInteger(self.score, forKey: "highscore")
        }
        
        userDefaults.synchronize()
        dispatch_async(dispatch_get_main_queue(), { //make ui changes in main thread to avoid "this application is modifying the autolayout engine from a background thread"
        self.gameoverSubview = GameoverOverlay(frame: CGRect(x: 0, y: 0, width: self.scnView.bounds.width, height: self.scnView.bounds.height), score: self.score ) //instatiate ui
            
        self.scnView.addSubview(self.gameoverSubview!)
        })
        
      //  performSegueWithIdentifier("gameOver", sender: self.score)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "gameOver"){
            let MenuScene = segue.destinationViewController as! MenuViewController
            self.navigationController?.popToRootViewControllerAnimated(false)

            let score = String(sender!)
            MenuScene.score = score
        }
    }
    
    func addSphere(colorIndex: Int = Int(arc4random_uniform(3)), positionIndex: Int = Int(arc4random_uniform(3)) ){

        let colors = [UIColor(red: 229/255, green: 200/255, blue: 70/255, alpha: 1),UIColor(red: 205/255, green: 32/255, blue: 34/255, alpha: 0.9),UIColor(red: 0/255, green: 76/255, blue: 116/255, alpha: 0.9)]
        let colorNames = ["blue","red","yellow"]
        var position = [Float(0),Float(0),Float(0)]
        
        position[positionIndex] = Float(10)
        
        let materialColor  = SCNMaterial()

        materialColor.diffuse.contents = colors[colorIndex]
        materialColor.locksAmbientWithDiffuse = true;
        
        let sphereGeometry = SCNSphere(radius:0.3)
        sphereGeometry.materials = [materialColor]
        
        let sphere = SCNNode(geometry: sphereGeometry)
     //   let sphereShape = SCNPhysicsShape(geometry: sphereGeometry, options: nil)
      //  let sphereBody = SCNPhysicsBody(type: .Kinematic, shape: sphereShape)
        
        sphere.position = SCNVector3Make(position[0],position[1],position[2])
        //sphere.physicsBody = sphereBody;
        sphere.name = colorNames[colorIndex]
        self.scn.rootNode.addChildNode(sphere)
        self.spheres.append(sphere)
        self.counted.append(0)
        sphere.runAction(SCNAction.moveTo(SCNVector3(x:0,y:0,z:0), duration: NSTimeInterval(2.7)))
    }

    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
      
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {

        let location = sender.locationOfTouch(0, inView: self.scnView)
       // let spin = CABasicAnimation(keyPath: "rotation")
        let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
        var x = Float(0.0), y = Float(0.0), z = Float(0.0)
        let halfWidth = Float(self.scnView.bounds.width/2)
        switch (sender.direction,Float(location.x)) {
        case (UISwipeGestureRecognizerDirection.Left,_): //swipe left change the color order so that sphere collisions can be checked
            y = -1
            let color = self.colorOrder[1]
            self.colorOrder[1] = self.colorOrder[2]
            self.colorOrder[2] = color

        case (UISwipeGestureRecognizerDirection.Right,_): //swipe right
            y = 1
            let color = self.colorOrder[1]
            self.colorOrder[1] = self.colorOrder[2]
            self.colorOrder[2] = color



        case let (UISwipeGestureRecognizerDirection.Up, xPos) where xPos <= halfWidth: //swipe up on the left side of the screen
            x = -1
            let color = self.colorOrder[2]
            self.colorOrder[2] = self.colorOrder[0]
            self.colorOrder[0] = color

        case let (UISwipeGestureRecognizerDirection.Up, xPos) where xPos > halfWidth: //swipe up on the right side of the sceen
            z = 1
            let color = self.colorOrder[1]
            self.colorOrder[1] = self.colorOrder[0]
            self.colorOrder[0] = color

        case let (UISwipeGestureRecognizerDirection.Down, xPos) where xPos <= halfWidth: //swipe down on the left side of the screen
            x = 1
            let color = self.colorOrder[0]
            self.colorOrder[0] = self.colorOrder[2]
            self.colorOrder[2] = color

        case let (UISwipeGestureRecognizerDirection.Down, xPos) where xPos > halfWidth: //swipe down on the right side of the screen
            z = -1
            let color = self.colorOrder[0]
            self.colorOrder[0] = self.colorOrder[1]
            self.colorOrder[1] = color

        default:
            break
        }

        let action = SCNAction.rotateByAngle(CGFloat(0.5*M_PI), aroundAxis: SCNVector3(x: x, y: y, z: z), duration: NSTimeInterval(0.08))
        box?.runAction(action)


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
