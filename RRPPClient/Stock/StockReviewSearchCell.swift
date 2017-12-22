//
//  StockReviewSearchCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class StockReviewSearchCell: UITableViewCell
{
	@IBOutlet weak var lblStockReviewId: UILabel!
	@IBOutlet weak var lblReviewReqDate: UILabel!
	@IBOutlet weak var lblProdAssetEpcName: UILabel!
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
