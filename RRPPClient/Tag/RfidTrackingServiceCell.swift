//
//  RfidInspectCell.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class RfidTrackingServiceCell: UITableViewCell {
	
	@IBOutlet weak var lblProcessDate: UILabel!
	@IBOutlet weak var lblEventName: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
	@IBOutlet weak var lblRecycleCnt: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
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
