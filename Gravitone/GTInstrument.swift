//
//  GTInstrument.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 12/12/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import AudioKit

/**
 Class that contains the instructions for creating the samplers necessary for the nodes.
 
 A `GTInstrument` object initialises all the available samples for all the possible sounds and connects
 them to samplers which can be accessed and triggered when needed.
 */
class GTInstrument {
    
    // Private properties
    private let pitchTable = [
        "C" : 60,
        "D" : 62,
        "E" : 64,
        "G" : 67,
        "A" : 69
    ]
    private let octave = 12
    private let fifth = 7
    private var shift = 0
    private var shapeMix: AKMixer!
    private var squareSamplers = [String : AKSampler]()
    private var circleSamplers = [String : AKSampler]()
    private var triangleSamplers = [String : AKSampler]()
    private var starSamplers = [String : AKSampler]()
    private var currentSamplerArray: [String : AKSampler]!
    
    // Public properties
    var squareAudio, circleAudio, triangleAudio, starAudio: AKMixer!
    var output: AKReverb!
    var isTaken = false
    var transposition = 0.0
    
    /**
     Initialises the new intrument.
     
     The 4 sampler arrays are set up and mixed together, then put through a simple `AKReverb`.
     */
    init() {
        
        setupSquare()
        setupCircle()
        setupTriangle()
        setupStar()
        
        shapeMix = AKMixer(squareAudio, circleAudio, triangleAudio, starAudio)
        output = AKReverb(shapeMix, dryWetMix: 0.4)
        output.loadFactoryPreset(.largeHall)
    }
    
    /**
     Sets up the samplers for the Square shape sounds.
     */
    private func setupSquare() {
        
        squareSamplers["red"] = AKSampler()
        squareSamplers["green"] = AKSampler()
        squareSamplers["blue"] = AKSampler()
        
        squareSamplers["red"]!.loadWav("Sounds/Square/KickHard23")
        squareSamplers["green"]!.loadWav("Sounds/Square/SNHard13")
        squareSamplers["blue"]!.loadWav("Sounds/Square/HatTightNatV06")
        
        squareAudio = AKMixer(squareSamplers["red"]!, squareSamplers["green"]!, squareSamplers["blue"]!)
        squareAudio.volume = 0.7
    }
    
    /**
     Sets up the samplers for the Circle shape sounds.
     */
    private func setupCircle() {
        
        circleSamplers["red"] = AKSampler()
        circleSamplers["green"] = AKSampler()
        circleSamplers["blue"] = AKSampler()
        
        circleSamplers["red"]!.loadWav("Sounds/Circle/BigDrone")
        circleSamplers["green"]!.loadWav("Sounds/Circle/HiQBass")
        circleSamplers["blue"]!.loadWav("Sounds/Circle/Portatone")
        
        circleAudio = AKMixer(circleSamplers["red"]!, circleSamplers["green"]!, circleSamplers["blue"]!)
        circleAudio.volume = 1.0
    }
    
    /**
     Sets up the samplers for the Triangle shape sounds.
     */
    private func setupTriangle() {
        
        triangleSamplers["red"] = AKSampler()
        triangleSamplers["green"] = AKSampler()
        triangleSamplers["blue"] = AKSampler()
        
        triangleSamplers["red"]!.loadWav("Sounds/Triangle/DanceHook")
        triangleSamplers["green"]!.loadWav("Sounds/Triangle/SquareLead")
        triangleSamplers["blue"]!.loadWav("Sounds/Triangle/FunkyLead")
        
        triangleAudio = AKMixer(triangleSamplers["red"]!, triangleSamplers["green"]!, triangleSamplers["blue"]!)
        triangleAudio.volume = 0.5
    }
    
    /**
     Sets up the samplers for the Star shape sounds.
     */
    private func setupStar() {
        
        starSamplers["red"] = AKSampler()
        starSamplers["green"] = AKSampler()
        starSamplers["blue"] = AKSampler()
        
        starSamplers["red"]!.loadWav("Sounds/Star/Stardust")
        starSamplers["green"]!.loadWav("Sounds/Star/SunBell")
        starSamplers["blue"]!.loadWav("Sounds/Star/CrystalEyes")
        
        starAudio = AKMixer(starSamplers["red"]!, starSamplers["green"]!, starSamplers["blue"]!)
        starAudio.volume = 0.5
    }
    
    /**
     Balances the volume of the samplers according to the node's RGB color content.
     
     - parameters:
        - samplerArray: The 3 samplers to be mixed.
        - color: The color used to mix the sampler volumes.
     
     - returns: The correctly mixed sampler array.
     */
    private func balanceSamplers(for samplerArray: [String : AKSampler], by color: UIColor) -> [String : AKSampler] {
        
        // Triple 'sqrt' is necessary to account for volume non-linearity
        let r = sqrt(sqrt(sqrt(Double(color.rgbComponents.red))))
        let g = sqrt(sqrt(sqrt(Double(color.rgbComponents.green))))
        let b = sqrt(sqrt(sqrt(Double(color.rgbComponents.blue))))
        
        samplerArray["red"]!.volume = r
        samplerArray["green"]!.volume = g
        samplerArray["blue"]!.volume = b
        
        return samplerArray
    }
    
    /**
     Plays the appropriate samples according the given node's parameters.
     
     - parameter node: The node from which the method was called.
     */
    func play(for node: GTNode) {
        
        // Choose random note from pitch table
        let pitch = pitchTable.random()
        
        // Choose the correct array of samples for this node's shape
        switch node.shape! {
        case .square: currentSamplerArray = balanceSamplers(for: squareSamplers, by: node.color!)
        case .circle: currentSamplerArray = balanceSamplers(for: circleSamplers, by: node.color!)
        case .triangle: currentSamplerArray = balanceSamplers(for: triangleSamplers, by: node.color!)
        case .star: currentSamplerArray = balanceSamplers(for: starSamplers, by: node.color!)
        }
        
        // Factor in global transposition to all samplers
        for sampler in currentSamplerArray.values {
            sampler.tuning = transposition
        }
        
        // Play all samplers in the array for the appropriate shape
        switch node.shape! {
        case .square:
            for sampler in currentSamplerArray.values {
                sampler.play()
            }
        case .circle:
            switch node.note! {
            case .bar, .double: shift = 0
            case .whole, .half: shift = octave
            case .quarter, .eighth: shift = octave*2
            }
            for sampler in currentSamplerArray.values {
                sampler.play(noteNumber: pitchTable["C"]!+shift, velocity: 127, channel: 0)
            }
        case .triangle, .star:
            switch node.note! {
            case .bar, .double: shift = -octave
            case .whole, .half: shift = 0
            case .quarter, .eighth: shift = octave
            }
            for sampler in currentSamplerArray.values {
                sampler.play(noteNumber: pitch+shift, velocity: 127, channel: 0)
            }
        }
    }
}
