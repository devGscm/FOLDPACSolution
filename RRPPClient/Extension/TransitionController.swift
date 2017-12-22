//
//  TransitionController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 12..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import UIKit
import Material

public extension TransitionController
{
	func move(to viewController: UIViewController, completion: ((Bool) -> Void)? = nil)
	{
		print("=========================================")
		print("*TransitionController.move(BaseViewController)")
		print("=========================================")

	
		if(rootViewController is BaseViewController)
		{
			let clsOldController = rootViewController as? BaseViewController
			
			// 이전 뷰컨트롤에서 언로드 처리
			// - 구현이 안되어 있다면 아래 getUnload()시 반드시 true로 리턴된다.
			clsOldController?.didUnload(to:viewController, completion: completion)
			
			// 이전 뷰컨트롤에서 언로드가 되어있는경우에만 현재 뷰컨트롤로 이동한다.
			if(clsOldController?.getUnload() == true)
			{
				transition(to: viewController, completion: completion)
			}
		}
	
		if(rootViewController is BaseTableViewController)
		{
			let clsOldController = rootViewController as? BaseTableViewController
			// 이전 뷰컨트롤에서 언로드 처리
			// - 구현이 안되어 있다면 아래 getUnload()시 반드시 true로 리턴된다.
			clsOldController?.didUnload(to:viewController, completion: completion)
			
			// 이전 뷰컨트롤에서 언로드가 되어있는경우에만 현재 뷰컨트롤로 이동한다.
			if(clsOldController?.getUnload() == true)
			{
				transition(to: viewController, completion: completion)
			}
		}
	}
}
