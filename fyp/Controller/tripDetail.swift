//
//  tripDetail.swift
//  fyp
//
//  Created by Scarlet on 23/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class tripDetail: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //VARIABLE
    var selectedTrip: Trip?
    var trip = Trip()
    var textHeight = [Item : CGFloat]()
    var statusBar = false
    
    //IBOUTLET
    @IBOutlet weak var contents: UICollectionView!
    
    //IBACTION
    
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trip.Items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! contentViewCell
            
            cell.ctn.text = trip.Items[0].I_Content
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! otherContentViewCell
            
            cell.img.image = #imageLiteral(resourceName: "Image-1")
            cell.content.text = trip.Items[indexPath.row].I_Content
            cell.content.sizeToFit()
            
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return .init(width: view.frame.width, height: view.frame.width / 2 * 2.5)
    
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0{
            
            return CGSize(width: collectionView.bounds.width, height: textHeight[trip.Items[0]]!)
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! otherContentViewCell
            
            return CGSize(width: collectionView.bounds.width, height: textHeight[trip.Items[indexPath.row]]! + cell.img.frame.height)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! HeaderView
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: collectionView.frame.width / 2 * 2.5)
                
                header.headerImg.image = #imageLiteral(resourceName: "Image")
                header.headerImg.contentMode = .scaleAspectFill
                
                
                
                header.xBtn.layer.cornerRadius = header.xBtn.frame.width / 2
                
                header.xBtn.addTarget(self, action: #selector(xLeave(_:)), for: .touchUpInside)
                
                header.plus.layer.cornerRadius = header.plus.frame.width / 2
                
                header.plus.addTarget(self, action: #selector(plus(_:)), for: .touchUpInside)
                
                header.gradient.layer.cornerRadius = 12
                if #available(iOS 11.0, *) {
                    header.gradient.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else {
                    // Fallback on earlier versions
                }
                
                header.title.text = trip.T_Title
                
                return header
            
            default:
                return UICollectionReusableView()
            
            }
    }
    
    //OBJC FUNC
    @objc func plus(_ sender: UIButton){
        
    }
    
    @objc func xLeave(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //FUNC
    func delegate(){
        contents.delegate = self
        contents.dataSource = self
    }
    
    func layout(){
        if #available(iOS 11.0, *) {
            contents.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        contents.collectionViewLayout = StretchyHeaderLayout()
    }
    
    func setup(){
        guard let t = selectedTrip else {return}
        trip = t
        contents.reloadData()
        for item in trip.Items{
            let height = Float(item.I_Content.count / 16)
            textHeight[item] = CGFloat(floor(height < 1 ? 1 : height) * 14)
        }
        
        
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statusBar = true
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return statusBar
    }
    
}
