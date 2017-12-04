//
//  ProdMappingRfidCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class ProdMappingRfidCell: UITableViewCell
{
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
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


class ProdMappingItemCell: UITableViewCell
{
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool)
	{
		super.setSelected(selected, animated: animated)
	}
}
