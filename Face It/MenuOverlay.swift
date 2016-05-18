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

@IBDesignable class menuOverlay: UIView {
    
    var view: UIView!
    let nibName = "MenuOverlay"
    var buttons = [false,false,false,false,false] //possible button from left to right

    @IBAction func play(sender: AnyObject) {
        buttons[2] = true
    }
    
    @IBAction func share(sender: AnyObject) {
        buttons[4] = true
        
    }



     override init(frame: CGRect) { // programmer creates our custom View
        super.init(frame: frame)
        setupGameover( frame)
        
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