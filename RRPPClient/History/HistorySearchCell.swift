//
//  HistorySearchCell.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 2..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class HistorySearchCell: UITableViewCell
{
	@IBOutlet weak var lblTraceDate: UILabel!
	@IBOutlet weak var lblAssetEpcName: UILabel!
	@IBOutlet weak var lblEventName: UILabel!
	@IBOutlet weak var lblEventCount: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
    @IBOutlet weak var lblToFromBranchName: UILabel!
    
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
