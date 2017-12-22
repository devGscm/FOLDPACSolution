//
//  TagDetailCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 29..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class TagDetailCell: UITableViewCell
{
    @IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
	@IBOutlet weak var lblEpcUrn: UILabel!
	@IBOutlet weak var lblReadTime: UILabel!
	
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
