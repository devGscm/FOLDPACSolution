//
//  ProductMountViewController.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 10..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material
import Mosaic

class ProductMountViewController: UIViewController, DataProtocol
{

	@IBOutlet weak var btnRfidReader: UIButton!

	@IBOutlet weak var btnMakeOrderId: UIButton!
	@IBOutlet weak var lblOrderCustName: UILabel!
	@IBOutlet weak var lblOrderCount: UILabel!
	@IBOutlet weak var lblMakeLotId: UITextField!
	
	var strMakeOrderId: String?
	var intOrderWorkCnt: Int = 0
	var intOrderReqCnt: Int = 0
	var strProdAssetEpc: String?
	var intCurOrderWorkCnt: Int = 0
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		view.backgroundColor = Color.grey.lighten5
		
	// For Test
		AppContext.sharedManager.getUserInfo().setEncryptId(strEncryptId: "xxOxOsU93/PvK/NN7DZmZw==")
		AppContext.sharedManager.getUserInfo().setCorpId(strCorpId: "logisallcm")
		AppContext.sharedManager.getUserInfo().setBranchId(branchId: "160530000045")
		AppContext.sharedManager.getUserInfo().setBranchCustId(branchCustId: "160530000071")
		AppContext.sharedManager.getUserInfo().setUserLang(strUserLang: "KR")
		
		
		prepareToolbar()
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segProductOrderSearch")
		{
			if let clsDialog = segue.destination as? ProductOrderSearch
			{
				clsDialog.ptcDataHandler = self
			}
		}
	}
	
	// 팝업 다이얼로그로 부터 데이터 수신
	func recvData( returnData : ReturnData)
	{
		if(returnData.returnType == "productOrderSearch")
		{
			if(returnData.returnRawData != nil)
			{
				clearUserInterfaceData()
				
				let clsDataRow = returnData.returnRawData as! DataRow
				strMakeOrderId	= clsDataRow.getString(name: "makeOrderId")
				intOrderWorkCnt	= clsDataRow.getInt(name: "orderWorkCnt") ?? 0
				intOrderReqCnt	= clsDataRow.getInt(name: "orderReqCnt") ?? 0
				strProdAssetEpc = clsDataRow.getString(name: "prodAssetEpc")
				intCurOrderWorkCnt = intOrderWorkCnt
				
				self.btnMakeOrderId.setTitle(strMakeOrderId, for: .normal)
				self.lblOrderCustName.text = clsDataRow.getString(name: "orderCustName")
				self.lblOrderCount.text = "\(intOrderWorkCnt)/\(intOrderReqCnt)"
				
				// 새로운 발주번호가 들어ㅗ면 기존 데이터를 삭제한다.
				clearTagData()
			}
		}
	}

	
	@IBAction func onRfidReaderClicked(_ sender: UIButton)
	{
	}
	
	// 주문선택
	@IBAction func onMakeOrderIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segProductOrderSearch", sender: self)
	}

	func clearTagData()
	{
		
	}
	
	func clearUserInterfaceData()
	{
		intOrderWorkCnt	= 0
		intCurOrderWorkCnt = 0
		intOrderReqCnt	= 0

		strMakeOrderId	= nil
		strProdAssetEpc = nil
		
		
		self.btnMakeOrderId.setTitle("", for: .normal)
		self.lblOrderCustName.text = ""
		self.lblOrderCount.text = ""
		self.lblMakeLotId.text = ""

	}
}
extension ProductMountViewController
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		
		tc.toolbar.title = "RRPP TRA"
		tc.toolbar.detail = "팔렛트 장착"
	}
}


