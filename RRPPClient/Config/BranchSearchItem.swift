//
//  BranchSearchItem.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 21..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class BranchSearchItem: UITableViewCell
{
    @IBOutlet weak var lblBranchCustType: UILabel!
    @IBOutlet weak var lblBranchName: UILabel!
    @IBOutlet weak var btnSelection: FABButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

