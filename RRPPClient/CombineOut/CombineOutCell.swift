//
//  CombineOutCell.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class CombineOutCell: UITableViewCell
{
    @IBOutlet weak var lblAssetEpcName: UILabel!    //유형
    @IBOutlet weak var lblAssignCnt: UILabel!       //출고예정
    @IBOutlet weak var lblProcCnt: UILabel!         //처리량
    @IBOutlet weak var lblRemainCnt: UILabel!       //미처리량
    @IBOutlet weak var btnSelection: UIButton!      //선택-버튼
    
    
    
    
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
