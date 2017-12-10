//
//  ProdInfoDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 8..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic
import Material

class ProdInfoDialog: BaseViewController
{

	@IBOutlet weak var tfProdCode: UITextField!
	@IBOutlet weak var tfProdName: UITextField!
	@IBOutlet weak var tfReadCnt: UITextField!
	
	var ptcDataHandler : DataProtocol?
	
	var type : String?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
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
		tfProdCode.text	= ""
		tfProdName.text	= ""
		tfReadCnt.text	= "1"
		tfReadCnt.becomeFirstResponder()
		
		if(type! == "addProduct")
		{
			tfProdName.isEnabled = false
			tfProdName.backgroundColor = Color.grey.lighten3
		}
	}
	
	@IBAction func onConfirmClicked(_ sender: UIButton)
	{
		let clsDataRow : DataRow = DataRow()
		clsDataRow.addRow(name: "prodCode", value: tfProdCode.text ?? "")
		clsDataRow.addRow(name: "prodName", value: tfProdName.text ?? "")
		clsDataRow.addRow(name: "readCnt", value: tfReadCnt.text ?? "")
		
		let strtData = ReturnData(returnType: "addProduct", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		ptcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
		
	}
	@IBAction func onCloseClicked(_ sender: UIButton){
		self.dismiss(animated: true, completion: nil)
	}
}
