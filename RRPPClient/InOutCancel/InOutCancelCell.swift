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
    @IBOutlet weak var lblRowNo: UILabel!
    @IBOutlet weak var lblWorkDate: UILabel!
    @IBOutlet weak var lblInoutCustName: UILabel!
    @IBOutlet weak var lblIoTypeName: UILabel!
    @IBOutlet weak var lblWorkId: UILabel!
    @IBOutlet weak var lblCompleteWorkCnt: UILabel!
    @IBOutlet weak var btnSelection: UIButton!
    @IBOutlet weak var lblWorkTime: UILabel!

    @IBOutlet weak var btnAssetEpcName: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

