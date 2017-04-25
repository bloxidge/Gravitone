//
//  GTNode.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 26/10/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
// 

import SpriteKit

/**
 Class that contains the instructions for creating a new node on the canvas.
 
 A `GTNode` object comprises of an `SKShapeNode` with a physics body, allowing it to interact with other
 nodes. It also contains the information about the node's note length and whether it is fixed in one
 position or able to move freely on the canvas.
 */
class GTNode: SKShapeNode {
    
    // Private properties
    private var nodeSize: CGSize!
    private var noteLength: Float!
    private var noteDuration: TimeInterval!
    private var spriteNode: SKSpriteNode!
    private var outlineNode: SKShapeNode!
    private let screwNode = SKSpriteNode(imageNamed: "screw.png")
    private var pulseTimer: Timer!
    private var start = DispatchTime.now()
    private var end = DispatchTime.now()
    private var firstPulse = true
    
    // Sprite actions for pulse and remove animation sequences
    private let pulseAction = SKAction.sequence([
        .scale(to: 0.8, duration: 0.05),
        .scale(to: 1.0, duration: 0.65, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 50.0)
    ])
    private let pulseOutlineAction = SKAction.sequence([
        .scale(to: 0.8, duration: 0.0),
        .fadeIn(withDuration: 0.0),
        .group([
            .scale(to: 1.4, duration: 0.6, delay: 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0),
            .fadeOut(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0)
        ])
    ])
    private let removeAction = SKAction.group([
        .scale(to: 1.25, duration: 0.1),
        .fadeOut(withDuration: 0.1)
        ])
    
    // Public properties
    var isFixed = false {
        didSet {
            isPinned = isFixed
            if isFixed {
                startPulsing()
                addChild(screwNode)
                physicsBody!.categoryBitMask = NodeCategory.fixed
                physicsBody!.contactTestBitMask = NodeCategory.dynamic
            } else {
                physicsBody!.categoryBitMask = NodeCategory.dynamic
                physicsBody!.contactTestBitMask = NodeCategory.all
            }
        }
    }
    var isPinned: Bool! {
        didSet {
            physicsBody!.pinned = isPinned
        }
    }
    var isDynamic: Bool! {
        didSet {
            physicsBody!.isDynamic = isDynamic
        }
    }
    var bounce: CGFloat! {
        didSet {
            physicsBody!.restitution = bounce
        }
    }
    var tempo: Float! {
        didSet {
            updateTempo(to: tempo)
        }
    }
    var instrument: GTInstrument!
    var shape: Shape!
    var color: UIColor!
    var note: Note!
    
    /**
     Initialises a new `GTNode`.
     
     - parameters:
        - shape: The shape type of the node.
        - color: The color of the node.
        - note: The note type of the node.
     */
    init(shape: Shape, color: SKColor, note: Note) {
        
        super.init()
        
        // Assign fundamental properties for this object
        self.shape = shape
        self.color = color
        self.note = note
        
        // Calculate sprite properties
        noteLength = note.length
        nodeSize = CGSize(width: note.size, height: note.size)
        let nodeRect = CGRect(origin: CGPoint(x: -note.size/2, y: -note.size/2), size: nodeSize)
        let nodePath = CGMutablePath()
        
        // Draw path for this shape's physical interaction
        switch shape {
        case .circle: nodePath.addEllipse(in: nodeRect)
        case .square: nodePath.addRect(nodeRect)
        case .triangle: nodePath.addTriangle(in: nodeRect)
        case .star: nodePath.addStar(in: nodeRect)
        }
        // Add textured image of shape for 3D dynamic lighting
        spriteNode = SKSpriteNode(imageNamed: shape.rawValue)
        spriteNode.normalTexture = SKTexture(imageNamed: "\(shape.rawValue)_n")

        // Set SKShapeNode properties
        path = nodePath
        name = "MainNode"
        lineWidth = 0.0
        
        // Set properties for child nodes
        spriteNode.size = nodeSize
        spriteNode.color = color
        spriteNode.colorBlendFactor = 0.9
        spriteNode.lightingBitMask = 0x1
        spriteNode.zPosition = -2
        
        outlineNode = SKShapeNode(path: nodePath)
        outlineNode.lineWidth = 5.0
        outlineNode.strokeColor = SKColor(hue: color.hsbComponents.hue, saturation: 0.5*color.hsbComponents.saturation, brightness: 1, alpha: 1)
        outlineNode.zPosition = -3
        outlineNode.isUserInteractionEnabled = false
        
        screwNode.size = CGSize(width: note.size/4, height: note.size/4)
        screwNode.zPosition = -1
        screwNode.zRotation = CGFloat(arc4random())
        
        // Create physics body and enable collision
        physicsBody = SKPhysicsBody(polygonFrom: nodePath)
        physicsBody!.friction = 0.4
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.collisionBitMask = NodeCategory.all
        
        // Add child nodes to parent
        addChild(outlineNode)
        addChild(spriteNode)
    }
    
    /**
     Required initialiser.
     */
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    /**
     Updates the tempo of the node according to the global tempo.
     
     This only applies to fixed nodes.
     
     - parameter tempo: New tempo to update the node to.
     */
    func updateTempo(to tempo: Float) {
        
        // Calculate new note duration
        noteDuration = TimeInterval(240.0*noteLength / tempo)
        // Destroy existing timer and start new one
        if pulseTimer != nil {
            pulseTimer.invalidate()
            pulse()
            startPulsing()
        }
    }
    
    /**
     Starts the pulsing action for a fixed node with regular pulsing.
     */
    private func startPulsing() {
        
        pulseTimer = Timer.scheduledTimer(timeInterval: noteDuration, target: self, selector: #selector(pulse), userInfo: nil, repeats: true)
    }
    
    /**
     Public method for executing a single pulse action. This function acts as a debouncer by ensuring
     that the node cannot pulse more than once in within a 20 ms interval.
     */
    func pulse() {
        
        if firstPulse {
            executePulse()
            firstPulse = false
        }
        end = .now()
        let msInterval = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 100000
        if msInterval >= 20 {
            executePulse()
        }
        start = .now()
    }
    
    /**
     Runs the sprite actions for the pulse, and plays the appropriate sample for this node's properties.
     */
    private func executePulse() {
        
        spriteNode.run(pulseAction)
        outlineNode.run(pulseOutlineAction)
        
        instrument.play(for: self)
    }
    
    /**
     Safely removes the node from the canvas.
     
     This method runs a smooth transition action before removing the node from its scene and unassigning
     the associated instrument object.
     */
    func remove() {
        
        run(removeAction)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(removeFromParent), userInfo: nil, repeats: false)
        if isFixed {
            pulseTimer.invalidate()
        }
        instrument.isTaken = false
    }
}
