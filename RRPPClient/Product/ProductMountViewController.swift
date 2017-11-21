//
//  ProductMountViewController.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 10..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material

class ProductMountViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Color.grey.lighten5
		
		//prepareToolbar()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
extension ProductMountViewController
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		
		tc.toolbar.title = "RRPP TRA"
		tc.toolbar.detail = "팔렛트 장착"
	}
}


