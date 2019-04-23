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
    
    //IBOUTLET
    @IBOutlet weak var interestTxt: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var catChoice: UICollectionView!
    
    //IBACTION
    @IBAction func finish(_ sender: UIButton) {
        let vc3 = storyboard?.instantiateViewController(withIdentifier: "vc3") as! reg_done
        
        self.present(vc3, animated: true, completion: nil)
        
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! cateChoiceCell
        
        cell.layer.cornerRadius = 7
        
//        cell.catImg.image = AppDelegate().cat[indexPath.row]
        cell.catName.text = session.getCategories()[indexPath.row].C_Name
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (view.frame.width / 2) - 20 - 5, height: (view.frame.width / 2) - 20 - 5)
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
