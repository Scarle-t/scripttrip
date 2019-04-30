//
//  ViewController10.swift
//  fyp
//
//  Created by Scarlet on 13/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Photo: UIViewController, UIScrollViewDelegate{
    
    //VARIABLE
    var statusBar = false
    var img: UIImage?
    
    //IBOUTLET
    @IBOutlet weak var imgScroll: UIScrollView!
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var xBtn: UIButton!
    
    //IBACTION
    @IBAction func xLeave(_ sender: UIButton) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        statusBar = false
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
        //SCROLL VIEW
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgDetail
    }
    
    //OBJC FUNC
    
    //FUNC
    
    func delegate(){
        imgScroll.delegate = self
    }
    
    func layout(){
        xBtn.layer.cornerRadius = xBtn.frame.width / 2
        
        imgScroll.minimumZoomScale = 1.0
        imgScroll.maximumZoomScale = 6.0
        imgDetail.contentMode = .scaleAspectFit
    }
    
    func setup(){
        imgDetail.image = img
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AppDelegate.AppUtility.lockOrientation(.all)
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        statusBar = true
        
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return statusBar
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return statusBar
    }
    
}
