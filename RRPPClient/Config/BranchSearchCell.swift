//
//  BranchSearchItem.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 21..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class BranchSearchCell: UITableViewCell
{
    @IBOutlet weak var lblBranchCustType: UILabel!
	@IBOutlet weak var lblBranchId: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
    @IBOutlet weak var btnSelection: FABButton!
    
    override func awakeFromNib()
	{
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
	{
        super.setSelected(selected, animated: animated)
    }
}

