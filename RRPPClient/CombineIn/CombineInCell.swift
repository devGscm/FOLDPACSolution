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
	@IBOutlet weak var lblWorkAssignCount: UILabel!
	@IBOutlet weak var lblProcCount: UILabel!
	@IBOutlet weak var lblRemainCount: UILabel!
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
