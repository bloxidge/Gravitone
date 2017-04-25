//
//  HelpViewController.swift
//  Gravitone
//
//  Created by Peter Bloxidge on 17/12/2016.
//  Copyright © 2016 Peter Bloxidge. All rights reserved.
//

import UIKit

class HelpViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var helpImageArray = [#imageLiteral(resourceName: "square_n"), #imageLiteral(resourceName: "circle_n"), #imageLiteral(resourceName: "triangle_n"), #imageLiteral(resourceName: "star_n")]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: .forward, animated: false, completion: nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let helpContent: HelpContentViewController = viewController as! HelpContentViewController
        var index = helpContent.pageIndex
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        index -= 1
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let helpContent: HelpContentViewController = viewController as! HelpContentViewController
        var index = helpContent.pageIndex
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (index == helpImageArray.count) {
            return nil
        }
        return getViewControllerAtIndex(index)
    }
    
    func getViewControllerAtIndex(_ index: Int) -> HelpContentViewController {
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpContentViewController") as! HelpContentViewController
        //pageContentViewController.strTitle = "\(arrPageTitle[index])"
        pageContentViewController.image = helpImageArray[index]
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    override var prefersStatusBarHidden : Bool {
        
        return true
    }
}
