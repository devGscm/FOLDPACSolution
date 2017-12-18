//
//  EasyIn.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 18..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic
import BarcodeScanner

class EasyIn: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{

	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var btnResaleWorkId: UIButton!
	@IBOutlet weak var btnBarcodeSearch: UIButton!
	@IBOutlet weak var btnWorkCustSearch: UIButton!
	@IBOutlet weak var tfVehName: UITextField!
	@IBOutlet weak var tfTradeChit: UITextField!
	@IBOutlet weak var lblProcCount: UILabel!
	@IBOutlet weak var tvEasyIn: UITableView!
	
	var strResaleBranchId		= ""
	var strResaleBranchName		= ""
	
	var strResaleOrderId		= ""		/**< 송장번호ID - DB에서 할당받은 */
	var intProcCount 			= 0			/**< 처리량 */
	var boolNewTagInfoExist							= false		/**< 신규태그 - 신규태그가 있는지 여부 -전소용 */
	
	
	var boolExistSavedInvoice	= false		/**< 송장번호ID - DB에서 할당받았는지 여부 */
	var strSaleWorkId			= ""		/**< 송장번호 */
	
	
	
	
	
	
	
	var strTitle	= ""
	

	
	
	

	var strProdAssetEpc								= ""			/**< 유형 */
	var intOrderReqCount							= 0			/**< 출고량 */
	var boolWorkListSelected						= false		/**< 송장-선택 했는지 여부 */
	
	
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
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*EasyIn.viewWillAppear()")
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
	
	override func didUnload(to viewController: UIViewController, completion: ((Bool) -> Void)? = nil)
	{
		print("=========================================")
		print("*ProdMappingOut.didUnload()")
		print("=========================================")
		
		if(self.strResaleOrderId.isEmpty == false)
		{
			// TransitionController에서 다른화면으로 이동못하도록 false 처리를 한다.
			super.setUnload(unload: false)
			
			Dialog.show(container: self, viewController: nil,
				title: NSLocalizedString("common_confirm", comment: "확인"),
				message: NSLocalizedString("easy_process_exist_message", comment: "임시 저장된 데이터가 지워집니다. 종료 하시겠습니까?"),
				okTitle: NSLocalizedString("common_confirm", comment: "확인"),
				okHandler: { (_) in
					
					// 작업 취소처리
					self.sendWorkInitData(resaleOrderId: self.strResaleOrderId)
				
					// 확인이 끝나면 다른 화면으로 이동한다.
					self.toolbarController?.transition(to: viewController, completion: completion)
					return
				},
				cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: { (_) in
					completion!(false)
				}
			)
		}
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewDidDisappear()")
		print("=========================================")
		
		boolNewTagInfoExist = false
		
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
		
		lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
	}

	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segEasyInSearch")
		{
			// 송장조회
			if let clsDialog = segue.destination as? EasyInSearch
			{
				clsDialog.ptcDataHandler = self
			}
		}
			
		else if(segue.identifier == "segWorkCustSearch")
		{
			// 고객사 조회
			if let clsDialog = segue.destination as? WorkCustSearch
			{
				clsDialog.inOutType = Constants.INOUT_TYPE_INPUT
				clsDialog.ptcDataHandler = self
			}
		}
			
		else if(segue.identifier == "segOutSignDialog")
		{
			if let clsDialog = segue.destination as? OutSignDialog
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
		//송장번호가 있는경우, 새로운 입고처가 들어오면 기존 데이터를 삭제한다.
		if(boolExistSavedInvoice == true)
		{
			clearTagData(clearScreen: true)
		}
		
		if(returnData.returnType == "easyInSearch")
		{
			// 송장조회
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow

				self.strResaleOrderId		= clsDataRow.getString(name: "resaleOrderId") ?? ""
				self.strSaleWorkId 			= clsDataRow.getString(name: "saleWorkId") ?? ""
				let strResaleBranchName		= clsDataRow.getString(name: "resaleBranchName") ?? ""	// 출고처명
				
				self.btnWorkCustSearch.setTitle(strResaleBranchName, for: UIControlState.normal)			// 출고처
				self.btnResaleWorkId.setTitle(strSaleWorkId, for: UIControlState.normal)					// 송장번호
				
				// 태그리스트 재조회
				doReloadTagList(showInitMsg: false)
			}
		}
		if(returnData.returnType == "workCustSearch")
		{
			// 고객사 조회
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strCustName = clsDataRow.getString(name: "custName") ?? ""
				self.strResaleBranchId	= clsDataRow.getString(name: "branchId") ?? ""
				self.btnWorkCustSearch.setTitle(strCustName, for: .normal)	// 출고처
			}
		}
		else if(returnData.returnType == "outSignDialog")
		{
			// 전송
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strRemark		= clsDataRow.getString(name: "remark") ?? ""
				let strSignData		= clsDataRow.getString(name: "signData") ?? ""
				let strVehName		= tfVehName?.text ?? ""
				let strTradeChit	= tfTradeChit?.text ?? ""
				
				if self.strResaleOrderId.isEmpty == false
				{
					//DB로 데이터 전송 처리
					sendDataExistResaleOrderId(workState: Constants.WORK_STATE_COMPLETE, resaleOrderId: self.strResaleOrderId, vehName: strVehName, tradeChit: strTradeChit, remark: strRemark, signData: strSignData)
				}
				else
				{
					sendDataNoneResaleOrderId(workState: Constants.WORK_STATE_COMPLETE, resaleCustId: self.strResaleBranchId, vehName: strVehName, tradeChit: strTradeChit, remark: strRemark, signData: strSignData)
				}
			}
		}
	}
	

	
	@IBAction func onResaleWorkIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segEasyInSearch", sender: self)
	}
	
	
	@IBAction func onWorkCustSearchClicked(_ sender: UIButton) {
	}
	
	// 데이터를 clear한다.
	func clearTagData(clearScreen : Bool)
	{
		self.boolNewTagInfoExist = false	// 신규태그 입력 체크, 전송용
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		
		DispatchQueue.main.async
		{
			self.tvEasyIn?.reloadData()
		}
		
		if(clearScreen == true)
		{
			strResaleOrderId		= ""
			intProcCount			= 0
			strResaleBranchId		= ""
			boolExistSavedInvoice	= false	//'송장번호'할당여부

			DispatchQueue.main.async
			{
				self.btnResaleWorkId.setTitle(NSLocalizedString("sale_work_id_selection", comment: "송장선택"), for: .normal)
				self.btnWorkCustSearch.setTitle(NSLocalizedString("title_easy_cust_selection", comment: "고객사 선택"), for: .normal)
				self.lblProcCount.text			= "0"	// 처리수량
				self.tfVehName.text				= ""	// 차량번호
				self.tfTradeChit.text			= ""	// 전표번호
			}
		}
		
		// RFID리더기 초기화
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
				
				self.intProcCount = Int(lblProcCount?.text ?? "0")! + 1 // 처리량
				lblProcCount?.text = "\(self.intProcCount)"
			}
		}
		DispatchQueue.main.async { self.tvEasyIn?.reloadData() }
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:EasyInCell = tableView.dequeueReusableCell(withIdentifier: "tvcEasyIn", for: indexPath) as! EasyInCell
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
			
			// 송장번호 할당된 경우
			if(self.boolExistSavedInvoice == true)
			{
				self.doReloadTagList(showInitMsg: true)
			}
			else
			{
				self.clearTagData(clearScreen: true)
				super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
			}
		},
		cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
	}
	
	
	// 작업초기화
	@IBAction func onWorkInitClick(_ sender: UIButton)
	{
		if(strResaleOrderId.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_temporary_saved_data", comment: "임시 저장된 데이터가 없습니다."))
			return
		}
		
		Dialog.show(container: self, viewController: nil,
			title: NSLocalizedString("common_task_init", comment: "작업초기화"),
			message: NSLocalizedString("common_confirm_work_Init", comment: "현재 작업을 초기화 하시겠습니까 ?"),
			okTitle: NSLocalizedString("common_confirm", comment: "확인"),
			okHandler: { (_) in
				self.sendWorkInitData(resaleOrderId: self.strResaleOrderId)
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
		
		if(self.boolNewTagInfoExist == false)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		let strVehName		= self.tfVehName?.text ?? ""
		let strTradeChit	= self.tfTradeChit.text ?? ""
		
		if(self.strResaleOrderId.isEmpty == false)
		{
			// 송장번호 O, DB로 데이터 전송 처리
			sendDataExistResaleOrderId(workState: Constants.WORK_STATE_WORKING, resaleOrderId: self.strResaleOrderId, vehName: strVehName, tradeChit: strTradeChit, remark: "", signData: "")
		}
		else
		{
			// 송장번호 X , 송장번호(ResaleOrderId) 발급후 DB로 데이터 전송 처리
			sendDataNoneResaleOrderId(workState: Constants.WORK_STATE_WORKING, resaleCustId: self.strResaleBranchId, vehName: strVehName, tradeChit: strTradeChit, remark: "", signData: "")
		}
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
		
		if(self.arrTagRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		self.performSegue(withIdentifier: "segOutSignDialog", sender: self)
	}
	
	
	// 초기화 버튼 처리, 태그 리스트 재조회
	func doReloadTagList(showInitMsg : Bool)
	{
		// 1) 태그리스트 초기화
		clearTagData(clearScreen: false)
		
		
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "supplyService:selectSaleInTagList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "resaleOrderId", value: self.strResaleOrderId)
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
			
			let intDataRowsSize = clsDataTable.getDataRows().count
			
			self.lblProcCount.text = "\(intDataRowsSize)"								// 처리량
			
			if( intDataRowsSize > 0)
			{
				for clsDataRow in clsDataTable.getDataRows()
				{
					let strEpcCode			= clsDataRow.getString(name: "epcCode") ?? ""
					let strEpcUrn 			= clsDataRow.getString(name: "epcUrn") ?? ""
					let strUtcTraceDate 	= clsDataRow.getString(name: "utcTraceDate") ?? ""
					let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
					
					let strProdAssetEpc 	= clsDataRow.getString(name: "prodAssetEpc") ?? ""
					//let strTradeChit		= clsDataRow.getString(name: "tradeChit") ?? ""
					//let strVehName 			= clsDataRow.getString(name: "vehName") ?? ""
					
					// DB에서 조회된 태그 데이터 전달용 리스트에 저장
					let clsTagInfo = RfidUtil.TagInfo()
					clsTagInfo.setEpcCode(strEpcCode)
					clsTagInfo.setAssetName(strProdAssetEpcName)
					if(strEpcUrn.isEmpty == false)
					{
						clsTagInfo.setEpcUrn(strEpcUrn)
						let arsEpcUrn = strEpcUrn.split(".")
						if( arsEpcUrn.count == 4)
						{
							let strSerialNo	= arsEpcUrn[ 3]
							clsTagInfo.setSerialNo(strSerialNo)
						}
					}
					clsTagInfo.setAssetEpc(strProdAssetEpc)
					clsTagInfo.setAssetName(strProdAssetEpcName)
					clsTagInfo.setReadCount(1)
					
					if(strUtcTraceDate.isEmpty == false)
					{
						let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate, dateFormat: "yyyyMMddHHmmss")
						clsTagInfo.setReadTime(strLocaleTraceDate)
					}
					
					self.arrTagRows.append(clsTagInfo)
				
					
					var boolFindAssetTypeOverlap = false
					
					//자산타입 증복확인 및 조회수를 업데이트한다.
					for clsInfo in self.arrAssetRows
					{
						//같은 Asset_Epc가 있다면
						if(clsInfo.getAssetEpc() == strProdAssetEpc)
						{
							boolFindAssetTypeOverlap = true
							let intCurReadCount = clsInfo.getReadCount()
							clsInfo.setReadCount(intCurReadCount + 1)
							break
						}
					}
					
					//자산타입이 중복되지 않으면, 그리드용 리스트에 삽입
					if(boolFindAssetTypeOverlap == false)
					{
						self.arrAssetRows.append(clsTagInfo)
					}
				}
				
				DispatchQueue.main.async
				{
					self.tvEasyIn.reloadData()
				}
				
				// 초기화버튼 처리의 경우
				if(showInitMsg == true)
				{
					super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
				}
				
			}
		})
	}
	
	
	
	// 송장조회 상세
	func doSearchWorkListDetail()
	{
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
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
				
				//그리드 리스트에 추가
				self.arrAssetRows.append(clsTagInfo)
			}
			DispatchQueue.main.async
				{
					self.tvEasyIn.reloadData()
			}
		})
	}
	
	
	// 송장조회(번호)에 대한 상세 태그리스트
	func doSearchTagList()
	{
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
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
	func sendWorkInitData(resaleOrderId: String)
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inOutService:executeInCancelData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "resaleOrderId", value: resaleOrderId)

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
					// 삭제성공
					//그리드 삭제 및 구조체 삭제
					DispatchQueue.main.async
					{
						self.clearTagData(clearScreen: true)
						if(super.getUnload() == true)
						{
							let strMsg = NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다.")
							self.showSnackbar(message: strMsg)
						}
					}
				}
				else
				{
					if(super.getUnload() == true)
					{
						let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
						self.showSnackbar(message: strMsg)
					}
				}
			}
		})
	}
	
	
	
	/**
	* 데이터를 서버로 전송 한다.
	* @param strWorkState			출하구분
	* @param strResaleOrderId		송장번호
	* @param strRemark				처리메모
	* @param strSignData			사인
	*/
	func sendDataExistResaleOrderId(workState: String, resaleOrderId: String, vehName: String, tradeChit: String, remark : String, signData: String)
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inOutService:executeInData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "inAgreeYn", 		value: AppContext.sharedManager.getUserInfo().getInAgreeYn()) // 입고자동승인여부
		clsDataClient.addServiceParam(paramName: "workState", 		value: workState)
		clsDataClient.addServiceParam(paramName: "workState",		value: strWorkState)
		clsDataClient.addServiceParam(paramName: "resaleOrderId",	value: strResaleOrderId)
		clsDataClient.addServiceParam(paramName: "vehName",			value: vehName)
		clsDataClient.addServiceParam(paramName: "easyInProcess",	value: "Y")	// 입고B타입
		clsDataClient.addServiceParam(paramName: "barcodeId",		value: "")	// 바코드ID
		clsDataClient.addServiceParam(paramName: "itemCode",		value: "")	// 제품 코드
		clsDataClient.addServiceParam(paramName: "prodCnt",			value: "")	// 제품 개수
	
	
		// 완료전송 및(강제)완료전송 경우
		if(Constants.WORK_STATE_COMPLETE == workState || Constants.WORK_STATE_COMPLETE_FORCE == workState)
		{
			let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
			let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
			clsDataClient.addServiceParam(paramName: "workDateTime",	value: strWorkDateTime)
			clsDataClient.addServiceParam(paramName: "workerName",		value: "")
			clsDataClient.addServiceParam(paramName: "tradeChit",		value: tradeChit)
			clsDataClient.addServiceParam(paramName: "remark",			value: remark)
			clsDataClient.addServiceParam(paramName: "forceYn",			value: "Y")
			if(signData.isEmpty == false)
			{
				clsDataClient.addServiceParam(paramName: "signData",	value: signData)		//사인데이터
			}
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
					let strSvrProcCount = clsDataRow.getString(name: "procCount")
					let strSvrWorkState = clsDataRow.getString(name: "workState")
					//print("-서버로부터 받은 처리갯수: \(strSvrProcCount)")
					//print("-서버로부터 받은 작업처리상태:  \(strSvrWorkState)")
					
					DispatchQueue.main.async
					{
							// 전송 성공인 경우
							for clsInfo in self.arrTagRows
							{
								if(clsInfo.getNewTag() == true)
								{
									clsInfo.setNewTag(false)	// 태그상태 NEW -> OLD로 변경
								}
							}
							self.boolNewTagInfoExist = false
							self.boolExistSavedInvoice = true	// 송장번호 할당여부
							
							// 현재 작업상태가 완료전송인경우
							if(Constants.WORK_STATE_COMPLETE == strSvrWorkState || Constants.WORK_STATE_COMPLETE_FORCE == strSvrWorkState)
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
					
					if(Constants.PROC_RESULT_ERROR_NEED_WORK_COMPLETE_FORCE == strResultCode)
					{
						// TAGID가 해당거점에 이미 입고처리가 되어져 있습니다. 그래도 입고처리하겠습니까?
						// TODO
						var strDialogMessage = strMsg
						if(strMsg.isEmpty == true)
						{
							strDialogMessage = NSLocalizedString("msg_error_need_work_complete_force", comment: "입고처리 하고자 하는 파렛트 중, 해당 거점에 이미 입고되어 있는 파렛트가 존재합니다. 해당 파렛트를 제외하고 입고처리됩니다. 계속하시겠습니까?")
						}
						
						Dialog.show(container: self, viewController: nil,
							title: NSLocalizedString("common_confirm", comment: "확인"),
							message: strDialogMessage,
							okTitle: NSLocalizedString("common_confirm", comment: "확인"),
							okHandler: { (_) in
								let strVehName		= self.tfVehName.text ?? ""
								let strTradeChit	= self.tfTradeChit.text ?? ""
								// 서버 전송 처리
								self.sendDataExistResaleOrderId(workState: Constants.WORK_STATE_COMPLETE_FORCE, resaleOrderId: self.strResaleOrderId, vehName: strVehName, tradeChit: strTradeChit, remark: remark, signData: signData)
					
							},
							cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
						
					}
					else if((Constants.PROC_RESULT_ERROR_NO_REGISTERED_READERS == strResultCode) || (Constants.PROC_RESULT_ERROR_NO_MATCH_BRANCH_CUST_INFO == strResultCode))
					{
						super.showSnackbar(message: NSLocalizedString("common_error", comment: "에러"))
					}
					else
					{
						self.showSnackbar(message: strMsg)
					}
					
					if(self.strResaleOrderId.isEmpty == false)
					{
						// 완료전송 처리중 오류시 발번받은 송장번호 초기화
						self.sendWorkInitData(resaleOrderId: self.strResaleOrderId)	// 초기화
						self.boolNewTagInfoExist = false
						self.boolExistSavedInvoice = true
						
						self.clearTagData(clearScreen: true)
					}
					
				}
			}
		})
	}
	
	
	/**
	* 송장번호를 발급후, 데이터를 서버로 전송 한다.
	*/

	func sendDataNoneResaleOrderId(workState: String, resaleCustId: String, vehName: String, tradeChit: String, remark: String, signData: String)
	{
		/*
		DataTable clsDataTable = null;
		DataClient clsDataClient = new DataClient(this);
		
		clsDataClient.setLocation(mCtxContext.getString(R.string.webservice_data_url));
		clsDataClient.setUserInfo(AppContext.getUserInfo().getEncryptId());
		clsDataClient.setServiceUrl("inOutService:selectResaleOrderId");
		clsDataClient.addServiceParam("corpId", 		AppContext.getUserInfo().getCorpId());
		clsDataClient.addServiceParam("branchId",		AppContext.getUserInfo().getBranchId());
		
		if(strResaleCustId != null) clsDataClient.addServiceParam("fromBranchId",	strResaleCustId);
		clsDataClient.addServiceParam("userId",			AppContext.getUserInfo().getUserId());
		
		try
	{
		clsDataTable = clsDataClient.selectData();
		
		if(clsDataTable == null)
		{
		if(clsDataClient.getReturnCode() == Constants.RETURN_CODE_AUTHENTICATE_FAIL)
		{
		showNewLoginDialogOnThread();
		}
		else
		{
		showToastOnThread(getString(R.string.common_not_load_data_from_server));
		}
		return;
		}
		
		//2)DB에서 리스트 조회값 받음
		List<DataRow> lstDataRows = clsDataTable.getDataRows();
		
		if( lstDataRows.size() > 0)
		{
		for(DataRow clsRow : lstDataRows)
		{
		mStrResaleOrderId = clsRow.getString("resultResaleOrderId");	//서버에서 발급 받은 '입고지서서ID(송장번호)'
		}
		
		//#2.DB로 데이터 저장하기
		sendDataExistResaleOrderId(strWorkState, mStrResaleOrderId, strVehName, strTradeChit, strRemark, strSignData);
		}
		}
		catch (Exception e)
		{
		showToastOnThread(getString(R.string.common_error_occurred_data_search));
		Logger.e(StrUtil.trace(e));
		}
		*/
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
		//		BarcodeScanner.Info.textColor = UIColor.black
		//		BarcodeScanner.Info.tint = UIColor.black
		//		BarcodeScanner.Info.loadingTint = UIColor.black
		//		BarcodeScanner.Info.notFoundTint = UIColor.red
		//
		
		clsBarcodeScanner = BarcodeScannerController()
		clsBarcodeScanner?.codeDelegate = self
		clsBarcodeScanner?.errorDelegate = self
		clsBarcodeScanner?.dismissalDelegate = self
	}
	
	
	@IBAction func onBarcodeSearchClicked(_ sender: UIButton)
	{
		// 모달로 띄운다.
		clsBarcodeScanner?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
		present(clsBarcodeScanner!, animated: true, completion: nil)
	}
	
	func doSearchBarcode(barcode: String)
	{
//		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
//		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
//		clsDataClient.SelectUrl = "inOutService:selectSaleInWorkList"
//		clsDataClient.removeServiceParam()
//		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
//		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
//		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
//		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
//		clsDataClient.addServiceParam(paramName: "saleWorkId", value: barcode)
//		clsDataClient.addServiceParam(paramName: "resaleType", value: self.strWorkType)
//		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
//			if let error = error {
//				// 에러처리
//				super.showSnackbar(message: error.localizedDescription)
//				print(error)
//				return
//			}
//			guard let clsDataTable = data else {
//				print("에러 데이터가 없음")
//				return
//			}
//			if(clsDataTable.getDataRows().count == 0)
//			{
//				super.showSnackbar(message: NSLocalizedString("common_no_data_for_barcode", comment: "해당 바코드에 해당하는 데이터가 없습니다."))
//				return
//			}
//
//			self.clearTagData(clearScreen: true)
//
//			let clsDataRow = clsDataTable.getDataRows()[0]
//			self.strResaleOrderId			= clsDataRow.getString(name: "resaleOrderId") ?? ""			// 구매주문ID
//			self.strSaleWorkId 				= clsDataRow.getString(name: "saleWorkId") ?? ""			// 송장번호
//			self.intOrderReqCount 			= clsDataRow.getInt(name: "orderReqCnt") ?? 0
//			self.intProcCount				= clsDataRow.getInt(name: "procCnt") ?? 0					// 처리량
//			self.intNoreadCnt				= clsDataRow.getInt(name: "noreadCnt") ?? 0					// 미인식
//			self.strWorkerName				= clsDataRow.getString(name: "workerName") ?? ""			// 작업자명
//			self.strProdAssetEpc			= clsDataRow.getString(name: "prodAssetEpc") ?? ""			// 유형
//			var intRemainCnt				= self.intOrderReqCount - self.intProcCount					// 미처리량
//			if(intRemainCnt < 0)
//			{
//				intRemainCnt = 0										//미처리량 0이하는 0
//			}
//
//			self.lblResaleBranchName.text	= clsDataRow.getString(name: "resaleBranchName") ?? ""		// 출고처
//			self.btnResaleWorkId.setTitle(self.strSaleWorkId, for: .normal)								// 송장번호
//			self.lblOrderReqCount.text		= "\(self.intOrderReqCount)"								// 입고예정수량
//			self.lblProcCount.text			= "\(self.intProcCount)"									// 처리량
//			//self.tfVehName.text				= clsDataRow.getString(name: "resaleVehName") ?? ""		// 차량번호
//			self.lblDriverName.text			= clsDataRow.getString(name: "resaleDriverName") ?? ""		// 납품자
//			self.lblProdAssetEpcName.text	= clsDataRow.getString(name: "prodAssetEpcName") ?? ""		// 유형명
//			self.lblRemainCount.text		= "\(intRemainCnt)"											// 미처리량
//
//			// 조회 및 그리드 리스트에 표시
//
//			self.doSearchWorkListDetail()		//선택된 '송장정보' 내용 조회
//			self.doSearchTagList()				//선택된 '송장정보'에 대한 태그리스트
//
//			self.boolWorkListSelected = true	//송장 선택 여부
//		})
	}
	//------------------------------------------------------------------------
	// 바코드 관련 이벤트및 처리 끝
	//========================================================================
	
}

extension EasyIn: BarcodeScannerCodeDelegate
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
		//		let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		//		DispatchQueue.main.asyncAfter(deadline: delayTime) {
		//			controller.resetWithError()
		//		}
	}
}

extension EasyIn: BarcodeScannerErrorDelegate {
	
	func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error)
	{
		print(error)
	}
}

extension EasyIn: BarcodeScannerDismissalDelegate {
	
	func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
		controller.dismiss(animated: true, completion: nil)
	}
}


extension EasyIn
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		if(self.strTitle.isEmpty == false)
		{
			tc.toolbar.detail = strTitle
		}
		else
		{
			tc.toolbar.detail = NSLocalizedString("title_work_in_warehouse", comment: "입고")
		}
	}
}


