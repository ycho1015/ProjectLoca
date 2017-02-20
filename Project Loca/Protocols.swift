//
//  Protocols.swift
//  Project Loca
//
//  Created by Tyler Angert on 2/17/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import Foundation
import UIKit

//Called from the MainVC -> Data Interface
protocol DataInterfaceDelegate {
    func didReceiveData(data: Data)
}

//Called from Data Interface -> ImageRecognition
protocol ImageRecognitionDelegate {
    func didReceiveImage(image: UIImage)
}


//Called from Data Intefcace -> Translation
protocol TranslationDelegate {
    func didReceiveText(input: String)
}

protocol UpdateDataInterfaceDelegate {
    func didFinishImageRecognition()
}


protocol LanguageSetupDelegate {
    func didChangeLanguage(language: String)
}

protocol UpdateUIDelegate {
    func willReceiveImage(image: UIImage)
    func willReceiveTranslation(input: String)
}
