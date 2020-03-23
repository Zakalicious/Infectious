//
//  AnimationScene.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit
import QuartzCore
import Charts

var startDate = CACurrentMediaTime()

struct Sums {
    var x = 0.0
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
    static let Edge      : UInt32 = 8
}


class AnimationScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var healthySprite : SKSpriteNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        //https://developer.apple.com/documentation/spritekit/skscene/creating_a_scene_with_a_transparent_background
        self.backgroundColor = .clear
        view.allowsTransparency = true
        //view.backgroundColor // cannot set?
        
        physicsWorld.contactDelegate = self
        
        let edge = SKPhysicsBody(edgeLoopFrom: self.frame)
        edge.categoryBitMask = PhysicsCategory.Edge
        edge.contactTestBitMask = PhysicsCategory.All
        edge.collisionBitMask = PhysicsCategory.All
        
        initSprites()
        startInfection()
    }
    
    func initSprites() {
        sprites = spritesCollection(count: 300)
        for sprite in sprites {
            addChild(sprite)
        }
    }
    
    private func spritesCollection(count: Int) -> [SKShapeNode] {

        var i = 0
        for _ in 0..<count {
            //let sprite = SKSpriteNode(imageNamed: "blueDot")
            let sprite = SKShapeNode(circleOfRadius: 6)
            sprite.name = String(i)
            sprite.fillColor = .gray
            sprite.strokeColor = .clear
            
            // giving the sprites a random position
            let x = CGFloat(arc4random() % UInt32(size.width))
            let y = CGFloat(arc4random() % UInt32(size.height))
            sprite.position = CGPoint(x:x, y:y)
            
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: 6) //sprite.size.height / 2.0)
            sprite.physicsBody?.isDynamic = true
            sprite.physicsBody?.allowsRotation = false
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.mass = 0.01
            
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Sus
            sprite.physicsBody!.contactTestBitMask = PhysicsCategory.All
            sprite.physicsBody?.collisionBitMask = PhysicsCategory.All
            
            sprite.physicsBody?.usesPreciseCollisionDetection = true
            
            let actualX = randomRange(min: -200, max: 200)
            let actualY = randomRange(min: -100, max: 100)
            sprite.physicsBody?.velocity = CGVector(dx: actualX, dy: actualY)
            sprite.physicsBody?.friction = 0
            sprite.physicsBody?.restitution = 1
            
            sprite.blendMode = .replace
            //sprite.physicsBody?.applyForce(CGVector(dx: actualX, dy: actualY))
            sprite.userData = [
                "keyInfectedDate" : 0.0,
                "keyHealedDate" : 0.0,
                "keyDeathDate" : 0.0
            ]
            
            //print(sprite.name, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.collisionBitMask)
            
            sprites.append(sprite)
            i+=1
        }
        return sprites
    }
    
    func moveSprite() {
        
        // Determine where to spawn the monster along the Y axis
        let actualX = randomRange(min: -200, max: 200)
        let actualY = randomRange(min: -100, max: 100)
        
        // Determine speed of the monster
        let actualDuration = randomRange(min: CGFloat(0.01), max: CGFloat(0.20))
        
        // Pick i
        let i = Int(randomRange(min: 0, max: 299).rounded())
        
        // Create the actions
        //let actionMove = SKAction.move(by: CGVector(dx: actualX, dy: actualY), duration: TimeInterval(actualDuration))
        let s = sprites[i]
        s.physicsBody?.applyForce(CGVector(dx: actualX, dy: actualY))
        //s.run(SKAction.sequence([actionMove]))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        if contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask { return }
        //print(contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask )
        if contact.bodyA.categoryBitMask == PhysicsCategory.Sus && contact.bodyB.categoryBitMask == PhysicsCategory.Inf {
            popSummary()
            let node = contact.bodyA.node as! SKShapeNode
            //print("infection",node.name, physicsBody?.categoryBitMask)
            healOrDie(node: node)
        }
        if contact.bodyB.categoryBitMask == PhysicsCategory.Sus && contact.bodyA.categoryBitMask == PhysicsCategory.Inf {
            popSummary()
            let node = contact.bodyB.node as! SKShapeNode
            //print("infection",node.name, physicsBody?.categoryBitMask)
            node.physicsBody?.categoryBitMask = PhysicsCategory.Inf
            node.fillColor = .red
            healOrDie(node: node)
        }

    }
    
    func touchDown(atPoint pos : CGPoint) {
        // gets called after mouse down
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
        animationIsRunning = !animationIsRunning
        if animationIsRunning {
        } else {
            stopAnimation()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if animationIsRunning { moveSprite() }
    }
}


func startInfection() {
    // start infection
    let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
        let i = Int(randomRange(min: 0, max: 299).rounded())
        
        startDate = CACurrentMediaTime()
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
    let t = CACurrentMediaTime() - startDate
    node.userData?.setObject(String(t), forKey: "keyInfectedDate" as NSString)
    
    let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
        //heal ot die1
        let p = randomRange(min: 0, max: 99)
        if p < 10 {
            let t = CACurrentMediaTime() - startDate
            node.userData?.setObject(String(t), forKey: "keyDeathDate" as NSString)
            
            node.physicsBody?.categoryBitMask = PhysicsCategory.None
            popSummary()
            //node.fillColor = .black
            node.removeFromParent()
        } else {
            let t = CACurrentMediaTime() - startDate
            node.userData?.setObject(String(t), forKey: "keyHealedDate" as NSString)
            node.physicsBody?.categoryBitMask = PhysicsCategory.Rec
            node.fillColor = .blue
            popSummary()
        }
    }
}
    
    func popSummary() {
        var sSum = 0, iSum = 0, rSum = 0
        let x = CACurrentMediaTime() - startDate
        
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
        
        let sumElement = Sums(x: x, s: sSum, i: iSum, r: rSum, d: dead)
        sir.append(sumElement)
        
        //chartVC.view.needsDisplay = true
        //chartVC.view.upda
    }


func random() -> CGFloat {
    return CGFloat(Double(arc4random()) / 0xFFFFFFFF)
}

func randomRange(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

