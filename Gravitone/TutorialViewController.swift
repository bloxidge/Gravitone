//
//  TutorialViewController.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 18/12/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
// 

import UIKit

/**
 Class for the tutorial view controller.
 
 This initialises a scroll view with a page control to swipe through a series of tutorial images.
 The tutorial view is reached by a modal segue.
 */
class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    // Private properties
    private var imageArray = [UIImage]()
    private var frame = CGRect()
    
    // Interface properties
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    /**
     Called when this view is loaded.
     */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set this view to be the delegate
        scrollView.delegate = self
        
        // Add all the tutorial image to the array
        for index in 0...6 {
            imageArray.append(UIImage(named: "Tutorials/tutorial-\(index).png")!)
        }
        
        // Add array of images to the scroll view in order
        for index in 0..<imageArray.count {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let subView = UIImageView(frame: frame)
            subView.image = imageArray[index]
            subView.contentMode = .scaleAspectFit
            scrollView.addSubview(subView)
        }
        
        // Set up size of scroll view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(imageArray.count), height: scrollView.frame.size.height)
        
        // Set up properties for page control indicator
        pageControl.numberOfPages = imageArray.count
        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
    }
    
    /**
     Called by `UIScrollViewDelegate` when scrolling finishes.
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    // Moves to the appropriate image in the scroll view
    @IBAction func changePage(_ sender: UIPageControl) -> () {
        
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
}
