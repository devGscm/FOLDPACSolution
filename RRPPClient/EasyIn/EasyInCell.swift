//
//  EasyInCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 18..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class EasyInCell: UITableViewCell
{
	
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblReadCount: UILabel!
	@IBOutlet weak var btnDetail: UIButton!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool)
	{
		super.setSelected(selected, animated: animated)
	}
}
