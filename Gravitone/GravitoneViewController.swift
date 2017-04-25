//
//  GravitoneViewController.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 25/10/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
// 

import UIKit
import SpriteKit
import AudioKit

/**
 Class for the main view controller.
 
 This initialises the Gravitone scene and places it in the `SpriteKit` view. It also controls the
 parameters of the Gravitone scene with `UIKit` controls.
 */
class GravitoneViewController: UIViewController {
    
    // Private properties
    private var gravitoneScene: GTScene!
    private var shape: Shape!
    private var color: UIColor!
    private var colorValue = DiscreteValue()
    private var transposeValue = DiscreteValue()
    
    // Interface properties
    @IBOutlet var gravitoneView: SKView! {
        didSet {
            gravitoneScene = GTScene(size: gravitoneView.bounds.size)
            gravitoneScene.scaleMode = .resizeFill
            gravitoneScene.isRealGravity = true
            
            gravitoneView.presentScene(gravitoneScene)
        }
    }
    @IBOutlet var shapeButton: UIButton!
    @IBOutlet var screwImageView: UIImageView!
    @IBOutlet var noteLengthControl: UISegmentedControl!
    @IBOutlet var colorSlider: UISlider!
    @IBOutlet var fixedSwitch: UISwitch!
    @IBOutlet var mixerButton: UIButton!
    @IBOutlet var transposeSlider: UISlider!
    @IBOutlet var tempoSlider: UISlider!
    @IBOutlet var bounceSlider: UISlider!
    
    // Interface control functions
    
    @IBAction func shapeButtonPressed(_ sender: UIButton) { updateCurrentShape(from: sender) }
    
    @IBAction func noteLengthChanged(_ sender: UISegmentedControl) { updateCurrentNoteLength(from: sender) }
   
    @IBAction func colorSliderChanged(_ sender: UISlider) { updateCurrentColor(from: sender) }
    
    @IBAction func colorSliderReleased(_ sender: UISlider) { sender.setValue(Float(colorValue.new), animated: true) }
    
    @IBAction func fixedSwitchChanged(_ sender: UISwitch) { updateCurrentFixedState(from: sender) }
    
    @IBAction func transposeSliderChanged(_ sender: UISlider) { updateGlobalTransposition(from: sender) }
    
    @IBAction func tempoSliderChanged(_ sender: UISlider) { updateGlobalTempo(from: sender) }
    
    @IBAction func bounceSliderChanged(_ sender: UISlider) { updateGlobalRestitution(from: sender) }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        gravitoneScene.removeAllNodes()
    }
    
    @IBAction func returnToGravitoneViewController(_ segue: UIStoryboardSegue) { }
    
    // View Controller functions
    
    private func updateCurrentShape(from button: UIButton) {
        
        shape.next()
        gravitoneScene.nodeShape = shape
        button.setImage(shape.image.tintImage(color), for: .normal)
    }
    
    private func updateCurrentNoteLength(from control: UISegmentedControl) {
        
        gravitoneScene.nodeNote = Note(rawValue: control.selectedSegmentIndex)
    }
    
    private func updateCurrentColor(from slider: UISlider) {
        
        colorValue.new = lroundf(slider.value)
        color = UIColor(hue: CGFloat(colorValue.new)/12, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        gravitoneScene.nodeColor = color
        if colorValue.changed {
            shapeButton.setImage(shape.image.tintImage(color), for: .normal)
        }
        colorValue.old = colorValue.new
    }
    
    private func updateCurrentFixedState(from aSwitch: UISwitch) {
        
        screwImageView.isHidden = !aSwitch.isOn
        gravitoneScene.nodeIsFixed = aSwitch.isOn
    }
    
    private func updateGlobalTransposition(from slider: UISlider) {
        
        transposeValue.new = lroundf(slider.value)
        if transposeValue.changed {
            gravitoneScene.globalTransposition = Double(slider.value)
        }
        transposeValue.old = transposeValue.new
    }
    
    private func updateGlobalTempo(from slider: UISlider) {
        
        gravitoneScene.globalTempo = slider.value
    }
    
    private func updateGlobalRestitution(from slider: UISlider) {
        
        gravitoneScene.globalRestitution = CGFloat(slider.value)
    }
    
    /**
     Called when this view is loaded.
     */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set initial view properties
        shape = Shape.triangle
        color = UIColor(hue: CGFloat(colorSlider.value), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        colorSlider.setThumbImage(#imageLiteral(resourceName: "sliderthumb").resizedImage(CGSize(width: 18, height: 35)), for: .normal)
        
        // Update properties according to Interface Builder values
        updateCurrentShape(from: shapeButton)
        updateCurrentColor(from: colorSlider)
        updateCurrentNoteLength(from: noteLengthControl)
        updateCurrentFixedState(from: fixedSwitch)
        updateGlobalTempo(from: tempoSlider)
        updateGlobalRestitution(from: bounceSlider)
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
}
