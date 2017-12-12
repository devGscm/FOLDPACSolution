//
//  InOutCancelDetailCell.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 8..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class InOutCancelDetailCell: UITableViewCell
{
    
    @IBOutlet weak var lblRowNo: UILabel!
    @IBOutlet weak var lblProdAssetEpcName: UILabel!
    @IBOutlet weak var lblWorkAssignCnt: UILabel!
    @IBOutlet weak var lblProdCnt: UILabel!
    @IBOutlet weak var lblRemainCnt: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
}
