//
//  BaseUIController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class BaseViewController : UIViewController
{
	func initController()
	{
		print("*BaseViewController.initController()")
	}
	
	func releaseController()
	{
		print("*BaseViewController.releaseController()")
	}
	
	func showSnackbar(message : String)
	{
		showSnackbar(message: message, visibleDelay: 0, hiddenDelay: 2)
	}
	func showSnackbar(message : String, visibleDelay: TimeInterval, hiddenDelay: TimeInterval)
	{
		DispatchQueue.main.async
		{
			guard let clsController = self.snackbarController else {
				return
			}
			clsController.snackbar.text = message
			_ = clsController.animate(snackbar: .visible, delay: visibleDelay)
			_ = clsController.animate(snackbar: .hidden, delay: hiddenDelay)
		}
	}
}



