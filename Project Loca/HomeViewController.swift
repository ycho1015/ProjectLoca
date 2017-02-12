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
import SwiftyJSON

class HomeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

	//UI Variables
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var whatIsThisButton: UIButton!
	@IBOutlet weak var objectNameLabel: UILabel!
	@IBOutlet weak var translationOutput: UILabel!
	@IBOutlet weak var textInput: UITextField!
	@IBOutlet weak var fromLanguage: UITextField!
	@IBOutlet weak var translateButton: UIButton!
	
	//data variables
	var captureSession: AVCaptureSession?
	var captureDevice : AVCaptureDevice?
	var captureDeviceInput: AVCaptureDeviceInput?
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var stillImageOutput: AVCaptureStillImageOutput?
	
	let session = URLSession.shared
	var googleAPIKey = "AIzaSyAA-6h_mKGKUHptGHIoPQLIyR6DkmUk7Dc"
	var googleURL: URL {
		return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
	}

	
	var inputLanguage: String = "English"
	var outputLanguage: String = "Chinese"

	
	var languages: [String: String] = [
		"English"	:"en",	"Chinese" : "zh",
		"Spanish"	:"es",
		"Azerbaijan":	"az",	"Maltese":	"mt",
		"Albanian":	"sq",	"Macedonian":	"mk",
		"Amharic":	"am",	"Maori"		:"mi",
		"Marathi"	:"mr",
		"Arabic"	:"ar",	"Mari"		:"mhr",
		"Armenian":	"hy",	"Mongolian"	:"mn",
		"Afrikaans":"af",	"German"	:"de",
		"Basque"	:"eu",	"Nepali"	:"ne",
		"Bashkir"	:"ba",	"Norwegian"	:"no",
		"Belarusian":"be",	"Punjabi"	:"pa",
		"Bengali"	:"bn",	"Papiamento":"pap",
		"Bulgarian"	:"bg",	"Persian"	:"fa",
		"Bosnian"	:"bs",	"Polish"	:"pl",
		"Welsh"		:"cy",	"Portuguese":"pt",
		"Hungarian"	:"hu",	"Romanian"	:"ro",
		"Vietnamese":	"vi",	"Russian":"ru",
		"Haitian (Creole)":	"ht",	"Cebuano":"ceb",
		"Galician"	:"gl",	"Serbian"	:"sr",
		"Dutch"		:"nl",	"Sinhala"	:"si",
		"Hill Mari"	:"mrj",	"Slovakian"	:"sk",
		"Greek"		:"el",	"Slovenian"	:"sl",
		"Georgian"	:"ka",	"Swahili"	:"sw",
		"Gujarati"	:"gu",	"Sundanese" :"su",
		"Danish"	:"da",	"Tajik"		:"tg",
		"Hebrew"	:"he",	"Thai"		:"th",
		"Yiddish"	:"yi",	"Tagalog"	:"tl",
		"Indonesian":"id",	"Tamil"		:"ta",
		"Irish"		:"ga",	"Tatar"		:"tt",
		"Italian"	:"it",	"Telugu"	:"te",
		"Icelandic"	:"is",	"Turkish"	:"tr",
		"Udmurt"	:"udm",
		"Kazakh"	:"kk",	"Uzbek"		:"uz",
		"Kannada"	:"kn",	"Ukrainian"	:"uk",
		"Catalan"	:"ca",	"Urdu"		:"ur",
		"Kyrgyz"	:"ky",	"Finnish"	:"fi",
		"French"	:"fr",
		"Korean"	:"ko",	"Hindi"		:"hi",
		"Xhosa"		:"xh",	"Croatian"	:"hr",
		"Latin"		:"la",	"Czech"		:"cs",
		"Latvian"	:"lv",	"Swedish"	:"sv",
		"Lithuanian":"lt",	"Scottish"	:"gd",
		"Luxembourgish":"lb","Estonian" :"et",
		"Malagasy"	:"mg",	"Esperanto"	:"eo",
		"Malay"		:"ms",	"Javanese"	:"jv",
		"Malayalam"	:"ml",	"Japanese"	:"ja"
	]
	var languagesArray: [String]?
	
	var picker: UIPickerView?
	
	override func viewDidLoad() {
		print("hello world")
		super.viewDidLoad()
		
		imageView.image = #imageLiteral(resourceName: "chair.jpg")
		
		languagesArray = Array(languages.keys)
		
		picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
		picker!.backgroundColor = UIColor.white
		
		picker!.showsSelectionIndicator = true
		picker!.delegate = self
		picker!.dataSource = self
		
		let toolBar = UIToolbar().ToolbarPicker(mySelect: #selector(HomeViewController.donePicker))
		
		fromLanguage.inputView = picker
		fromLanguage.inputAccessoryView = toolBar
		fromLanguage.isHidden = false
		fromLanguage.backgroundColor = UIColor.brown
		
	}
	@IBAction func whatIsThisButton(_ sender: Any) {
		guard let image = imageView.image else {
			print("no image found")
			return
		}
		callGoogleVision(with: image)
	}
	
	/*
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
	*/
	/*capture video (not functional right now
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
	}*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//translation stuff
	func BingAPICall(word: String) -> String{
		
		let toTranslate = word.replacingOccurrences(of: " ", with: "+")
		
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		//Yandex translate
		//let key = "a4466e949cde47e585edec2da6b2404b"
		var baseURL: String = "https://translate.yandex.net/api/v1.5/tr.json/translate"
		let key: String = "trnsl.1.1.20170206T214522Z.d28a904e6f61ba84.aac82dfc3243245cfe6429478e1e72257716f354"
		
		let inCode = languages[inputLanguage]!
		let outCode = languages[outputLanguage]!
		
		print("in code is \(inCode)")
		print("out code is \(outCode)")
		
		guard let tokenURL: URL = URL(string: "\(baseURL)?key=\(key)&lang=\(inCode)-\(outCode)&text=\(toTranslate)") else{
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
	@IBAction func translate(_ sender: Any) {
		
		guard let text = textInput.text?.replacingOccurrences(of: " ", with: "+") else{
			translationOutput.text = "invalid input"
			return
		}
		BingAPICall(word: text)
	}
	
	//picker view
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return languagesArray!.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return languagesArray![row]
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if component == 0{
			inputLanguage = languagesArray![row]
		}else if component == 1{
			outputLanguage = languagesArray![row]
		}else{
			print("error with picker")
		}
		fromLanguage.text = "\(inputLanguage) to \(outputLanguage)"
	}
	func donePicker(){
		print("resigning first responder")
			fromLanguage.resignFirstResponder()
	}
	
	
	
	//Google Vision
	
	
}
//Google Cloud API
extension HomeViewController{
	//key: AIzaSyAA-6h_mKGKUHptGHIoPQLIyR6DkmUk7Dc
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
	func callGoogleVision(with pickedImage: UIImage) {
		print("in call google vision")
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
		// Run the request on a background thread
		DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
	}
	func runRequestOnBackgroundThread(_ request: URLRequest) {
		print("calling google api in background")
		// run the request
		
		let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
			guard let data = data, error == nil else {
				print(error?.localizedDescription ?? "")
				return
			}
			self.analyzeResults(data)
		}
		task.resume()
	}
	func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
		UIGraphicsBeginImageContext(imageSize)
		image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		let resizedImage = UIImagePNGRepresentation(newImage!)
		UIGraphicsEndImageContext()
		return resizedImage!
	}
	func analyzeResults(_ dataToParse: Data) {
		print("analyzing results from google api call")
		// Update UI on the main thread
		DispatchQueue.main.async(execute: {
			// Use SwiftyJSON to parse results
			let json = JSON(data: dataToParse)
			let errorObj: JSON = json["error"]
			
			// Check for errors
			if (errorObj.dictionaryValue != [:]) {
				self.objectNameLabel.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
			} else {
				// Parse the response
				print(json)
				let responses: JSON = json["responses"][0]
				
				// Get label annotations
				let labelAnnotations: JSON = responses["labelAnnotations"]
				let numLabels: Int = labelAnnotations.count
				print("we have \(numLabels) labels for this image")
				var labels: Array<String> = []
				if numLabels > 0 {
					self.objectNameLabel.text = labelAnnotations[0]["description"].stringValue
					if let text = self.objectNameLabel.text?.replacingOccurrences(of: " ", with: "+"){
						self.translationOutput.text = self.BingAPICall(word: text)
						return
					}
				} else {
					self.objectNameLabel.text = "No labels found"
				}
			}
		})
		
	}
}













