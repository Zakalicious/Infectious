//
//  ContainerViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/23/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import  AppKit

class ContainerViewController: NSViewController {

    @IBOutlet weak var startButton: NSButton!
    @IBAction func startSimulation(_ sender: Any) {
        if animationIsRunning { return }
        gIteration = 0

        sir.removeAll()

         for sprite in sprites {
             sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sus
             sprite.physicsBody?.contactTestBitMask = PhysicsCategory.All
             sprite.physicsBody?.collisionBitMask = PhysicsCategory.All
             sprite.fillColor = .gray
         }
        popSummary()

        NotificationCenter.default.post(name: Notification.Name(rawValue: "start"), object: nil )
        startMotion()

        startInfection()
        animationIsRunning = true

        stopButton.isEnabled = true
        startButton.isEnabled = false

    }
    
    @IBOutlet weak var stopButton: NSButton!
    @IBAction func stopSimulation(_ sender: Any) {

        animationIsRunning = false
        stopMotion()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "stop"), object: nil )

        analyzeSprites()
        
        stopButton.isEnabled = false
        startButton.isEnabled = true
    }
    
   
    @IBOutlet weak var forceSlider: NSSlider!
    @IBAction func applyForce(_ sender: NSSlider) {
        let d = forceSlider.doubleValue
        gForce = CGFloat(d)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        let sliderFrame = NSRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 120, height: 40))
        let slider = RangeSlider(frame:sliderFrame)

    }

}
