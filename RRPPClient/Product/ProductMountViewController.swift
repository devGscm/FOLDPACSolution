//
//  ProductMount.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 10..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material
import Mosaic

class ProductMount: BaseRfidViewController, DataProtocol
{
	@IBOutlet weak var tvProductMount: UITableView!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!

	@IBOutlet weak var btnMakeOrderId: UIButton!
	@IBOutlet weak var lblOrderCustName: UILabel!
	@IBOutlet weak var lblOrderCount: UILabel!
	@IBOutlet weak var lblMakeLotId: UITextField!
	
	
	
	var strMakeOrderId: String = ""
	var intOrderWorkCnt: Int = 0
	var intOrderReqCnt: Int = 0
	var strProdAssetEpc: String?
	var intCurOrderWorkCnt: Int = 0
	
	var arrMasterTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrDetailTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	override func viewDidLoad()
	{
		print("=========================================")
		print("*ProductMount.viewDidLoad()")
		print("=========================================")
		super.viewDidLoad()
		//view.backgroundColor = Color.grey.lighten5
		prepareToolbar()
		super.initRfid()
		
		initViewControl()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewWillAppear()")
		print("=========================================")

		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewDidAppear()")
		print("=========================================")
		
		super.viewDidAppear(animated)
		
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewWillDisappear()")
		print("=========================================")
		
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewDidDisappear()")
		print("=========================================")
		
		super.viewDidDisappear(animated)
		
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
				strMakeOrderId	= clsDataRow.getString(name: "makeOrderId") ?? ""
				intOrderWorkCnt	= clsDataRow.getInt(name: "orderWorkCnt") ?? 0
				intOrderReqCnt	= clsDataRow.getInt(name: "orderReqCnt") ?? 0
				strProdAssetEpc = clsDataRow.getString(name: "prodAssetEpc")
				intCurOrderWorkCnt = intOrderWorkCnt
				
				print("@@@@@@@@strMakeOrderId=\(strMakeOrderId)")
				print("@@@@@@@@intOrderWorkCnt=\(intOrderWorkCnt)")
				
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
		clsTagInfo1.setEpcUrn(strEpcUrn: "grai:0.95100027.1028.190010")
		clsTagInfo1.setCorpEpc(strCorpEpc: "95100027")
		clsTagInfo1.setAssetEpc(assetEpc: "1027")
		getRfidData(clsTagInfo: clsTagInfo1)

		let clsTagInfo2 = RfidUtil.TagInfo()
		clsTagInfo2.setYymm(strYymm: "1506")
		clsTagInfo2.setSeqNo(strSeqNo: "69")
		clsTagInfo2.setEpcCode(strEpcCode: "3312D58E4581004000000045")
		clsTagInfo1.setEpcUrn(strEpcUrn: "grai:0.95100027.1028.190010")
		clsTagInfo2.setCorpEpc(strCorpEpc: "95100027")
		clsTagInfo2.setAssetEpc(assetEpc: "1027")
		getRfidData(clsTagInfo: clsTagInfo2)

		let clsTagInfo3 = RfidUtil.TagInfo()
		clsTagInfo3.setYymm(strYymm: "1506")
		clsTagInfo3.setSeqNo(strSeqNo: "70")
		clsTagInfo3.setEpcCode(strEpcCode: "3312D58E4581004000000046")
		clsTagInfo1.setEpcUrn(strEpcUrn: "grai:0.95100027.1028.190010")
		clsTagInfo3.setCorpEpc(strCorpEpc: "95100027")
		clsTagInfo3.setAssetEpc(assetEpc: "1027")
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
			let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
			
			let strSerialNo = clsTagInfo.getSerialNo()
			let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"	// 회사EPC코드 + 자산EPC코드

			//------------------------------------------------
			clsTagInfo.setAssetEpc(assetEpc: strAssetEpc)
			if(clsTagInfo.getAssetEpc().isEmpty == false)
			{
				guard let strAssetName = super.getAssetName(strAsset: strAssetEpc) as? String
				else
				{
					return
				}
				clsTagInfo.setAssetName(assetName : strAssetName)
				print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
			}
			clsTagInfo.setNewTag(newTag : true)
			clsTagInfo.setReadCount(readCount: 1)
			clsTagInfo.setReadTime(readTime: strCurReadTime)
			//------------------------------------------------
			
			var boolValidAsset = false
			var boolFindSerialNoOverlap = false
			var boolFindAssetTypeOverlap = false
			for clsAssetInfo in super.getAssetList()
			{
				print("@@@@@clsAssetInfo.assetEpc:\(clsAssetInfo.assetEpc)")
				if(clsAssetInfo.assetEpc == strAssetEpc)
				{
					// 자산코드에 등록되어 있는 경우
					boolValidAsset = true
					break;
				}
			}
			print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
			if(boolValidAsset == true)
			{
				// Detail 다이얼로그 전달용 태그 리스트
				for clsTagInfo in arrDetailTagRows
				{
					// 같은 시리얼번호가 있는지 체크
					if(clsTagInfo.getSerialNo() == strSerialNo)
					{
						boolFindSerialNoOverlap = true
						break;
					}
				}
				
				// 시리얼번호가 중복이 안되어 있다면
				if(boolFindSerialNoOverlap == false)
				{
					// 상세보기용 배열에 추가
					arrDetailTagRows.append(clsTagInfo)
					
					for clsTagInfo in arrMasterTagRows
					{
						// 같은 자산유형이 있다면 자산유형별로 조회수 증가
						if(clsTagInfo.getAssetEpc() == strAssetEpc)
						{
							boolFindAssetTypeOverlap = true
							let intCurReadCount = clsTagInfo.getReadCount()
							clsTagInfo.setReadCount(readCount: (intCurReadCount + 1))
							break;
						}
					}
					
					// 마스터용 배열에 추가
					if(boolFindAssetTypeOverlap == false)
					{
						arrMasterTagRows.append(clsTagInfo)
					}
					
					let intCurDataSize = arrDetailTagRows.count
					
					// 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
					
					print("@@@@@@strMakeOrderId:\(strMakeOrderId)")
					
					if(strMakeOrderId.isEmpty == false)
					{
						intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
						lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
					}
				}
				
			}
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

		strMakeOrderId	= ""
		strProdAssetEpc = nil
		
		
		self.btnMakeOrderId.setTitle("", for: .normal)
		self.lblOrderCustName.text = ""
		self.lblOrderCount.text = ""
		self.lblMakeLotId.text = ""

	}
	

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrMasterTagRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:ProductMountCell = tableView.dequeueReusableCell(withIdentifier: "tvcProductMount", for: indexPath) as! ProductMountCell
		let clsTagInfo = arrMasterTagRows[indexPath.row]
	
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
		
		objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnDetail.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
		objCell.btnDetail.tag = indexPath.row
		//objCell.btnDetail.addTarget(self, action: #selector(BranchSearchDialog.onSelectionClicked(_:)), for: .touchUpInside)
		return objCell
	}
}


extension ProductMount
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_product_mount", comment: "자산등록")
	}
}


