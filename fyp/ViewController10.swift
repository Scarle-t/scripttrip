//
//  ViewController10.swift
//  fyp
//
//  Created by Scarlet on 13/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class ViewController10: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var imgScroll: UIScrollView!
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var xBtn: UIButton!
    
    var statusBar = false
    
    @IBAction func xLeave(_ sender: UIButton) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        statusBar = false
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AppDelegate.AppUtility.lockOrientation(.all)
        
        xBtn.layer.cornerRadius = xBtn.frame.width / 2
        
        imgScroll.delegate = self
        
        imgScroll.minimumZoomScale = 1.0
        imgScroll.maximumZoomScale = 6.0
        imgDetail.contentMode = .scaleAspectFit
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        statusBar = true
        
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgDetail
    }
    
    override var prefersStatusBarHidden: Bool{
        return statusBar
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return statusBar
    }
    
}
