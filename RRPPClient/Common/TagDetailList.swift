//
//  TagList.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 29..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

class TagDetailList: UIViewController, UITableViewDataSource, UITableViewDelegate
{

	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
	@IBOutlet weak var lblEpcUrn: UILabel!
	@IBOutlet weak var lblReadTime: UILabel!
	
	@IBOutlet weak var tvTagDetailList: UITableView!
	
	var arcDataRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var boolSortAsc	= true
	
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
		initViewControl()
        self.hideKeyboardWhenTappedAround()
	}
	
	func initViewControl()
	{
		let tgrAssetName = UITapGestureRecognizer(target: self, action: #selector((onAssetNameClicked)))
		self.lblAssetName.addGestureRecognizer(tgrAssetName)
		
		let tgrSerialNo = UITapGestureRecognizer(target: self, action: #selector((onSerialNoClicked)))
		self.lblSerialNo.addGestureRecognizer(tgrSerialNo)
		
		let tgrEpcUrn = UITapGestureRecognizer(target: self, action: #selector((onEpcUrnClicked)))
		self.lblEpcUrn.addGestureRecognizer(tgrEpcUrn)
		
		let tgrReadTime = UITapGestureRecognizer(target: self, action: #selector((onReadTimeClicked)))
		self.lblReadTime.addGestureRecognizer(tgrReadTime)
		
		// 테이블뷰 셀표시 지우기
		tvTagDetailList.tableFooterView = UIView(frame: CGRect.zero)
	}

	@objc func onAssetNameClicked(sender: UITapGestureRecognizer)
	{
		print("onAssetNameClicked")

		if(boolSortAsc == true)
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getAssetName() > clsTagInfo2.getAssetName()
			})
		}
		else
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getAssetName() < clsTagInfo2.getAssetName()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.self.tvTagDetailList?.reloadData() }
		

	}
	
	@objc func onSerialNoClicked(sender: UITapGestureRecognizer)
	{
		print("onSerialNoClicked")
		if(boolSortAsc == true)
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return Int(clsTagInfo1.getSerialNo())! > Int(clsTagInfo2.getSerialNo())!
			})
		}
		else
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return Int(clsTagInfo1.getSerialNo())! < Int(clsTagInfo2.getSerialNo())!
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.self.tvTagDetailList?.reloadData() }
	}

	@objc func onEpcUrnClicked(sender: UITapGestureRecognizer)
	{
		print("onEpcUrnClicked")
		
		if(boolSortAsc == true)
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getEpcUrn() > clsTagInfo2.getEpcUrn()
			})
		}
		else
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getEpcUrn() < clsTagInfo2.getEpcUrn()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.self.tvTagDetailList?.reloadData() }
		
	}
	
	@objc func onReadTimeClicked(sender: UITapGestureRecognizer)
	{
		print("onReadTimeClicked")
		if(boolSortAsc == true)
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getReadTime() > clsTagInfo2.getReadTime()
			})
		}
		else
		{
			self.arcDataRows = self.arcDataRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getReadTime() < clsTagInfo2.getReadTime()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.self.tvTagDetailList?.reloadData() }
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
