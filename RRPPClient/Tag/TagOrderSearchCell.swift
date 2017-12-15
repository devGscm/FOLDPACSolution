//
//  ProductOrderSearchCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 11..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class TagOrderSearchCell: UITableViewCell
{
	@IBOutlet weak var lblOrderDate: UILabel!
	@IBOutlet weak var lblOrderReqCnt: UILabel!
	@IBOutlet weak var lblOrderCustName: UILabel!
	@IBOutlet weak var lblIssueOrderId: UILabel!
	@IBOutlet weak var lblAssetEpcName: UILabel!
	@IBOutlet weak var lblDeliBranchName: UILabel!
	@IBOutlet weak var btnSelection: UIButton!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
	}
	
}

