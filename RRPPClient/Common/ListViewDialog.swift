//
//  ListViewDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import FontAwesome

class ListViewDialog: UITableViewController
{
	struct ListViewItem
	{
		let itemCode : String
		let itemName : String
	}
	
	var selectedRow : ListViewItem {
		let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
		return mArcData[intSelectedIndex]
	}

	
	var contentHeight : CGFloat {
		get
		{
			return self.preferredContentSize.height
		}
		set
		{
			self.preferredContentSize.height = newValue
		}
	}
	
	
	var mArcData:Array<ListViewItem> = Array<ListViewItem>()
	
	func loadData(data:Array<ListViewItem>)
	{
		print("@@@@@@@@@@@")
		print(" ListViewDialog :\(mArcData.count) ")
		print("@@@@@@@@@@@")
		print("@@@@@@@@@@@")
		mArcData = data
		
		
		
		self.tableView.beginUpdates()
		self.tableView.insertRows(at: [IndexPath(row: mArcData.count - 1, section: 0)], with: .automatic)
		self.tableView.endUpdates()
	}
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		//self.preferredContentSize.height = 220
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return mArcData.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let tvcCell = UITableViewCell()
		let strtData = mArcData[indexPath.row]
		tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
		tvcCell.textLabel!.text = "\(strtData.itemName )"
		return tvcCell
	}
}

