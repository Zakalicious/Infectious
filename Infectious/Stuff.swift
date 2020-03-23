//
//  Stuff.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/23/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import SpriteKit

var sprites:[SKShapeNode] = []

var animationIsRunning =  true

func stopAnimation() {
    for s in sprites {
        s.physicsBody?.velocity = CGVector()
    }
}
