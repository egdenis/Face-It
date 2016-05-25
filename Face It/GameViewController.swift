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
    var products = [SKProduct]()

    var scn: Primitive!
    var spheres:Array<SCNNode> = []
    var counted:Array<Int> = []
    var maxTime: CFTimeInterval = 1
    var colorOrder:Array<String>!
    var score = 0
    var gameState = "menu"
    var gameoverSubview: GameoverOverlay?
    var menuSubview: MenuOverlay?
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String()
    var lastUpdateTimeInterval: CFTimeInterval = 0
    var delta: CFTimeInterval = 0
 
    var sounds: [String:AVAudioPlayer] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the SCNView
        self.scn = Primitive()
        // set the scene to the view
        self.colorOrder = ["blue","red","yellow"]
        self.scnView = self.view as! SCNView
        self.scnView.scene = self.scn
        self.scnView.backgroundColor = UIColor(red: (243+6)/255, green: (224+12)/255, blue: (177+31)/255, alpha: 1.0)
        self.scnView.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        self.scnView.delegate = self
        // configure the view
        // add a tap gesture recognizer
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipes(_:)))
    
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe) //gesture added
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handlePurchaseNotification(_:)), name: IAPHelper.IAPHelperPurchaseNotification, object: nil)
        
        if let pop = self.setupAudioPlayerWithFile("pop1", type:"wav") { //sounds
            self.sounds["red"] = pop
        }
        if let pop = self.setupAudioPlayerWithFile("pop2", type:"wav") { //sounds
            self.sounds["blue"] = pop
        }

        if let pop = self.setupAudioPlayerWithFile("pop3", type:"wav") { //sounds
            self.sounds["yellow"] = pop
        }
        
        let userDefaults=NSUserDefaults()
      
        
        if( userDefaults.objectForKey("highscore") == nil)
        {
            userDefaults.setInteger(0, forKey: "highscore")
        }
        userDefaults.synchronize()
        
        self.authenticateLocalPlayer()

        setUpGameMenu()
        print("game loaded")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        products = []
        gameProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
            }
        }
    }
  
    func buyButtonTapped(sender: AnyObject) {
        buyButtonHandler?(product: product!)
    }
    var buyButtonHandler: ((product: SKProduct) -> ())?
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            
            if gameProducts.store.isProductPurchased(product.productIdentifier) {
                
            } else {
                ProductCell.priceFormatter.locale = product.priceLocale
                detailTextLabel?.text = ProductCell.priceFormatter.stringFromNumber(product.price)
                
                accessoryType = .None
                accessoryView = newBuyButton()
            }
        }
    }

    func handlePurchaseNotification(notification: NSNotification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerate() {
            guard product.productIdentifier == productID else { continue }
            
            //tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
        }
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
    func instantiateGameVars(){
        self.colorOrder = ["blue","red","yellow"]
        self.maxTime = 1
        self.spheres = []
        self.score = 0
    }
    
     func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
     
        
        if self.gameState == "play" { //is the gameover?? if not process game loop
            self.delta  = self.delta + time - lastUpdateTimeInterval
            
            lastUpdateTimeInterval = time
          
            if self.delta > self.maxTime {
                if(self.maxTime > 0.5){
                self.maxTime = self.maxTime - 0.01*self.maxTime
                }
                self.delta = 0

            if((Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * self.maxTime < 0.2){ //generate 3 sphere
                    createThreeSpheres()
                }
                else {
                    self.addSphere() //single sphere
                }
                
            }
            
            self.checkCollisions()
          
            
        }
            
        else if self.gameState == "gameover"  && self.gameoverSubview != nil {
            checkGameoverButtons()
        }
        else if self.gameState == "menu" && self.menuSubview != nil {
            checkMenuButtons()
        }
    }
    
    func checkCollisions(){
        var isGameover = false

        for (var i = self.spheres.endIndex-1 ; i>=0; i = i-1 ){
            let position = self.spheres[i].position
            
            if(position.x != 0 && position.x<1.3 && self.counted[i] == 0){
                
                if(self.colorOrder[1]==self.spheres[i].name!){
                    self.score += 1
                    self.counted[i] = 1
                    self.sounds[self.spheres[i].name!]?.play()
                    self.spheres[i].geometry = nil
                    self.counted.removeAtIndex(i)
                    self.spheres.removeAtIndex(i)
                    self.gameoverSubview?.updateScore(self.score)
                    
                }
                else{
                    
                    isGameover = true
                    
                }
            }
            else if(position.y != 0 && position.y<1.3 && self.counted[i] == 0){
                
                if(self.colorOrder[0]==self.spheres[i].name!){
                    self.score += 1
                    self.counted[i] = 1
                    self.sounds[self.spheres[i].name!]?.play()
                    self.spheres[i].geometry = nil
                    self.counted.removeAtIndex(i)
                    self.spheres.removeAtIndex(i)
                    self.gameoverSubview?.updateScore(self.score)
                    
                }
                else{
                    
                    isGameover = true
                    
                    
                }
            }
            else if(position.z != 0 && position.z<1.3 && self.counted[i] == 0){
                
                
                if(self.colorOrder[2]==self.spheres[i].name!){
                    self.score += 1
                    self.counted[i] = 1
                    self.sounds[self.spheres[i].name!]?.play()
                    self.spheres[i].geometry = nil
                    self.counted.removeAtIndex(i)
                    self.spheres.removeAtIndex(i)
                    self.gameoverSubview?.updateScore(self.score)
                }
                else{
                    
                    isGameover = true
                }
            }
            
            
        }
        
        
        
        
        if isGameover {
            gameOver()
        }

    }
    
    func checkGameoverButtons(){
       
            if(self.gameoverSubview!.buttons[0]){
                self.gameoverSubview!.buttons[0] = false
                
            }
            else if(self.gameoverSubview!.buttons[1]){
                self.gameoverSubview!.buttons[1] = false
                gameProducts.store.buyProduct(self.products[0])
            }
            else if(self.gameoverSubview!.buttons[2]){
                
                let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
                dispatch_async(dispatch_get_main_queue(), {
                    box?.removeActionForKey("rotate")
                    
                    box?.runAction(SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.5, shortestUnitArc: true))
                    self.gameoverSubview?.play()

                    
                })
                
                self.instantiateGameVars()
                self.gameState = "play"
                self.gameoverSubview!.buttons[2] = false

                
                print("2")
                self.menuSubview!.buttons[2] = false
                print("STARTING COLOR ORDER 1 ")

                print(self.colorOrder)
                print("STARTING COLOR ORDER 22")
                
                print(self.colorOrder)
                print("STARTING COLOR ORDER 3")
                
                print(self.colorOrder)
            }
            else if(self.gameoverSubview!.buttons[3]){
                self.gameoverSubview!.buttons[3] = false
                print("shar")
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.share()
                })
            }
            else if(self.gameoverSubview!.buttons[4]){
                
                
                
            }
    

        
    }
    
    
    func checkMenuButtons(){
        
            if(self.menuSubview!.buttons[0]){
                self.menuSubview!.buttons[0] = false
                print("1")

            }
            else if(self.menuSubview!.buttons[1]){
                self.menuSubview!.buttons[1] = false
                print(self.products)
                gameProducts.store.buyProduct(self.products[0])
                

                print("2")

            }
            else if(self.menuSubview!.buttons[2]){
                let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
                dispatch_async(dispatch_get_main_queue(), {
                    box?.removeActionForKey("rotate")

                    box?.runAction(SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.5, shortestUnitArc: true))
                    
                    self.view.subviews[0].removeFromSuperview()
                    self.gameoverSubview = GameoverOverlay(frame: CGRect(x: 0, y: 0, width: self.scnView.bounds.width, height: self.scnView.bounds.height), score: self.score, rootViewController: self ) //instatiate ui
                    
                    self.scnView.addSubview(self.gameoverSubview!)
                   
                    self.gameoverSubview?.play()

                })

                self.instantiateGameVars()
                self.gameState = "play"

                print("2")
                self.menuSubview!.buttons[2] = false
            }
            else if(self.menuSubview!.buttons[3]){
                self.menuSubview!.buttons[3] = false
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
    
    func rotateCube(){
        let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
        if(self.colorOrder[0] == "blue"){
            box?.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0.0, y: 0.5, z: 0.0, duration: 1)), forKey: "rotate")
        }
        else if (self.colorOrder[0] == "red") {
            box?.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0.5, y: 0, z: 0.0, duration: 1)), forKey: "rotate")
            
        }
        else if (self.colorOrder[0] == "yellow") {
            box?.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 0.5, z: 0.0, duration: 1)), forKey: "rotate")
            
        }
    }
    
    func setUpGameMenu(){
        rotateCube()
        dispatch_async(dispatch_get_main_queue(), { //make ui changes in main thread to avoid "this application is modifying the autolayout engine from a background thread"
            self.menuSubview = MenuOverlay(frame: CGRect(x: 0, y: 0, width: self.scnView.bounds.width, height: self.scnView.bounds.height)) //instatiate ui
            self.scnView.addSubview(self.menuSubview!)
        })
    }
    
    func gameOver(){
        self.gameState = "gameover"
        
        for (var i = self.spheres.endIndex-1 ; i>=0; i -= 1 ){
            self.spheres[i].removeFromParentNode()
            self.counted.removeAtIndex(i)
            self.spheres.removeAtIndex(i)
        }
        
        self.rotateCube()
        
        let userDefaults=NSUserDefaults()
        let highscore=userDefaults.integerForKey("highscore")
        
        if(self.score>highscore)
        {
            userDefaults.setInteger(self.score, forKey: "highscore")
        }
        userDefaults.synchronize()
        
        dispatch_async(dispatch_get_main_queue(), { //make ui changes in main thread to avoid "this application is modifying the autolayout engine from a background thread"
            self.gameoverSubview?.gameover()
        })
        
      //  performSegueWithIdentifier("gameOver", sender: self.score)

    }
    

    
    func addSphere(colorIndex: Int = Int(arc4random_uniform(3)), positionIndex: Int = Int(arc4random_uniform(3)) ){
        
        let colors = [UIColor(red: (247+6/255), green: (194+12)/255, blue: (49+17)/255, alpha: 1.0),UIColor(red: (229+6)/255, green: (72+12)/255, blue: (48+17)/255, alpha: 1.0),UIColor(red: (48+6)/255, green: (68+12)/255, blue: (84+17)/255, alpha: 1.0)]
        let colorNames = ["blue","red","yellow"]
        var position = [Float(0),Float(0),Float(0)]
        
        position[positionIndex] = Float(10)
        
        let materialColor  = SCNMaterial()
        
        materialColor.diffuse.contents = colors[colorIndex]
        materialColor.locksAmbientWithDiffuse = false;
        
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
        sphere.runAction(SCNAction.moveTo(SCNVector3(x:0,y:0,z:0), duration: NSTimeInterval(3)))
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
        
        var touch: Set<UITouch> = touches
        var location = touch.first?.locationInView(self.gameoverSubview)
        
        
      /* if(location.name == "retry") {
            var backToMainScene = GameScene(size: self.size)
            var transitionToMainScene = SKTransition.fadeWithDuration(1.0)
            backToMainScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(backToMainScene, transition: transitionToMainScene)
        }
        
        var touchLocation = touch.locationInNode(self)
        
        if(node.name == "taptostart") {
            tapToStartButton.hidden = true
            view?.scene?.paused = false
            
        */
        }
        
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        let location = sender.locationOfTouch(0, inView: self.scnView)
        // let spin = CABasicAnimation(keyPath: "rotation")
        let box = self.scn.rootNode.childNodeWithName("box", recursively: true)
        var x = Float(0.0), y = Float(0.0), z = Float(0.0)
        let halfWidth = Float(self.scnView.bounds.width/2)
        if(self.gameState == "play") {
            print("gesture")
            print(self.colorOrder)
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
            print("gesture 2")
            print(self.colorOrder)
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
