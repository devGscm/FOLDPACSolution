//
//  String.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


extension String
{
	static func className(_ aClass: AnyClass) -> String
	{
		return NSStringFromClass(aClass).components(separatedBy: ".").last!
	}
	
	func substring(_ from: Int) -> String {
		return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
	}
	
	var length: Int {
		return self.characters.count
	}
}
