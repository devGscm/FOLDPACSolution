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
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblUserName: UILabel!
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
		//view.backgroundColor = Color.grey.lighten5
		prepareToolbar()
		initViewControl()
	}
	

	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{
		// For Test
		AppContext.sharedManager.getUserInfo().setEncryptId(strEncryptId: "xxOxOsU93/PvK/NN7DZmZw==")
		AppContext.sharedManager.getUserInfo().setCorpId(strCorpId: "logisallcm")
		AppContext.sharedManager.getUserInfo().setBranchId(branchId: "160530000045")
		AppContext.sharedManager.getUserInfo().setBranchCustId(branchCustId: "160530000071")
		AppContext.sharedManager.getUserInfo().setUserLang(strUserLang: "KR")
	
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
		
		// TODO  : test
		
		let clsTagInfo1 = RfidUtil.TagInfo()
		clsTagInfo1.setYymm(strYymm: "1506")
		clsTagInfo1.setSeqNo(strSeqNo: "68")
		clsTagInfo1.setEpcCode(strEpcCode: "3312D58E4581004000000044")
		clsTagInfo1.setEpcUrn(strEpcUrn: "grai:0.95100043.1025.68")
		clsTagInfo1.setAssetEpc(strAssetEpc: "951000431025")
		getRfidData(clsTagInfo: clsTagInfo1)

		let clsTagInfo2 = RfidUtil.TagInfo()
		clsTagInfo2.setYymm(strYymm: "1506")
		clsTagInfo2.setSeqNo(strSeqNo: "69")
		clsTagInfo2.setEpcCode(strEpcCode: "3312D58E4581004000000045")
		clsTagInfo2.setEpcUrn(strEpcUrn: "grai:0.95100043.1025.69")
		clsTagInfo2.setAssetEpc(strAssetEpc: "951000431025")
		getRfidData(clsTagInfo: clsTagInfo2)

		let clsTagInfo3 = RfidUtil.TagInfo()
		clsTagInfo3.setYymm(strYymm: "1506")
		clsTagInfo3.setSeqNo(strSeqNo: "70")
		clsTagInfo3.setEpcCode(strEpcCode: "3312D58E4581004000000046")
		clsTagInfo3.setEpcUrn(strEpcUrn: "grai:0.95100043.1025.70")
		clsTagInfo3.setAssetEpc(strAssetEpc: "951000431025")
		getRfidData(clsTagInfo: clsTagInfo3)
		
		
	}
	
	// 주문선택
	@IBAction func onMakeOrderIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segProductOrderSearch", sender: self)
	}

	// 데이터를 clear한다.
	func clearTagData()
	{
		
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
		if(clsTagInfo != nil)
		{
			
		}
	}
	
	func sendData(strMakeOrderid: String, strMakeLotId: String, strWorkerName: String, strRemark: String)
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


