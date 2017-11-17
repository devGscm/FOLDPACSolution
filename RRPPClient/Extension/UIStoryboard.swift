//
//  UIStoryboard.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 10..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit

extension UIStoryboard
{
	class func viewController(identifier: String) -> UIViewController
	{
		return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
	}
}