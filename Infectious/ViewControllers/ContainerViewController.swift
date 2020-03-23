//
//  ContainerViewController.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/23/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import  AppKit

class ContainerViewController: NSViewController {

    @IBAction func startSimulation(_ sender: Any) {
        if animationIsRunning { return }
        DispatchQueue.global(qos: .userInitiated).async {
            for sprite in sprites {
                sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sus
            }
            print("finished Sus")
            DispatchQueue.main.async {
                animationIsRunning = true
                //lineViewUpdateTimer.repeats = true
                print("reanimating")
                startInfection()
            }
        }

        
    }
    
    @IBAction func stopSimulation(_ sender: Any) {
        animationIsRunning = false
        stopAnimation()
        //lineViewUpdateTimer.repeats = false
        
        for sprite in sprites {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sus
        }
        popSummary()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}
