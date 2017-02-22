//
//  DataManagerInterface.swift
//  Project Loca
//
//  Created by Tyler Angert on 2/19/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import Foundation
import UIKit

class DataInterface: NSObject{
    
    //This class receives raw camera data and delegates both the image recognition and translation tasks.
    //returns back the information to the main VC.
    static let sharedInstance = DataInterface()
    //delegates
	 static var imageRecognitionDelegate: ImageRecognitionDelegate?
	 static var translationDelegate: TranslationDelegate?
	static var updateUIDelegate: UpdateUIDelegate?
	static var updateDataInterfaceDelegate: UpdateDataInterfaceDelegate?
    
    //data storage variables
    var analyzedImageLabels = [String]()
    var translatedImageLabels = [String]()

    
    
    //function is called from HomeVC once camera data has arrived.
	func imageDataToTranslation(data: Data, completion: @escaping (_ translations: [String]) -> Void) {
        let dataProvider = CGDataProvider(data: data as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
        
        //sends data as an image to the image recognition instance and retuns data on the image sent
		ImageRecognitionManager.sharedInstance.processImage(image: image, completion: {(words) -> Void in
			//got data from image recognition back. Now
			//time to send to translator
			print("got image recognition. now going to tranlsation")
			TranslationManager.sharedInstance.didReceiveText(input: words, completion: {(words) -> Void in
				print("leaving data manager with translations")
				completion(words)
			})
			
		})
    }
}
