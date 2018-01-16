//
//  EventSelectStore.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 14..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic



class EventSelectStore : BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, ReaderResponseDelegate
{
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var tvSelectStore: UITableView!
	
	@IBOutlet weak var btnProdGrade: UIButton!
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	

	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	
	var arcProdGrade: Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
	var strProdGrade = ""
	
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*EventOther.viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		//RFID를 처리할 델리게이트 지정
		self.initRfid(self as ReaderResponseDelegate )
		
		initViewControl()
	}
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
    }
    
    
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*EventOther.viewDidDisappear()")
		print("=========================================")
		
		arcProdGrade.removeAll()
		
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
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray, indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		
		lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
		
		
		makeProdGradeCodeList(userLang: AppContext.sharedManager.getUserInfo().getUserLang())
		
	}

	func makeProdGradeCodeList(userLang : String)
	{
		self.strProdGrade = ""
		//arcProdGrade.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
		let arrCodeInfo: Array<CodeInfo> = LocalData.shared.getCodeDetail(fieldValue:"PROD_GRADE", commCode:"nil", viewYn:"Y", initCodeName:nil)
		
		print("@@@@@@@@ arrCodeInfo.count:\(arrCodeInfo.count)")
		
		for clsInfo in arrCodeInfo
		{
			var strCommName = ""
			if(Constants.USER_LANG_CH == userLang)
			{
				strCommName = clsInfo.commNameCh
			}
			else if(Constants.USER_LANG_EN == userLang)
			{
				strCommName = clsInfo.commNameEn
			}
            else if(Constants.USER_LANG_JP == userLang)
            {
                strCommName = clsInfo.commNameJp
            }
			else
			{
				strCommName = clsInfo.commNameKr
			}
			arcProdGrade.append(ListViewDialog.ListViewItem(itemCode: clsInfo.commCode, itemName: strCommName))
		}
	}
	

	@IBAction func onProdGradeClicked(_ sender: UIButton)
	{
		let clsDialog = ListViewDialog()
		clsDialog.loadData(data: arcProdGrade, selectedItem: strProdGrade)
		clsDialog.contentHeight = 150
		
		let acDialog = UIAlertController(title: NSLocalizedString("make_prod_grade", comment: "등급"), message:nil, preferredStyle: .alert)
		acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
		
		let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			self.strProdGrade = clsDialog.selectedRow?.itemCode ?? ""
			let strItemName = clsDialog.selectedRow?.itemName ?? ""
			self.btnProdGrade.setTitle(strItemName, for: .normal)
		}
		acDialog.addAction(aaOkAction)
		self.present(acDialog, animated: true)
		
	}
	
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		
		if(segue.identifier == "segTagDetailList")
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
	
	
	// 데이터를 clear한다.
	func clearAllData()
	{
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		tvSelectStore?.reloadData()
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
                        clsTagInfo.setReadCount((intCurReadCount + 1))
						break;
					}
				}
				
				// 마스터용 배열에 추가
				if(boolFindAssetTypeOverlap == false)
				{
					arrAssetRows.append(clsTagInfo)
				}
				
			}
		}
		DispatchQueue.main.async { self.tvSelectStore?.reloadData() }
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:EventSelectStoreCell = tableView.dequeueReusableCell(withIdentifier: "tvcEventSelectStore", for: indexPath) as! EventSelectStoreCell
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
				self.clearAllData()
				super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
			},
			cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
	}
	
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		
		if(arrAssetRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		if(strProdGrade.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("event_select_grade", comment: "등급을 선택하여 주십시오."))
			return
		}
		
		sendData(eventType: Constants.EVENT_CODE_SELECT_STORE)
	}
	
	func sendData(eventType: String)
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "eventService:executeEventData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "evenCode", value: eventType)
		clsDataClient.addServiceParam(paramName: "prodGrade", value: strProdGrade)
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "EVENT"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "traceDateTime", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		
		for clsInfo in self.arrTagRows
		{
			let strTraceDate = DateUtil.localeToUtc(localeDate: clsInfo.getReadTime(), dateFormat: "yyyyMMddHHmmss")
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
			clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
			clsDataRow.addRow(name:"traceDateTime", value: strTraceDate)
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			self.clsIndicator?.hide()
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
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
				let strResultCode	= clsDataRow.getString(name: "resultCode")
				//let strResultMsg	= clsDataRow.getString(name: "resultMsg")
				
				print(" -strResultCode:\(strResultCode!)")
				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
				{
					DispatchQueue.main.async
					{
						self.clearAllData()
						self.clearUserInterfaceData()
					}
					let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
					self.showSnackbar(message: strMsg)
					
				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
		})
	}
	
	func clearUserInterfaceData()
	{
		self.btnProdGrade.setTitle("", for: .normal)
		self.strProdGrade = ""
	}
	
	
	//========================================================================
	// 리더기 관련 이벤트및 처리 시작
	//------------------------------------------------------------------------
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
	//------------------------------------------------------------------------
	// 리더기 관련 이벤트및 처리 끝
	//========================================================================
}


extension EventSelectStore
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_event_select_store", comment: "선별/보관")
	}
}
