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
	@IBOutlet weak var tfProdReadCnt: UITextField!
	
	var ptcDataHandler : DataProtocol?
	
	var segueType : String?
	
	var itemInfo : ItemInfo?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
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
		print("==========================================")
		print("*initViewControl()")
		print("@@@@@@@@@@@ segueType:\(segueType!)")
		print("==========================================")
		tfProdCode.text	= ""
		tfProdName.text	= ""
		tfProdReadCnt.text	= "1"
		tfProdReadCnt.becomeFirstResponder()
		
		if(segueType! == "addProduct")
		{
			tfProdName.isEnabled = false
			tfProdName.backgroundColor = Color.grey.lighten3
		}
		else if(segueType! == "editProduct")
		{
			tfProdCode.isEnabled = false
			tfProdCode.backgroundColor = Color.grey.lighten3
			
			tfProdName.isEnabled = false
			tfProdName.backgroundColor = Color.grey.lighten3
			
			tfProdCode.text = itemInfo?.getProdCode()
			tfProdName.text	= itemInfo?.getProdName()
			tfProdReadCnt.text	= itemInfo?.getProdReadCnt()
		}
	
	}
	
	@IBAction func onConfirmClicked(_ sender: UIButton)
	{
		let clsDataRow : DataRow = DataRow()
		clsDataRow.addRow(name: "prodCode", value: tfProdCode.text ?? "")
		clsDataRow.addRow(name: "prodName", value: tfProdName.text ?? "")
		clsDataRow.addRow(name: "prodReadCnt", value: tfProdReadCnt.text ?? "")
		
		let strtData = ReturnData(returnType: segueType!, returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		ptcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
		
	}
	@IBAction func onCloseClicked(_ sender: UIButton){
		self.dismiss(animated: true, completion: nil)
	}
}
