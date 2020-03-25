//
//  AnimationViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import AppKit
import SpriteKit

class AnimationViewController: NSViewController {

    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Load the SKScene from 'AnimationScene.sks'
            if let scene = SKScene(fileNamed: "AnimationScene") {
                // Set the scale mode to scale to fill the view
                scene.scaleMode = .fill
                print(view.frame)
                view.setNeedsDisplay(scene.frame) // needed! why?
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

