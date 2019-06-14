//
//  addPhoto.swift
//  fyp
//
//  Created by Scarlet on A2019/J/9.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class addPhoto: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NetworkDelegate{
    
    
    
    //VARIABLE
    let network = Network()
    let imgPicker = UIImagePickerController()
    var mode = ""
    var item: Item?
    var planID: Int?
    
    //IBOUTLET
    @IBOutlet weak var img: UIImageView!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showPhotoPicker(_ sender: UITapGestureRecognizer) {
        displayMenu()
    }
    @IBAction func save(_ sender: UIButton) {
        guard let image = img.image else {
            SVProgressHUD.showInfo(withStatus: Localized.photoEmptyMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        SVProgressHUD.show()
        network.uploadPhoto(image: image, param: [
            "user":"\(Session.user.UID)",
            "post":"\(planID!)",
            "publicity":"\(0)"
            ], postID: planID!)
    }
    
    
    //DELEGATION
        //IMAGE PICKER
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if img.image == nil{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        img.image = chosenImage
        picker.dismiss(animated: true, completion: nil)
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {return}
        SVProgressHUD.dismiss()
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
        
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func displayMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Localized.Camera.rawValue.localized(), style: .default, handler: { (_) in
            self.imgPicker.sourceType = .camera
            self.imgPicker.cameraDevice = .rear
            self.displayPicker()
        }))
        
        alert.addAction(UIAlertAction(title: Localized.photoLibrary.rawValue.localized(), style: .default, handler: { (_) in
            self.imgPicker.sourceType = .photoLibrary
            self.imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.displayPicker()
        }))
        
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: { (_) in
            if self.img.image == nil{
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func displayPicker(){
        imgPicker.allowsEditing = false
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func delegate(){
        imgPicker.delegate = self
        network.delegate = self
    }
    
    func layout(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setup(){
        if mode == ""{
            displayMenu()
        }else if mode == "edit"{
            network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(item!.I_Image)") { (data, response, error) in
                guard let image = UIImage(data: data!) else {return}
                DispatchQueue.main.async {
                    self.img.image = image
                }
            }
        }
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
