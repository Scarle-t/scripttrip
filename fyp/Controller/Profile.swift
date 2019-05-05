//
//  Profile.swift
//  fyp
//
//  Created by Scarlet on 5/2/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class Profile: UITableViewController {
    //VARIABLE
    let session = Session.shared
    
    //IBOUTLET
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var left: UIBarButtonItem!
    @IBOutlet weak var right: UIBarButtonItem!
    
    //IBACTION
    @IBAction func leftItem(_ sender: UIBarButtonItem) {
        if sender.tag == 0{
            self.dismiss(animated: true, completion: nil)
        }
        
        if sender.tag == -1{
            sender.tag = 0
            right.tag = 0
            right.image = #imageLiteral(resourceName: "Edit_pdf")
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            email.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            email.isUserInteractionEnabled = false
            return
        }
        
    }
    
    @IBAction @objc func rightItem(_ sender: UIBarButtonItem) {
        
        if sender.tag == 0{
            fname.layer.shadowOpacity = 1
            lname.layer.shadowOpacity = 1
            email.layer.shadowOpacity = 1
            fname.isUserInteractionEnabled = true
            lname.isUserInteractionEnabled = true
            email.isUserInteractionEnabled = true
            sender.tag = -1
            left.tag = -1
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            left.image = #imageLiteral(resourceName: "small_cross_pdf")
            return
        }
        
        if sender.tag == -1{
            sender.tag = 0
            left.tag = 0
            sender.image = #imageLiteral(resourceName: "Edit_pdf")
            left.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            email.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            email.isUserInteractionEnabled = false
            return
        }
        
    }
    
    //DELEGATE
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        fname.setBottomBorder()
        lname.setBottomBorder()
        email.setBottomBorder()
        
        fname.layer.shadowOpacity = 0
        lname.layer.shadowOpacity = 0
        email.layer.shadowOpacity = 0
        
        userIcon.layer.cornerRadius = userIcon.frame.width / 2
        
    }
    
    func setup(){
        userIcon.image = session.usr.iconImage
        fname.text = session.usr.Fname
        lname.text = session.usr.Lname
        email.text = session.usr.email
        
        fname.isUserInteractionEnabled = false
        lname.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate()
        layout()
        setup()
    }

    

}
