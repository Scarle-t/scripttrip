//
//  ViewController8.swift
//  fyp
//
//  Created by Scarlet on 10/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Settings: UITableViewController {
    
    //VARIABLE
    
    //IBOUTLET
    
    //IBACTION
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
        //TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    //OBJC FUNC
    
    //FUNC
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
