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
	
	var selectedRow : ListViewItem? {
		let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
		if(arcData.count > 0)
		{
			return arcData[intSelectedIndex]
		}
		return nil
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
	
    var strSelectedItem = ""
	var arcData:Array<ListViewItem> = Array<ListViewItem>()
	
//    func loadData(data:Array<ListViewItem>)
//    {
//        print("@@@@@@@@@@@")
//        print(" ListViewDialog :\(arcData.count) ")
//        print("@@@@@@@@@@@")
//        arcData = data
//
//        self.tableView.beginUpdates()
//        self.tableView.insertRows(at: [IndexPath(row: arcData.count - 1, section: 0)], with: .automatic)
//        self.tableView.endUpdates()
//    }
    
    func loadData(data: Array<ListViewItem>, selectedItem: String)
    {
        print("@@@@@@@@@@@")
        print(" ListViewDialog :\(arcData.count) ")
        print("@@@@@@@@@@@")
        arcData = data
        strSelectedItem = selectedItem

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: arcData.count - 1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }
	
	
	override func viewDidLoad()
	{
        print("@@@@@@@@@@@")
        print(" ListView viewDidLoad")
        print("@@@@@@@@@@@")
		super.viewDidLoad()
		//self.preferredContentSize.height = 220
        self.hideKeyboardWhenTappedAround()
	}
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if(strSelectedItem.isEmpty == false)
        {
            for (index, strtData) in arcData.enumerated()
            {
                if(strtData.itemCode == strSelectedItem)
                {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                    break
                }
            }
        }
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return arcData.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let tvcCell = UITableViewCell()
		let strtData = arcData[indexPath.row]
		tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
		tvcCell.textLabel!.text = "\(strtData.itemName )"
		return tvcCell
	}
}

