//
//  RoundedButton.swift
//  Face It
//
//  Created by Etienne Denis on 5/23/16.
//  Copyright © 2016 Etienne Denis. All rights reserved.
//

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.height / 2.0
        clipsToBounds = true
    }
}