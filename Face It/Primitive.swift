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
        let boxGeometry = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.0)
       
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor(red: 96/255, green: 157/255, blue: 160/255, alpha: 1.0)
        greenMaterial.locksAmbientWithDiffuse = true;
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor(red: 178/255, green: 34/255, blue: 34/255, alpha: 1.0)
        redMaterial.locksAmbientWithDiffuse = true;
        
        let blueMaterial  = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor(red: 254/255, green: 1, blue: 153/255, alpha: 0.0)
        blueMaterial.locksAmbientWithDiffuse = true;
        
        boxGeometry.materials = [blueMaterial,redMaterial,blueMaterial,redMaterial,greenMaterial,greenMaterial]
        
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
        cameraNode.position = SCNVector3Make(10,10, 10)
        cameraNode.eulerAngles = SCNVector3Make(Float(-0.6), Float(M_PI_4), Float(0))
        self.rootNode.addChildNode(cameraNode)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
