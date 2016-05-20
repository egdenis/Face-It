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
        yellowMaterial.diffuse.contents = UIColor(red: 253/255, green: 223/255, blue: 78/255, alpha: 1.0)
        yellowMaterial.locksAmbientWithDiffuse = true;
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor(red: 228/255, green: 36/255, blue: 38/255, alpha: 1.0)
        redMaterial.locksAmbientWithDiffuse = true;
        
        let blueMaterial  = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor(red: 0/255, green: 85/255, blue: 129/255, alpha: 1.0)
        blueMaterial.locksAmbientWithDiffuse = true;
        
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
