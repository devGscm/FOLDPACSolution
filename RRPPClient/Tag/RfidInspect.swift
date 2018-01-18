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

class RfidInspect: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, ReaderResponseDelegate
{
	@IBOutlet weak var lblAssetName: UILabel!
	@IBOutlet weak var lblEpcUrn: UILabel!
	@IBOutlet weak var lblSerialNo: UILabel!
	@IBOutlet weak var lblReadTime: UILabel!	
	@IBOutlet weak var lblResult: UILabel!
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var btnSelectAll: UIButton!
	@IBOutlet weak var btnDeleteTagId: UIButton!
	
	@IBOutlet weak var lblReadCnt: UILabel!
	@IBOutlet weak var tvRfidInspect: UITableView!
	
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var clsIndicator : ProgressIndicator?
	
	var bisAllChekced = false
	var boolSortAsc	= true
	
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
		
		arrTagRows.removeAll()
		clsIndicator = nil
		
		super.destoryRfid()
		super.viewDidDisappear(animated)
	}
	
	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
		
		lblReadCnt.text = "0"
		
		//Ordering 지정
		let tgrAssetName = UITapGestureRecognizer(target: self, action: #selector((onAssetNameClicked)))
		self.lblAssetName.addGestureRecognizer(tgrAssetName)
		
		let tgrSerialNo = UITapGestureRecognizer(target: self, action: #selector((onSerialNoClicked)))
		self.lblSerialNo.addGestureRecognizer(tgrSerialNo)
		
		let tgrEpcUrn = UITapGestureRecognizer(target: self, action: #selector((onEpcUrnClicked)))
		self.lblEpcUrn.addGestureRecognizer(tgrEpcUrn)
		
		let tgrReadTime = UITapGestureRecognizer(target: self, action: #selector((onReadTimeClicked)))
		self.lblReadTime.addGestureRecognizer(tgrReadTime)
		
		let tgrResult = UITapGestureRecognizer(target: self, action: #selector((onResultClicked)))
		self.lblResult.addGestureRecognizer(tgrResult)
		
		//테이블의 셀에대한 높이설정
		self.tvRfidInspect.rowHeight = 70
	}
	
	@objc func onAssetNameClicked(sender: UITapGestureRecognizer)
	{
		print("onAssetNameClicked")
		
		if(boolSortAsc == true)
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getAssetName() > clsTagInfo2.getAssetName()
			})
		}
		else
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getAssetName() < clsTagInfo2.getAssetName()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidInspect?.reloadData() }
		
		
	}
	
	@objc func onSerialNoClicked(sender: UITapGestureRecognizer)
	{
		print("onSerialNoClicked")
		if(boolSortAsc == true)
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return Int(clsTagInfo1.getSerialNo())! > Int(clsTagInfo2.getSerialNo())!
			})
		}
		else
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return Int(clsTagInfo1.getSerialNo())! < Int(clsTagInfo2.getSerialNo())!
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidInspect?.reloadData() }
	}
	
	@objc func onEpcUrnClicked(sender: UITapGestureRecognizer)
	{
		print("onEpcUrnClicked")
		
		if(boolSortAsc == true)
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getEpcUrn() > clsTagInfo2.getEpcUrn()
			})
		}
		else
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getEpcUrn() < clsTagInfo2.getEpcUrn()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidInspect?.reloadData() }
		
	}
	
	@objc func onReadTimeClicked(sender: UITapGestureRecognizer)
	{
		print("onReadTimeClicked")
		if(boolSortAsc == true)
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getReadTime() > clsTagInfo2.getReadTime()
			})
		}
		else
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getReadTime() < clsTagInfo2.getReadTime()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidInspect?.reloadData() }
	}
	
	@objc func onResultClicked(sender: UITapGestureRecognizer)
	{
		print("onResultClicked")
		if(boolSortAsc == true)
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getResult() > clsTagInfo2.getResult()
			})
		}
		else
		{
			self.arrTagRows = self.arrTagRows.sorted(by: { (clsTagInfo1: RfidUtil.TagInfo, clsTagInfo2: RfidUtil.TagInfo) -> Bool in
				return clsTagInfo1.getResult() < clsTagInfo2.getResult()
			})
		}
		boolSortAsc = !boolSortAsc
		DispatchQueue.main.async { self.tvRfidInspect?.reloadData() }
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
		arrTagRows.removeAll()
		tvRfidInspect?.reloadData()
		lblReadCnt?.text = "\(self.arrTagRows.count)"
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
				// 배열에 추가
				self.arrTagRows.append(clsTagInfo)
				DispatchQueue.main.async { self.lblReadCnt?.text = "\(self.arrTagRows.count)"
					self.tvRfidInspect?.reloadData() }
			}
		}
	}
	
	func sendData()
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inspectService:inspectTagData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "TAG_ISSUE"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "unitId", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "updtId", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		
		for clsInfo in self.arrTagRows
		{
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_MODIFIED
			clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
			clsDataRow.addRow(name:"unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
			clsDataRow.addRow(name:"updtId", value: AppContext.sharedManager.getUserInfo().getUserId())			
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			
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
			for dataRow in clsResultDataRows
			{
				let strResult = dataRow.getString(name: "result")
				let strEpcCode = dataRow.getString(name: "epcCode")
				if(strResult == Constants.PROC_RESULT_SUCCESS)
				{
					self.arrTagRows = self.arrTagRows.filter({ $0.getEpcCode() != strEpcCode })
				}
				else
				{
					var tagInfo = self.arrTagRows.filter({ $0.getEpcCode() == strEpcCode })
					if(tagInfo.count > 0)
					{
						tagInfo[0].setResult(self.getErrorMessage(strResult ?? ""))
					}
				}
			}
			
			DispatchQueue.main.async {
				super.clearInventory()
				self.clsIndicator?.hide()
				self.lblReadCnt?.text = "\(self.arrTagRows.count)"
				self.tvRfidInspect?.reloadData()
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
		self.lblReadCnt.text = "0"
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrTagRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:RfidInspectCell = tableView.dequeueReusableCell(withIdentifier: "tvcRfidInspect", for: indexPath) as! RfidInspectCell
		let clsTagInfo = arrTagRows[indexPath.row]
		
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblEpcUrn.text = clsTagInfo.getEpcUrn()
		objCell.lblSerialNo.text = clsTagInfo.getSerialNo()
		
		let strReadTimeDate = clsTagInfo.getReadTime()
		let strDisplayReadTime = DateUtil.getConvertFormatDate(date: strReadTimeDate, srcFormat: "yyyyMMddHHmmss", dstFormat: "HH:mm:ss")
		objCell.lblReadTime.text = strDisplayReadTime
		
		objCell.lblResult.text = clsTagInfo.getResult()
		
		//체크버튼 정의
		objCell.chkYN.borderStyle = .circle
		objCell.chkYN.checkmarkStyle = .circle
		objCell.chkYN.borderWidth = 1
		objCell.chkYN.uncheckedBorderColor = .lightGray
		objCell.chkYN.checkedBorderColor = .blue
		objCell.chkYN.checkmarkSize = 0.8
		objCell.chkYN.checkmarkColor = .blue
		objCell.chkYN.isChecked = clsTagInfo.getChecked()
		objCell.chkYN.tag = indexPath.row
		objCell.chkYN.addTarget(self, action: #selector(circleBoxValueChanged(sender:)), for: .valueChanged)
		
		//TODO:: Result 처리
		//objCell.lblResult.text = "\(clsTagInfo.getEpcUrn())"
		//objCell.accessoryType = .checkmark
		return objCell
	}
	
	@objc func circleBoxValueChanged(sender: Checkbox) {
		let rowIndex = sender.tag
		if arrTagRows.count > rowIndex
		{
			arrTagRows[rowIndex].setChecked(sender.isChecked)
		}
		//print("circle box value change: \(sender.isChecked)")
	}
	
	//전체선택 / 해재
	@IBAction func onSelecteAllClicked(_ sender: Any) {
		self.bisAllChekced = self.bisAllChekced ? false : true		
		for tagInfo in arrTagRows
		{
			tagInfo.setChecked(self.bisAllChekced)
		}
		tvRfidInspect?.reloadData()
	}
	
	//선택된 데이터 삭제
	@IBAction func onSelectedDelClicked(_ sender: Any) {
		arrTagRows = arrTagRows.filter { $0.getChecked() == false }
		DispatchQueue.main.async { self.lblReadCnt?.text = "\(self.arrTagRows.count)"
			self.tvRfidInspect?.reloadData() }
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
		
		self.sendData()
	}
}

extension RfidInspect
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else
		{
			return
		}
		//tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.title = NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")
	}
}

