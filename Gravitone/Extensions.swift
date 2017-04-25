//
//  Extensions.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 22/11/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import SpriteKit

extension Dictionary {
    
    /**
     Returns a random value from a Dictionary of any type.
     
     - returns: The value at the randomly selected index.
     */
    func random() -> Value {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        let randomValue = Array(self.values)[index]
        return randomValue
    }
}

extension UIColor {
    
    /// Random color from a selection of UIColor presets.
    class var random: UIColor {
        switch arc4random() % 9 {
        case 0: return .green
        case 1: return .blue
        case 2: return .orange
        case 3: return .red
        case 4: return .purple
        case 5: return .gray
        case 6: return .brown
        case 7: return .yellow
        case 8: return .magenta
        default: return .white
        }
    }
    
    /// Contains values for Red, Green, Blue, and Alpha components of the color.
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0,0,0,0)
    }
    
    /// Contains values for Hue, Saturation, Brightness, and Alpha components of the color.
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        
        var h:CGFloat = 0, s:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return (h,s,b,a)
        }
        return (0,0,0,0)
    }
}

extension CGMutablePath {
    
    /**
     Creates an equilateral triangle path in the current path.
     
     - parameter rect: `CGRect` containing the path.
     */
    func addTriangle(in rect: CGRect) {
        self.addPath(polygonPath(in: rect, points: 3, spikeRatio: 1), transform: CGAffineTransform(rotationAngle: CGFloat(M_PI)))
    }
    
    /**
     Creates an equilateral triangle path in the current path.
     
     - parameter rect: `CGRect` containing the path.
     */
    func addStar(in rect: CGRect) {
        self.addPath(polygonPath(in: rect, points: 5, spikeRatio: 0.5))
    }
    
    /**
     Returns a custom polygon path.
     
     - parameters:
         - rect: `CGRect` containing the path.
         - points: Number of sides/vertices/edges/points.
         - spikeRatio: Ratio of inner spikes to outer spikes (Default: 1) (No spikes).
     
     - returns: The polygon path.
     
     */
    private func polygonPath(in rect: CGRect, points: Int, spikeRatio: CGFloat) -> CGPath {
        
        let path = CGMutablePath()
        let outerRadius = rect.width/2
        let innerRadius = outerRadius*spikeRatio
        let step = CGFloat(M_PI)/CGFloat(points)
        var rot = CGFloat(M_PI/2 * 3)
        
        var p = CGPoint()
        path.move(to: CGPoint(x: 0, y: -innerRadius))
        for _ in 1...points {
            p = CGPoint(x: cos(rot)*innerRadius, y: sin(rot)*innerRadius)
            path.addLine(to: p)
            rot += step
            if innerRadius != outerRadius {
                p = CGPoint(x: cos(rot)*outerRadius, y: sin(rot)*outerRadius)
                path.addLine(to: p)
            }
            rot += step
        }
        path.closeSubpath()
        
        return path
    }
}

extension UIImage {
    /**
     Returns a colorized version of the original image with given tint color.
     
     - parameter tintColor: The color to tint the image with.
     
     - returns: The tinted image.
     */
    func tintImage(_ tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            context.setBlendMode(.softLight)
            UIColor.black.setFill()
            context.fill(rect)
            
            context.setBlendMode(.multiply)
            tintColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    /**
     Returns the modified drawn on the new image context.
     
     - parameters:
        - draw: The context and rect of the existing image.
        - CGContext: The image context
        - CGRect: The image rect
     
     - returns: The modified image.
     */
    private func modifiedImage(draw: (_ CGContext: CGContext, _ CGRect: CGRect) -> ()) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     Returns an image that fills in `newSize`.
     
     - parameter newSize: New size of the image.
     
     - returns: The resized image.
     */
    func resizedImage(_ newSize: CGSize) -> UIImage {
        
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    /**
     Returns a resized image that fits in `rectSize`, keeping it's aspect ratio.
     
     - parameter rect: `CGRect` to contain the image.
     
     - returns: The resized image.
     */
    private func resizedImage(in rect: CGRect) -> UIImage {
        let widthFactor = size.width / rect.size.width
        let heightFactor = size.height / rect.size.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize)
        return resized
    }
}
