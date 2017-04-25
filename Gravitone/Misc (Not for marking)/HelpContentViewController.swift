//
//  HelpContentViewController.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 17/12/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import UIKit

class HelpContentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int = 0
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }
}
