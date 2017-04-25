//
//  Globals.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 15/11/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import UIKit

/**
 Type of shape to be drawn.
 
 - Square
 - Circle
 - Triangle
 - Star
 */
enum Shape: String {
    
    case square, circle, triangle, star
    
    /// The lit image for the shape.
    var image: UIImage {
        switch self {
        case .square: return #imageLiteral(resourceName: "square_lit")
        case .circle: return #imageLiteral(resourceName: "circle_lit")
        case .triangle: return #imageLiteral(resourceName: "triangle_lit")
        case .star: return #imageLiteral(resourceName: "star_lit")
        }
    }
    
    /// The relative size for drawing the shape relative to square.
    var scale: CGFloat {
        switch self {
        case .square: return 1.00
        case .circle: return 1.05
        case .triangle: return 1.10
        case .star: return 1.15
        }
    }
    
    /// Changes current shape to the next shape.
    mutating func next() {
        switch self {
        case .square: self = .circle
        case .circle: self = .triangle
        case .triangle: self = .star
        case .star: self = .square
        }
    }
}

/**
 Length of note to be played.
 
 - Bar: 4 beats
 - Double: 2 beats
 - Whole: 1 beat
 - Half: ½ beat
 - Quarter: ¼ beat
 - Eighth: ⅛ beat
 */
enum Note: Int {
    
    case bar = 0, double, whole, half, quarter, eighth
    
    /// The floating point value of the note length.
    var length: Float {
        switch self {
        case .bar: return 4
        case .double: return 2
        case .whole: return 1
        case .half: return 1/2
        case .quarter: return 1/4
        case .eighth: return 1/8
        }
    }
    
    /// The size of the shape to be drawn according to its note.
    var size: CGFloat {
        switch self {
        case .bar: return 200
        case .double: return 160
        case .whole: return 120
        case .half: return 90
        case .quarter: return 60
        case .eighth: return 40
        }
    }
}

/**
 Structure for detecting physics collisions using bit masks.
 */
struct NodeCategory {
    
    static let none: UInt32 = 0x0
    static let fixed: UInt32 = 0x1 << 0
    static let dynamic: UInt32 = 0x1 << 1
    static let all: UInt32 = NodeCategory.fixed | NodeCategory.dynamic
}

/**
 Structure for detecting changes in an integer value.
 */
struct DiscreteValue {
    
    var old = 0
    var new = 0
    var changed: Bool {
        if new == old {
            return false
        } else {
            return true
        }
    }
}
