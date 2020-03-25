//
//  Stuff.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/23/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import SpriteKit

var startDate = CACurrentMediaTime()
var gIteration = 0
var gForce: CGFloat = 100.0

struct Sums {
    var x = 0
    var s = 0
    var i = 0
    var r = 0
    var d = 0
}

var sir: [Sums] = []

struct PhysicsCategory {
    static let None     : UInt32 = 0
    static let All      : UInt32 = UInt32.max
    static let Sus      : UInt32 = 0b1       // 1
    static let Inf      : UInt32 = 0b10      // 2
    static let Rec      : UInt32 = 4
    static let Edge     : UInt32 = 8
}

var sprites:[SKShapeNode] = []

var animationIsRunning =  true

func stopMotion() {
    for s in sprites {
        s.physicsBody?.velocity = CGVector()
    }
}

func startMotion() {

    for s in sprites {
        let actualX = randomRange(min: -200, max: 200)
        let actualY = randomRange(min: -100, max: 100)
        s.physicsBody?.velocity = CGVector(dx: actualX, dy: actualY)
    }
}

func startInfection() {
    // start infection
    let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
        let i = Int(randomRange(min: 0, max: 299).rounded())
        
        //startDate = CACurrentMediaTime()
        for sprite in sprites {
            if sprite.name == String(i) {
                
                let node = sprites[i]
                healOrDie(node: node)
                
            }
        }
    }
}

func healOrDie(node: SKShapeNode) {
    
    node.physicsBody?.categoryBitMask = PhysicsCategory.Inf
    node.fillColor = .red
    //let t = CACurrentMediaTime() - startDate
    node.userData?.setValue(gIteration, forKey: "keyInfectedDate")
    
    let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
        //heal ot die1
        let probability = randomRange(min: 0, max: 100)
        if probability < 10 {
            //let t = CACurrentMediaTime() - startDate
            node.userData?.setValue(gIteration, forKey: "keyDeathDate")
            
            node.physicsBody?.categoryBitMask = PhysicsCategory.None
            node.physicsBody?.contactTestBitMask = PhysicsCategory.None
            node.physicsBody?.collisionBitMask = PhysicsCategory.None
            popSummary()
            node.fillColor = .clear
            //node.removeFromParent()
        } else {
            //let t = CACurrentMediaTime() - startDate
            node.userData?.setValue(gIteration, forKey: "keyHealedDate")
            
            node.physicsBody?.categoryBitMask = PhysicsCategory.Rec
            node.fillColor = .blue
            popSummary()
        }
    }
}
    
    func popSummary() {
        var sSum = 0, iSum = 0, rSum = 0
        //let x = CACurrentMediaTime() - startDate
        
        for sprite in sprites {
            if sprite.physicsBody?.categoryBitMask == PhysicsCategory.Sus {
                sSum += 1
            }
            if sprite.physicsBody?.categoryBitMask == PhysicsCategory.Rec {
                rSum += 1
            }
            if sprite.physicsBody?.categoryBitMask == PhysicsCategory.Inf {
                iSum += 1
            }
        }
        let total = sSum + iSum + rSum
        let dead = 300 - total
        
        //print("S",sSum,"I",iSum,"R",rSum,"D", dead)
        
        let sumElement = Sums(x: gIteration, s: sSum, i: iSum, r: rSum, d: dead)
        sir.append(sumElement)
        
        //chartVC.view.needsDisplay = true
        //chartVC.view.upda
    }

func analyzeSprites() {
    var count0 = 0
    var count1 = 0
    var count2 = 0
    var count3 = 0
    var count4 = 0
    var countOther = 0
    
    for sprite in sprites {
        
        let infectionDate = sprite.userData?.value(forKey: "keyInfectedDate") as? Int
        if infectionDate ?? 0 > 0 {
            print("keyInfectedDate", sprite.userData?.value(forKey: "keyInfectedDate"))
            print(sprite.userData?.value(forKey: "keyHasInfected"))
            switch sprite.userData?.value(forKey: "keyHasInfected") as! Int {
            case 0:
                count0 += 1
            case 1:
                count1 += 1
            case 2:
                count2 += 1
            case 3:
                count3 += 1
            case 4:
                count4 += 1
            default:
                countOther += 1
            }
        }
    }
    print ("analyzeSprites keyHasInfected", count0,count1,count2,count3, count4, countOther)
}


func random() -> CGFloat {
    return CGFloat(Double(arc4random()) / 0xFFFFFFFF)
}

func randomRange(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}


