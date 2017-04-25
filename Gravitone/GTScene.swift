//
//  GTScene.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 25/10/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import SpriteKit
import AudioKit
import CoreMotion

/**
 The `GTScene` object contains all the content displayed on the `SpriteKit` scene.
 
 This class contains all the information about the scene such as the properties from the view controller,
 including properties for setting up the next `GTNode` and properties that affect all nodes on the scene.
 
 This class also acts as the physics contact delegate for detecting node collisions.
 */
class GTScene: SKScene, SKPhysicsContactDelegate {
    
    // Private properties
    private var nodeCount = 0
    private var touchLocation: CGPoint!
    private var touchedNodes = [GTNode]()
    private var targetNode: GTNode! {
        didSet {
            targetNode.isPinned = false
            targetNode.isDynamic = false
        }
    }
    private let motionManager = CMMotionManager()
    private let masterMixer = AKMixer()
    private var instrumentBank = [GTInstrument]()
    
    // Public properties
    var nodeNote: Note!
    var nodeShape: Shape!
    var nodeColor: SKColor!
    var nodeIsFixed = false
    var isRealGravity = false {
        didSet {
            updateRealGravity()
        }
    }
    var globalRestitution: CGFloat = 0.0 {
        didSet {
            for node in self.children {
                if node is GTNode {
                    (node as! GTNode).bounce = globalRestitution
                }
            }
        }
    }
    var globalTempo: Float = 0.0 {
        didSet {
            for node in self.children {
                if node is GTNode {
                    (node as! GTNode).updateTempo(to: globalTempo)
                }
            }
        }
    }
    var globalTransposition = 0.0 {
        didSet {
            for instrument in instrumentBank {
                instrument.transposition = globalTransposition
            }
        }
    }
    
    /**
     Updates the real gravity from the device's accelerometer data.
     */
    private func updateRealGravity() {
        
        let gravity = 9.81
        
        if isRealGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.05
                motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (data, error) in
                    // If accelerometer data is received, set physics gravity accordingly
                    if let dx = data?.acceleration.x, let dy = data?.acceleration.y {
                        self.physicsWorld.gravity = CGVector(dx: -dy*gravity, dy: dx*gravity)
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    /**
     Adds a new node to the scene.
     
     - parameters:
        - point: Position on the canvas.
        - instrument: `GTInstrument` to be attached to the node.
     */
    private func addNode(at point: CGPoint, with instrument: GTInstrument) {
        
        // Create new GTNode from global properties and assign first available instrument in the bank
        let node = GTNode(shape: nodeShape, color: nodeColor, note: nodeNote)
        node.position = point
        node.zPosition = CGFloat(nodeCount*4)
        node.instrument = instrument
        node.instrument.isTaken = true
        node.tempo = globalTempo
        node.isFixed = nodeIsFixed
        node.bounce = globalRestitution
        
        // Initial pulse for fixed nodes
        if node.isFixed {
            node.pulse()
        }
        
        // Add to canvas and increment counter (for z-position)
        addChild(node)
        nodeCount += 1
    }
    
    /**
     Moves the target node to a new position on the canvas.
     
     - parameters:
        - node: Node to be moved.
        - translation: Value to move the node by.
     */
    private func moveNode(_ node: GTNode, by translation: CGPoint) {
        
        targetNode.position = CGPoint(x: targetNode.position.x + translation.x, y: targetNode.position.y + translation.y)
    }
    
    /**
     Removes all node currently on the canvas.
     */
    func removeAllNodes() {
        
        for node in children {
            if node is GTNode {
                (node as! GTNode).remove()
            }
        }
    }
    
    /**
     Called when a touch gesture is detected.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // If no touch registered, break out of method
        guard let touch = touches.first else {
            return
        }
        // Set touched location to first received touch
        touchLocation = touch.location(in: self)
        
        // If touched space was empty, add a node and assign an available instrument
        if nodes(at: touchLocation).isEmpty {
            availabilityLoop: for instrument in instrumentBank {
                if !instrument.isTaken {
                    addNode(at: touchLocation, with: instrument)
                    break availabilityLoop
                }
            }
        }
        
        // Escape if no instrument is available
        if nodes(at: touchLocation).isEmpty {
            return
        }
        
        // Now that node exists at touched location, set target to be the top-most node
        for node in self.nodes(at: touchLocation) {
            if node.name == "MainNode" {
                touchedNodes.append(node as! GTNode)
            }
        }
        targetNode = touchedNodes.first
        
        // If node was double-tapped, remove from canvas
        if touch.tapCount == 2 {
            targetNode.remove()
        }
    }
    
    /**
     Called when a pan gesture is recognised.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // If no touch registered, break out of method
        guard let touch = touches.first else {
            return
        }
        // Set new position to moved location and calculate translation from old point to new point
        let newPosition = touch.location(in: self)
        let translation = CGPoint(x: newPosition.x - touchLocation.x, y: newPosition.y - touchLocation.y)
        touchLocation = newPosition
        moveNode(targetNode, by: translation)
    }
    
    /**
     Called when a touch gesture is finished.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Re-engage physics proprties upon finishing
        if targetNode.isFixed {
            targetNode.isPinned = true
        }
        targetNode.isDynamic = true
        touchedNodes.removeAll()
    }
    
    /**
     Called when a touch gesture is cancelled.
     */
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    /**
     Called when this SpriteKit view is loaded.
     */
    override func didMove(to view: SKView) {
        
        // Set up physics world properties
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsWorld.contactDelegate = self
        
        // Set up global dynamic lighting properties
        let globalLight = SKLightNode()
        globalLight.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        globalLight.falloff = 0.2
        globalLight.lightColor = .white
        globalLight.ambientColor = .gray
        addChild(globalLight)
        
        // Create instrument bank of 20 instruments (maximum possible at current processing capabilities)
        // Connect to output mixer and start AudioKit
        for _ in 0...19 {
            let instrument = GTInstrument()
            instrumentBank.append(instrument)
            masterMixer.connect(instrument.output)
        }
        AudioKit.output = masterMixer
        AudioKit.start()
    }
    
    /**
     Overrides existing function.
     */
    override func update(_ currentTime: TimeInterval) {
    }
    
    
    /**
     Called by `SKPhysicsContactDelegate` when a physics contact occurs.
     */
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Detect if collision has occured between two nodes
        if ((contact.bodyA.categoryBitMask == NodeCategory.fixed) || (contact.bodyA.categoryBitMask == NodeCategory.dynamic)) &&
            ((contact.bodyB.categoryBitMask == NodeCategory.fixed) || (contact.bodyB.categoryBitMask == NodeCategory.dynamic)) {
            let nodeA = contact.bodyA.node as! GTNode
            let nodeB = contact.bodyB.node as! GTNode
            
            nodeA.pulse()
            nodeB.pulse()
        }
    }
}
