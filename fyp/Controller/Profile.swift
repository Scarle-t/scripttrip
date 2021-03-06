//
//  Profile.swift
//  fyp
//
//  Created by Scarlet on 5/2/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class Profile: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let userDefault = UserDefaults.standard
    let network = Network()
    let imgPicker = UIImagePickerController()
    
    //IBOUTLET
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var left: UIBarButtonItem!
    @IBOutlet weak var right: UIBarButtonItem!
    @IBOutlet weak var naemText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var tfaText: UILabel!
    @IBOutlet weak var tfa: UISwitch!
    @IBOutlet weak var interestText: UILabel!
    @IBOutlet var imageSelector: UITapGestureRecognizer!
    @IBOutlet weak var userIDText: UILabel!
    
    //IBACTION
    @IBAction func leftItem(_ sender: UIBarButtonItem) {
        if sender.tag == 0{
            self.dismiss(animated: true, completion: nil)
        }
        
        if sender.tag == -1{
            sender.tag = 0
            right.tag = 0
//            if #available(iOS 13.0, *) {
//                right.image = UIImage(systemName: "pencil.circle")
//                sender.image = UIImage(systemName: "checkmark.circle")
//            } else {
//                // Fallback on earlier versions
//                right.image = #imageLiteral(resourceName: "Edit_pdf")
//                sender.image = #imageLiteral(resourceName: "small_tick_pdf")
//            }
            right.image = #imageLiteral(resourceName: "Edit_pdf")
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            imageSelector.isEnabled = false
            return
        }
        
    }
    
    @IBAction func rightItem(_ sender: UIBarButtonItem) {
        
        if sender.tag == 0{
            fname.layer.shadowOpacity = 1
            lname.layer.shadowOpacity = 1
            fname.isUserInteractionEnabled = true
            lname.isUserInteractionEnabled = true
            imageSelector.isEnabled = true
            sender.tag = -1
            left.tag = -1
//            if #available(iOS 13.0, *) {
//                left.image = UIImage(systemName: "xmark.circle")
//                sender.image = UIImage(systemName: "checkmark.circle")
//            } else {
//                // Fallback on earlier versions
//                left.image = #imageLiteral(resourceName: "small_cross_pdf")
//                sender.image = #imageLiteral(resourceName: "small_tick_pdf")
//            }
            left.image = #imageLiteral(resourceName: "small_cross_pdf")
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            return
        }
        
        if sender.tag == -1{
            sender.tag = 0
            left.tag = 0
//            if #available(iOS 13.0, *) {
//                left.image = UIImage(systemName: "checkmark.circle")
//                sender.image = UIImage(systemName: "pencil.circle")
//            } else {
//                // Fallback on earlier versions
//                sender.image = #imageLiteral(resourceName: "Edit_pdf")
//                left.image = #imageLiteral(resourceName: "small_tick_pdf")
//            }
            sender.image = #imageLiteral(resourceName: "Edit_pdf")
            left.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            imageSelector.isEnabled = false
            
            var query = "user=\(session.usr.UID)&fname=\(fname.text!)&lname=\(lname.text!)"
            
            query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            network.send(url: "https://scripttrip.scarletsc.net/iOS/profile.php?\(query)", method: "UPDATE", query: nil)
            SVProgressHUD.show()
            return
        }
        
    }
    @IBAction func tfaSwitch(_ sender: UISwitch) {
        let setup = storyboard?.instantiateViewController(withIdentifier: "otp_setup") as! otp_setup
        
        sender.isOn ? (setup.mode = "create") : (setup.mode = "remove")
        
        self.present(setup, animated: true, completion: nil)
        
    }
    @IBAction func imgSelect(_ sender: UITapGestureRecognizer) {
        displayMenu()
    }
    
    //DELEGATE
        //TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        case 1, 2:
            return 1
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if indexPath.section == 1 && indexPath.row == 0{
            let interest = storyboard?.instantiateViewController(withIdentifier: "interest") as! reg_interestChoice
            interest.change = true
            self.present(interest, animated: true, completion: nil)
        }
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else { SVProgressHUD.showError(withStatus: nil)
            return
        }
        
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                DispatchQueue.main.async {
                    self.session.usr.Fname = self.fname.text!
                    self.session.usr.Lname = self.lname.text!
                    self.session.reloadUserTable()
                }
            }else{
                SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                DispatchQueue.main.async {
                    self.fname.text = self.session.usr.Fname
                    self.lname.text = self.session.usr.Lname
                }
            }
        }
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
        //IMAGE PICKER
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
        self.imageSelector.isEnabled = false
        
        let cropViewController = CropViewController(image: chosenImage)
        cropViewController.delegate = self
        navigationController?.pushViewController(cropViewController, animated: false)
    }
    
    //CROP VIEW
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        navigationController?.popViewController(animated: false)
        SVProgressHUD.show()
        network.uploadPhoto(url: "https://scripttrip.scarletsc.net/iOS/upload_icon.php", image: image, param: ["user" : "\(session.usr.UID)"]) { (data, filename) in
            
            guard let result = Session.parser.parse(data!) else{
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                self.imageSelector.isEnabled = true
                return
            }
            
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: nil)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    DispatchQueue.main.async {
                        self.userIcon.image = image
                    }
                    self.session.usr.icon = "https://scripttrip.scarletsc.net/img/icon/\(filename!)"
                }else{
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    self.imageSelector.isEnabled = true
                }
            }
            
        }
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func displayPicker(){
        imgPicker.allowsEditing = false
        self.present(imgPicker, animated: true, completion: nil)
    }
    func displayMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Localized.Camera.rawValue.localized(), style: .default, handler: { (_) in
            self.imgPicker.sourceType = .camera
            self.imgPicker.cameraDevice = .rear
            self.imgPicker.cameraCaptureMode = .photo
            self.imgPicker.showsCameraControls = true
            self.displayPicker()
        }))
        
        alert.addAction(UIAlertAction(title: Localized.photoLibrary.rawValue.localized(), style: .default, handler: { (_) in
            self.imgPicker.sourceType = .photoLibrary
            self.imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.displayPicker()
        }))
        
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func delegate(){
        network.delegate = self
        imgPicker.delegate = self
    }
    
    func layout(){
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.hideKB.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.tintColor = "42C89D".uiColor
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-DemiBold", size: 17)!], for: .normal)
        
        fname.inputAccessoryView = toolBar
        lname.inputAccessoryView = toolBar
        
        fname.setBottomBorder(strokeColor: darkGreen.cgColor, backgroundColor: UIColor.clear.cgColor)
        lname.setBottomBorder(strokeColor: darkGreen.cgColor, backgroundColor: UIColor.clear.cgColor)
        
        fname.layer.shadowOpacity = 0
        lname.layer.shadowOpacity = 0
        email.layer.shadowOpacity = 0
        
        fname.placeholder = Localized.firstName.rawValue.localized()
        lname.placeholder = Localized.lastName.rawValue.localized()
        email.placeholder = Localized.email.rawValue.localized()
        emailText.text = Localized.email.rawValue.localized()
        naemText.text = Localized.name.rawValue.localized()
        
        interestText.text = Localized.Interest.rawValue.localized()
        
        tfaText.text = Localized.tfaText.rawValue.localized()
        
        tfa.isEnabled = false
        
    }
    
    func setup(){
        userIcon.image = session.usr.iconImage
        fname.text = session.usr.Fname
        lname.text = session.usr.Lname
        email.text = session.usr.email
        userIDText.text = "ID\n\(session.usr.UID)"
        
        userIDText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        fname.isUserInteractionEnabled = false
        lname.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        
        if #available(iOS 12.0, *) {
            switch self.traitCollection.userInterfaceStyle{
            case .light:
                fname.textColor = .black
                lname.textColor = .black
                email.textColor = .black
            case .dark:
                fname.textColor = .white
                lname.textColor = .white
                email.textColor = .white
            default:
                fname.textColor = .black
                lname.textColor = .black
                email.textColor = .black
            }
        } else {
            //fallback statements
        }
        
//        if #available(iOS 13.0, *){
//            userIDText.textColor = .systemGray
//        }else{
//            userIDText.textColor = .gray
//            right.image = #imageLiteral(resourceName: "Edit_pdf")
//            left.image = #imageLiteral(resourceName: "small_cross_pdf")
//        }
        userIDText.textColor = .gray
        right.image = #imageLiteral(resourceName: "Edit_pdf")
        left.image = #imageLiteral(resourceName: "small_cross_pdf")
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate()
        layout()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        network.send(url: "https://scripttrip.scarletsc.net/iOS/otp.php?mode=check&user=\(session.usr.UID)", method: "POST", query: nil) { (data) in
            guard let result = Session.parser.parse(data!) else {
                self.tfa.setOn(false, animated: false)
                return
            }
            for item in result{
                DispatchQueue.main.async {
                    if (item["Result"] as! String) == "Yes"{
                        self.tfa.setOn(true, animated: true)
                        self.tfa.isEnabled = true
                    }else if (item["Result"] as! String) == "No"{
                        self.tfa.setOn(false, animated: true)
                        self.tfa.isEnabled = true
                    }
                }
            }
        }
    }

}
