//
//  DataManagerInterface.swift
//  Project Loca
//
//  Created by Tyler Angert on 2/19/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import Foundation
import UIKit

class DataInterface: NSObject, DataInterfaceDelegate, UpdateDataInterfaceDelegate {
    
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
    
    override init() {
        super.init()
        HomeViewController.dataIntefaceDelegate = self
        ImageRecognitionManager.sharedInstance.updateDataInterfaceDelegate = self
        //initialization
        let _ = ImageRecognitionManager()
        let _ = TranslationManager()
        
        ImageRecognitionManager.sharedInstance.dataInterfaceCallback = {
            print("I got the delegate!")
        }
    }
    
    
    //function is called from HomeVC once camera data has arrived.
    func didReceiveData(data: Data) {
        let dataProvider = CGDataProvider(data: data as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
        
        //sends data as an image to the image recognition delegate
        DataInterface.imageRecognitionDelegate?.didReceiveImage(image: image)
    }
    
    //this is called once the image recognition is finished.
    func didFinishImageRecognition() {
        print("finished image recognition")
        print(analyzedImageLabels)
        DataInterface.translationDelegate?.didReceiveText(input: analyzedImageLabels.first!)
    }
    
    //setup this delegate later
    func didReceiveTranslation() {
        
    }
    
}
