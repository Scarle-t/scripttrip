//
//  Extensions.swift
//  fyp
//
//  Created by Scarlet on 16/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

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
