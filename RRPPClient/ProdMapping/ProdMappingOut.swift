//
//  ProdMappingOutProcess.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic

class ProdMappingOut: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var btnWorkOutCustSearch: UIButton!
	
	
	
	@IBOutlet weak var tvProdMappingRfid: UITableView!
	@IBOutlet weak var tvProdMappingItem: UITableView!

    var strSaleWorkId	= ""	// 송장번호
    var strToBranchId	= ""	// 출하거점
    
    
    
    
    
    
//    var strMakeOrderId: String = ""
//    var intOrderWorkCnt: Int = 0
//    var intOrderReqCnt: Int = 0
//    var strProdAssetEpc: String?
//    var intCurOrderWorkCnt: Int = 0
	
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		//TODO:: 전역객체에서 등록된 리더기정보를 가져온다.
		let devId  = "D32F0010-8DB8-856F-A8DF-85B3D00CF26A"
		self.initRfid(.SWING, id:  devId, delegateReder:  self as ReaderResponseDelegate )
		
		initViewControl()
	}
	
	
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewDidDisappear()")
		print("=========================================")
		arrAssetRows.removeAll()
		arrTagRows.removeAll()
		clsIndicator = nil
		clsDataClient = nil
		
		super.destoryRfid()
		super.viewDidDisappear(animated)
		
	}
	
	
	
	
	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{

        
		// For Test
		//		AppContext.sharedManager.getUserInfo().setEncryptId(strEncryptId: "xxOxOsU93/PvK/NN7DZmZw==")
		//		AppContext.sharedManager.getUserInfo().setCorpId(strCorpId: "logisallcm")
		//		AppContext.sharedManager.getUserInfo().setBranchId(branchId: "160530000045")
		//		AppContext.sharedManager.getUserInfo().setBranchCustId(branchCustId: "160530000071")
		//		AppContext.sharedManager.getUserInfo().setUserLang(strUserLang: "KR")
		
		/*
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
		*/
		
		lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
		lblReaderName.text = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY)
	}
	
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segWorkOutCustSearch")
		{
			if let clsDialog = segue.destination as? WorkOutCustSearch
			{
				clsDialog.ptcDataHandler = self
			}
		}
	}
	
	// 팝업 다이얼로그로 부터 데이터 수신
	func recvData( returnData : ReturnData)
	{
   		if(returnData.returnType == "workOutCustSearch")
		{
			if(returnData.returnRawData != nil)
			{

                // 새로운 입고처가 들어오면 기존 데이터를 삭제한다.
                if(strSaleWorkId.isEmpty == false)
                {
                	clearTagData(boolClearScreen: true)
                }
                
				let clsDataRow = returnData.returnRawData as! DataRow
                var strCustName = clsDataRow.getString(name: "custName") ?? ""
				self.strToBranchId	= clsDataRow.getString(name: "branchId") ?? ""
	        	self.btnWorkOutCustSearch.setTitle(strCustName, for: .normal)
			}
		}
	}
	
	
	// 리더기 연결 클릭이벤트
	@IBAction func onRfidReaderClicked(_ sender: UIButton)
	{
		if(sender.isSelected == false)
		{
			print(" 리더기 연결")
			sender.isSelected = true
			sender.backgroundColor = Color.orange.base
			sender.tintColor = Color.orange.base
			sender.setTitle(NSLocalizedString("rfid_reader_close", comment: "종료"), for: .normal)
		}
		else
		{
			print(" 리더기 종료")
			sender.isSelected = false
			sender.backgroundColor = Color.blue.base
			sender.tintColor = Color.white
			sender.setTitle(NSLocalizedString("rfid_reader_connect", comment: "연결"), for: .normal)
		}
		
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
	
	
	// 입고처 선택
	@IBAction func onWorkOutCustSearchClicked(_ sender: Any)
	{
		self.performSegue(withIdentifier: "segWorkOutCustSearch", sender: self)
	}

	
	// 데이터를 clear한다.
    func clearTagData( boolClearScreen: Bool)
	{
//		arrTagRows.removeAll()
//		arrAssetRows.removeAll()
//
//		tvProdMappingRfid?.reloadData()
//
//		self.intCurOrderWorkCnt = self.intOrderWorkCnt
//		if(lblOrderCustName.text?.isEmpty == false)
//		{
//			lblOrderCount?.text = "\(self.intCurOrderWorkCnt)/\(self.intOrderReqCnt)"
//		}
//
//		// TODO : 나중에 구현할 사항
//		//super.clear항nventory()
		
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
//		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
//		let strSerialNo = clsTagInfo.getSerialNo()
//		let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"	// 회사EPC코드 + 자산EPC코드
//
//		//------------------------------------------------
//		clsTagInfo.setAssetEpc(assetEpc: strAssetEpc)
//		if(clsTagInfo.getAssetEpc().isEmpty == false)
//		{
//			guard let strAssetName = super.getAssetName(assetEpc: strAssetEpc) as? String
//				else
//			{
//				return
//			}
//			clsTagInfo.setAssetName(assetName : strAssetName)
//			print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
//		}
//		clsTagInfo.setNewTag(newTag : true)
//		clsTagInfo.setReadCount(readCount: 1)
//		clsTagInfo.setReadTime(readTime: strCurReadTime)
//		//------------------------------------------------
//
//		var boolValidAsset = false
//		var boolFindSerialNoOverlap = false
//		var boolFindAssetTypeOverlap = false
//		for clsAssetInfo in super.getAssetList()
//		{
//			print("@@@@@clsAssetInfo.assetEpc:\(clsAssetInfo.assetEpc)")
//			if(clsAssetInfo.assetEpc == strAssetEpc)
//			{
//				// 자산코드에 등록되어 있는 경우
//				print(" 동일한 자산코드 존재")
//				boolValidAsset = true
//				break;
//			}
//		}
//		print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
//		if(boolValidAsset == true)
//		{
//			// Detail 다이얼로그 전달용 태그 리스트
//			for clsTagInfo in arrTagRows
//			{
//				// 같은 시리얼번호가 있는지 체크
//				if(clsTagInfo.getSerialNo() == strSerialNo)
//				{
//					print(" 동일한 시리얼번호 존재")
//					boolFindSerialNoOverlap = true
//					break;
//				}
//			}
//
//			// 시리얼번호가 중복이 안되어 있다면
//			if(boolFindSerialNoOverlap == false)
//			{
//				// 상세보기용 배열에 추가
//				arrTagRows.append(clsTagInfo)
//
//				for clsTagInfo in arrAssetRows
//				{
//					// 같은 자산유형이 있다면 자산유형별로 조회수 증가
//					if(clsTagInfo.getAssetEpc() == strAssetEpc)
//					{
//						boolFindAssetTypeOverlap = true
//						let intCurReadCount = clsTagInfo.getReadCount()
//						clsTagInfo.setReadCount(readCount: (intCurReadCount + 1))
//						break;
//					}
//				}
//
//				// 마스터용 배열에 추가
//				if(boolFindAssetTypeOverlap == false)
//				{
//					arrAssetRows.append(clsTagInfo)
//				}
//
//				let intCurDataSize = arrTagRows.count
//
//				// 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
//
//				print("@@@@@@strMakeOrderId:\(strMakeOrderId)")
//
//				if(strMakeOrderId.isEmpty == false)
//				{
//					intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
//					lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
//				}
//			}
//
//		}
//
		
		DispatchQueue.main.async { self.tvProdMappingRfid?.reloadData() }
	}
	
	func sendData(makeOrderId: String, makeLotId: String, workerName: String, remark: String)
	{
//		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//		print("makeOrderId:\(makeOrderId)")
//		print("makeLotId:\(makeLotId)")
//		print("workerName:\(workerName)")
//		print("remark:\(remark)")
//		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//
//		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
//
//		//		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//		//			self.clsIndicator?.hide()
//		//		}
//
//		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
//		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
//		clsDataClient.ExecuteUrl = "mountService:executeMountData"
//		clsDataClient.removeServiceParam()
//		clsDataClient.addServiceParam(paramName: "makeOrderId", value: makeOrderId)
//		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
//		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
//		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
//		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
//		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
//		clsDataClient.addServiceParam(paramName: "makeLotId", value: makeLotId)
//		clsDataClient.addServiceParam(paramName: "workerName", value: workerName)
//		clsDataClient.addServiceParam(paramName: "remark", value: remark)
//
//		let clsDataTable : DataTable = DataTable()
//		clsDataTable.Id = "TAG_MOUNT"
//		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
//
//		for clsInfo in self.arrTagRows
//		{
//			if(self.strProdAssetEpc != clsInfo.getAssetEpc())
//			{
//				clsIndicator!.hide()
//
//				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_can_not_processed_because_different_pallet", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
//				return
//			}
//
//			let clsDataRow : DataRow = DataRow()
//			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
//			clsDataRow.addRow(value: clsInfo.getEpcUrn())
//			clsDataTable.addDataRow(dataRow: clsDataRow)
//		}
//		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
//
//
//			self.clsIndicator!.hide()
//
//			if let error = error {
//				// 에러처리
//				print(error)
//				return
//			}
//			guard let clsResultDataTable = data else {
//				print("에러 데이터가 없음")
//				return
//			}
//
//			print("####결과값 처리")
//			let clsResultDataRows = clsResultDataTable.getDataRows()
//			if(clsResultDataRows.count > 0)
//			{
//				let clsDataRow = clsResultDataRows[0]
//				let strResultCode = clsDataRow.getString(name: "resultCode")
//
//				print(" -strResultCode:\(strResultCode!)")
//				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
//				{
//					self.clearTagData()
//					self.clearUserInterfaceData()
//
//					let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
//					self.showSnackbar(message: strMsg)
//				}
//				else
//				{
//					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
//					self.showSnackbar(message: strMsg)
//				}
//			}
//
//		})
//
	}
	
	func clearUserInterfaceData()
	{
        strToBranchId = ""
        
//		intOrderWorkCnt	= 0
//		intCurOrderWorkCnt = 0
//		intOrderReqCnt	= 0
//
//		strMakeOrderId	= ""
//		strProdAssetEpc = ""
//
//
//		self.btnMakeOrderId.setTitle("", for: .normal)
//		self.lblOrderCustName.text = ""
//		self.lblOrderCount.text = ""
//		self.tfMakeLotId.text = ""
//
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if(tableView == tvProdMappingRfid)
		{
			return self.arrAssetRows.count
		}
		else
		{
			return 0
		}
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		
		if(tableView == tvProdMappingRfid)
		{
			let objCell:ProdMappingRfidCell = tableView.dequeueReusableCell(withIdentifier: "tvcProdMappingRfid", for: indexPath) as! ProdMappingRfidCell
			let clsTagInfo = arrAssetRows[indexPath.row]
		
//		objCell.lblAssetName.text = clsTagInfo.getAssetName()
//		objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
//
//		objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
//		objCell.btnDetail.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
//		objCell.btnDetail.tag = indexPath.row
//		objCell.btnDetail.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
			return objCell
		}
		else
		{
			let objCell:ProdMappingItemCell = tableView.dequeueReusableCell(withIdentifier: "tvcProdMappingItem", for: indexPath) as! ProdMappingItemCell
			return objCell
		}
		
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
						
						if(self.strSaleWorkId.isEmpty == true)
						{
							self.clearTagData(boolClearScreen: true)
							super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
						}
						else
						{
							self.doReloadTagList(reoadStatus: Constants.RELOAD_STATE_DEFAULT)
						}
					},
					cancelTitle: NSLocalizedString("common_cancel", comment: "확인"), cancelHandler: nil)
	}
	
	
	
	// 작업초기화
	@IBAction func onWorkInitClick(_ sender: UIButton)
	{
	}
	
	
	// 임시저장
	@IBAction func onTempSaveClick(_ sender: UIButton) {
	}
	
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
//		print("- UnitID:\(AppContext.sharedManager.getUserInfo().getUnitId())")
//
//		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
//			return
//		}
//		if(arrTagRows.count == 0)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
//			return
//		}
//
//		let strMakeOrderId = btnMakeOrderId.titleLabel?.text
//		if(strMakeOrderId?.isEmpty == true)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_enter_your_order_no", comment: "발주번호를 입력하여 주십시오."))
//			return
//		}
//
//		let strMakeLotId = tfMakeLotId?.text
//		if(strMakeLotId?.isEmpty == true)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_enter_your_lot_no", comment: "LOT 번호를 입력하여 주십시오."))
//			return
//		}
//
//		let intTagCount = 0
//		let intCurWorkCount = self.intOrderWorkCnt + intTagCount // 기제작수량과 현재 인식한 태그 수량
//
//		// 발주수량보다 크면
//		if(intCurWorkCount > self.intOrderReqCnt)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_cannot_handle_amount_greater_qty", comment: "인식수량이 발주 수량보다 많을수는 없습니다."))
//			return
//		}
//
//
//		let acDialog = UIAlertController(title: NSLocalizedString("common_confirm", comment: "확인"), message: nil, preferredStyle: .alert)
//		acDialog.addTextField() {
//			$0.placeholder = NSLocalizedString("make_remark", comment: "확인")
//		}
//		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
//			acDialog.textFields?[0].text = ""
//		})
//		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
//
//			let strMakeOrderId = self.btnMakeOrderId?.titleLabel?.text
//			let strMakeLotId = self.tfMakeLotId?.text
//			let strWorkerName = self.lblUserName?.text
//			let strRemark = acDialog.textFields?[0].text
//			self.sendData(makeOrderId: strMakeOrderId!, makeLotId: strMakeLotId!, workerName: strWorkerName!, remark: strRemark!)
//		})
//		self.present(acDialog, animated: true, completion: nil)
//
	}
	
	
	func doReloadTagList(reoadStatus: Int)
	{
		
//		String strEpcUrn 			= null;
//		String strEpcCode			= null;
//		String strTraceDate 		= null;
//		String strProdAssetEpc 		= null;
//		String strProdAssetEpcName 	= null;
//		String[] splitValue 		= null;
//		String strTraceDateFormat	= null;
		var strSerialNo 			= ""
//		String strBarcodeId 		= null;
//		String strSaleItemSeq		= null;
//		String strItemCode			= null;
//		String strItemName			= null;
//		String strCnt 				= null;
//		String strVehName			= null;
//		String strTradeChit			= null;
		
		var clsDataTable : DataTable!
		var clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "supplyService:selectProdMappingOutTagList" //출고C타입용 (출고A,B타입과 다름)
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: strSaleWorkId)
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		
		
		//SimpleDateFormat sdfDateFormat = new SimpleDateFormat ("yyyyMMddHHmmss");
		//SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		var arcDataRows : Array<DataRow> = Array<DataRow>()
		do
		{
			// 1) 태그데이터 초기화
			clearTagData(boolClearScreen: false)

			clsDataClient.selectData(dataCompletionHandler: {(data, error) in
				if let error = error {
					// 에러처리
					print(error)
					return
				}
				guard let clsDataTable = data else {
					print("에러 데이터가 없음")
					return
				}
				
				// 2) DB에서 리스트 조회값 받음
				for clsDataRow in clsDataTable.getDataRows()
				{
					let strEpcUrn 			= clsDataRow.getString(name: "epcUrn") ?? ""
					let strEpcCode			= clsDataRow.getString(name: "epcCode")
					let strUtcTraceDate 	= clsDataRow.getString(name: "utcTraceDate")
					let strProdAssetEpc 	= clsDataRow.getString(name: "prodAssetEpc")
					let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName")
					let strBarcodeId 		= clsDataRow.getString(name: "barcodeId")
					let strSaleItemSeq 		= clsDataRow.getString(name: "saleItemSeq")
					let strItemCode 		= clsDataRow.getString(name: "itemCode")
					let strItemName 		= clsDataRow.getString(name: "itemName")
					let strCnt 				= clsDataRow.getString(name: "cnt")
					let strTradeChit		= clsDataRow.getString(name: "tradeChit")
					let strVehName 			= clsDataRow.getString(name: "vehName")
					
					// 날짜 포맷 변환
					let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
					let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"yyyy-MM-dd HH:mm:ss")

			
					if(strEpcUrn.isEmpty == false)
					{
                        let intIndex = strEpcUrn.lastIndex(of: ".") + 1
                        let intLength = strEpcUrn.length - intIndex
                        
						strSerialNo = strEpcUrn.substring(intIndex, length: intLength)
						print("=============================================")
						print("strSerialNo:\(strSerialNo)")
						print("=============================================")
					}
					//데이터 축출
					
					/*
					Logger.i("==========================");
					Logger.i("EPC코드(KEY): " + strEpcCode);
					Logger.i("EPC-URN: " + strEpcUrn);
					Logger.i("시리얼번호: " + strSerialNo);
					Logger.i("유형(코드): " + strProdAssetEpc);
					Logger.i("유형(이름): " + strProdAssetEpcName);
					Logger.i("상품SEQ: " + strSaleItemSeq);
					Logger.i("바코드ID: " + strBarcodeId);
					Logger.i("상품명: " + strItemName);
					Logger.i("바코드수량: " + strCnt);
					*/
					
					//마스터-RFID태그정보
//					ItemInfo clsMastItemInfo = new ItemInfo();
//					clsMastItemInfo.setEpcCode(strEpcCode);
//					clsMastItemInfo.setEpcUrn(strEpcUrn);
//					clsMastItemInfo.setSerialNo(strSerialNo);
//					clsMastItemInfo.setAssetEpc(strProdAssetEpc);
//					clsMastItemInfo.setAssetName(strProdAssetEpcName);
//					clsMastItemInfo.setRowState(Constants.DATA_ROW_STATE_UNCHANGED);
//					clsMastItemInfo.setReadCount(1);
//					clsMastItemInfo.setReadTime(strTraceDate);
//
//					//슬래이브-상품정보
//					ItemInfo clsSlaveItemInfo = new ItemInfo();
//					clsSlaveItemInfo.setEpcCode(strEpcCode);
//					clsSlaveItemInfo.setSaleItemSeq(strSaleItemSeq);
//					clsSlaveItemInfo.setProdCode(strBarcodeId);
//					clsSlaveItemInfo.setProdName(strItemName);
//					clsSlaveItemInfo.setRowState(Constants.DATA_ROW_STATE_UNCHANGED);
//					clsSlaveItemInfo.setProdReadCnt(strCnt);
//					clsSlaveItemInfo.setReadTime(strTraceDate);
//
//					//#1.헤시맵 생성
//					if(mClsProdContainer.containEpcCode(strEpcCode) == false)
//					{
//						//#1-1.구조체 수정
//						if(strEpcCode != null) mClsProdContainer.loadProdEpc(strEpcCode);
//
//						//#1-2.마스터 그리스 저장
//						mLstItemListMasterRows.add(clsMastItemInfo);
//					}
//
//					//#2.아이템 생성-바코드ID가 있는경우
//					if((strBarcodeId != null)&&(strBarcodeId.equals("") == false))
//					{
//						mClsProdContainer.addItem(strEpcCode, clsSlaveItemInfo);
//
//						//#3.서브 그리드 저장
//						mLstItemListSlaveRows.add(clsSlaveItemInfo);
//					}
				}
//				//3)'처리량' 텍스트박스에 표시
//				mTvProcCount.setText(String.valueOf(mLstItemListMasterRows.size()));
//
//				//4)그리드 업데이트
//				mClsAdapterMaster.notifyDataSetChanged();
//				mClsAdapterSlave.notifyDataSetChanged();
//
//				//5)마지막 마스터 그리드가 선택되게 만들기
//				mStrSelectedEpcCode = strEpcCode;
//				mTvSelectedSerialNo.setText(strSerialNo);
//				mTvSelectedAssetName.setText(strProdAssetEpcName);
//
//
//				showDialogOnThread(getString(R.string.common_confirm), getString(R.string.common_success_delete), 2000);	//성공적으로 삭제가 완료되었습니다.
	
			})
			

			

		}
		catch let error
		{
			print(error.localizedDescription)
			//if(mViFooterView != null) mViFooterView.setVisibility(View.INVISIBLE);
			//showToastOnThread(getString(R.string.common_error_occurred_data_search));
			//Logger.e(StrUtil.trace(e));
		}
	}
	
	func didReadTagList(_ tagId: String)
	{
		
	}
	
}


extension ProdMappingOut
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")

        var strType = ""
        let strIdentificationSystem = UserDefaults.standard.string(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
        if(strIdentificationSystem == Constants.IDENTIFICATION_SYSTEM_AGQR)
        {
			strType = NSLocalizedString("identification_system_agqr", comment: "농산물 QR코드")
        }
        else
        {
            strType = NSLocalizedString("identification_system_itf14", comment: "ITF-14 바코드")
        }
        
        if(AppContext.sharedManager.getUserInfo().getCustType() == "MGR")
        {
            tc.toolbar.detail = "\(NSLocalizedString("title_work_sale_c", comment: "출고C")) (\(strType))"
        }
        
	}
}
