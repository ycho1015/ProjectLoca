//
//  toolbar.extensions.swift
//  Project Loca
//
//  Created by Jake Cronin on 2/12/17.
//  Copyright © 2017 TeamMilton370. All rights reserved.
//

import Foundation
import UIKit

extension UIToolbar {
	
	func ToolbarPicker(mySelect : Selector) -> UIToolbar {
		
		let toolBar = UIToolbar()
		
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.tintColor = UIColor.black
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		toolBar.setItems([ spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		return toolBar
	}
	
}
