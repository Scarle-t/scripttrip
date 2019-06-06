//
//  DeviceSettings.swift
//  fyp
//
//  Created by Scarlet on 5/13/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class DeviceSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    //VARIABLE
    let session = Session.shared
    let userDefault = UserDefaults.standard
    let langPicker = UIPickerView()
    let dimBg = UIView()
    
    //IBOUTLET
    @IBOutlet weak var history: UISwitch!
    @IBOutlet weak var shake: UISwitch!
    @IBOutlet weak var localeLabel: UITextField!
    @IBOutlet weak var langText: UILabel!
    @IBOutlet weak var shakeText: UILabel!
    @IBOutlet weak var historyText: UILabel!
    @IBOutlet weak var clearHistoryText: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var reduceMotion: UISwitch!
    @IBOutlet weak var reduceMotionText: UILabel!
    
    //IBACTION
    @IBAction func historySwitch(_ sender: UISwitch) {
        userDefault.set(sender.isOn, forKey: "history")
    }
    @IBAction func shakeSwitch(_ sender: UISwitch) {
        userDefault.set(sender.isOn, forKey: "shake")
    }
    @IBAction func reduceMotionSwitch(_ sender: UISwitch) {
        userDefault.set(sender.isOn, forKey: "reduceMotion")
    }
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
        //TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0, 1, 2:
            return 1
        case 3:
            return 2
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 1{
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            let alert = UIAlertController(title: Localized.historyClearMsg.rawValue.localized(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .destructive, handler: { (_) in
                Network().send(url: "https://scripttrip.scarletsc.net/iOS/history.php?user=\(Session.user.UID)", method: "DELETE", query: nil, completion: { (data) in
                    guard let d = data, let result = Session.parser.parse(d) else {return}
                    for item in result{
                        if (item["Result"] as! String) == "OK"{
                            SVProgressHUD.showSuccess(withStatus: Localized.Success.rawValue.localized())
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }else{
                            SVProgressHUD.showError(withStatus: Localized.Fail.rawValue.localized())
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: { _ in
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UILabel()
        
        footer.font = UIFont(name: "AvenirNext-Medium", size: 12)
        footer.textColor = .lightGray
        footer.textAlignment = .center
        footer.numberOfLines = 0
        
        switch section{
        case 0:
            footer.text = Localized.langFooter.rawValue.localized()
        case 1:
            footer.text = Localized.shakeFooter.rawValue.localized()
        case 3:
            footer.text = Localized.historyFooter.rawValue.localized()
        default:
            return nil
        }
        
        return footer
    }
    
        //PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locale.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let l = locale.allCases[row]
        return Localized.init(rawValue: "\(l)")!.rawValue.localized()
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "AvenirNext-Medium", size: 27)
            pickerLabel?.textAlignment = .center
        }
        
        let l = locale.allCases[row]
        pickerLabel?.text = Localized.init(rawValue: "\(l)")!.rawValue.localized()
        
        pickerLabel?.textColor = "42A89D".uiColor
        
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 55
    }
    
        //TEXT FIELD
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.dimBg.alpha = dimViewAlpha
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.2) {
            self.dimBg.alpha = dimViewAlpha
        }
        return true
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
        UIView.animate(withDuration: 0.2) {
            self.dimBg.alpha = 0
        }
        
    }
    @objc func confirmPicker(){
        let index = langPicker.selectedRow(inComponent: 0)
        userDefault.set(locale.allCases[index].rawValue, forKey: "locale")
        localeLabel.text = Localized.init(rawValue: "\(locale.allCases[index])")!.rawValue.localized()
        session.reloadLocale()
        dismissKb()
        SVProgressHUD.showSuccess(withStatus: nil)
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    
    //FUNC
    func delegate(){
        langPicker.delegate = self
        localeLabel.delegate = self
    }
    
    func layout(){
        langPicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/1.8)
        if #available(iOS 13.0, *) {
            langPicker.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            langPicker.backgroundColor = .white
        }
        
        dimBg.frame = view.frame
        dimBg.backgroundColor = .black
        dimBg.alpha = 0
        view.addSubview(dimBg)
        view.bringSubviewToFront(dimBg)
        langText.text = Localized.languages.rawValue.localized()
        shakeText.text = Localized.shakeForTrips.rawValue.localized()
        historyText.text = Localized.history.rawValue.localized()
        clearHistoryText.text = Localized.clearHistory.rawValue.localized()
        heading.text = Localized.Settings.rawValue.localized()
        reduceMotionText.text = Localized.reduceMotion.rawValue.localized()
    }
    
    func setup(){
        
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        dimBg.addGestureRecognizer(tapDismiss)
        
        let toolBar = UIToolbar()
        let confirmButton = UIBarButtonItem(title: Localized.Confirm.rawValue.localized(), style: .plain, target: self, action: #selector(confirmPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.Cancel.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.tintColor = "42C89D".uiColor
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        toolBar.setItems([cancelButton, spaceButton, confirmButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-DemiBold", size: 17)!], for: .normal)
        confirmButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-DemiBold", size: 17)!], for: .normal)
        
        history.setOn(userDefault.bool(forKey: "history"), animated: false)
        
        shake.setOn(userDefault.bool(forKey: "shake"), animated: false)
        
        reduceMotion.setOn(userDefault.bool(forKey: "reduceMotion"), animated: false)
        
        localeLabel.text = Localized.init(rawValue: "\(locale.init(rawValue: (userDefault.string(forKey: "locale") ?? "system"))!)")?.rawValue.localized()
        localeLabel.inputView = langPicker
        localeLabel.inputAccessoryView = toolBar
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dimBg.removeFromSuperview()
    }
    
}
