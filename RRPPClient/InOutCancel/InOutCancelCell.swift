//
//  InOutCancelProcessCell.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class InOutCancelCell: UITableViewCell
{
    @IBOutlet weak var lblTraceDate: UILabel!
    @IBOutlet weak var lblAssetEpcName: UILabel!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblEventCount: UILabel!
    @IBOutlet weak var lblBranchName: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

