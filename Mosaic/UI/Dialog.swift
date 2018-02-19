//
//  Dialog.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 11. 23..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


public class Dialog
{
	/* 사용법
	Dialog.show(container: self, title: "테스트", message: "해보시다.", okTitle:"OK", okHandler: doOkActionHandler)
	
	func doOkActionHandler(action : UIAlertAction)
	{
	print("@@@@@@@@@@@@@@@@@@")
	print("doTest")
	print("@@@@@@@@@@@@@@@@@@")
	} */
	
	public static func show(container: UIViewController, title: String?, message: String)
	{
		let okTitle = "OK"
		show(container: container, viewController: nil, title: title, message: message, okTitle: okTitle, okHandler: nil, cancelTitle : nil, cancelHandler: nil)
	}

	public static func show(container: UIViewController, title: String?, message: String, okHandler: ((UIAlertAction) -> Void)?)
	{
		let okTitle = "OK"
		show(container: container, viewController: nil, title: title, message: message, okTitle: okTitle, okHandler: okHandler, cancelTitle : nil, cancelHandler: nil)
	}
	
	public static func show(container: UIViewController, title: String?, message: String, okTitle : String)
	{
		show(container: container, viewController: nil, title: title, message: message, okTitle: okTitle, okHandler: nil, cancelTitle : nil, cancelHandler: nil)
	}
	
	public static func show(container: UIViewController, title: String?, message: String, okTitle : String, okHandler: ((UIAlertAction) -> Void)?)
	{
		show(container: container, viewController: nil, title: title, message: message, okTitle: okTitle, okHandler: okHandler, cancelTitle : nil, cancelHandler: nil)
	}
	
	public static func show(container: UIViewController, viewController: UIViewController?, title: String?, message: String,
								okTitle : String, okHandler: ((UIAlertAction) -> Void)?,
								cancelTitle : String?, cancelHandler: ((UIAlertAction) -> Void)?)
	{

		DispatchQueue.main.async
		{
			let acDialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

			if(viewController != nil)
			{
				print("@@@@@@ set value @@@@@")
				acDialog.setValue(viewController, forKeyPath: "contentViewController")
			}
			
			if(cancelTitle?.isEmpty == false)
			{
				let aaCancelAction = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.default, handler: cancelHandler)
				acDialog.addAction(aaCancelAction)
			}
			let aaOkAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.default, handler: okHandler)
			acDialog.addAction(aaOkAction)
			
			container.present(acDialog, animated: true, completion: nil)
		}
	}
	
}
