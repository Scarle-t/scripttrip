//
//  Plans.swift
//  fyp
//
//  Created by Scarlet on R1/M/23.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class Plans: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var plans: [Trip]?
    var btnTrip = [UIButton : Trip]()
    var tripView: TripView!
    let colors: [[CGColor]] = [[lightGreen.uiColor.cgColor, blue.uiColor.cgColor], [blue.uiColor.cgColor, lightGreen.uiColor.cgColor]]
    var mode = ""
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addPlan(_ sender: UIButton) {
        plans?.insert(Trip(), at: 0)
        mode = "add"
        cv.isScrollEnabled = false
        cv.allowsSelection = false
        cv.reloadData()
    }
    
    
    //DELEGATION
    	//COLLECTION VIEW
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if mode == "add"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as! featuredCell
            
            cell.alpha = 0
            if !UserDefaults.standard.bool(forKey: "reduceMotion"){
                cell.contentView.frame.origin.x += 500
            }
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.view.layer.cornerRadius = 15
            
            cell.newtitle.delegate = self
            cell.newtitle.text = nil
            cell.newtitle.becomeFirstResponder()
            
            let gradient = CAGradientLayer()
            gradient.frame = cell.view.bounds
            
            gradient.colors = colors[indexPath.row % colors.count]
            
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            
            cell.gradView.layer.addSublayer(gradient)
            
            cell.removeBK.alpha = 0
            
            if !UserDefaults.standard.bool(forKey: "reduceMotion"){
                UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                    cell.contentView.frame.origin.x -= 500
                }, completion: nil)
            }else{
                UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                }, completion: nil)
            }
            
            cell.isUserInteractionEnabled = true
            
            mode = ""
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
            
            cell.alpha = 0
            if !UserDefaults.standard.bool(forKey: "reduceMotion"){
                cell.contentView.frame.origin.x += 500
            }
            
            guard let plan = plans?[indexPath.row] else {return cell}
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.title.text = plan.T_Title
            
            cell.view.layer.cornerRadius = 15
            
            let gradient = CAGradientLayer()
            gradient.frame = cell.view.bounds
            
            gradient.colors = colors[indexPath.row % colors.count]
            
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            
            cell.gradView.layer.addSublayer(gradient)
            
            cell.removeBK.layer.cornerRadius = 35 / 2
            btnTrip[cell.removeBK] = plan
            cell.removeBK.addTarget(self, action: #selector(removeBk(_:)), for: .touchUpInside)
            
            if !UserDefaults.standard.bool(forKey: "reduceMotion"){
                UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                    cell.contentView.frame.origin.x -= 500
                }, completion: nil)
            }else{
                UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                }, completion: nil)
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! categoryTripsHeader
            
            header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
            
            header.title.text = Localized.plans.rawValue.localized()
            
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 62)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewPlan = storyboard?.instantiateViewController(withIdentifier: "viewPlan") as! viewPlan
        viewPlan.selectedPlan = plans![indexPath.row]
        self.navigationController?.pushViewController(viewPlan, animated: true)
    }
    
    	//NETWORK
    func ResponseHandle(data: Data) {
        plans = session.parsePlan(Session.parser.parse(data))
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
    }
    
        //TEXT FIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard var t = textField.text, t != "" else {return false}
        t = t.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php", method: "POST", query: "user=\(Session.user.UID)&title=\(t)&publicity=0&mode=plan") { (data) in
            guard let d = data, let result = Session.parser.parse(d) else {return}
            
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    SVProgressHUD.showSuccess(withStatus: nil)
                    DispatchQueue.main.async {
                        textField.resignFirstResponder()
                        self.cv.isScrollEnabled = true
                        self.cv.allowsSelection = true
                        self.setup()
                    }
                }else{
                    SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                }
            }
            SVProgressHUD.dismiss(withDelay: 1.5)
        }
        return true
    }
    
    //OBJC FUNC
    @objc func removeBk(_ sender: UIButton){
        let alert = UIAlertController(title: Localized.removeBKMsg.rawValue.localized(), message: btnTrip[sender]?.T_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { _ in
//            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/bookmark.php?user=\(Session.user.UID)&trip=\(self.btnTrip[sender]!.TID)", method: "DELETE", query: nil) { (data) in
//                guard let result = Session.parser.parse(data!) else {return}
//                for item in result{
//                    if (item["Result"] as! String) == "OK"{
//                        self.setup()
//                    }else{
//                        SVProgressHUD.showInfo(withStatus: Localized.Fail.rawValue.localized() + "\n\(item["Reason"] as! String)")
//                        SVProgressHUD.dismiss(withDelay: 1.5)
//                    }
//                }
//            }
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //FUNC
    func delegate(){
        cv.delegate = self
        cv.dataSource = self
        network.delegate = self
        tripView = TripView(delegate: self, haveTabBar: false)
    }
    
    func layout(){
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout
    }
    
    func setup(){
        plans?.removeAll()
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(session.usr.UID)&mode=plan", method: "GET", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
