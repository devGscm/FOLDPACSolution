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

class ProductMount: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol
{
	@IBOutlet weak var tvProductMount: UITableView!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var btnMakeOrderId: UIButton!
	@IBOutlet weak var lblOrderCustName: UILabel!
	@IBOutlet weak var lblOrderCount: UILabel!
		
	@IBOutlet weak var tfMakeLotId: UITextField!
	
	
	var strMakeOrderId: String = ""
	var intOrderWorkCnt: Int = 0
	var intOrderReqCnt: Int = 0
	var strProdAssetEpc: String?
	var intCurOrderWorkCnt: Int = 0
	
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	
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
		
		super.destoryRfid()
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
		
		
//		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
//									  indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		
		// 취소가능하도록 수정
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.",
			cancelable: true, cancelHandler: { (_) in
				
				print("@@@@@@ 취소함@@@@@")
		})

		clsIndicator?.show()
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.clsIndicator?.hide()
		}
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
		else if(segue.identifier == "segTagDetailList")
		{
			if let clsDialog = segue.destination as? TagDetailList
			{
				if let btnDetail = sender as? UIButton
				{
					let clsTagInfo = arrAssetRows[btnDetail.tag]
					
					// 해당 자산코드만 필터링하여 배열을 재생성하여 전달
					let arrData = arrTagRows.filter({ (clsData) -> Bool in
						if(clsData.getAssetEpc() == clsTagInfo.getAssetEpc())
						{
							return true
						}
						return false
					})
					clsDialog.loadData(  arcTagInfo : arrData)
				}
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
		clsTagInfo1.setYymm(strYymm: "1705")
		clsTagInfo1.setSeqNo(strSeqNo: "170005")
		clsTagInfo1.setEpcCode(strEpcCode: "3312D58E4581004000029815")
		clsTagInfo1.setEpcUrn(strEpcUrn: "grai:0.95100043.1025.170005")
		clsTagInfo1.setSerialNo(strSerialNo: "170005")
		clsTagInfo1.setCorpEpc(strCorpEpc: "95100043")
		clsTagInfo1.setAssetEpc(assetEpc: "1025")
		getRfidData(clsTagInfo: clsTagInfo1)
		
		
		
		
		let clsTagInfo2 = RfidUtil.TagInfo()
		clsTagInfo2.setYymm(strYymm: "1705")
		clsTagInfo2.setSeqNo(strSeqNo: "170004")
		clsTagInfo2.setEpcCode(strEpcCode: "3312D58E4581004000029814")
		clsTagInfo2.setEpcUrn(strEpcUrn: "grai:0.95100043.1025.170004")
		clsTagInfo2.setSerialNo(strSerialNo: "170004")
		clsTagInfo2.setCorpEpc(strCorpEpc: "95100043")
		clsTagInfo2.setAssetEpc(assetEpc: "1025")
		getRfidData(clsTagInfo: clsTagInfo2)
		
		
		
		
		let clsTagInfo3 = RfidUtil.TagInfo()
		clsTagInfo3.setYymm(strYymm: "1607")
		clsTagInfo3.setSeqNo(strSeqNo: "6002")
		clsTagInfo3.setEpcCode(strEpcCode: "3312D58E3D81004000001772")
		clsTagInfo3.setEpcUrn(strEpcUrn: "grai:0.95100027.1025.6002")
		clsTagInfo3.setSerialNo(strSerialNo: "6002")
		clsTagInfo3.setCorpEpc(strCorpEpc: "95100027")
		clsTagInfo3.setAssetEpc(assetEpc: "1025")
		getRfidData(clsTagInfo: clsTagInfo3)
		
		let clsTagInfo4 = RfidUtil.TagInfo()
		clsTagInfo4.setYymm(strYymm: "1607")
		clsTagInfo4.setSeqNo(strSeqNo: "6001")
		clsTagInfo4.setEpcCode(strEpcCode: "3312D58E3D81004000001771")
		clsTagInfo4.setEpcUrn(strEpcUrn: "grai:0.95100027.1025.6001")
		clsTagInfo4.setSerialNo(strSerialNo: "6001")
		clsTagInfo4.setCorpEpc(strCorpEpc: "95100027")
		clsTagInfo4.setAssetEpc(assetEpc: "1025")
		getRfidData(clsTagInfo: clsTagInfo4)
		
		
	}
	
	// 주문선택
	@IBAction func onMakeOrderIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segProductOrderSearch", sender: self)
	}
	
	// 데이터를 clear한다.
	func clearTagData()
	{
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		
		tvProductMount?.reloadData()
		
		self.intCurOrderWorkCnt = self.intOrderWorkCnt
		if(lblOrderCustName.text?.isEmpty == false)
		{
			lblOrderCount?.text = "\(self.intCurOrderWorkCnt)/\(self.intOrderReqCnt)"
		}
		
		// TODO : 나중에 구현할 사항
		//super.clear항nventory()
		
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
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
				print(" 동일한 자산코드 존재")
				boolValidAsset = true
				break;
			}
		}
		print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
		if(boolValidAsset == true)
		{
			// Detail 다이얼로그 전달용 태그 리스트
			for clsTagInfo in arrTagRows
			{
				// 같은 시리얼번호가 있는지 체크
				if(clsTagInfo.getSerialNo() == strSerialNo)
				{
					print(" 동일한 시리얼번호 존재")
					boolFindSerialNoOverlap = true
					break;
				}
			}
			
			// 시리얼번호가 중복이 안되어 있다면
			if(boolFindSerialNoOverlap == false)
			{
				// 상세보기용 배열에 추가
				arrTagRows.append(clsTagInfo)
				
				for clsTagInfo in arrAssetRows
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
					arrAssetRows.append(clsTagInfo)
				}
				
				let intCurDataSize = arrTagRows.count
				
				// 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
				
				print("@@@@@@strMakeOrderId:\(strMakeOrderId)")
				
				if(strMakeOrderId.isEmpty == false)
				{
					intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
					lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
				}
			}
			
		}
		
		
		DispatchQueue.main.async { self.tvProductMount?.reloadData() }
	}
	
	func sendData(makeOrderId: String, makeLotId: String, workerName: String, remark: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		print("makeOrderId:\(makeOrderId)")
		print("makeLotId:\(makeLotId)")
		print("workerName:\(workerName)")
		print("remark:\(remark)")
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
//		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//			self.clsIndicator?.hide()
//		}
		
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "mountService:executeMountData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "makeOrderId", value: makeOrderId)
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "makeLotId", value: makeLotId)
		clsDataClient.addServiceParam(paramName: "workerName", value: workerName)
		clsDataClient.addServiceParam(paramName: "remark", value: remark)
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "TAG_MOUNT"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))

		for clsInfo in self.arrTagRows
		{
			if(self.strProdAssetEpc != clsInfo.getAssetEpc())
			{
				clsIndicator!.hide()
				
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_can_not_processed_because_different_pallet", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
				return
			}
		
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
			clsDataRow.addRow(value: clsInfo.getEpcUrn())
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			
		
			self.clsIndicator!.hide()
			
			if let error = error {
					// 에러처리
					print(error)
					return
				}
				guard let clsResultDataTable = data else {
					print("에러 데이터가 없음")
					return
				}
				
				print("####결과값 처리")
				let clsResultDataRows = clsResultDataTable.getDataRows()
				if(clsResultDataRows.count > 0)
				{
					let clsDataRow = clsResultDataRows[0]
					let strResultCode = clsDataRow.getString(name: "resultCode")
					
					print(" -strResultCode:\(strResultCode!)")
					if(Constants.PROC_RESULT_SUCCESS == strResultCode)
					{
						self.clearTagData()
						self.clearUserInterfaceData()
						
						let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
						self.showSnackbar(message: strMsg)
					}
					else
					{
						// TODO : getProcMsgName
						//let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
						
						//self.showSnackbar(message: NSLocalizedString("c", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
					}
				}
			
		})
		
	}
	
	func clearUserInterfaceData()
	{
		intOrderWorkCnt	= 0
		intCurOrderWorkCnt = 0
		intOrderReqCnt	= 0
		
		strMakeOrderId	= ""
		strProdAssetEpc = ""
		
		
		self.btnMakeOrderId.setTitle("", for: .normal)
		self.lblOrderCustName.text = ""
		self.lblOrderCount.text = ""
		self.tfMakeLotId.text = ""
		
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		//let cell : UITableViewCell = UITableViewCell(style: <#T##UITableViewCellStyle#>, reuseIdentifier: <#T##String?#>)
		let objCell:ProductMountCell = tableView.dequeueReusableCell(withIdentifier: "tvcProductMount", for: indexPath) as! ProductMountCell
		let clsTagInfo = arrAssetRows[indexPath.row]
		
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
		
		objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnDetail.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
		objCell.btnDetail.tag = indexPath.row
		objCell.btnDetail.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	// RFID 태그 목록 보기
	@objc func onTagListClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segTagDetailList", sender: self)
	}
	
	// 초기화
	@IBAction func onClearAllClicked(_ sender: UIButton)
	{
	
		Dialog.show(container: self, viewController: nil,
			title: NSLocalizedString("common_delete", comment: "삭제"),
			message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
			okTitle: NSLocalizedString("common_confirm", comment: "확인"),
			okHandler: { (_) in
				self.clearTagData()
				super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
			},
			cancelTitle: NSLocalizedString("common_cancel", comment: "확인"), cancelHandler: nil)
	}
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		print("- UnitID:\(AppContext.sharedManager.getUserInfo().getUnitId())")
		
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		if(arrTagRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		let strMakeOrderId = btnMakeOrderId.titleLabel?.text
		if(strMakeOrderId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_enter_your_order_no", comment: "발주번호를 입력하여 주십시오."))
			return
		}
		
		let strMakeLotId = tfMakeLotId?.text
		if(strMakeLotId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_enter_your_lot_no", comment: "LOT 번호를 입력하여 주십시오."))
			return
		}
		
		let intTagCount = 0
		let intCurWorkCount = self.intOrderWorkCnt + intTagCount // 기제작수량과 현재 인식한 태그 수량
		
		// 발주수량보다 크면
		if(intCurWorkCount > self.intOrderReqCnt)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_cannot_handle_amount_greater_qty", comment: "인식수량이 발주 수량보다 많을수는 없습니다."))
			return
		}
		
		
		let acDialog = UIAlertController(title: NSLocalizedString("common_confirm", comment: "확인"), message: nil, preferredStyle: .alert)
		acDialog.addTextField() {
			$0.placeholder = NSLocalizedString("make_remark", comment: "확인")
		}
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
			acDialog.textFields?[0].text = ""
		})
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			
			let strMakeOrderId = self.btnMakeOrderId?.titleLabel?.text
			let strMakeLotId = self.tfMakeLotId?.text
			let strWorkerName = self.lblUserName?.text
			let strRemark = acDialog.textFields?[0].text
			self.sendData(makeOrderId: strMakeOrderId!, makeLotId: strMakeLotId!, workerName: strWorkerName!, remark: strRemark!)
		})
		self.present(acDialog, animated: true, completion: nil)
		
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