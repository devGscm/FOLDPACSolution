//
//  IdentificationSystemDialog.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 11. 29..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import FontAwesome

class IdentificationSystemDialog: UITableViewController
{
    var mLstIdentificationList:Array<IdentificationSystem> = Array<IdentificationSystem>()
    
    struct IdentificationSystem
    {
        let IdentificationSystemType:Int
        let IdentificationSystemName:String
    }
    
    var selectedRow : IdentificationSystem {
        let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
        return mLstIdentificationList[intSelectedIndex]
    }
    
    
    
    func loadData(lstIdentificationSystem:Array<IdentificationSystem>)
    {
        mLstIdentificationList = lstIdentificationSystem
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: mLstIdentificationList.count - 1, section: 0)], with: .automatic)
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
        return mLstIdentificationList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tvcCell = UITableViewCell()
        let strtIdentificationList = mLstIdentificationList[indexPath.row]
        tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
        tvcCell.textLabel!.text = "\(String.fontAwesomeIcon(name: .bolt)) \(strtIdentificationList.IdentificationSystemName)"
        return tvcCell
    }
    
    
    
    
}

