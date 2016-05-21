//
//  Primitive.swift
//  Face It
//
//  Created by Etienne Denis on 6/2/15.
//  Copyright (c) 2015 Etienne Denis. All rights reserved.
//

import SceneKit
import UIKit

class Primitive: SCNScene {
    var box:SCNNode!
    override init() {
        super.init()
        let boxGeometry = SCNBox(width: 3.5, height: 3.5, length: 3.5, chamferRadius: 0.1)
       
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor(red: 247/255, green: 194/255, blue: 49/255, alpha: 1.0)
        yellowMaterial.locksAmbientWithDiffuse = false;
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor(red: 229/255, green: 72/255, blue: 48/255, alpha: 1.0)
        redMaterial.locksAmbientWithDiffuse = false;
        
        let blueMaterial  = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor(red: 48/255, green: 68/255, blue: 84/255, alpha: 1.0)
        blueMaterial.locksAmbientWithDiffuse = false;
        
        boxGeometry.materials = [blueMaterial,redMaterial,blueMaterial,redMaterial,yellowMaterial,yellowMaterial]
        
        self.box = SCNNode(geometry: boxGeometry)
        self.box.name = "box"
        let boxShape = SCNPhysicsShape(geometry: boxGeometry, options: nil)
        let boxBody = SCNPhysicsBody(type: .Kinematic, shape: boxShape)
        
        self.box.physicsBody = boxBody;
        self.rootNode.addChildNode(self.box)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.47, alpha: 1.0)
        self.rootNode.addChildNode(ambientLightNode)
        
       
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(10,8, 10)
        cameraNode.eulerAngles = SCNVector3Make(Float(-0.55), Float(M_PI_4), Float(0))
        self.rootNode.addChildNode(cameraNode)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
