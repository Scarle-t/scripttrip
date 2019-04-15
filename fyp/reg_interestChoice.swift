//
//  ViewController2.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_interestChoice: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppDelegate().catTxt.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! cateChoiceCell
        
        cell.layer.cornerRadius = 7
        
        cell.catImg.image = AppDelegate().cat[indexPath.row]
        cell.catName.text = AppDelegate().catTxt[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (view.frame.width / 2) - 20 - 5, height: (view.frame.width / 2) - 20 - 5)
    }
    
//    @IBOutlet var choice: [UIView]!
    @IBOutlet weak var interestTxt: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var catChoice: UICollectionView!
    
    @IBAction func finish(_ sender: UIButton) {
        let vc3 = storyboard?.instantiateViewController(withIdentifier: "vc3") as! ViewController3
        
        self.present(vc3, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        catChoice.delegate = self
        catChoice.dataSource = self
        
        interestTxt.frame = CGRect(x: interestTxt.frame.minX, y: interestTxt.frame.minY + 30, width: interestTxt.frame.width, height: interestTxt.frame.height)
        
//        for item in choice{
//            item.layer.cornerRadius = 7
//            item.layer.backgroundColor = UIColor(white: 1, alpha: 0.7).cgColor
//            item.alpha = 0
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.view.layer.backgroundColor = "D3F2FF".toUIColor.cgColor
            
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar.backgroundColor = "D3F2FF".toUIColor
            }
            
        }
        UIView.animate(withDuration: 0.5) {
            self.interestTxt.frame = CGRect(x: self.interestTxt.frame.minX, y: self.interestTxt.frame.minY - 30, width: self.interestTxt.frame.width, height: self.interestTxt.frame.height)
            self.interestTxt.alpha = 1
            self.finishBtn.alpha = 1
            self.catChoice.alpha = 1
        }
        
    }
    
}

extension String{
    var toUIColor: UIColor{
        
        var r = 0.0, g = 0.0, b = 0.0
        let charset = CharacterSet(charactersIn: "abcdefABCDEF1234567890")
        
        if self.count != 6 {
            return UIColor.white
        }
        if self.rangeOfCharacter(from: charset.inverted) != nil{
            return UIColor.white
        }
        
        let rIndex = self.index(self.startIndex, offsetBy: 2)
        
        let gIndex = self.index(rIndex, offsetBy: 2)
        
        let bIndex = self.index(gIndex, offsetBy: 2)
        
        r = Double((Int(self[..<rIndex], radix: 16) ?? 0 )) / 255
        g = Double((Int(self[rIndex..<gIndex], radix: 16) ?? 0 )) / 255
        b = Double((Int(self[gIndex..<bIndex], radix: 16) ?? 0 )) / 255
        
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        
    }
}

extension UIImageView{
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = image!.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
    newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
    newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image!.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
    }
}
