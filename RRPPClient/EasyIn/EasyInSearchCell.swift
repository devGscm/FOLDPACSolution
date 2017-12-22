//
//  EasyInSearchCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 18..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class EasyInSearchCell: UITableViewCell
{
	@IBOutlet weak var lblSaleWorkId: UILabel!
	@IBOutlet weak var lblResaleBranchName: UILabel!
	@IBOutlet weak var lblProdAssetEpcName: UILabel!
	@IBOutlet weak var lblOrderReqCnt: UILabel!
	@IBOutlet weak var btnSelection: UIButton!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}
	
	
	override func setSelected(_ selected: Bool, animated: Bool)
	{
		//super.setSelected(selected, animated: animated)
		if(selected)
		{
			contentView.backgroundColor = UIColor.groupTableViewBackground
		}
		else
		{
			contentView.backgroundColor = UIColor.white
		}
	}
}

