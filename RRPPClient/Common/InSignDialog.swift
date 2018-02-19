//
//  InSignDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 16..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material

class InSignDialog: BaseViewController, YPSignatureDelegate
{
	var ptcDataHandler : DataProtocol?
	
	@IBOutlet weak var tfNoReadCount: UITextField!
	@IBOutlet weak var tfWorkerName: UITextField!
	@IBOutlet weak var tfRemark: UITextField!
	@IBOutlet weak var vwSign: YPDrawSignatureView!
	
    var clsDataRow : DataRow? = DataRow()
	
	func loadData( dataRow: DataRow)
	{
		self.clsDataRow = dataRow
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		super.initController()
		
		initViewControl()
	}
	
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.releaseController()
		super.viewDidDisappear(animated)
	}
	
	func initViewControl()
	{
		vwSign.delegate = self

        tfNoReadCount?.text    = clsDataRow?.getString(name: "noReadCount") ?? ""
        tfWorkerName?.text    = clsDataRow?.getString(name: "workerName") ?? ""
        tfRemark?.text        = clsDataRow?.getString(name: "remark") ?? ""
        
       
	}
	
	@IBAction func onClearClicked(_ sender: UIButton)
	{
		self.vwSign.clear()
        tfNoReadCount?.text = clsDataRow?.getString(name: "noReadCount") ?? ""
        tfWorkerName?.text  = clsDataRow?.getString(name: "workerName") ?? ""
        tfRemark?.text      = clsDataRow?.getString(name: "remark") ?? ""
	}
    
	
	@IBAction func onConfirmClicked(_ sender: UIButton)
	{
        clsDataRow = nil
        clsDataRow  = DataRow()
		clsDataRow?.addRow(name: "noReadCount", value: tfNoReadCount.text ?? "")
		clsDataRow?.addRow(name: "workerName", value: tfWorkerName.text ?? "")
		clsDataRow?.addRow(name: "remark", value: tfRemark.text ?? "")
	
		if let imgSign = self.vwSign.getSignature()
		{
			let strSignData = imgSign.base64(format: .png) ?? ""
			clsDataRow?.addRow(name: "signData", value: strSignData)
			self.vwSign.clear()
		}
		let strtData = ReturnData(returnType: "inSignDialog", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		ptcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func onCloseClicked(_ sender: UIButton)
	{
		self.dismiss(animated: true, completion: nil)
	}
	
	func didStart()
	{
		print("Started Drawing")
	}
	
	// didFinish() is called rigth after the last touch of a gesture is registered in the view.
	// Can be used to enabe scrolling in a scroll view if it has previous been disabled.
	func didFinish()
	{
		print("Finished Drawing")
	}
}

