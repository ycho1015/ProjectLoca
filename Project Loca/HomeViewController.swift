//
//  ViewController.swift
//  Project Loca
//
//  Created by Jake Cronin on 2/2/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AKPickerView

class HomeViewController: UIViewController, UpdateUIDelegate {
    
    //IBOutlets
    @IBOutlet weak var queryButton: UIButton!
    @IBOutlet weak var previewView: CameraView!
    @IBOutlet weak var languagePicker: AKPickerView!
    
    @IBOutlet weak var inLanguage: UILabel!
    @IBOutlet weak var outLanguage: UILabel!
    
	//Camera-related variables
    var sessionIsActive = false
	var captureSession = AVCaptureSession()
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //for picker view
    let languages = ["Spanish", "French", "Italian", "Japanese", "Chinese"]

    
    static let session = URLSession.shared
    let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // Communicate with the session and other session objects on this queue.
    
    static var dataIntefaceDelegate: DataInterfaceDelegate?
    static var languageSetupDelegate: LanguageSetupDelegate?
    static var updateUIDelegate: UpdateUIDelegate?

    
	override func viewDidLoad() {
		super.viewDidLoad()
        print("hello world")
        //CAMERA
        //starts the capture session
        startSession()
        
        //initializing data interface
        let _ = DataInterface()
        DataInterface.updateUIDelegate = self
        
        //VISUALS        
        //camera view
        inLanguage.text = ""
        outLanguage.text = ""
        
        //query button
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.prominent))
        blur.frame = queryButton.bounds
        blur.isUserInteractionEnabled = false //This allows touches to forward to the button.
        blur.layer.cornerRadius = 30
        blur.clipsToBounds = true
        queryButton.insertSubview(blur, at: 0)
        queryButton.layer.borderColor = UIColor.darkGray.cgColor
        queryButton.layer.borderWidth = 2
        queryButton.layer.cornerRadius = 30
        queryButton.setTitleColor(UIColor.darkGray, for: .normal)
        queryButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        
        //language picker
        self.languagePicker.dataSource = self
        self.languagePicker.delegate = self
        
        self.languagePicker.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.languagePicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.languagePicker.pickerViewStyle = .styleFlat
        self.languagePicker.isMaskDisabled = false
        self.languagePicker.reloadData()
        self.languagePicker.interitemSpacing = 5
	}
    
    func didReceiveTranslation(input1: String, input2: String) {
        print("Original: \(input1)")
        print("Translation: \(input2)")
        
        self.inLanguage.text = input1
        self.outLanguage.text = input2
    }
    
    @IBAction func pressQuery(_ sender: Any) {
        takePicture()
    }
    
    let photoOutput = AVCapturePhotoOutput()
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startSession() {
        if !sessionIsActive {
            captureSession = AVCaptureSession()
            
            //image quality
            captureSession.sessionPreset = AVCaptureSessionPresetMedium
            
            var defaultDevice: AVCaptureDevice?
            if let backCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
                defaultDevice = backCamera
            }
            
            var error: NSError?
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: defaultDevice)
            } catch let error1 as NSError {
                error = error1
                input = nil
                print("Error: \(error!.localizedDescription)")
            }
            
            //adding camera input
            if error == nil && (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
            }
            
            //adding camera output
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            
            videoPreviewLayer!.frame = previewView.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession.startRunning()
            
            sessionIsActive = true
        } else {
            captureSession.stopRunning()
            print("session running problem")
            sessionIsActive = false
        }
    }
    
	func getVideoAuthorization(){
		if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized{
            print("already authorized")
        }else{
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
				if granted {
					print("got it")
				} else {
					print("don't have video permission")
				}
			});
		}
	}
}

extension HomeViewController: AVCapturePhotoCaptureDelegate {
    //delegate method called from takePicture()
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            //SENDING IMAGE TO DATA INTEFACE
            HomeViewController.dataIntefaceDelegate?.didReceiveData(data: dataImage)
            
        } else {
            print("some error here")
        }
    }
}

extension HomeViewController: AKPickerViewDelegate, AKPickerViewDataSource {
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.languages[item]
    }
    
    func numberOfItems(in pickerView: AKPickerView!) -> UInt {
        return UInt(languages.count)
    }
    
    func pickerView(_ pickerView: AKPickerView!, didSelectItem item: Int) {
        print("language selected: \(languages[item])")
        HomeViewController.languageSetupDelegate?.didChangeLanguage(language: languages[item])
    }
}
