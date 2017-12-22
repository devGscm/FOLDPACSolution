//
//  CombineOutWorkListCell.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 14..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class CombineOutWorkListCell: UITableViewCell
{
    @IBOutlet weak var lblSaleWorkId: UILabel!          //송장번호
    @IBOutlet weak var lblAssetEpcName: UILabel!        //유형
    @IBOutlet weak var lblOrderReqDate: UILabel!        //출고예정일
    @IBOutlet weak var lblWorkAssignCnt: UILabel!       //출고예정량
    @IBOutlet weak var lblResaleBranchName: UILabel!    //입고처
    @IBOutlet weak var lblResaleAddr: UILabel!          //입고처주소
    @IBOutlet weak var btnSelection: UIButton!          //선택
    
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

