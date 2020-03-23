//
//  AnimationViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit
import Charts

class AnimationViewController: NSViewController {

    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Load the SKScene from 'AnimationScene.sks'
            if let scene = SKScene(fileNamed: "AnimationScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                print(view.bounds, scene.frame)
                //view.setFrameSize(scene.frame)
                view.setNeedsDisplay(scene.frame)
                print(scene.anchorPoint)
                scene.anchorPoint = CGPoint(x:0,y:0)
                print(scene.anchorPoint)
                
                scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

}

