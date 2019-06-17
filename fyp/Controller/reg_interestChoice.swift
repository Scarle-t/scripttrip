//
//  ViewController2.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_interestChoice: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NetworkDelegate {
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var change: Bool?
    var userInterest = Set<Int>()
    
    //IBOUTLET
    @IBOutlet weak var interestTxt: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var catChoice: UICollectionView!
    @IBOutlet weak var backbtn: UIButton!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        
        if change == nil {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true) {
                self.change = nil
            }
        }
        
    }
    @IBAction func next(_ sender: UIButton) {
        
        if change == nil{
            if session.regInterest.count < 3{
                SVProgressHUD.showInfo(withStatus: Localized.regItemMsg.rawValue.localized())
                SVProgressHUD.dismiss(withDelay: 1.5)
            }else{
                let reg_secure = storyboard?.instantiateViewController(withIdentifier: "reg_secure") as! reg_password
                self.navigationController?.pushViewController(reg_secure, animated: true)
            }
        }else{
            if userInterest.count < 3 {
                SVProgressHUD.showInfo(withStatus: Localized.regItemMsg.rawValue.localized())
                SVProgressHUD.dismiss(withDelay: 1.5)
            }else{
                
                var t = ""
                
                for item in userInterest{
                    t += "\(item),"
                }
                
                t = String(t.dropLast())
                
                network.send(url: "https://scripttrip.scarletsc.net/iOS/interest.php?user=\(session.usr.UID)&interest=\(t)", method: "POST", query: nil) { (data) in
                    guard let result = Session.parser.parse(data!) else {return}
                    
                    for item in result{
                        if (item["Result"] as! String) == "OK"{
                            SVProgressHUD.showSuccess(withStatus: nil)
                            SVProgressHUD.dismiss(withDelay: 1.5)
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }else{
                            SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }
                    }
                    
                }
            }
        }
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! cateChoiceCell
        
        cell.layer.cornerRadius = 7
        cell.alpha = 0
        
        cell.catImg.image = session.cate_icons[session.getCategories()[indexPath.row].CID - 1]
        cell.catName.text = "\(cateEnum.init(rawValue: session.getCategories()[indexPath.row].CID)!)".localized()
        
        UIView.animate(withDuration: 0.2) {
            cell.alpha = 1
        }
        
        if session.regInterest.contains(session.getCategories()[indexPath.row]){
            cell.white.alpha = 1
        }else{
            cell.white.alpha = 0
        }
        
        if change != nil{
            for itm in userInterest{
                if itm - 1 == indexPath.row{
                    cell.white.alpha = 1
                }
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (view.frame.width / 2) - 20 - 5, height: (view.frame.width / 2) - 20 - 5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! cateChoiceCell
        
        if change != nil {
            if userInterest.contains(indexPath.row + 1){
                cell.white.alpha = 0
                userInterest.remove(indexPath.row + 1)
            }else{
                cell.white.alpha = 1
                userInterest.insert(indexPath.row + 1)
            }
        }else{
            let choice = session.getCategories()[indexPath.row]
            let set = session.regInterest
            
            if set.contains(choice){
                cell.white.alpha = 0
                session.regInterest.remove(session.getCategories()[indexPath.row])
            }else{
                cell.white.alpha = 1
                session.regInterest.insert(session.getCategories()[indexPath.row])
            }
        }
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        session.setCategories(session.parseCategory(Session.parser.parse(data)))
        DispatchQueue.main.async {
            self.catChoice.reloadData()
        }
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        catChoice.delegate = self
        catChoice.dataSource = self
        
        network.delegate = self
    }
    
    func layout(){
        interestTxt.frame = CGRect(x: interestTxt.frame.minX, y: interestTxt.frame.minY + 30, width: interestTxt.frame.width, height: interestTxt.frame.height)
        interestTxt.text = Localized.interestIntro.rawValue.localized()
        finishBtn.setTitle(Localized.Next.rawValue.localized(), for: .normal)
        backbtn.setTitle(Localized.Back.rawValue.localized(), for: .normal)
    }
    
    func setup(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getCategory.php", method: "GET", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if change != nil {
            network.send(url: "https://scripttrip.scarletsc.net/iOS/interest.php?user=\(session.usr.UID)", method: "GET", query: nil) { (data) in
                guard let result = Session.parser.parse(data!) else {return}
                
                self.userInterest.removeAll()
                for item in result{
                    self.userInterest.insert(Int(item["Interest"] as! String)!)
                }
                DispatchQueue.main.async {
                    self.catChoice.reloadData()
                }
            }
        }
    }
    
}
