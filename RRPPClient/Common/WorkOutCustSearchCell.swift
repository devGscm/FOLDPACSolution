//
//  WorkEasyOutCustSearchCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class WorkOutCustSearchCell: UITableViewCell
{
    @IBOutlet weak var lblParentCustName: UILabel!
    @IBOutlet weak var lblCustTypeName: UILabel!
    @IBOutlet weak var lblCustId: UILabel!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var btnSelection: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
