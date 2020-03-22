//
//  GameScene.swift
//  Infectious
//
//  Created by Thomas Hartmann on 3/21/20.
//  Copyright © 2020 Thomas Hartmann. All rights reserved.
//

import SpriteKit
import GameplayKit
import Charts

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var healthySprite : SKSpriteNode?
    private var spinnyNode : SKShapeNode?
    
    var sprites:[SKShapeNode] = []
    
    struct PhysicsCategory {
      static let None     : UInt32 = 0
      static let All      : UInt32 = UInt32.max
      static let Sus      : UInt32 = 0b1       // 1
      static let Inf      : UInt32 = 0b10      // 2
      static let Rec      : UInt32 = 4
      static let Edge      : UInt32 = 8
    }
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = .clear
        view.allowsTransparency = true
        
        let lineChartView = LineChartView()
        
        let ys1 = Array(1..<10).map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = Array(1..<10).map { x in return cos(Double(x) / 2.0 / 3.141) }
        
        let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let ds1 = LineChartDataSet(entries: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.addDataSet(ds1)
        
        let ds2 = LineChartDataSet(entries: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.addDataSet(ds2)
        
        view.addSubview(lineChartView)

        lineChartView.data = data
        
        lineChartView.gridBackgroundColor = NSUIColor.white

        lineChartView.chartDescription?.text = "Linechart Demo"
        
        physicsWorld.contactDelegate = self
        
        sprites = spritesCollection(count: 300)
        for sprite in sprites {
            addChild(sprite)
        }

        let edge = SKPhysicsBody(edgeLoopFrom: self.frame)
        edge.categoryBitMask = PhysicsCategory.Edge
        edge.contactTestBitMask = PhysicsCategory.All
        edge.collisionBitMask = PhysicsCategory.All

        // start infection
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in

            let i = Int(self.random(min: 0, max: 299).rounded())
            self.sprites[i].physicsBody?.categoryBitMask = PhysicsCategory.Inf
            self.sprites[i].fillColor = .red
            
        }
    }
    
    func popSummary() {
        var sSum = 0, iSum = 0, rSum = 0
        
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
        print(sSum,iSum,rSum, total, dead)
    }
    
 
    private func spritesCollection(count: Int) -> [SKShapeNode] {
        //var sprites = [SKSpriteNode]()
        var i = 0
        for _ in 0..<count {
            //let sprite = SKSpriteNode(imageNamed: "blueDot")
            let sprite = SKShapeNode(circleOfRadius: 6)
            sprite.name = String(i)
            sprite.fillColor = .gray
            // skipping the physicsBody stuff for now as it is not part of the question

            // giving the sprites a random position
            //let max = size.
            //let x = CGFloat(arc4random_uniform(UInt32((view?.bounds.maxX)! + 1)))
            //let y = CGFloat(arc4random_uniform(UInt32((view?.bounds.maxY)! + 1)))

            let x = CGFloat(arc4random() % UInt32(size.width))
            let y = CGFloat(arc4random() % UInt32(size.height))
            sprite.position = CGPoint(x:x, y:y)
/*
            let rangeX = SKRange(lowerLimit: 0, upperLimit: size.width)
            let contraintX = SKConstraint.positionX(rangeX)
            let rangeY = SKRange(lowerLimit: 0, upperLimit: size.height)
            let contraintY = SKConstraint.positionY(rangeY)
            sprite.constraints = [contraintX, contraintY]
*/
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: 6) //sprite.size.height / 2.0)
            sprite.physicsBody?.isDynamic = true
            sprite.physicsBody?.allowsRotation = false
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.mass = 0.01

            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Sus //1//0b00001
            sprite.physicsBody!.contactTestBitMask = PhysicsCategory.All
            //sprite.physicsBody!.collisionBitMask = ColliderType.PIPE.rawValue

            sprite.physicsBody?.collisionBitMask = PhysicsCategory.All // was 0
            
            sprite.physicsBody?.usesPreciseCollisionDetection = true
            
            let actualX = random(min: -200, max: 200)
            let actualY = random(min: -100, max: 100)
            sprite.physicsBody?.velocity = CGVector(dx: actualX, dy: actualY)
            sprite.physicsBody?.friction = 0
            sprite.physicsBody?.restitution = 1
            
            sprite.blendMode = .replace
            //sprite.physicsBody?.applyForce(CGVector(dx: actualX, dy: actualY))
            sprite.userData = [
                "keyA" : "blahblah",
                "keyB" : 17.0
            ]

            print(sprite.name, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.categoryBitMask, sprite.physicsBody!.collisionBitMask)

            sprites.append(sprite)
            i+=1
        }
        return sprites
    }
        
    func random() -> CGFloat {
      return CGFloat(Double(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    func moveSprite() {
      
      // Determine where to spawn the monster along the Y axis
      let actualX = random(min: -200, max: 200)
      let actualY = random(min: -100, max: 100)
      
      // Determine speed of the monster
      let actualDuration = random(min: CGFloat(0.01), max: CGFloat(0.20))
        
      // Pick i
      let i = Int(random(min: 0, max: 299).rounded())

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
            node.physicsBody?.categoryBitMask = PhysicsCategory.Inf
            node.fillColor = .red
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                //heal ot die1
                let p = self.random(min: 0, max: 99)
                if p < 10 {
                    node.physicsBody?.categoryBitMask = PhysicsCategory.None
                    node.fillColor = .black
                    node.removeFromParent()
                } else {
                    node.physicsBody?.categoryBitMask = PhysicsCategory.Rec
                    node.fillColor = .blue
                }
             }
        }
        if contact.bodyB.categoryBitMask == PhysicsCategory.Sus && contact.bodyA.categoryBitMask == PhysicsCategory.Inf {
            popSummary()
            let node = contact.bodyB.node as! SKShapeNode
            //print("infection",node.name, physicsBody?.categoryBitMask)
            node.physicsBody?.categoryBitMask = PhysicsCategory.Inf
            node.fillColor = .red
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                //heal ot die1
                let p = self.random(min: 0, max: 99)
                if p < 10 {
                    node.physicsBody?.categoryBitMask = PhysicsCategory.None
                    node.fillColor = .black
                    node.removeFromParent()
                } else {
                    node.physicsBody?.categoryBitMask = PhysicsCategory.Rec
                    node.fillColor = .blue
                }
                
             }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
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
        //SKAction.run(moveSprite)
        moveSprite()
    }
}
