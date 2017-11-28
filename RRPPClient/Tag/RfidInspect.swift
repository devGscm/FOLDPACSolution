//
//  RfidInspectController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class RfidInspect: UIViewController
{

    override func viewDidLoad()
	{
        super.viewDidLoad()
    }

}

extension RfidInspect
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else
		{
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")
	}
}

