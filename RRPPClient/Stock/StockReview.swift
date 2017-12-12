//
//  StockReviewProcess.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 1..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class StockReview: BaseViewController
{

    override func viewDidLoad()
	{
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*StockReview.viewDidAppear()")
		print("=========================================")
		super.viewDidAppear(animated)
	}
	
//	override func didUnload(to viewController: BaseViewController, completion: ((Bool) -> Void)? = nil)
//	{
//		print("=========================================")
//		print("*StockReview.didUnload()")
//		print("=========================================")
//		
//	}
	
	override func viewWillDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*StockReview.viewWillDisappear()")
		print("=========================================")
	}
}
