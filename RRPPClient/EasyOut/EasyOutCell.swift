//
//  EasyOutCell.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 19..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class EasyOutCell: UITableViewCell
{
    
    @IBOutlet weak var lblAssetName: UILabel!
    @IBOutlet weak var lblReadCount: UILabel!
    @IBOutlet weak var btnDetail: UIButton!    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
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
