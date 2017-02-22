//
//  testCompletionHandler.swift
//  
//
//  Created by Jake Cronin on 2/20/17.
//
//

import Foundation


class testCompletionHandler: NSObject{
	override init() {
		super.init
	}
	func testCompletionHandler(input: String, completion: (_ result: String) -> Void){
		print("in the completion handler doing some shit")
		completion("success")
	}
}
