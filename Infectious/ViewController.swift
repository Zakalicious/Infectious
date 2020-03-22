//
//  ViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit
import Charts

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!

 /*   override func viewWillLayout() {
        super.viewWillLayout()

        if (skView == nil) {
            let backgroundImageView = lineChartView
            view.addSubview(backgroundImageView!)

            skView = SKView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 1536, height: 2048)))
            //skView!.ignoreSiblingOrder = true
            if let scene = SKScene(fileNamed: "GameScene") {
                            // Set the scale mode to scale to fit the window
                            scene.scaleMode = .aspectFit
                            print(view.bounds, scene.frame)
                            //view.setFrameSize(scene.frame)
                            view.setNeedsDisplay(scene.frame)
                            print(scene.anchorPoint)
                            scene.anchorPoint = CGPoint(x:0,y:0)
                            print(scene.anchorPoint)
                            
                            scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
            //scene.physicsBody?..
                            
                            // Present the scene
                            skView.presentScene(scene)
                        }
        }
    }
*/
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                print(view.bounds, scene.frame)
                //view.setFrameSize(scene.frame)
                view.setNeedsDisplay(scene.frame)
                print(scene.anchorPoint)
                scene.anchorPoint = CGPoint(x:0,y:0)
                print(scene.anchorPoint)
                
                scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
//scene.physicsBody?..
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

}

