//
//  Network.swift
//  fyp
//
//  Created by Scarlet on 16/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

protocol NetworkDelegate: class{
    func reachabilityError()
    func httpErrorHandle(httpStatus: HTTPURLResponse)
    func URLSessionError(error: Error?)
    func ResponseHandle(data: Data)
    func ResponsePhoto(data: Data)->UIImage?
}

extension NetworkDelegate{
    func httpErrorHandle(httpStatus: HTTPURLResponse){
        let alert = UIAlertController(title: "HTTP Error", message: "\(httpStatus.statusCode).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func reachabilityError(){
        let alert = UIAlertController(title: "Network unavailable, please try again later.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func URLSessionError(error: Error?){
        let alert = UIAlertController(title: "URL Session Error", message: "\(error ?? Error.self as! Error).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func ResponsePhoto(data: Data)->UIImage?{
        return UIImage(data: data)
    }
}

class Network: NSObject{
    
    weak var delegate: NetworkDelegate?
    
    func send(url action: String, method: String, query content: String?){
        
        if Reachability().isConnectedToNetwork(){
            var request = URLRequest(url: URL(string: action)!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method
            if let content = content{
                request.httpBody = content.data(using: .utf8)
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    self.delegate?.URLSessionError(error: error)
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    self.delegate?.httpErrorHandle(httpStatus: httpStatus)
                    return
                }
                self.delegate?.ResponseHandle(data: data)
            }
            task.resume()
        }else{
            self.delegate?.reachabilityError()
        }
    }
    
    func getPhoto(url: URL) -> UIImage? {
        var img: UIImage?
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                self.delegate?.URLSessionError(error: error)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                self.delegate?.httpErrorHandle(httpStatus: httpStatus)
                return
            }
            img = self.delegate?.ResponsePhoto(data: data)
        }.resume()
        return img
    }
    
}
