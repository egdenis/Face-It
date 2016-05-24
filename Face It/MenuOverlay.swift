//
//  GameoverOverlay.swift
//  Face It
//
//  Created by Etienne Denis on 5/13/16.
//  Copyright © 2016 Etienne Denis. All rights reserved.
//

import Foundation
import UIKit
import Social

@IBDesignable class MenuOverlay: UIView {
    
    var view: UIView!
    let nibName = "MenuOverlay"
    var buttons = [false,false,false,false,false]
    
    @IBAction func scores(sender: AnyObject) {
        buttons[0] = true

    }
    
    @IBAction func ads(sender: AnyObject) {
        buttons[1] = true
        
    }
    @IBAction func play(sender: AnyObject) {
        buttons[2] = true
    }
    
  
    
    @IBAction func share(sender: AnyObject) {
        print("this is share 4")
        buttons[3] = true
    }
    //possible button from left to right
  
    
    @IBAction func rate(sender: AnyObject) {
        print("rate")
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1053533457&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!);
    }
    
    /*@IBAction func play(sender: AnyObject) {
        print("play")
        print("play")

        buttons[2] = true
    }
    @IBAction func scores(sender: AnyObject) {
    }
    
    @IBAction func ads(sender: AnyObject) {
        buttons[1] = true
    }
    @IBAction func rate(sender: AnyObject){
        print("rate")
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1053533457&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!);
    }
    @IBAction func share(sender: AnyObject) {
        print("this is share 4")
        buttons[4] = true
        
    }
*/


     override init(frame: CGRect) { // programmer creates our custom View
        super.init(frame: frame)
        print("***************HELLLLLOOOOOO THERE")

        setupGameover( frame)
        
    }
    
    
    required init!(coder aDecoder: NSCoder) {  // Storyboard or UI File
        super.init(coder: aDecoder)
        
        print("required init")
        let frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        setupGameover(frame)
    }
    
    func gameover(){
        
    }
    
    func play(){
        
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