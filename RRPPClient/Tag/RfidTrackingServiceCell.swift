//
//  RfidInspectCell.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class RfidTrackingServiceCell: UITableViewCell {
	
	@IBOutlet weak var lblProcessDate: UILabel!
	@IBOutlet weak var lblEventName: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
	@IBOutlet weak var lblRecycleCnt: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
