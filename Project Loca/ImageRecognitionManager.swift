//
//  ImageRecognitionManager.swift
//  Project Loca
//
//  Created by Tyler Angert on 2/17/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ImageRecognitionManager: NSObject{
    
    static let sharedInstance = ImageRecognitionManager()
    
    override init() {
        super.init()
		//DataInterface.imageRecognitionDelegate = self
    }
    
	//var dataInterfaceCallback:(()->())?
    
    var googleAPIKey = "AIzaSyBRjyA574z2Dk_T6IVrLGImH8ThrSB2wqY"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    //This function is passed images from elsewhere in app, passes data to another function that calls google. We 'forward' the completion handler to the callGoogleVision function
	func processImage(image: UIImage, completion: @escaping ([String]) -> Void) {
		callGoogleVision(with: image, completion: completion)
	}
	fileprivate func callGoogleVision(with pickedImage: UIImage, completion: @escaping ([String]) -> Void) {
        print("Calling google vision")
        let imageBase64 =  base64EncodeImage(pickedImage)
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            print("error, unable to make json raw data")
            return
        }
        request.httpBody = data
        // Run the request on a background thread and forward the completion handler
		DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, completion: completion) }
    }
	func runRequestOnBackgroundThread(_ request: URLRequest, completion: @escaping ([String]) -> Void) {
        print("calling google api in background")
        // run the request
        let task: URLSessionDataTask = HomeViewController.session.dataTask(with: request) { (data, response, error) in
			if (error != nil){
				print("error at 1\(error) cannot complete task")
			}else{
				do{
					let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
					print("we got the json: \(json)")
					let words = (json["text"] as! [String]).joined()
					print("our words are: \(words)")
					completion([words]) //execute whatever function was passed to us with this data as the parameter
				}catch{
					print("error in JSON serialization: \(error)")
				}
            }
        }
        task.resume()
    }
    func base64EncodeImage(_ image: UIImage) -> String {
        guard var imagedata = UIImagePNGRepresentation(image) else{
            print("error with imageData")
            return ""
        }
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
