//
//  AnimationScene.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import AppKit
import SpriteKit
import QuartzCore

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
        
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let circle = CGPath(ellipseIn: rect, transform: nil)
        //print(circle)
        //print("self.frame",self.frame)
        //let edge = SKPhysicsBody(edgeLoopFrom: self.frame)  // rect scene
        let edge = SKPhysicsBody(edgeLoopFrom : circle)       // petri dish
        edge.categoryBitMask = PhysicsCategory.Edge
        edge.contactTestBitMask = PhysicsCategory.All
        edge.collisionBitMask = PhysicsCategory.All
        self.physicsBody = edge
        
        initSprites()
        popSummary()
        startInfection()
    }
    
    func initSprites() {
        sprites = spritesCollection(count: kPopulationSize)
        for sprite in sprites {
            addChild(sprite)
        }
    }
    
    func spritesCollection(count: Int) -> [SKShapeNode] {

        var i = 0
        for _ in 0..<count {
            //let sprite = SKSpriteNode(imageNamed: "blueDot")
            let sprite = SKShapeNode(circleOfRadius: 3)
            sprite.name = String(i)
            sprite.fillColor = .gray
            sprite.strokeColor = .clear
            
            // for petri dish scene
            let a = random() * 2 * .pi
            let r = size.width / 2 * sqrt(random())
            let x = r * cos(a) + size.width / 2
            let y = r * sin(a) + size.width / 2
            
            // for rect scene
            //let x = CGFloat(arc4random() % UInt32(size.width))
            //let y = CGFloat(arc4random() % UInt32(size.width))
            sprite.position = CGPoint(x:x, y:y)
            
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: 3)
            sprite.physicsBody?.isDynamic = true
            sprite.physicsBody?.allowsRotation = false
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.mass = 0.01
            
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Sus
            sprite.physicsBody!.contactTestBitMask = PhysicsCategory.All
            sprite.physicsBody?.collisionBitMask = PhysicsCategory.All
            
            sprite.physicsBody?.usesPreciseCollisionDetection = true
            
            let actualX = randomRange(min: -100, max: 100)
            let actualY = randomRange(min: -100, max: 100)
            sprite.physicsBody?.velocity = CGVector(dx: actualX, dy: actualY)
            sprite.physicsBody?.friction = 0
            sprite.physicsBody?.restitution = 1
            
            sprite.blendMode = .replace
            //sprite.physicsBody?.applyForce(CGVector(dx: actualX, dy: actualY))
            sprite.userData = [
                "keyInfectedDate" : 0,
                "keyHealedDate" : 0,
                "keyDeathDate" : 0,
                "keyHasInfected" : 0
            ]
            
            //print(sprite.name, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.collisionBitMask)
            
            sprites.append(sprite)
            i+=1
        }
        return sprites
    }
    
    func applyForceToSprite() {
        
        // Determine force
        let actualX = randomRange(min: -gForce, max: gForce)
        let actualY = randomRange(min: -gForce, max: gForce)
                
        // Pick random sprite
        let max = CGFloat(kPopulationSize-1)
        let i = Int(randomRange(min: 0, max: max).rounded())
        let s = sprites[i]
        if s.physicsBody?.categoryBitMask == PhysicsCategory.None { return } // ignore the dead
        
        s.physicsBody?.applyForce(CGVector(dx: actualX, dy: actualY))
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        if contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask { return }
        //print(contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask )
        if contact.bodyA.categoryBitMask == PhysicsCategory.Sus && contact.bodyB.categoryBitMask == PhysicsCategory.Inf {
            popSummary()
            let infectiousNode = contact.bodyB.node as! SKShapeNode
            var hasInfected = infectiousNode.userData?.value(forKey: "keyHasInfected") as! Int
            hasInfected += 1
            infectiousNode.userData?.setValue(hasInfected, forKey: "keyHasInfected")
            
            let node = contact.bodyA.node as! SKShapeNode
            //print("infection",node.name, physicsBody?.categoryBitMask)
            healOrDie(node: node)
        }
        if contact.bodyB.categoryBitMask == PhysicsCategory.Sus && contact.bodyA.categoryBitMask == PhysicsCategory.Inf {
            popSummary()
            let infectiousNode = contact.bodyA.node as! SKShapeNode
            var hasInfected = infectiousNode.userData?.value(forKey: "keyHasInfected") as! Int
            hasInfected += 1
            infectiousNode.userData?.setValue(hasInfected, forKey: "keyHasInfected")

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
            stopMotion()
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
        
        if animationIsRunning {
            gIteration += 1
            applyForceToSprite() }
    }
}

