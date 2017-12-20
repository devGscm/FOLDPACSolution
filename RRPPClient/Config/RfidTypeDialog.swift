//
//  RfidReaderDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import FontAwesome

class RfidTypeDialog: UITableViewController
{
    var selectedRow : ReaderType {
        let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
        return mLstRfidType[intSelectedIndex]
    }
    
    var mLstRfidType:Array<ReaderType> = Array<ReaderType>()
    
    func loadData(lstRfidReader:Array<ReaderType>)
    {
        mLstRfidType = lstRfidReader
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: mLstRfidType.count - 1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.preferredContentSize.height = 220
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return mLstRfidType.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tvcCell = UITableViewCell()
        let strtRfidReader = mLstRfidType[indexPath.row]
        tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
        tvcCell.textLabel!.text = "\(String.fontAwesomeIcon(name: .bolt)) \(strtRfidReader )"
        return tvcCell
    }
}


