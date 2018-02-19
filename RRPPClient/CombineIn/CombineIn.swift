//
//  CombineIn.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 15..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import BarcodeScanner

class CombineIn: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	
	@IBOutlet weak var btnWorkType: UIButton!
	@IBOutlet weak var btnSaleWorkId: UIButton!
	@IBOutlet weak var btnBarcodeSearch: UIButton!
	@IBOutlet weak var tfVehName: UITextField!
	@IBOutlet weak var lblResaleBranchName: UILabel!
	@IBOutlet weak var lblDriverName: UILabel!
	@IBOutlet weak var lblProdAssetEpcName: UILabel!
	@IBOutlet weak var lblOrderReqCount: UILabel!
	@IBOutlet weak var lblProcCount: UILabel!
	@IBOutlet weak var lblRemainCount: UILabel!
	
	
	@IBOutlet weak var tvCombineIn: UITableView!
	
	var strTitle	= ""
	
	var arcWorkType: Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
	var strWorkType = ""
	
	
	
	var strResaleOrderId							= ""			/**< 구매주문ID */
	var strSaleWorkId								= ""			/**< 송장번호 */
	var strProdAssetEpc								= ""			/**< 유형 */
	var intOrderReqCount							= 0			/**< 출고량 */
	var intProcCount 								= 0			/**< 처리량 */
	
	
	var boolWorkListSelected						= false		/**< 송장-선택 했는지 여부 */
	var boolNewTagInfoExist							= false		/**< 신규태그 - 신규태그가 있는지 여부 -전소용 */
	
	var strWorkerName								= ""			/**< 반납-인수자정보*/
	var intNoreadCnt								= 0			/**< 미인식 -고장으로 인해 리더기 미인식*/
	var strCustType									= ""			/**< 고객사 구분 */
	
	var strWorkState								= ""			/**< 작업상태(서버전송) */
	var boolWorkCompleteBtn							= false		/**< 완료전송 버튼 입력 -전송용 */
	var strNoReadCount								= "0"			/**< 미인식수량-전송용 */
	
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	var clsBarcodeScanner: BarcodeScannerController?
	
	func setTitle(title: String)
	{
		self.strTitle = title
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		initBarcodeScanner()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
        
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*CombineIn.viewWillAppear()")
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
		print("*CombineIn.viewDidDisappear()")
		print("=========================================")
		
		boolWorkListSelected	= false
		boolNewTagInfoExist		= false
		
		arcWorkType.removeAll()
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
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
		
		makeWorkTypeCodeList(userLang: AppContext.sharedManager.getUserInfo().getUserLang())
		
		// 송장 선택여부
		boolWorkListSelected = false
        
        // 테이블뷰 셀표시 지우기
        tvCombineIn.tableFooterView = UIView(frame: CGRect.zero)
	}
	
	
	func makeWorkTypeCodeList(userLang : String)
	{
		var strCustType = AppContext.sharedManager.getUserInfo().getCustType()
		print("@@@@@@@@@ strCustType0:\(strCustType)")
		// 고객사 타입
		if(AppContext.sharedManager.getUserInfo().getCustType() == Constants.CUST_TYPE_MGR)
		{
			strCustType = AppContext.sharedManager.getUserInfo().getBranchCustType()
			print("@@@@@@@@@ strCustType1:\(strCustType)")
		}
		
		print("@@@@@@@@@ strCustType2:\(strCustType)")
		
		let enuCustType = LocalData.CustType(rawValue: strCustType)
		let arrCodeInfo: Array<CodeInfo> = LocalData.shared.getSaleTypeCodeDetail(fieldValue: "RESALE_TYPE", saleResale: LocalData.SaleResaleType.Resale, custType: enuCustType!, initCodeName: nil)
		
		print("@@@@@@@@@ arrCodeInfo.count:\(arrCodeInfo.count)")
		
		
		for (intIndex, clsInfo) in arrCodeInfo.enumerated()
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
			
			if(intIndex == 0)
			{
				self.strWorkType = clsInfo.commCode
				self.btnWorkType.setTitle(strCommName, for: .normal)
			}
			arcWorkType.append(ListViewDialog.ListViewItem(itemCode: clsInfo.commCode, itemName: strCommName))
		}
	}
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segCombineInSearch")
		{
			if let clsDialog = segue.destination as? CombineInSearch
			{
				clsDialog.ptcDataHandler = self
				clsDialog.workType = self.strWorkType
			}
		}
		else if(segue.identifier == "segInSignDialog")
		{
			if let clsDialog = segue.destination as? InSignDialog
			{
				let clsDataRow : DataRow = DataRow()
				clsDataRow.addRow(name: "noReadCount", value: self.strNoReadCount)
				
				// 인수자 : 업무구분이 "구매(반납)" 인 경우, 반납주문정보의 "인수자" 정보표시
				if(Constants.RESALE_TYPE_RETURN == self.strWorkType)
				{
					clsDataRow.addRow(name: "workerName", value: self.strWorkerName)
				}
				else
				{
					clsDataRow.addRow(name: "workerName", value: AppContext.sharedManager.getUserInfo().getUserName())
				}
				clsDataRow.addRow(name: "remark", value: "")
				clsDialog.loadData(dataRow: clsDataRow)
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
		if(returnData.returnType == "combineInSearch")
		{
			if(returnData.returnRawData != nil)
			{
				// 새로운 발주번호가 들어오면 기존 데이터는 삭제한다.
				if(self.strSaleWorkId.isEmpty == false)
				{
					clearTagData(clearScreen: true)
				}
				
				let clsDataRow = returnData.returnRawData as! DataRow
				
				self.strResaleOrderId			= clsDataRow.getString(name: "resaleOrderId") ?? ""
				self.strSaleWorkId 				= clsDataRow.getString(name: "saleWorkId") ?? ""
				self.intOrderReqCount 			= clsDataRow.getInt(name: "orderReqCnt") ?? 0
				self.intProcCount				= clsDataRow.getInt(name: "procCnt") ?? 0
				self.intNoreadCnt				= clsDataRow.getInt(name: "noreadCnt") ?? 0				//미인식
				self.strWorkerName				= clsDataRow.getString(name: "workerName") ?? ""		//반납-인수자
				self.strProdAssetEpc			= clsDataRow.getString(name: "prodAssetEpc") ?? ""		//유형
				//let intRemainCnt				= clsDataRow.getInt(name: "remainCnt") ?? 0				//미처리량
                var intRemainCnt                = self.intOrderReqCount - self.intProcCount             //미처리량
                if(intRemainCnt < 0)    { intRemainCnt = 0 }
                
				
				self.lblResaleBranchName.text	= clsDataRow.getString(name: "resaleBranchName") ?? ""		// 출고처
				self.btnSaleWorkId.setTitle(strSaleWorkId, for: .normal)									// 송장번호
				self.lblOrderReqCount.text		= "\(intOrderReqCount)"									// 입고예정수량
				self.lblProcCount.text			= "\(intProcCount)"										// 처리수량
				self.tfVehName.text				= clsDataRow.getString(name: "resaleVehName") ?? ""			// 차량번호
				self.lblDriverName.text			= clsDataRow.getString(name: "resaleDriverName") ?? ""		// 납품자
				self.lblProdAssetEpcName.text 	= clsDataRow.getString(name: "prodAssetEpcName") ?? ""	// 유형
				self.lblRemainCount.text		= "\(intRemainCnt)"										// 미처리량
				
				
				//선택된 '송장정보' 내용 조회
				doSearchWorkListDetail()
				
				//선택된 '송장정보'에 대한 태그리스트
				doSearchTagList()
				
				//송장 선택 여부
				boolWorkListSelected = true
				
			}
		}
		else if(returnData.returnType == "inSignDialog")
		{
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let intNoReadCount	= clsDataRow.getInt(name: "noReadCount") ?? 0
				let strWorkerName	= clsDataRow.getString(name: "workerName") ?? ""
				let strRemark		= clsDataRow.getString(name: "remark") ?? ""
				let strSignData		= clsDataRow.getString(name: "signData") ?? ""
				let strVehName		= tfVehName?.text ?? ""
				let strDriverName	= lblDriverName?.text ?? ""
				
				sendData(workState: self.strWorkState, resaleOrderId: self.strResaleOrderId, saleWorkId: self.strSaleWorkId, vehName: strVehName, driverName: strDriverName, orderReqCount: self.intOrderReqCount, noReadCount: intNoReadCount, remark: strRemark, workerName: strWorkerName, signData: strSignData)
			}
		}
		
	}
	
	// 구분 선택
	@IBAction func onWorkTypeClicked(_ sender: UIButton)
	{
		let clsDialog = ListViewDialog()
		
		print("@@@@@@@@@ onWOkrTypeClicked:\(strWorkType)")
		
		
		clsDialog.loadData(data: arcWorkType, selectedItem: strWorkType)
		clsDialog.contentHeight = 150
		
		let acDialog = UIAlertController(title: NSLocalizedString("combine_work_type", comment: "구분"), message:nil, preferredStyle: .alert)
		acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
		
		let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			self.strWorkType = clsDialog.selectedRow?.itemCode ?? ""
			let strItemName = clsDialog.selectedRow?.itemName ?? ""
			self.btnWorkType.setTitle(strItemName, for: .normal)
		}
		acDialog.addAction(aaOkAction)
		self.present(acDialog, animated: true)
	}
	
	@IBAction func onSaleWorkIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segCombineInSearch", sender: self)
	}
	
	
	// 데이터를 clear한다.
	func clearTagData(clearScreen : Bool)
	{
		print("@@@@@@@@@@@@@@@@@@@@@@@@")
		print("*clearTagData()")
		print("@@@@@@@@@@@@@@@@@@@@@@@@")
		self.boolNewTagInfoExist = false	// 신규태그 입력 체크, 전송용
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		
		DispatchQueue.main.async
		{
			self.tvCombineIn?.reloadData()
		}
		
		if(clearScreen == true)
		{
			strSaleWorkId				= ""
			strProdAssetEpc				= ""
			intProcCount				= 0
			intOrderReqCount			= 0		/**< 출고량 */
			intNoreadCnt				= 0
			strWorkerName				= ""
			boolWorkCompleteBtn			= false
			strWorkState				= ""
			strNoReadCount				= "0"
            boolWorkListSelected        = false     //송장선택 유무
            
            
            self.lblResaleBranchName.text	= ""	//출고처
            self.btnSaleWorkId.setTitle(NSLocalizedString("sale_work_id_selection", comment: "송장선택"), for: .normal) //송장번호
            self.lblOrderReqCount.text		= "0"	// 입고예정수량
            self.lblProcCount.text			= "0"	// 처리량
            self.tfVehName.text				= ""	// 차량번호
            self.lblProdAssetEpcName.text	= ""	// 유형
            self.lblRemainCount.text		= "0"	// 미처리량
            self.lblDriverName.text			= ""	// 납품자
		
		}
		
		// RFID리더기 초기화
		super.clearInventory()
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
		// 송장이 선택되어 진행
        if(self.boolWorkListSelected == false)
        {
            return
        }
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
				// 신규태그 입력 체크
				self.boolNewTagInfoExist = true
				
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
						break
					}
				}
				
				// 마스터용 배열에 추가
				if(boolFindAssetTypeOverlap == false)
				{
					arrAssetRows.append(clsTagInfo)
				}
				
				// 입력창 내용 갱신(처리량증가/미처리량감소)
				var intRemainCount: Int = Int(lblRemainCount?.text ?? "0")! // 미처리량
				
				print(" @@@@@@@ intRemainCount:\(intRemainCount)")
				
				if intRemainCount > 0
				{
					intRemainCount = intRemainCount - 1
					lblRemainCount.text = "\(intRemainCount)"
				}
				
				
				self.intProcCount = Int(lblProcCount?.text ?? "0")! + 1 // 처리량
				
				print(" @@@@@@@ self.intProcCount:\(self.intProcCount)")
				
				lblProcCount?.text = "\(self.intProcCount)"
				
				
				//5)그리드 리스에 내용 갱신
				for clsGridInfo in arrAssetRows
				{
					// 같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
					if(strAssetEpc == clsGridInfo.getAssetEpc())
					{
						clsGridInfo.setProcCount((clsGridInfo.getProcCount() + 1)) // 처리량 증가
						
						var intGridRemainCount = clsGridInfo.getRemainCount()
						if(intGridRemainCount > 0)
						{
							intGridRemainCount = intGridRemainCount - 1
							clsGridInfo.setRemainCount(intGridRemainCount) // 미처리량 감소
						}
					}
				}
			}
		}
		DispatchQueue.main.async { self.tvCombineIn?.reloadData() }
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        //tableView.allowsSelection = false           //셀 선택안되게 막음
		let objCell:CombineInCell = tableView.dequeueReusableCell(withIdentifier: "tvcCombineIn", for: indexPath) as! CombineInCell
		let clsTagInfo = arrAssetRows[indexPath.row]
		
		objCell.lblAssetName.text		= clsTagInfo.getAssetName()
		objCell.lblWorkAssignCount.text = "\(clsTagInfo.getWorkAssignCount())"
		objCell.lblProcCount.text		= "\(clsTagInfo.getProcCount())"
		objCell.lblRemainCount.text		= "\(clsTagInfo.getRemainCount())"
		
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
				
				if(self.strSaleWorkId.isEmpty == false)
				{
					self.doReloadTagList()	// 초기화
				}
				else
				{
					self.clearTagData(clearScreen: false)
					super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
				}
				},
				cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
	}
	
	
	// 작업초기화
	@IBAction func onWorkInitClick(_ sender: UIButton)
	{
		if(strSaleWorkId.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_select_sale_work_id", comment: "조회된 송장번호가 없습니다."))
			return
		}
		
		Dialog.show(container: self, viewController: nil,
					title: NSLocalizedString("common_task_init", comment: "작업초기화"),
					message: NSLocalizedString("common_confirm_work_Init", comment: "현재 작업을 초기화 하시겠습니까 ?"),
					okTitle: NSLocalizedString("common_confirm", comment: "확인"),
					okHandler: { (_) in
						self.sendWorkInitData(resaleOrderId: self.strResaleOrderId, saleWorkId: self.strSaleWorkId)
		},
					cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
	}
	
	
	// 임시저장
	@IBAction func onTempSaveClick(_ sender: UIButton)
	{
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		
		if(self.strSaleWorkId.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_enter_your_work_id", comment: "송장번호를 입력하여 주십시오."))
			return
		}
		
		if(self.boolNewTagInfoExist == false)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		// 납품(지서서O) 입고 처리
		if(self.strWorkType == Constants.RESALE_TYPE_DELIVERY)
		{
			if((self.intProcCount + self.intNoreadCnt) > self.intOrderReqCount)
			{
				// 처리수량이 예정수량보다 큽니다.(입고불가)
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_processing_qty_work_require_qty", comment: "처리수량은 예정수량을 초과할 수 없습니다. 다시 확인해 주세요."))
				return
			}
		}
		
		let strVehName		= self.tfVehName?.text ?? ""
		let strDriverName	= self.lblDriverName.text ?? ""
		self.strWorkState	= Constants.WORK_STATE_WORKING	//작업상태 '01'-임시저장
		//DB로 데이터 전송 처리
		sendData(workState: self.strWorkState, resaleOrderId: self.strResaleOrderId, saleWorkId: self.strSaleWorkId, vehName: strVehName, driverName: strDriverName, orderReqCount: self.intOrderReqCount, noReadCount: self.intNoreadCnt, remark: "", workerName: "", signData: "")
	}
	
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		
		// 차량번호 필수
		let strVehName = tfVehName?.text ?? ""
		if(strVehName.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_enter_vehicle_number", comment: "차량번호를 입력하여 주십시오."))
			return
		}
		
		let strSaleWorkId = btnSaleWorkId.titleLabel?.text
		if(strSaleWorkId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_enter_your_work_id", comment: "송장번호를 입력하여 주십시오."))
			return
		}
		
		
		// 납품입고(지시서O) 처리
		if(self.strWorkType == Constants.RESALE_TYPE_DELIVERY)
		{
			if(self.intProcCount == self.intOrderReqCount)
			{
				//1)처리량 == 출고예정
				self.strWorkState = Constants.WORK_STATE_COMPLETE
			}
			else if(self.intProcCount > self.intOrderReqCount)
			{
				//2)처리량 >출고예정
				self.strWorkState = ""
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_processing_qty_work_require_qty", comment: "처리수량은 예정수량을 초과할 수 없습니다. 다시 확인해 주세요."))
				return
			}
			else if(self.intProcCount < self.intOrderReqCount)
			{
				//3)처리량 <출고예정
				if(AppContext.sharedManager.getUserInfo().getInAgreeYn() == Constants.AUTO_COMPLETED_AGGREMENT_YES)
				{
					self.strWorkState = Constants.WORK_STATE_COMPLETE	//3-1) 자동승인 'Y' -> 완료처리(상태값02)
				}
				else
				{
					self.strWorkState = Constants.WORK_STATE_ONGOING	//3-2) 자동승인 'N' -> 처리진행(상태값04)
				}
			}
		}
		else if(self.strWorkType == Constants.RESALE_TYPE_RETURN)
		{
			// 4)이동입고
			if(AppContext.sharedManager.getUserInfo().getInAgreeYn() == Constants.AUTO_COMPLETED_AGGREMENT_YES)
			{
				self.strWorkState = Constants.WORK_STATE_COMPLETE	//4-1) 자동승인 'Y' -> 완료처리(상태값02)
			}
			else
			{
				
				self.strWorkState = Constants.WORK_STATE_ONGOING	//4-2) 자동승인 'N' -> 처리진행(상태값04)
			}
		}
		else
		{
			
			self.strWorkState = Constants.WORK_STATE_COMPLETE		//3-1) 자동승인 'Y' -> 완료처리(상태값02)
		}
		
		
		self.performSegue(withIdentifier: "segInSignDialog", sender: self)
	}
	
	
	// 초기화 버튼 처리, 태그 리스트 재조회
	func doReloadTagList()
	{
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "inOutService:selectSaleInWorkList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.strSaleWorkId)
		clsDataClient.addServiceParam(paramName: "pageNo", value: 1)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: 300)
		
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
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
				self.strResaleOrderId			= clsDataRow.getString(name: "resaleOrderId") ?? ""		// 구매주문ID
				self.strSaleWorkId 				= clsDataRow.getString(name: "saleWorkId") ?? ""		// 송장번호
				self.intOrderReqCount 			= clsDataRow.getInt(name: "orderReqCnt") ?? 0
				self.intProcCount				= clsDataRow.getInt(name: "procCnt") ?? 0				// 처리량
				self.intNoreadCnt				= clsDataRow.getInt(name: "noreadCnt") ?? 0				// 미인식
				self.strWorkerName				= clsDataRow.getString(name: "workerName") ?? ""		// 작업자명
				self.strProdAssetEpc			= clsDataRow.getString(name: "prodAssetEpc") ?? ""		// 유형
				var intRemainCnt				= self.intOrderReqCount - self.intProcCount				// 미처리량
				if(intRemainCnt < 0)
				{
					intRemainCnt = 0										//미처리량 0이하는 0
				}
				
                DispatchQueue.main.async
                {
                    self.lblResaleBranchName.text	= clsDataRow.getString(name: "resaleBranchName") ?? ""	// 출고처
                    self.btnSaleWorkId.setTitle(self.strSaleWorkId, for: .normal)							// 송장번호
                    self.lblOrderReqCount.text		= "\(self.intOrderReqCount)"							// 입고예정수량
                    self.lblProcCount.text			= "\(self.intProcCount)"								// 처리량
                    //self.tfVehName.text				= clsDataRow.getString(name: "resaleVehName") ?? ""	// 차량번호
                    self.lblDriverName.text			= clsDataRow.getString(name: "resaleDriverName") ?? ""	// 납품자
                    self.lblProdAssetEpcName.text	= clsDataRow.getString(name: "prodAssetEpcName") ?? ""	// 유형명
                    self.lblRemainCount.text		= "\(intRemainCnt)"										// 미처리량
                }
				
				//2) 태그데이터 초기화
				self.clearTagData(clearScreen: false)
				
				
				//3)조회 및 그리드 리스트에 표시
				
				self.doSearchWorkListDetail()		//선택된 '송장정보' 내용 조회
				self.doSearchTagList()				//선택된 '송장정보'에 대한 태그리스트
				
				self.boolWorkListSelected = true	//송장 선택 여부
				super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
			}
		})
	}
	
	
	
	// 송장조회 상세
	func doSearchWorkListDetail()
	{
		print("=========================================")
		print("*doSearchWorkListDetail")
		print("=========================================")
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "inOutService:selectCombineInWorkListDetail"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.strSaleWorkId)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
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
				let intProcCount		= clsDataRow.getInt(name: "procCnt") ?? 0
				let intWorkAssignCount	= clsDataRow.getInt(name: "workAssignCnt") ?? 0
				let intRemainCount		= clsDataRow.getInt(name: "remainCnt") ?? 0
				let strProdAssetEpc		= clsDataRow.getString(name: "prodAssetEpc") ?? ""
				let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
				
				let clsTagInfo = RfidUtil.TagInfo()
				clsTagInfo.setAssetEpc(strProdAssetEpc)
				clsTagInfo.setAssetName(strProdAssetEpcName)
				clsTagInfo.setProcCount(intProcCount)
				clsTagInfo.setWorkAssignCount(intWorkAssignCount)
				clsTagInfo.setRemainCount(intRemainCount)
			
				print("====================================")
				print(" -ProdAssetEpc:\(strProdAssetEpc)")
				print(" -ProdAssetEpcName:\(strProdAssetEpcName)")
				print("====================================")
				
				//그리드 리스트에 추가
				self.arrAssetRows.append(clsTagInfo)
			}
			DispatchQueue.main.async
			{
				self.tvCombineIn.reloadData()
			}
		})
	}
	
	
	// 송장조회(번호)에 대한 상세 태그리스트
	func doSearchTagList()
	{
		print("=========================================")
		print("*doSearchTagList, strResaleOrderId:\(strResaleOrderId)")
		print("=========================================")
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "supplyService:selectSaleInTagList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "resaleOrderId", value: self.strResaleOrderId)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
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
				let strEpcCode			= clsDataRow.getString(name: "epcCode") ?? ""
				let strEpcUrn 			= clsDataRow.getString(name: "epcUrn") ?? ""
				let strUtcTraceDate 	= clsDataRow.getString(name: "utcTraceDate") ?? ""
				let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
				
				let clsTagInfo = RfidUtil.TagInfo()
				clsTagInfo.setEpcCode(strEpcCode)
				clsTagInfo.setAssetName(strProdAssetEpcName)
				
				if(strEpcUrn.isEmpty == false)
				{
					clsTagInfo.setEpcUrn(strEpcUrn)
					let arsEpcUrn = strEpcUrn.split(".")
					if( arsEpcUrn.count == 4)
					{
						let strCorpEpc	= arsEpcUrn[ 1]
						let strAssetEpc	= arsEpcUrn[ 2]
						let strSerialNo	= arsEpcUrn[ 3]
						
						let strNewAssetEpc = "\(strCorpEpc)\(strAssetEpc)"
						
						print("=============================================")
						print("strCorpEpc:\(strCorpEpc)")
						print("strNewAssetEpc:\(strNewAssetEpc)")
						print("strSerialNo:\(strSerialNo)")
						print("=============================================")
						
						clsTagInfo.setAssetEpc(strNewAssetEpc)
						clsTagInfo.setSerialNo(strSerialNo)
					}
				}
				
				if(strUtcTraceDate.isEmpty == false)
				{
					let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate, dateFormat: "yyyyMMddHHmmss")
					clsTagInfo.setReadTime(strLocaleTraceDate)
				}
				
				self.arrTagRows.append(clsTagInfo)
			}
			
		})
		
	}
	
	// 작업초기화 데이터를 전송한다
	func sendWorkInitData(resaleOrderId: String, saleWorkId: String)
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inOutService:executeInCancelData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "resaleOrderId", value: resaleOrderId)
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: saleWorkId)
		clsDataClient.executeData(dataCompletionHandler: { (data, error) in
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
				let strResultCode = clsDataRow.getString(name: "resultCode")
				
				print(" -strResultCode:\(strResultCode!)")
				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
				{
					//DispatchQueue.main.async
                    //{
							// 초기화 처리
							self.doReloadTagList()
							
							// self.doReloadTagList() 에서 하므로 주석처리
							//let strMsg = NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다.")
							//self.showSnackbar(message: strMsg)
					//}
				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
			
		})
	}
	
	
	func sendData(workState: String, resaleOrderId: String, saleWorkId: String, vehName: String, driverName: String, orderReqCount: Int, noReadCount: Int, remark: String, workerName: String, signData: String)
	{
		/**
		* 1. 전송 완료후, 'boolNewTagInfoExist = false' 처리
		* 2. 전송 완료후, 전송된 태그들을 리스트에서 'setNewTagInfo(false)' 처리 -> 재 전송 방지
		*/
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inOutService:executeInData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "workState",		value: strWorkState)
		clsDataClient.addServiceParam(paramName: "corpId",			value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId",			value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "branchId",		value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "unitId",			value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "inAgreeYn",		value: AppContext.sharedManager.getUserInfo().getInAgreeYn())	//입고자동승인여부
		clsDataClient.addServiceParam(paramName: "resaleOrderId",	value: resaleOrderId)
		clsDataClient.addServiceParam(paramName: "saleWorkId",		value: saleWorkId)
		clsDataClient.addServiceParam(paramName: "vehName",			value: vehName)
		clsDataClient.addServiceParam(paramName: "driverName",		value: driverName)
		clsDataClient.addServiceParam(paramName: "workerName",		value: workerName)
		clsDataClient.addServiceParam(paramName: "barcodeId",		value: "")	// 바코드ID
		clsDataClient.addServiceParam(paramName: "itemCode",		value: "")	// 제품 코드
		clsDataClient.addServiceParam(paramName: "prodCnt",			value: "")	// 제품 개수
		clsDataClient.addServiceParam(paramName: "easyInProcess",	value: "N")	// 입고B타입
		
		//완료전송 및(강제)완료전송, 처리진행인경우
		if(Constants.WORK_STATE_COMPLETE == workState || Constants.WORK_STATE_COMPLETE_FORCE == workState || Constants.WORK_STATE_ONGOING == workState)
		{
			let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
			let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
			clsDataClient.addServiceParam(paramName: "workDateTime",	value: strWorkDateTime)
			
			clsDataClient.addServiceParam(paramName: "orderReqCount",	value: orderReqCount)
			clsDataClient.addServiceParam(paramName: "procCount",		value: self.intProcCount)	// 처리량
			clsDataClient.addServiceParam(paramName: "noReadCount",		value: noReadCount)
			clsDataClient.addServiceParam(paramName: "remark",			value: remark)
			clsDataClient.addServiceParam(paramName: "forceYn",			value: "Y")
			
			if(signData.isEmpty == false)
			{
				clsDataClient.addServiceParam(paramName: "signData",	value: signData)		// 사인데이터
			}
			
			self.boolWorkCompleteBtn = true
		}
		
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "WORK_IN"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "traceDateTime", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		
		for clsInfo in self.arrTagRows
		{
			if(clsInfo.getNewTag() == true)
			{
				let strTraceDate = DateUtil.localeToUtc(localeDate: clsInfo.getReadTime(), dateFormat: "yyyyMMddHHmmss")
				let clsDataRow : DataRow = DataRow()
				clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
				clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
				clsDataRow.addRow(name:"traceDateTime", value: strTraceDate)
				clsDataTable.addDataRow(dataRow: clsDataRow)
			}
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			self.clsIndicator?.hide()
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
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
					//let strSvrProcCount = clsDataRow.getString(name: "procCount")
					//let strSvrWorkState = clsDataRow.getString(name: "workState")
					//print("-서버로부터 받은 처리갯수: \(strSvrProcCount)")
					//print("-서버로부터 받은 작업처리상태:  \(strSvrWorkState)")
					
					DispatchQueue.main.async
						{
							// 전송 성공인 경우
							for clsInfo in self.arrTagRows
							{
                                clsInfo.setNewTag(false)	// 태그상태 NEW -> OLD로 변경
							}
							self.boolNewTagInfoExist = false
							
							// 현재 작업상태가 완료전송인경우
							if(self.boolWorkCompleteBtn == true)
							{
								// 송장정보관련 UI객체를 초기화한다.
								self.clearTagData(clearScreen: true)
							}
							let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
							self.showSnackbar(message: strMsg)
					}
				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
		})
		
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
	
	
	//========================================================================
	// 바코드 관련 이벤트및 처리 시작
	//------------------------------------------------------------------------
	func initBarcodeScanner()
	{
		BarcodeScanner.Title.text = NSLocalizedString("common_barcode_search", comment: "바코드")
		BarcodeScanner.CloseButton.text = NSLocalizedString("common_close", comment: "닫기")
		BarcodeScanner.SettingsButton.text = "설정"
		BarcodeScanner.Info.text = NSLocalizedString("msg_default_status", comment: "바코드를 사각형 안으로 넣어주세요.")
		BarcodeScanner.Info.notFoundText = NSLocalizedString("common_no_data_for_barcode", comment: "해당 바코드에 해당하는 데이터가 없습니다.")
		
		BarcodeScanner.Info.loadingText = NSLocalizedString("common_progressbar_loading", comment: "로딩 중 입니다.")
		//		BarcodeScanner.Info.settingsText = NSLocalizedString("In order to scan barcodes you have to allow camera under your settings.", comment: "")
		
		//		// Fonts
		//		BarcodeScanner.Title.font = UIFont.boldSystemFont(ofSize: 17)
		//		BarcodeScanner.CloseButton.font = UIFont.boldSystemFont(ofSize: 17)
		//		BarcodeScanner.SettingsButton.font = UIFont.boldSystemFont(ofSize: 17)
		//		BarcodeScanner.Info.font = UIFont.boldSystemFont(ofSize: 14)
		//		BarcodeScanner.Info.loadingFont = UIFont.boldSystemFont(ofSize: 16)
		//
		//		// Colors
		//		BarcodeScanner.Title.color = UIColor.black
		//		BarcodeScanner.CloseButton.color = UIColor.black
		//		BarcodeScanner.SettingsButton.color = UIColor.white
		//	/Users/roy/Projects/32.RRPPSolutions/02.Solutions/RRPPSolution/RRPPClient/CombineIn/CombineIn.swift	BarcodeScanner.Info.textColor = UIColor.black
		//		BarcodeScanner.Info.tint = UIColor.black
		//		BarcodeScanner.Info.loadingTint = UIColor.black
		//		BarcodeScanner.Info.notFoundTint = UIColor.red
		//
	}
	
	
	@IBAction func onBarcodeSearchClicked(_ sender: UIButton)
	{
		clsBarcodeScanner = BarcodeScannerController()
		clsBarcodeScanner?.codeDelegate = self
		clsBarcodeScanner?.errorDelegate = self
		clsBarcodeScanner?.dismissalDelegate = self
		
		// 모달로 띄운다.
		clsBarcodeScanner?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
		present(clsBarcodeScanner!, animated: true, completion: nil)
	}
	
	func doSearchBarcode(barcode: String)
	{
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "inOutService:selectSaleInWorkList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: barcode)
		clsDataClient.addServiceParam(paramName: "resaleType", value: self.strWorkType)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
				print(error)
				return
			}
			guard let clsDataTable = data else {
				print("에러 데이터가 없음")
				return
			}
			if(clsDataTable.getDataRows().count == 0)
			{
				super.showSnackbar(message: NSLocalizedString("common_no_data_for_barcode", comment: "해당 바코드에 해당하는 데이터가 없습니다."))
				return
			}
			
			self.clearTagData(clearScreen: true)
			
			let clsDataRow = clsDataTable.getDataRows()[0]
			self.strResaleOrderId			= clsDataRow.getString(name: "resaleOrderId") ?? ""			// 구매주문ID
			self.strSaleWorkId 				= clsDataRow.getString(name: "saleWorkId") ?? ""			// 송장번호
			self.intOrderReqCount 			= clsDataRow.getInt(name: "orderReqCnt") ?? 0
			self.intProcCount				= clsDataRow.getInt(name: "procCnt") ?? 0					// 처리량
			self.intNoreadCnt				= clsDataRow.getInt(name: "noreadCnt") ?? 0					// 미인식
			self.strWorkerName				= clsDataRow.getString(name: "workerName") ?? ""			// 작업자명
			self.strProdAssetEpc			= clsDataRow.getString(name: "prodAssetEpc") ?? ""			// 유형
			var intRemainCnt				= self.intOrderReqCount - self.intProcCount					// 미처리량
			if(intRemainCnt < 0)
			{
				intRemainCnt = 0										//미처리량 0이하는 0
			}
			
			self.lblResaleBranchName.text	= clsDataRow.getString(name: "resaleBranchName") ?? ""		// 출고처
			self.btnSaleWorkId.setTitle(self.strSaleWorkId, for: .normal)								// 송장번호
			self.lblOrderReqCount.text		= "\(self.intOrderReqCount)"								// 입고예정수량
			self.lblProcCount.text			= "\(self.intProcCount)"									// 처리량
			//self.tfVehName.text				= clsDataRow.getString(name: "resaleVehName") ?? ""		// 차량번호
			self.lblDriverName.text			= clsDataRow.getString(name: "resaleDriverName") ?? ""		// 납품자
			self.lblProdAssetEpcName.text	= clsDataRow.getString(name: "prodAssetEpcName") ?? ""		// 유형명
			self.lblRemainCount.text		= "\(intRemainCnt)"											// 미처리량
			
			// 조회 및 그리드 리스트에 표시
			
			self.doSearchWorkListDetail()		//선택된 '송장정보' 내용 조회
			self.doSearchTagList()				//선택된 '송장정보'에 대한 태그리스트
			
			self.boolWorkListSelected = true	//송장 선택 여부
		})
	}
	//------------------------------------------------------------------------
	// 바코드 관련 이벤트및 처리 끝
	//========================================================================
	
}

extension CombineIn: BarcodeScannerCodeDelegate
{
	func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode barcode: String, type: String)
	{
		print("================================")
		print(" - Barcode Data: \(barcode)")
		print(" - Symbology Type: \(type)")
		print("================================")
		controller.dismiss(animated: true, completion: nil)
		if(barcode.isEmpty == false)
		{
			if(strSaleWorkId.isEmpty == false)
			{
				// 새로운 발주번호가 들어오면 기존 데이터는 삭제한다.
				clearTagData(clearScreen: true)
				
				if(strSaleWorkId != barcode)
				{
					doSearchBarcode(barcode: barcode)
				}
			}
			else
			{
				doSearchBarcode(barcode: barcode)
			}
		}
	}
}

extension CombineIn: BarcodeScannerErrorDelegate {
	
	func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error)
	{
		print(error)
	}
}

extension CombineIn: BarcodeScannerDismissalDelegate {
	
	func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
		controller.dismiss(animated: true, completion: nil)
	}
}


extension CombineIn
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		//tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		if(self.strTitle.isEmpty == false)
		{
			tc.toolbar.title = strTitle
		}
		else
		{
			tc.toolbar.title = NSLocalizedString("title_work_in_warehouse", comment: "입고")
		}
	}
}

