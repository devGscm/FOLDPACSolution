//
//  RfidReaderDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import FontAwesome

class RfidReaderDialog: UITableViewController
{
	struct RfidReader
	{
		let mIntType : Int
		let mStrName : String
	}

	var selectedRow : RfidReader {
		let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
		return mLstRfidReader[intSelectedIndex]
	}
	
	var mLstRfidReader:Array<RfidReader> = Array<RfidReader>()

	func loadData(lstRfidReader:Array<RfidReader>)
	{
		mLstRfidReader = lstRfidReader
		
		self.tableView.beginUpdates()
		self.tableView.insertRows(at: [IndexPath(row: mLstRfidReader.count - 1, section: 0)], with: .automatic)
		self.tableView.endUpdates()
	}

	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		self.preferredContentSize.height = 220
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return mLstRfidReader.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let tvcCell = UITableViewCell()
		let strtRfidReader = mLstRfidReader[indexPath.row]
		tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
		tvcCell.textLabel!.text = "\(String.fontAwesomeIcon(name: .bolt)) \(strtRfidReader.mStrName )"
		return tvcCell
	}
	

}
