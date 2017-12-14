//
//  RfidInspectCell.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class RfidInspectCell: UITableViewCell {

	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblEpcUrn: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
	@IBOutlet weak var lblReadTime: UILabel!
	@IBOutlet weak var lblResult: UILabel!
	@IBOutlet weak var chkYN: Checkbox!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
