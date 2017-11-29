//
//  TagList.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 29..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class TagDetailList: UIViewController, UITableViewDataSource, UITableViewDelegate
{

	@IBOutlet weak var tvTagDetailList: UITableView!

	var arcDataRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	func loadData(arcTagInfo : Array<RfidUtil.TagInfo>)
	{
		self.arcDataRows = arcTagInfo
		
		self.tvTagDetailList?.beginUpdates()
		self.tvTagDetailList?.insertRows(at: [IndexPath(row: self.arcDataRows.count - 1, section: 0)], with: .automatic)
		self.tvTagDetailList?.endUpdates()
	}
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arcDataRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:TagDetailCell = tableView.dequeueReusableCell(withIdentifier: "tvcTagDetailCell", for: indexPath) as! TagDetailCell
		let clsTagInfo = arcDataRows[indexPath.row]
		let strReadTimeDate = clsTagInfo.getReadTime()
		let strDisplayReadTime = DateUtil.getConvertFormatDate(date: strReadTimeDate, srcFormat: "yyyyMMddHHmmss", dstFormat: "HH:mm:ss")
	
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblSerialNo.text = clsTagInfo.getSerialNo()
		objCell.lblEpcUrn.text = clsTagInfo.getEpcUrn()
		objCell.lblReadTime.text = strDisplayReadTime
		
		return objCell
	}

	@IBAction func onCloseClicked(_ sender: UIButton)
	{
		self.dismiss(animated: true, completion: nil)
	}
}
