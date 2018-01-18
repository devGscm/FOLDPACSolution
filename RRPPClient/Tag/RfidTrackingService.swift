//
//  RfidInspectController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//
import UIKit
import Material
import Mosaic

class RfidTrackingService: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, ReaderResponseDelegate
{
	struct TrackingInfo {
		let traceDate : String			/**< 추적일자 **/
		let eventName : String			/**< 이벤트명 **/
		let branchName : String		/**< 거점명 **/
		let recycleCnt : String			/**< Trip건수 **/
	}
	
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
	
	@IBOutlet weak var lblProcessDate: UILabel!
	@IBOutlet weak var lblEventName: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
	@IBOutlet weak var lblRecycleCnt: UILabel!
		
	@IBOutlet weak var tvRfidTrackingService: UITableView!
	
	var arrTrackingRows : Array<TrackingInfo> = Array<TrackingInfo>()
	var clsIndicator : ProgressIndicator?
	
	var bisAllChekced = false
	var boolSortAsc	= true
	
	var mEpcMode : String = ""
	var mEpcUrn : String = ""
	var mAssetEpc : String = ""
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		//RFID를 처리할 델리게이트 지정
		self.initRfid(self as ReaderResponseDelegate )
		initViewControl()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*viewDidDisappear()")
		print("=========================================")
		
		arrTrackingRows.removeAll()
		clsIndicator = nil
		
		super.destoryRfid()
		super.viewDidDisappear(animated)
	}
	
	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
		
		
		//Ordering 지정
		let tgrProcessDate = UITapGestureRecognizer(target: self, action: #selector((onProcessDateCliecked)))
		self.lblProcessDate.addGestureRecognizer(tgrProcessDate)
		
		let tgrEventName = UITapGestureRecognizer(target: self, action: #selector((onEventNameClicked)))
		self.lblEventName.addGestureRecognizer(tgrEventName)
		
		let tgrBranchName = UITapGestureRecognizer(target: self, action: #selector((onBranchNameClicked)))
		self.lblBranchName.addGestureRecognizer(tgrBranchName)
		
		let tgrRecycleCnt = UITapGestureRecognizer(target: self, action: #selector((onRecycleCntClicked)))
		self.lblRecycleCnt.addGestureRecognizer(tgrRecycleCnt)
		
		 self.tvRfidTrackingService.rowHeight = 70
	}
	
	@objc func onRecycleCntClicked(sender: UITapGestureRecognizer)
	{
		print("onRecycleNameClicked")
		if(boolSortAsc == true)
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return Int(clsTraceInfo1.recycleCnt)! > Int(clsTraceInfo2.recycleCnt)!
			})
		}
		else
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return Int(clsTraceInfo1.recycleCnt)! < Int(clsTraceInfo2.recycleCnt)!
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidTrackingService?.reloadData() }
	}
	
	@objc func onProcessDateCliecked(sender: UITapGestureRecognizer)
	{
		print("onEpcUrnClicked")
		
		if(boolSortAsc == true)
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.traceDate > clsTraceInfo2.traceDate
			})
		}
		else
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.traceDate < clsTraceInfo2.traceDate
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidTrackingService?.reloadData() }
		
	}
	
	@objc func onEventNameClicked(sender: UITapGestureRecognizer)
	{
		print("onReadTimeClicked")
		if(boolSortAsc == true)
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.eventName > clsTraceInfo2.eventName
			})
		}
		else
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.eventName < clsTraceInfo2.eventName
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidTrackingService?.reloadData() }
	}
	
	@objc func onBranchNameClicked(sender: UITapGestureRecognizer)
	{
		print("onResultClicked")
		if(boolSortAsc == true)
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.branchName > clsTraceInfo2.branchName
			})
		}
		else
		{
			self.arrTrackingRows = self.arrTrackingRows.sorted(by: { (clsTraceInfo1: TrackingInfo, clsTraceInfo2: TrackingInfo) -> Bool in
				return clsTraceInfo1.branchName < clsTraceInfo2.branchName
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidTrackingService?.reloadData() }
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	////   리더기 관련 이벤트및 처리 시작
	//////////////////////////////////////////////////////////////////////////////////////////
	// 리더기 연결 클릭이벤트
	@IBAction func onRfidReaderClicked(_ sender: UIButton)
	{
		if(sender.isSelected == false)
		{
			showSnackbar(message: NSLocalizedString("rfid_connecting_reader", comment: "RFID 리더기에 연결하는 중 입니다."))
			//print(" 리더기 연결")
			super.readerConnect()
		}
		else
		{
			super.readerDisConnect()
		}
	}
	
	//리더기에서 읽어드린 태그에 대한 이벤트 발생처리
	func didReadTagid(_ tagid: String)
	{
		let clsTagInfo = RfidUtil.parse(strData: tagid)
		getRfidData(clsTagInfo: clsTagInfo)
	}
	
	//리더기 연결성공
	func didReaderConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
		changeBtnRfidReader(true)
	}
	
	//리더기 연결종로
	func didReaderDisConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connection_terminated", comment: "연결이 종료되었습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 타임오바
	func didRederConnectTimeOver()
	{
		showSnackbar(message: NSLocalizedString("rfid_not_connect_reader", comment: "RFID 리더기에 연결할수 없습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 여부에 따른 버튼에대한 상태값 변경
	func changeBtnRfidReader(_ isConnected : Bool)
	{
		if(isConnected )
		{
			self.btnRfidReader.isSelected = true
			self.btnRfidReader.backgroundColor = Color.orange.base
			self.btnRfidReader.tintColor = Color.orange.base
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_close", comment: "종료"), for: .normal)
		}
		else
		{
			self.btnRfidReader.isSelected = false
			self.btnRfidReader.backgroundColor = Color.blue.base
			self.btnRfidReader.tintColor = Color.white
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_connect", comment: "연결"), for: .normal)
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	////   리더기 관련 이벤트및 처리 종료
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// 데이터를 clear한다.
	func clearTagData()
	{
		arrTrackingRows.removeAll()
		DispatchQueue.main.async
		{
			self.lblAssetName.text = ""
			self.lblSerialNo.text = ""
			self.tvRfidTrackingService?.reloadData()
		}
		super.clearInventory()
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
		let strSerialNo = clsTagInfo.getSerialNo()
		let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"	// 회사EPC코드 + 자산EPC코드
		
		//------------------------------------------------
		clsTagInfo.setAssetEpc(strAssetEpc)
		if(clsTagInfo.getAssetEpc().isEmpty == false)
		{
			let strAssetName = super.getAssetName(assetEpc: strAssetEpc)
			clsTagInfo.setAssetName(strAssetName)
			print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
		}
		clsTagInfo.setNewTag(true)
		clsTagInfo.setReadCount(1)
		clsTagInfo.setReadTime(strCurReadTime)
		//------------------------------------------------
		
		var boolValidAsset = false
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
			mEpcMode = StrUtil.substring(strInputString: clsTagInfo.getEpcCode(), intIndexStart: 0, intIndexEnd: 1)
			if(mEpcMode == Constants.RFID_EPC_MODE_GRAI_96)
			{
				mEpcUrn = StrUtil.substring(strInputString: clsTagInfo.getEpcUrn(), intIndexStart: 5, intIndexEnd: clsTagInfo.getEpcUrn().length - 1)
			}
			else if(mEpcMode == Constants.RFID_EPC_MODE_SGTIN_96)
			{
				mEpcUrn = StrUtil.substring(strInputString: clsTagInfo.getEpcUrn(), intIndexStart: 6, intIndexEnd: clsTagInfo.getEpcUrn().length - 1)
			}
			mAssetEpc = strAssetEpc
			
			DispatchQueue.main.async {
				self.lblAssetName.text = clsTagInfo.getAssetName()
				self.lblSerialNo.text = strSerialNo
				self.arrTrackingRows.removeAll()
				self.tvRfidTrackingService?.reloadData()
			}
			
		}
	}
	
	func sendData()
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))		
		let clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "supplyService:selectTagTraceDetailList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		
		clsDataClient.addServiceParam(paramName: "epcMode", value: mEpcMode)
		clsDataClient.addServiceParam(paramName: "epcUrn", value: mEpcUrn)
		clsDataClient.addServiceParam(paramName: "assetEpc", value: mAssetEpc)
		
		clsDataClient.selectData(dataCompletionHandler: { (data, error) in
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
			self.arrTrackingRows.removeAll()
			let clsResultDataRows = clsResultDataTable.getDataRows()
			for dataRow in clsResultDataRows
			{
				let strTraceDate = dataRow.getString(name: "traceDate") ?? ""
				let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strTraceDate, dateFormat: "yyyy-MM-dd HH:mm:ss")
				
				let strEventName = dataRow.getString(name: "eventName") ?? ""
				let strBranchName = dataRow.getString(name: "branchName") ?? ""
				let strRecycleCnt = dataRow.getString(name: "recycleCnt") ?? ""
				let trackingInfo = TrackingInfo( traceDate: strLocaleTraceDate,  eventName: strEventName, branchName: strBranchName, recycleCnt: strRecycleCnt)
				self.arrTrackingRows.append(trackingInfo)
			}
			
			DispatchQueue.main.async {
				self.clsIndicator?.hide()
				if( self.arrTrackingRows.count == 0)
				{
					super.showSnackbar(message: NSLocalizedString("product_more_data", comment: "데이터가 없습니다."))
				}
				self.tvRfidTrackingService?.reloadData()
			}
		})
	}
	
	func getErrorMessage(_ strResult : String) -> String
	{
		var strResultMsg = ""
		if(Constants.PROC_RESULT_ERROR_INSPECT_TAG_ISSUE == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_tag_issue", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_TAG_ENCODING_FAIL == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_tag_encoding_fail", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_TAG_INSERT_SUCCESS == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_tag_insert_success", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_TAG_INSERT_FAIL == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_tag_insert_fail", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_TAG_DISCARD == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_tag_discard", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_UNKNOWN_EXCEPTION == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_unknown_exception", comment: "")
		}
		else if(Constants.PROC_RESULT_ERROR_INSPECT_NOT_REGISTERED_DATA == strResult)
		{
			strResultMsg = NSLocalizedString("proc_result_error_inspect_not_registered_data", comment: "")
		}
		return strResultMsg
	}
	
	func clearUserInterfaceData()
	{
		
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrTrackingRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:RfidTrackingServiceCell = tableView.dequeueReusableCell(withIdentifier: "tvcRfidTrackingService", for: indexPath) as! RfidTrackingServiceCell
		let clsTraceInfo = arrTrackingRows[indexPath.row]
		
		objCell.lblProcessDate.text = clsTraceInfo.traceDate
		objCell.lblEventName.text = clsTraceInfo.eventName
		objCell.lblBranchName.text = clsTraceInfo.branchName
		objCell.lblRecycleCnt.text = clsTraceInfo.recycleCnt
		
		return objCell
	}
	
	// 초기화
	@IBAction func onClearAllClicked(_ sender: UIButton)
	{
		self.clearTagData()
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
		
		//TODO:: 검색할 조건을 설정하라는 메세지 다국어 필요
//		if(mEpcUrn.isEmpty == true)
//		{
//			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
//			return
//		}
		
		self.sendData()
	}
}

extension RfidTrackingService
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else
		{
			return
		}
		//tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.title = NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")
	}
}


