//
//  RfidReaderDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import FontAwesome

class RfidReaderDialog: UITableViewController, SwingProtocolProtocol
{
    var swing : SwingProtocol?
    
    var selectedRow : ReaderDevInfo? {
        let intSelectedIndex = self.tableView.indexPathForSelectedRow?.row ?? 0
        return mLstRfidReader[intSelectedIndex]
    }
    var mLstRfidReader = Array<ReaderDevInfo>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.preferredContentSize.height = 220
        
        self.swing = SwingProtocol.sharedInstace() as? SwingProtocol
        self.swing!.delegate = self as SwingProtocolProtocol
        self.swing?.swingapi.scan()
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
        let strtReaderDevInfo = mLstRfidReader[indexPath.row]
        tvcCell.textLabel?.font = UIFont.fontAwesome(ofSize: 13)
        tvcCell.textLabel!.text = "\(String.fontAwesomeIcon(name: .bolt)) \(strtReaderDevInfo.name)"
        return tvcCell
    }
    
    public func readerStatus() -> Bool {
        print("readerStatus")
        return true
    }
    
    public func reciveData(_ result: String!) {
        print("reciveData")
    }
    
    public func discoverStop()
    {
        self.swing?.swingapi.stop()
    }
    
    public func swing_didDiscover(_ dev: SwingDevice!) {
        let rederInfo = ReaderDevInfo( id:  dev.identifier, name: dev.name, macAddr: dev.macaddress)
        if (self.mLstRfidReader.contains(where: { (item) -> Bool in
            item.id ==  dev.identifier
        }) == false)
        {
            self.mLstRfidReader.append(rederInfo)
            self.tableView.reloadData()
        }
    }
    
}

