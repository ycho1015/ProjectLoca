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
import Alamofire

class HomeViewController: UIViewController{

	//UI Variables
	var previewView: UIView?
	
	let textInput = UITextField()
	let translationOutput = UILabel()
	let translateButton = UIButton()
	let poweredLabel = UILabel()
	
	//data variables
	var captureSession: AVCaptureSession?
	var captureDevice : AVCaptureDevice?
	var captureDeviceInput: AVCaptureDeviceInput?
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var stillImageOutput: AVCaptureStillImageOutput?
	
	override func viewDidLoad() {
		print("hello world")
		super.viewDidLoad()
		
		self.view.addSubview(textInput)
		textInput.frame = CGRect(x: 0, y: 0, width: 180, height: 30)
		textInput.center = self.view.center
		textInput.layer.borderColor = UIColor.gray.cgColor
		textInput.layer.cornerRadius = 10
		textInput.layer.borderWidth = 1
		textInput.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
		
		translationOutput.frame = CGRect(x: 0, y: 0, width: 180, height: 30)
		translationOutput.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
		self.view.addSubview(translationOutput)
		translationOutput.center = self.view.center
		translationOutput.center.y = textInput.frame.maxY + 30
		
		translateButton.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
		self.view.addSubview(translateButton)
		translateButton.layer.cornerRadius = 20
		translateButton.addTarget(self, action: #selector(HomeViewController.translate), for: .touchUpInside)
		translateButton.center = self.view.center
		translateButton.center.y = translationOutput.frame.maxY + 30
		translateButton.backgroundColor = UIColor.green
		translateButton.setTitle("Translate", for: .normal)
		
		
		self.view.addSubview(poweredLabel)
		poweredLabel.frame = CGRect(x: self.view.frame.maxX - 200, y: self.view.frame.maxY - 15, width: 200, height: 15)
		poweredLabel.textAlignment = .right
		poweredLabel.text = "Powered by Yandex.Translate"
		poweredLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
		
		
	}
	
	func translate(){
		
		guard let text = textInput.text?.replacingOccurrences(of: " ", with: "+") else{
			translationOutput.text = "invalid input"
			return
		}
		BingAPICall(word: textInput.text!)
	}
	
	func getVideoAuthorization(){
		if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized{
			startCapture()
		}else{
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
				if granted == true
				{
					print("got it")
					self.startCapture()
				}
				else
				{
					print("don't have video permission")
				}
			});
		}
	}
	func startCapture(){
		
		//check for authorization
		if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != AVAuthorizationStatus.authorized{
			getVideoAuthorization()
		}
		
		//create capture session
		captureSession = AVCaptureSession()
		captureSession?.sessionPreset = AVCaptureSessionPresetLow
		
		//get video  device
		var defaultVideoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		if let backCamera = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDualCamera, mediaType: AVMediaTypeVideo, position: .back){
			defaultVideoDevice = backCamera
		}
		
		//configure device input
		var deviceInput: AVCaptureDeviceInput?
		do{
			deviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
		}catch{
			print("error: \(error)")
		}
		
		//configure capture session
		captureSession?.beginConfiguration()
		if (captureSession?.canAddInput(deviceInput))!{
			captureSession?.addInput(deviceInput)
		}
		let dataOutput = AVCaptureVideoDataOutput()
		dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)] // 3
		dataOutput.alwaysDiscardsLateVideoFrames = true
		if (captureSession?.canAddOutput(dataOutput))!{
			captureSession?.addOutput(dataOutput)
		}
		captureSession?.commitConfiguration()
		//let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
		//dataOutput.setSampleBufferDelegate(self, queue: queue)


		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
		videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
		
		previewView = UIView()
		self.view.addSubview(previewView!)
		previewView!.frame = self.view.frame
		videoPreviewLayer?.frame = previewView!.bounds
		previewView?.layer.addSublayer(videoPreviewLayer!)
		
		
		captureSession?.startRunning()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func BingAPICall(word: String) -> String{
		
		let toTranslate = word.replacingOccurrences(of: " ", with: "+")
		
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		//Yandex translate
		//let key = "a4466e949cde47e585edec2da6b2404b"
		var baseURL: String = "https://translate.yandex.net/api/v1.5/tr.json/translate"
		let key: String = "trnsl.1.1.20170206T214522Z.d28a904e6f61ba84.aac82dfc3243245cfe6429478e1e72257716f354"
		let inputLanguage = "en"
		let outputLanguage = "zh"
		
		guard let tokenURL: URL = URL(string: "\(baseURL)?key=\(key)&lang=\(inputLanguage)-\(outputLanguage)&text=\(toTranslate)") else{
			print("error making tokenURL")
			return "error"
		}
		print(tokenURL)
		var urlRequest = URLRequest(url: tokenURL)
		urlRequest.httpMethod = "GET"
		print("url request: \(urlRequest)")

		/* Microsoft Translate
		//let key = "a4466e949cde47e585edec2da6b2404b"
		guard let tokenURL: URL = URL(string: "https:api.cognitive.microsoft.com/svc/v1.0/issueToken") else{
		print("error generating key url")
		return
		}
		var urlRequest = URLRequest(url: tokenURL)
		urlRequest.httpMethod = operation
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest.addValue("application/jwt", forHTTPHeaderField: "Accept")
		urlRequest.addValue("a4466e949cde47e585edec2da6b2404b", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
		print("url request: \(urlRequest)")
		*/
		let task = session.dataTask(with: urlRequest) { (data, response, error) in
			if response != nil{
				print("response: \(response)")
			}
			if data != nil{
				print("data: \(data)")
			}
			if (error != nil){
				print("error at 1\(error)")
			}else{
				do{
					let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
					print("we got the json: \(json)")
					let word = (json["text"] as! [String]).joined()
					print("our word is: \(word)")
					DispatchQueue.main.async {
						self.translationOutput.text = word
					}
				}catch{
					print("error in JSON serialization: \(error)")
				}
			}
		}
		print("executing api call")
		task.resume()
		return "loading"
	}
}



