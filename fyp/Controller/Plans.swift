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
    var removePlan = [UIButton : UIButton]()
    var editPlan = [UIButton : UIButton]()
    var viewPlanBtn = [UIButton : UIButton]()
    var planTripBtn = [UIButton : Trip]()
    var mode = ""
    var addBtn: UIButton?
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addPlan(_ sender: UIButton) {
        addBtn = sender
        sender.alpha = 0
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
            cell.removeBK.layer.shadowOpacity = 0.7
            cell.removeBK.layer.shadowColor = UIColor.lightGray.cgColor
            cell.removeBK.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.removeBK.tag = 0
            cell.removeBK.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 2)
            
            cell.edit.layer.cornerRadius = 35 / 2
            cell.edit.layer.shadowOpacity = 0.7
            cell.edit.layer.shadowColor = UIColor.lightGray.cgColor
            cell.edit.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            cell.viewPost.layer.cornerRadius = 35 / 2
            cell.viewPost.layer.shadowOpacity = 0.7
            cell.viewPost.layer.shadowColor = UIColor.lightGray.cgColor
            cell.viewPost.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            cell.delete.layer.cornerRadius = 35 / 2
            cell.delete.layer.shadowOpacity = 0.7
            cell.delete.layer.shadowColor = UIColor.lightGray.cgColor
            cell.delete.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            btnTrip[cell.delete] = plan
            cell.removeBK.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
            cell.edit.addTarget(self, action: #selector(edit(_:)), for: .touchUpInside)
            cell.delete.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
            cell.viewPost.addTarget(self, action: #selector(viewPlan(_:)), for: .touchUpInside)
            
            viewPlanBtn[cell.removeBK] = cell.viewPost
            editPlan[cell.removeBK] = cell.edit
            removePlan[cell.removeBK] = cell.delete
            
            cell.viewPost.tag = indexPath.row
            
            planTripBtn[cell.viewPost] = plan
            
            cell.viewPost.alpha = 0
            cell.edit.alpha = 0
            cell.delete.alpha = 0
            
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
                        self.addBtn?.alpha = 1
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
    @objc func showMenu(_ sender: UIButton){
        if sender.tag == 0{
            UIView.animate(withDuration: slideAnimationTime, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                sender.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 4)
                self.editPlan[sender]?.alpha = 1
                self.removePlan[sender]?.alpha = 1
                self.viewPlanBtn[sender]?.alpha = 1
                
                self.removePlan[sender]?.frame.origin.x -= 150
                self.editPlan[sender]?.frame.origin.x -= 100
                self.viewPlanBtn[sender]?.frame.origin.x -= 50
                
            }, completion: nil)
            sender.tag = 1
        }else if sender.tag == 1{
            UIView.animate(withDuration: slideAnimationTime, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                sender.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 2)
                self.editPlan[sender]?.frame.origin.x = sender.frame.origin.x
                self.removePlan[sender]?.frame.origin.x = sender.frame.origin.x
                self.viewPlanBtn[sender]?.frame.origin.x = sender.frame.origin.x
                self.editPlan[sender]?.alpha = 0
                self.removePlan[sender]?.alpha = 0
                self.viewPlanBtn[sender]?.alpha = 0
            }, completion: nil)
            sender.tag = 0
        }
    }
    @objc func remove(_ sender: UIButton){
        let alert = UIAlertController(title: Localized.removePlanMsg.rawValue.localized(), message: btnTrip[sender]?.T_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { _ in
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&plan=\(self.btnTrip[sender]!.TID)", method: "DELETE", query: nil) { (data) in
                guard let result = Session.parser.parse(data!) else {return}
                for item in result{
                    if (item["Result"] as! String) == "OK"{
                        self.setup()
                    }else{
                        SVProgressHUD.showInfo(withStatus: Localized.Fail.rawValue.localized() + "\n\(item["Reason"] as! String)")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func edit(_ sender: UIButton){
        
    }
    @objc func viewPlan(_ sender: UIButton){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(session.usr.UID)&PID=\(planTripBtn[sender]!.TID)&mode=item", method: "GET", query: nil, completion: { data in
            
            guard let data = data else {return}
            
            self.planTripBtn[sender]?.Items = self.session.parsePlanItem(Session.parser.parse(data))!
            self.tripView.displayTrip = self.planTripBtn[sender]
            self.tripView.headerImg = UIImage()
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: 800, height: 800)
            gradient.colors = self.colors[sender.tag % self.colors.count]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            self.tripView.gradientMask = gradient
            self.tripView.isCustomPlan = true
            DispatchQueue.main.async {
                self.tripView.show()
            }
            
        })
        
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
