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
}

extension NetworkDelegate{
    func httpErrorHandle(httpStatus: HTTPURLResponse){
        SVProgressHUD.showInfo(withStatus: "\(Localized.httpErrorMsg.rawValue.localized())\n\(httpStatus.statusCode)")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    func reachabilityError(){
        SVProgressHUD.showError(withStatus: Localized.networkErrorMsg.rawValue.localized())
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    func URLSessionError(error: Error?){
        SVProgressHUD.showInfo(withStatus: "\(Localized.urlSessionErrorMsg.rawValue.localized())\n\(error ?? Error.self as! Error)")
        SVProgressHUD.dismiss(withDelay: 1.5)
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
    
    func send(url action: String, method: String, query content: String?, completion: ((Data?)->())?){
        
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
                completion?(data)
            }
            task.resume()
        }else{
            self.delegate?.reachabilityError()
        }
    }
    
    func getPhoto(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let u = URL(string: url) else {self.delegate?.URLSessionError(error: nil); return}
        URLSession.shared.dataTask(with: u) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func uploadPhoto(url action: String, image: UIImage, param: [String : String]?, postID: Int){
        if Reachability().isConnectedToNetwork(){
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: URL(string: action)!)
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            var data = Data()
            
            let filename = "\(Session.user.UID)_\(postID)_\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10)).jpg"
            
            if let param = param {
                for (key, value) in param{
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)".data(using: .utf8)!)
                }
            }
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.jpegData(compressionQuality: 0.0)!)
            
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
                
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
            }).resume()
            
        }else{
            self.delegate?.reachabilityError()
        }
    }
    
    func uploadPhoto(url action: String, image: UIImage, param: [String : String]?, completion: ((Data?, String?)->())?){
        if Reachability().isConnectedToNetwork(){
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: URL(string: action)!)
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            var data = Data()
            
            let filename = "\(Session.user.UID)_\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10))\(Int.random(in: 0..<10)).jpg"
            
            if let param = param {
                for (key, value) in param{
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)".data(using: .utf8)!)
                }
            }
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.jpegData(compressionQuality: 0.5)!)
            
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
                
                guard let data = data, error == nil else {
                    self.delegate?.URLSessionError(error: error)
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    self.delegate?.httpErrorHandle(httpStatus: httpStatus)
                    return
                }
                completion?(data, filename)
            }).resume()
            
        }else{
            self.delegate?.reachabilityError()
        }
    }
    
}
