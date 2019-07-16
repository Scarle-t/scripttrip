//
//  ViewController4.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Featured: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let parser = Session.parser
    let network = Network()
    var selectedItem = Trip()
    var imgs = [Trip : UIImage]()
    var textHeight = [Item : CGFloat]()
    var yLoc: CGFloat = 0.0
    var timer = Timer()
    var added = false
    var feedItems = 3
    var state = ""
    var mainRefresh: UIRefreshControl?
    var tripView: TripView!
    var planView: TripView!
    let group = DispatchGroup()
    var lastOffset: CGFloat = 0.0
    var plans: [Trip]?
    let colors: [[CGColor]] = [[lightGreen.cgColor, blue.cgColor], [blue.cgColor, lightGreen.cgColor]]
    var pv: UICollectionView?
    var gradient: CAGradientLayer?
    var qaState: Bool?
    var menu: UIButton?
    var more: UIButton?
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    //IBACTION
    @IBAction func userBtn(_ sender: UIButton) {
        DispatchQueue.main.async {
            let userview = self.storyboard?.instantiateViewController(withIdentifier: "userView") as! userView
            userview.logout = {
                userview.dismiss(animated: false) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
            self.present(userview, animated: true, completion: nil)
        }
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag{
        case 0:
            return plans?.count ?? 0
        case 1:
            if session.getTrips().count == 1 && session.getTrips()[0].TID == 0{
                return 0
            }else{
                return session.getTrips().count
            }
        default:
            return 0
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        switch collectionView.tag{
        case 0:
            guard let plan = plans?[indexPath.row] else {return cell}
            cell.layer.masksToBounds = true
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.title.text = plan.T_Title
            
            let grad = CAGradientLayer()
            grad.frame = CGRect(x: 0, y: 0, width: 165, height: 30)
            grad.colors = colors[indexPath.row % colors.count]
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint = CGPoint(x: 1, y: 1)
            
            cell.gradView.layer.addSublayer(grad)
            
            cell.layer.cornerRadius = 7
            
            gradient = grad
            
            return cell
        case 1:
            cell.alpha = 0
            if !UserDefaults.standard.bool(forKey: "reduceMotion"){
                cell.contentView.frame.origin.x += 500
            }
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.title.text = session.getTrips()[indexPath.row].T_Title
            
            cell.view.layer.cornerRadius = 15
            
            if imgs[self.session.getTrips()[indexPath.row]] == nil{
                
                if Session.imgCache.object(forKey: self.session.getTrips()[indexPath.row]) == nil{
                    group.enter()
                    network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(session.getTrips()[indexPath.row].Items[0].I_Image)") { (data, response, error) in
                        guard let data = data, error == nil else {return}
                        self.imgs[self.session.getTrips()[indexPath.row]] = UIImage(data: data)!
                        Session.imgCache.setObject(UIImage(data: data)!, forKey: self.session.getTrips()[indexPath.row])
                        self.group.leave()
                    }
                    group.notify(queue: .main) {
                        self.cv.reloadItems(at: [indexPath])
                    }
                }else{
                    self.imgs[self.session.getTrips()[indexPath.row]] = Session.imgCache.object(forKey: self.session.getTrips()[indexPath.row])
                }
                
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.img.image = self.imgs[self.session.getTrips()[indexPath.row]]
                })
            }
            
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
        default:
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch collectionView.tag{
        case 0:
            return .zero
        case 1:
            if UserDefaults.standard.bool(forKey: "quickAccess"){
                return .init(width: self.view.bounds.width, height: 154)
            }else{
                return .init(width: self.view.bounds.width, height: 62)
            }
            
        default:
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch collectionView.tag{
        case 0:
            return UICollectionReusableView()
        case 1:
            switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderView
                
                header.userIcon.setImage(session.usr.iconImage, for: .normal)
                header.userIcon.contentMode = .scaleAspectFill
                header.userIcon.clipsToBounds = true
                header.userIcon.frame.origin.x = self.view.bounds.width - 75
                header.userIcon.layer.cornerRadius = header.userIcon.frame.width / 2
                header.plans.delegate = self
                header.plans.dataSource = self
                pv = header.plans
                menu = header.userIcon
                more = header.more
                
                header.more.addTarget(self, action: #selector(showPlan(_:)), for: .touchUpInside)
                
//                if #available(iOS 13.0, *){
//                }else{
//                    header.more.setImage(#imageLiteral(resourceName: "right_tint.png"), for: .normal)
//                }
                header.more.setImage(#imageLiteral(resourceName: "right_tint.png"), for: .normal)
                
                header.quickAccess.text = Localized.quickAccess.rawValue.localized()
                
                if UserDefaults.standard.bool(forKey: "quickAccess"){
                    header.plans.alpha = 1
                    header.more.alpha = 1
                    header.more.frame.origin.x = self.view.bounds.width - 50
                    header.plans.frame = CGRect(x: header.plans.frame.minX, y: header.plans.frame.minY, width: self.view.bounds.width, height: header.plans.frame.height)
                    header.quickAccess.alpha = 1
                    network.send(url: "https://scripttrip.scarletsc.net/iOS/quickAccess.php?user=\(session.usr.UID)", method: "GET", query: nil) { (data) in
                        guard let data = data else {
                            header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
                            header.plans.alpha = 0
                            return
                        }
                        self.plans = self.session.parsePlan(Session.parser.parse(data))
                        DispatchQueue.main.async {
                            header.plans.reloadData()
                        }
                    }
                }else{
                    header.plans.alpha = 0
                    header.more.alpha = 0
                    header.quickAccess.alpha = 0
                }
                
                return header
                
            default:
                return UICollectionReusableView()
            }
        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag{
        case 0:
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?PID=\(plans![indexPath.row].TID)&mode=item", method: "GET", query: nil, completion: { data in
                guard let data = data else {return}
                self.plans?[indexPath.row].Items = self.session.parsePlanItem(Session.parser.parse(data))!
                self.planView.displayTrip = self.plans?[indexPath.row]
                self.planView.headerImg = UIImage()
                let gradient = CAGradientLayer()
                gradient.frame = CGRect(x: 0, y: 0, width: 800, height: 800)
                gradient.colors = self.colors[indexPath.row % self.colors.count]
                gradient.startPoint = CGPoint(x: 0, y: 0)
                gradient.endPoint = CGPoint(x: 1, y: 1)
                self.planView.gradientMask = gradient
                self.planView.isCustomPlan = true
                DispatchQueue.main.async {
                    self.planView.show()
                    let postview = self.storyboard?.instantiateViewController(withIdentifier: "postView") as! postView
                    postview.tripView = self.planView
                    let pvnc = self.storyboard?.instantiateViewController(withIdentifier: "postViewNC") as! UINavigationController
                    pvnc.addChild(postview)
                    self.present(pvnc, animated: true, completion: nil)
                }
            })
        case 1:
            if UserDefaults.standard.bool(forKey: "history") {
                network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(session.usr.UID)&trip=\(session.getTrips()[indexPath.row].TID)") { (_) in
                }
            }
            tripView.displayTrip = session.getTrips()[indexPath.row]
            tripView.headerImg = imgs[session.getTrips()[indexPath.row]]
            tripView.show()
            DispatchQueue.main.async {
                let postview = self.storyboard?.instantiateViewController(withIdentifier: "postView") as! postView
                postview.tripView = self.tripView
                let pvnc = self.storyboard?.instantiateViewController(withIdentifier: "postViewNC") as! UINavigationController
                pvnc.addChild(postview)
                self.present(pvnc, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag{
        case 0:
            return .init(width: 165, height: 30)
        case 1:
            return .init(width: 341, height: 338)
        default:
            return .zero
        }
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        DispatchQueue.main.async {
            if self.mainRefresh!.isRefreshing{
                self.mainRefresh!.endRefreshing()
            }
        }
        
        if state == "trip"{
            session.setTrips(session.parseTrip(parser.parseNested(data)))
            DispatchQueue.main.async {
                self.cv.reloadData()
            }
        }
    }
    func httpErrorHandle(httpStatus: HTTPURLResponse) {
        SVProgressHUD.showInfo(withStatus: "\(Localized.httpErrorMsg.rawValue.localized())\n\(httpStatus.statusCode)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    func reachabilityError() {
        SVProgressHUD.showError(withStatus: Localized.networkErrorMsg.rawValue.localized())
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    func URLSessionError(error: Error?) {
        SVProgressHUD.showInfo(withStatus: "\(Localized.urlSessionErrorMsg.rawValue.localized())\n\(error ?? Error.self as! Error)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    
    //OBJC FUNC
    @objc func showPlan(_ ender: UIButton){
        let planView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "planNav") as! UINavigationController
        self.present(planView, animated: true, completion: nil)
    }
    @objc func refreshFeatured(_ sender: UIRefreshControl){
        updateList()
    }
    @objc func updateFrame(){
        DispatchQueue.main.async {
            self.more?.frame.origin.x = self.view.bounds.width - 50
            self.menu?.frame.origin.x = self.view.bounds.width - 75
        }
        
    }
    
    //FUNC
    func updateList(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/score.php", method: "POST", query: "user=\(session.usr.UID)") { (data) in
            guard let result = Session.parser.parse(data!)else{
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }
            for item in result {
                if (item["Result"] as! String) == "OK"{
                    self.state = "trip"
                    self.network.send(url: "https://scripttrip.scarletsc.net/iOS/getAITrips.php?user=\(self.session.usr.UID)", method: "GET", query: nil)
                }else{
                    self.state = "trip"
                    self.network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
                }
            }
            
        }
        
    }
    func delegate(){
        cv.dataSource = self
        cv.delegate = self
        network.delegate = self
    }
    
    func layout(){
        SVProgressHUD.dismiss()
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout
    }
    
    func setup(){
        session.clearTrips()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFrame), name: UIDevice.orientationDidChangeNotification, object: nil)
        session.setupUserView()
        tripView = TripView(delegate: self, haveTabBar: true)
        planView = TripView(delegate: self, haveTabBar: true)
        DispatchQueue.main.async {
            self.mainRefresh = UIRefreshControl()
            self.mainRefresh!.addTarget(self, action: #selector(self.refreshFeatured(_:)), for: .valueChanged)
            self.mainRefresh!.tintColor = darkGreen
            self.cv.refreshControl = self.mainRefresh
        }
        self.becomeFirstResponder()
        qaState = UserDefaults.standard.bool(forKey: "quickAccess")
        updateList()
        
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate()
        layout()
        setup()
        
        if UserDefaults.standard.bool(forKey: "isReg"){
            let tut = storyboard?.instantiateViewController(withIdentifier: "tut") as! UINavigationController
            present(tut, animated: true, completion: nil)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if qaState != UserDefaults.standard.bool(forKey: "quickAccess"){
            DispatchQueue.main.async {
                self.cv.reloadData()
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if UserDefaults.standard.bool(forKey: "shake") {
            if motion == .motionShake{
                let trip = session.getTrips().randomElement()!
                if UserDefaults.standard.bool(forKey: "history") {
                    network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(session.usr.UID)&trip=\(trip.TID)") { (_) in
                    }
                }
                
                tripView.displayTrip = trip
                tripView.headerImg = imgs[trip]
                tripView.show()
                DispatchQueue.main.async {
                    if #available(iOS 13.0, *) {
                        let postview = self.storyboard?.instantiateViewController(withIdentifier: "postView") as! postView
                        postview.tripView = self.tripView
                        self.present(postview, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
    }

}
