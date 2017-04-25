//
//  MixerViewController.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 17/12/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import UIKit

protocol MixerViewControllerDelegate: class {
    
    func updateMixerValues(mixerValues: (square: Double, circle: Double, triangle: Double, star: Double))
}

class MixerViewController: UIViewController {
    
    @IBOutlet var squareSlider: UISlider!
    @IBOutlet var circleSlider: UISlider!
    @IBOutlet var triangleSlider: UISlider!
    @IBOutlet var starSlider: UISlider!
    
    weak var delegate: MixerViewControllerDelegate?

    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        delegate?.updateMixerValues(mixerValues: (
            square: Double(squareSlider.value),
            circle: Double(squareSlider.value),
            triangle: Double(squareSlider.value),
            star: Double(squareSlider.value)
        ))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
