//
//  ProdMappingRfidCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit


// RFID
class MappingRfidCell: UITableViewCell
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


// 상품
class MappingProdCell: UITableViewCell
{
	@IBOutlet weak var lblProdCode: UILabel!
	@IBOutlet weak var lblProdName: UILabel!
	@IBOutlet weak var lblProdReadCnt: UILabel!
	@IBOutlet weak var btnDelete: UIButton!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool)
	{
		super.setSelected(selected, animated: animated)
	}
}
