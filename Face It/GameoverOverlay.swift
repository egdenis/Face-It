    //
//  GameoverOverlay.swift
//  Face It
//
//  Created by Etienne Denis on 5/13/16.
//  Copyright © 2016 Etienne Denis. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
    

@IBDesignable class GameoverOverlay: UIView, GADBannerViewDelegate {
    
    var view: UIView!
    let nibName = "GameoverOverlay"
    var buttons = [false,false,false,false,false,false,false] //possible button from left to right
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestText: UILabel!
   
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var shareButton: RoundedButton!
    @IBOutlet weak var adsImage: UIImageView!
    @IBOutlet weak var adsButton: RoundedButton!
    @IBOutlet weak var playButton: RoundedButton!
    
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var playScore: UILabel!
    
    @IBAction func ads(sender: AnyObject) {
        self.buttons[1] = true
        print("ads gameove")

    }
    
    
    @IBAction func play(sender: AnyObject) {
        self.buttons[2] = true

    }
    
    @IBAction func share(sender: AnyObject) {
        self.buttons[3] = true
        print("gmaeover share")
    }
  
    func updateScore(score: Int){
        print("score:")
        print(score)

        print(self.playScore.text!)
        dispatch_async(dispatch_get_main_queue(), {
        self.playScore.text = String(stringInterpolationSegment:score)
        self.scoreLabel.text = String(stringInterpolationSegment:score)
        })
    }
    
    func play(){
        self.playScore.text = "0"
        self.playScore.fadeIn()
        self.scoreLabel.fadeOut()
        self.highscoreLabel.fadeOut()
        self.bestText.fadeOut()
        self.scoreText.fadeOut()
        self.shareImage.hidden = true
        self.shareButton.fadeOut()
        self.playButton.fadeOut()
        self.playImage.hidden = true
        
        self.adsButton.fadeOut()
        self.adsImage.hidden = true
    }

    func gameover(){

        self.playScore.fadeOut()
        self.scoreLabel.fadeIn()
        self.highscoreLabel.fadeIn()
        self.bestText.fadeIn()
        self.scoreText.fadeIn()
        self.shareImage.hidden = false
        self.shareButton.fadeIn()
        self.playButton.fadeIn()
        self.playImage.hidden = false
        self.adsButton.fadeIn()
        self.adsImage.hidden = false
    }
    init(frame: CGRect, score: Int, rootViewController: UIViewController) { // programmer creates our custom View
        super.init(frame: frame)
       
        
        print(score)
        
        setupGameover( frame)
        scoreLabel.text = String(score)
        highscoreLabel.text = (NSUserDefaults().stringForKey("highscore"))
        print("its good")
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = rootViewController
        bannerView.loadRequest(GADRequest())

        }
    
    
    required init!(coder aDecoder: NSCoder) {  // Storyboard or UI File
        super.init(coder: aDecoder)
        let frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        setupGameover(frame)
    }
    
    func setupGameover(frame: CGRect) { // setup XIB here
        
        view = loadHudFromNib()
        view.frame = frame// this will be the size of your HUD in game
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    
    func loadHudFromNib() ->UIView {
        
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView        
        return view
        
    }
    
}