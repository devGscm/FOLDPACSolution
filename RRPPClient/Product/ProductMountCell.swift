//
//  ProductMountCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class ProductMountCell: UITableViewCell
{
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblReadCount: UILabel!
 	@IBOutlet weak var btnDetail: UIButton!
	
	override func awakeFromNib()
	{
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
