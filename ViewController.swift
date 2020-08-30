//
//  ViewController.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 22/08/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    deinit {
        print("ViewController")
    }
    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    fileprivate func UploadImage() {
        let image = Media(withJPEGImage: #imageLiteral(resourceName: "Dark-Netflix-Series"), forKey: "profile", compression: .low)

        let medias : [Media?] = [
            image
        ]

        let params : [String : Any] = [
            "name":"Dhruv Thakkar",
            "email":"govani@lux.la",
            "phone":"555999111222",
            "id":75,
            "gender":"male",
            "address":"AHM",
            "country":1
        ]
        
        DGNetworkingServices.main.delegate = self

        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://propertyauction-live.com/api/v2/update_profile"), Attachments: medias, HttpMethod: .post, parameters: params) { (Result) in

            switch Result{

            case .success(let Response):
                print(Response.0)
//                DispatchQueue.main.async {
//                self.dismiss(animated: true, completion: nil)
//                }
            case .failure(let error):
                print(error.rawValue)
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), Attachments: nil, HttpMethod: .get, parameters: nil) { (Response) in
            switch Response{

            case .success((_, _)):
                print("done")
            case .failure(_):
                print("failed")
                self.dismiss(animated: true, completion: nil)
            }

        }
        
    }
    
    
//    func requestNativeImageUpload(image: UIImage) {
//
//        guard let url = URL(string: "https://propertyauction-live.com/public/api/v2/update_profile") else { return }
//        let boundary = generateBoundary()
//        var request = URLRequest(url: url)
//
//        let parameters : [String : Any] = [
//            "name":"Dhruv Govani",
//            "email":"testvh@yopmail.com",
//            "phone":"555999111222",
//            "id":33,
//            "gender":"male",
//            "address":"AHM",
//            "country":1
//        ]
        
//        guard let mediaImage = Media(withImage: image, forKey: "profile") else { return }
//
//        request.httpMethod = "POST"
//
//        request.allHTTPHeaderFields = [
//            "Accept": "application/json",
//            "Content-Type": "multipart/form-data; boundary=\(boundary)",
//        ]
//
//        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
//        request.httpBody = dataBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            if let response = response {
//                print(response)
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//        }.resume()
//    }
    
    
//    func generateBoundary() -> String {
//        return "Boundary-\(NSUUID().uuidString)"
//    }
    
//    func createDataBody(withParameters params: [String: Any]?, media: [Media]?, boundary: String) -> Data {
//
//        let lineBreak = "\r\n"
//        var body = Data()
//
//        if let parameters = params {
//            for (key, value) in parameters {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                body.append("\("\(value)" + lineBreak)")
//            }
//        }
//
//        if let media = media {
//            for photo in media {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
//                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//                body.append(photo.data)
//                body.append(lineBreak)
//            }
//        }
//
//        body.append("--\(boundary)--\(lineBreak)")
//
//        return body
//    }
    
}
extension ViewController : DGNetworkingServicesDelegate{
    func didProggressed(_ ProgressDone: Double) {
        print(ProgressDone)
        self.progressView.progress = Float(ProgressDone)
    }
}
