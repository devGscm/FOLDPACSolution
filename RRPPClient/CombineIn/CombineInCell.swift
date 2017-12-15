//
//  CombineInCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 15..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class CombineInCell: UITableViewCell
{
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblAssignCnt: UILabel!
	@IBOutlet weak var lblProcCnt: UILabel!
	@IBOutlet weak var lblRemainCnt: UILabel!
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
