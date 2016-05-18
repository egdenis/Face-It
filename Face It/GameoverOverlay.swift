//
//  GameoverOverlay.swift
//  Face It
//
//  Created by Etienne Denis on 5/13/16.
//  Copyright © 2016 Etienne Denis. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GameoverOverlay: UIView {
    
    var view: UIView!
    let nibName = "GameoverOverlay"
    var buttons = [false,false,false,false,false] //possible button from left to right
    
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func scores(sender: AnyObject) {
        self.buttons[0] = true

    }
    
    @IBAction func share(sender: AnyObject) {
        self.buttons[1] = true
    }
    
    @IBAction func restart(sender: AnyObject) {
        self.buttons[2] = true

    }
    @IBAction func rate(sender: AnyObject) {
        self.buttons[3] = true

    }
    @IBAction func buy(sender: AnyObject) {
        self.buttons[4] = true
    }


     init(frame: CGRect, score: Int) { // programmer creates our custom View
        super.init(frame: frame)
        print(score)
        setupGameover( frame)
        scoreLabel.text = String(score)
        highscoreLabel.text = NSUserDefaults().stringForKey("highscore")
        
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