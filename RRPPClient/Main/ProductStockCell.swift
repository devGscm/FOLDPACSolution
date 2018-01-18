//
//  ProductStockCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2018. 1. 18..
//  Copyright © 2018년 MORAMCNT. All rights reserved.
//

import UIKit

class ProductStockCell: UITableViewCell
{
	@IBOutlet weak var lblProdAssetName: UILabel!
	@IBOutlet weak var lblMoveStockCnt: UILabel!
	@IBOutlet weak var lblStockCnt: UILabel!
	@IBOutlet weak var lblReleaseCnt: UILabel!

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
