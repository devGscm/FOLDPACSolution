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
import Foundation

class ProdMappingOut: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{

	class ProdReadCntGestureRecognizer: UITapGestureRecognizer
	{
		var indexNo: Int = -1
	}
	

	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var btnToBranchSearch: UIButton!
	
	
    @IBOutlet weak var tfVehName: UITextField!
    @IBOutlet weak var lblProcCount: UILabel!
    @IBOutlet weak var tfTradeChit: UITextField!
    
    @IBOutlet weak var lblAssetName: UILabel!
    @IBOutlet weak var lblSerialNo: UILabel!
    
	@IBOutlet weak var btnProductAdd: UIButton!
	
	@IBOutlet weak var btnProdBarcode: UIButton!
	@IBOutlet weak var tvMappingRfid: UITableView!
	@IBOutlet weak var tvMappingProd: UITableView!


	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
    
	
    var strToBranchId    = ""    // 출하고객사ID
    
    //==== Ver2.0.0 ====
    var strSaleWorkId = ""	/**< 송장번호ID - DB에서 할당받은 */
    var intProcCount			= 0		/**< 처리량 */
    var arrRfidRows : Array<ItemInfo> = Array<ItemInfo>()        /**< 데이터 리스트 - 마스터 ITEM데이터, 그리드 표출용 */
    var arrProdRows : Array<ItemInfo> = Array<ItemInfo>()        /**< 데이터 리스트 - 슬래이브 ITEM데이터, 그리드 표출용 */
	
	var boolNewTagInfoExist		= false	/**< 신규태그 - 신규태그가 있는지 여부 -전송용 */
	var boolExistSavedInvoice	= false	/**< 송장번호ID - DB에서 할당받았는지 여부 */
	var	intIDSystem 			= -1	/**< 환경설정값:바코드/QR코드	*/
    var strSelectedEpcCode		= ""	/**< 선택된 시리얼의 EPC 코드    */
    var strSelectedProdCode		= ""	/**< 선택된 시리얼의 상품 코드    */
    var intSelectedProdIndex	= -1	/**< 선택된 상품의 인덱스    */
    var intSelectedIndex		= -1
    
    var clsProdContainer: ProdContainer!
	
	var strSegueType			= ""	/**< 세그웨이 타임 */
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProdMappingOut.viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		// RFID를 처리할 델리게이트 지정
		self.initRfid( self as ReaderResponseDelegate )
		
		initViewControl()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProdMappingOut.viewDidAppear()")
		print("=========================================")
		super.viewDidAppear(animated)
		//initTestProcess()
	}
	
	override func didUnload(to viewController: UIViewController, completion: ((Bool) -> Void)? = nil)
	{
		print("=========================================")
		print("*ProdMappingOut.didUnload()")
		print("=========================================")
	
		if(self.strSaleWorkId.isEmpty == false)
		{
			// TransitionController에서 다른화면으로 이동못하도록 false 처리를 한다.
			super.setUnload(unload: false)
			
			Dialog.show(container: self, viewController: nil,
						title: NSLocalizedString("common_confirm", comment: "확인"),
						message: NSLocalizedString("easy_process_exist_message", comment: "임시 저장된 데이터가 지워집니다. 종료 하시겠습니까?"),
						okTitle: NSLocalizedString("common_confirm", comment: "확인"),
						okHandler: { (_) in
							
							// 작업 취소처리
							self.sendWorkInitData(saleWorkId: self.strSaleWorkId)

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
	
	override func viewWillDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProdMappingOut.viewWillDisappear()")
		print("=========================================")
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProdMappingOut.viewDidDisappear()")
		print("=========================================")
		
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
		lblReaderName.text = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY)
        
        lblProcCount.text = "0"
		
		intIDSystem = UserDefaults.standard.integer(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
		if(intIDSystem == Constants.IDENTIFICATION_SYSTEM_GTIN14)
		{
			btnProdBarcode.setTitle(NSLocalizedString("common_read_itf14", comment: "바코드"), for: .normal)
		}
		else
		{
			btnProdBarcode.setTitle(NSLocalizedString("common_read_aqgr", comment: "QR코드"), for: .normal)
		}
        clsProdContainer = ProdContainer()
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
		
		if(segue.identifier == "segProdInfoDialog")
		{
			if let clsDialog = segue.destination as? ProdInfoDialog
			{
				clsDialog.segueType = self.strSegueType
				if(self.strSegueType == "editProduct" && self.intSelectedProdIndex > -1)
				{
					clsDialog.itemInfo = arrProdRows[self.intSelectedProdIndex]
				}
				clsDialog.ptcDataHandler = self
			}
		}
		
		if(segue.identifier == "segOutSignDialog")
		{
			if let clsDialog = segue.destination as? OutSignDialog
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
				let strCustName = clsDataRow.getString(name: "custName") ?? ""
				self.strToBranchId	= clsDataRow.getString(name: "branchId") ?? ""
	        	self.btnToBranchSearch.setTitle(strCustName, for: .normal)
			}
		}
		else if(returnData.returnType == "addProduct")
		{
			// 상품 등록
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strProdCode	= clsDataRow.getString(name: "prodCode") ?? ""
				let strProdName	= clsDataRow.getString(name: "prodName") ?? ""
				let strProdReadCnt	= clsDataRow.getString(name: "prodReadCnt") ?? ""
				
				print("@@@@@@@@@@@@@ prodCode:\(strProdCode)")
				
				// 상품코드 입력확인
				if(strProdCode.isEmpty == false)
				{
					var boolAbnormalProdCode = false
					
					//이상 유무 판단
					if(intIDSystem == Constants.IDENTIFICATION_SYSTEM_GTIN14 && strProdCode.length == Constants.READING_LANGTH_BARCODE)
					{
						//바코드 처리
						boolAbnormalProdCode = false
					}
					else if(intIDSystem == Constants.IDENTIFICATION_SYSTEM_AGQR && strProdCode.length == Constants.READING_LANGTH_QRCODE)
					{
						//농산물(QR코드)
						boolAbnormalProdCode = false
					}
					else
					{
						boolAbnormalProdCode = true
						
						Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_error_product_code", comment: "상품코드 오류"))
						return
					}
					
					// 이상없을시 처리 프로세스
					if(boolAbnormalProdCode == false)
					{
						//2)DB에서 상품명 조회
						loadProdName(processType: "addProduct", prodCode: strProdCode, prodReadCnt: strProdReadCnt)
					}
				}
				else
				{
					Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_enter_product_code", comment: "상품코드를 입력하여 주십시오."))
					return
				}
			}
		}
		else if(returnData.returnType == "editProduct")
		{
			// 상품정보 수정
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strProdCode		= clsDataRow.getString(name: "prodCode") ?? ""
				let strProdName		= clsDataRow.getString(name: "prodName") ?? ""
				let strProdReadCnt	= clsDataRow.getString(name: "prodReadCnt") ?? ""
				
				print("@@@@@@@@@@@@@ prodCode:\(strProdCode)")
				print("@@@@@@@@@@@@@ strProdName:\(strProdName)")
				print("@@@@@@@@@@@@@ strProdReadCnt:\(strProdReadCnt)")
				
				let clsItemInfo = arrProdRows[self.intSelectedProdIndex]
				
				let clsNewItemInfo = ItemInfo()
				if(clsItemInfo.getSaleItemSeq().isEmpty == true)
				{
					clsNewItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)	//태그 신규여부 상태값 변경
				}
				else
				{
					//임시 저장된 경우 - Rowstate를 Modified로 변경
					clsNewItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_MODIFIED)	//태그 신규여부 상태값 변경
					boolNewTagInfoExist = true	//전송 가능하도록
				}
				clsNewItemInfo.setProdCode(prodCode: strProdCode)
				clsNewItemInfo.setProdName(prodName: strProdName)
				clsNewItemInfo.setProdReadCnt(prodReadCnt: strProdReadCnt)	//인식 수량 변경
				clsProdContainer.updateItem(epcCode: strSelectedEpcCode, prodCode: strProdCode, itemInfo: clsNewItemInfo)
			
	
				//서브그리드에 반영
				arrProdRows[self.intSelectedProdIndex] = clsNewItemInfo
				
				DispatchQueue.main.async
				{
					self.tvMappingProd.reloadData()
				}
				//mLstItemListSlaveRows.clear();
				//mLstItemListSlaveRows.addAll(mClsProdContainer.getItemes(strSelectedEpcCode));
				//mClsAdapterSlave.notifyDataSetChanged();
			}
		}
		else if(returnData.returnType == "outSignDialog")
		{
			// 상품정보 수정
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strRemark		= clsDataRow.getString(name: "remark") ?? ""
				let strSignData		= clsDataRow.getString(name: "signData") ?? ""
				
				print("@@@@@@@@@@@@@ strRemark:\(strRemark)")
				print("@@@@@@@@@@@@@ strSignData:\(strSignData)")
				
				let strVehName		= tfVehName?.text ?? ""
				let strTradeChit	= tfTradeChit?.text ?? ""
				
				if strSaleWorkId.isEmpty == false
				{
					//DB로 데이터 전송 처리
					sendDataExistSaleWorkId(workState: Constants.WORK_STATE_COMPLETE, saleWorkId: self.strSaleWorkId, vehName: strVehName, tradeChit: strTradeChit, remark: strRemark, signData: strSignData)
				}
				else
				{
					sendDataNoneSaleWorkId(workState: Constants.WORK_STATE_COMPLETE, toBranchId: self.strToBranchId, vehName: strVehName, tradeChit: strTradeChit, remark: strRemark, signData: strSignData)
				}
				
			}
		}
	}
	

	
	
	
	// 입고처 선택
	@IBAction func onWorkOutCustSearchClicked(_ sender: Any)
	{
		self.performSegue(withIdentifier: "segWorkOutCustSearch", sender: self)
	}
    
    // 상품추가
    @IBAction func onProductAddClicked(_ sender: UIButton)
    {
        if(self.lblSerialNo.text?.isEmpty == true)
        {
            super.showSnackbar(message: NSLocalizedString("msg_no_selected_serial_no", comment: "시리얼번호를 선택하여 주십시오."))
            return
        }
        
        // 리더기 읽기 중지
        if(super.isConnected() == true)
        {
        	stopRead()
        }
		self.strSegueType = "addProduct"
		self.performSegue(withIdentifier: "segProdInfoDialog", sender: self)
    }
    

    // 바코드 버튼
    @IBAction func onProdBarcodeClicked(_ sender: UIButton)
    {
		// 마스터 그리드에서 상품이 선택된 경우만 진입.
		if(lblSerialNo.text?.isEmpty == false)
		{
			//리더기 읽기 중지
			if(isConnected() == true)
			{
				stopRead()
			}
			
			if(intIDSystem == Constants.IDENTIFICATION_SYSTEM_GTIN14)
			{
				if(sender.isSelected == false)
				{
					sender.isSelected = true
					setRederMode(ReaderSenssorMode.BARCODE)
					btnProdBarcode.setTitle(NSLocalizedString("common_read_rfid", comment: "RFID태그"), for: .normal)
				}
				else
				{
					sender.isSelected = false
					setRederMode(ReaderSenssorMode.RFID)
					btnProdBarcode.setTitle(NSLocalizedString("common_read_itf14", comment: "바코드"), for: .normal)
				}
			}
			else
			{
				if(sender.isSelected == false)
				{
					sender.isSelected = true
					setRederMode(ReaderSenssorMode.BARCODE)
					btnProdBarcode.setTitle(NSLocalizedString("common_read_rfid", comment: "RFID태그"), for: .normal)
				}
				else
				{
					sender.isSelected = false
					setRederMode(ReaderSenssorMode.RFID)
					btnProdBarcode.setTitle(NSLocalizedString("common_read_aqgr", comment: "QR코드"), for: .normal)
				}
			}
		}
		else
		{
			super.showSnackbar(message: NSLocalizedString("msg_no_selected_serial_no", comment: "시리얼번호를 선택하여 주십시오."))
		}
    }
	
    
	// 데이터를 clear한다.
    func clearTagData( boolClearScreen: Bool)
	{
		self.boolNewTagInfoExist = false // 신규태그 입력 체크, 전송용
		
		self.arrRfidRows.removeAll()
		self.arrProdRows.removeAll()
		
		
		self.intSelectedIndex = -1
		
		DispatchQueue.main.async
		{
			self.tvMappingRfid.reloadData()
			self.tvMappingProd.reloadData()
		
			// 바코드 버튼
			if(self.intIDSystem == Constants.IDENTIFICATION_SYSTEM_GTIN14)
			{
				self.btnProdBarcode.setTitle(NSLocalizedString("common_read_itf14", comment: "바코드"), for: .normal)
			}
			else
			{
				self.btnProdBarcode.setTitle(NSLocalizedString("common_read_aqgr", comment: "QR코드"), for: .normal)
			}
		}
		
		if(isConnected() == true)
		{
			stopRead()	//리더기 읽기 중지
		}
		
		setRederMode(ReaderSenssorMode.RFID)	//리더기 모드 초기화

		//헤시맵 클리어
		clsProdContainer.clear()

		//작업자,거점명을 제외한 모든 데이터 초기화
		if(boolClearScreen == true)
		{
			self.strToBranchId = ""
			btnToBranchSearch.setTitle(NSLocalizedString("title_easy_cust_selection", comment: "고객사 선택"), for: .normal)
		
			tfVehName.text			= ""	// 차량번호
			tfTradeChit.text		= ""	// 전표번호
			strSaleWorkId			= ""
			intProcCount			= 0
			intSelectedProdIndex	= -1
			strSelectedEpcCode		= ""
			strSelectedProdCode		= ""
			boolExistSavedInvoice	= false	//'송장번호'할당여부
			boolNewTagInfoExist 	= false
		}

		lblSerialNo.text	= ""	// 시리얼 번호
		lblAssetName.text	= ""	// 유형
		lblProcCount.text	= "0"	// 처리수량

		// RFID리더기 초기화
		clearInventory()
	
	}
	
	func getRfidData(clsTagInfo : RfidUtil.TagInfo)
	{
        let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
        let strSerialNo = clsTagInfo.getSerialNo()
        let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드

		// RFID 태그 데이터 처리
		let strEpcCode	= clsTagInfo.getEpcCode()
		
		let clsEpcInfo = ItemInfo()
		clsEpcInfo.setEpcCode(epcCode: strEpcCode)
		clsEpcInfo.setEpcUrn(epcUrn: clsTagInfo.getEpcUrn())
		clsEpcInfo.setSerialNo(serialNo: strSerialNo)
		clsEpcInfo.setAssetEpc(assetEpc: strAssetEpc)
		clsEpcInfo.setReadCount(readCount: 1)
		clsEpcInfo.setReadTime(readTime: strCurReadTime)
		if(clsTagInfo.getAssetEpc().isEmpty == false)
		{
			let strAssetName = super.getAssetName(assetEpc: strAssetEpc)
			clsEpcInfo.setAssetName(assetName: strAssetName)
		}
		
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
				break
			}
		}
		print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
		if(boolValidAsset == true)
		{
			for clsTagInfo in arrRfidRows
			{
				// 같은 시리얼번호가 있는지 체크
				if(clsTagInfo.getSerialNo() == strSerialNo)
				{
					print(" 동일한 시리얼번호 존재")
					boolFindSerialNoOverlap = true
					break
				}
			}
			
			// 시리얼번호가 중복이 안되어 있다면
			if(boolFindSerialNoOverlap == false)
			{
				// 1) 신규태그 입력 체크
				self.boolNewTagInfoExist = true
				
				// 2) 읽은 바코드/QR 코드 수량 갱신(처리량 증가)
				self.intProcCount = Int(lblProcCount.text ?? "0")!
				self.intProcCount = self.intProcCount + 1
				lblProcCount.text = "\(self.intProcCount)"
				
				self.arrRfidRows.append(clsEpcInfo)
			}
		}
		
		DispatchQueue.main.async { self.tvMappingRfid?.reloadData() }
		if(strEpcCode.isEmpty == false)
		{
			clsProdContainer.addProdEpc(epcCode: strEpcCode)
		}
		
	}
	
	
	func getBarcodeData(clsTagInfo : RfidUtil.TagInfo)
	{
		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
		//let strSerialNo = clsTagInfo.getSerialNo()
		//let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드
	
		// 바코드(ITF-14)/QR코드(농산물) 처리
		let strSelectedSerialNo = lblSerialNo.text ?? ""
		
		var boolFindProdCodeOverlap = false
		
		if(strSelectedSerialNo.isEmpty == false)
		{
			let strProdCode = clsTagInfo.getEpcCode()
			print("=============================")
			print(" - 입력상품_코드: \(strProdCode)")
			print("=============================")
		
			
			//슬래이브-그리드용 태그 리스트
			for clsInfo in arrProdRows
			{
				//같은 상품코드가 있다면
				if(clsInfo.getProdCode() == strProdCode)
				{
					print("*중복 상품코드 : \(strProdCode)")
					//Logger.i("=============================");
					
					boolFindProdCodeOverlap = true
					break
				}
			}
			
			if(boolFindProdCodeOverlap == false)
			{
				//1)신규태그 입력 체크
				boolNewTagInfoExist = true
				
				//2)DB에서 상품명 조회
				loadProdName(processType: "barcode", prodCode: strProdCode, prodReadCnt: "")
			}
		}
	}
	

	func clearUserInterfaceData()
	{
        strToBranchId = ""
		btnToBranchSearch.setTitle(NSLocalizedString("common_selection", comment: "선택"), for: .normal)
		//처리메모
		
		// TODO
		//final EditText etRemark	 = (EditText)findViewById(R.id.etRemark);
		//if(etRemark != null) etRemark.setText("");
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if(tableView == tvMappingRfid)
		{
			return self.arrRfidRows.count
		}
		else
		{
			return self.arrProdRows.count
		}
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if(tableView == tvMappingRfid)
		{
			let objCell:MappingRfidCell = tableView.dequeueReusableCell(withIdentifier: "tvcMappingRfid", for: indexPath) as! MappingRfidCell
			let clsTagInfo = arrRfidRows[indexPath.row]
            objCell.lblAssetName.text = clsTagInfo.getAssetName()
            objCell.lblSerialNo.text = clsTagInfo.getSerialNo()
            objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
            objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
            objCell.btnSelection.tag = indexPath.row
            objCell.btnSelection.addTarget(self, action: #selector(onTagSelectionClicked(_:)), for: .touchUpInside)
			return objCell
		}
		else
		{
			let objCell:MappingProdCell = tableView.dequeueReusableCell(withIdentifier: "tvcMappingProd", for: indexPath) as! MappingProdCell
            let clsProdInfo = arrProdRows[indexPath.row]
            objCell.lblProdCode.text = clsProdInfo.getProdCode()
            objCell.lblProdName.text = clsProdInfo.getProdName()
			
            //mClsViewWrapper.tvSaleItemSeq.setText(clsDataRow.getSaleItemSeq());
 
			objCell.lblProdReadCnt.attributedText = NSAttributedString(string: clsProdInfo.getProdReadCnt(),
						   attributes: [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
			
			objCell.lblProdReadCnt.isUserInteractionEnabled = true
			let tgrProdReadCnt = ProdReadCntGestureRecognizer(target: self, action: #selector((onProdReadCntClicked)))
			tgrProdReadCnt.indexNo = indexPath.row
			objCell.lblProdReadCnt.addGestureRecognizer(tgrProdReadCnt)
			

            objCell.btnDelete.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
			objCell.btnDelete.backgroundColor = Color.red.darken1
            objCell.btnDelete.setTitle(String.fontAwesomeIcon(name:.close), for: .normal)
            objCell.btnDelete.tag = indexPath.row
            objCell.btnDelete.addTarget(self, action: #selector(onProdDeleteClicked(_:)), for: .touchUpInside)
			return objCell
		}
	}
	
    @objc func onTagSelectionClicked(_ sender: UIButton)
    {
        let clsDataRow = arrRfidRows[sender.tag]
        
        if(lblSerialNo.text != clsDataRow.getSerialNo())
        {
            lblSerialNo.text = clsDataRow.getSerialNo()
            lblAssetName.text = clsDataRow.getAssetName()
            strSelectedEpcCode = clsDataRow.getEpcCode()
            
            //선택된 인덱스, 색상변경
			//self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            //setSelectedIndex(intPosition);
            
            //슬래이브-그리드 초기화
            arrProdRows.removeAll()
            
            
            //선택된 RFID태그에 대한 바코드리스트
            if(self.lblSerialNo.text?.isEmpty == false)
            {
                let arrProds = clsProdContainer.getItemes(epcCode: strSelectedEpcCode)
                if(arrProds.count > 0)
                {
                    arrProdRows.append(contentsOf: arrProds)
                }
            }
            
			
			DispatchQueue.main.async
			{
				//슬래이브-그리드 업데이트
				self.tvMappingProd.reloadData()
		
    	        //처리량
        	    self.lblProcCount.text = "\(self.arrProdRows.count)"
			}
        }
    }
    
    @objc func onProdDeleteClicked(_ sender: UIButton)
    {
		print("=====================================")
		print("*onProdDeleteClicked()")
		print("=====================================")
		let clsProdInfo = arrProdRows[sender.tag]
		let strProdCode = clsProdInfo.getProdCode()
		
		print("@@@@strProdCode:\(strProdCode))")

		//헤시맵과 그리드뷰에서 제거
		let	intRowState = clsProdContainer.deleteItem(epcCode: strSelectedEpcCode, prodCode: clsProdInfo.getProdCode(), removeState: Constants.REMOVE_STATE_NORMAL)
		print(" - intRowState : \(intRowState)")
		
		
		if( intRowState == Constants.DATA_ROW_STATE_ADDED)
		{
			print(" 삭제1")
			arrProdRows.removeAll()
			print(" 삭제2")
			
			let arrItems = clsProdContainer.getItemes(epcCode: strSelectedEpcCode)
			
			print(" 삭제3:\(arrItems.count)")
			
			arrProdRows.append(contentsOf: arrItems)
			print(" 삭제4")
			DispatchQueue.main.async
			{
				self.tvMappingProd.reloadData()
			}
		}
		else
		{
			// 델리트
			let arrItemList = clsProdContainer.getItemes(epcCode: strSelectedEpcCode)
			for clsItemInfo in arrItemList
			{
				if(clsItemInfo.getProdCode() == clsProdInfo.getProdCode())
				{
					self.strSelectedProdCode = clsProdInfo.getProdCode()    //선택한 상품코드
					sendDeleteItemInfo(saleItemSeq: clsItemInfo.getSaleItemSeq(), prodCode: self.strSelectedProdCode)
					break
				}
			}
		}
    }
	
	// 인식수량 클릭시
	@objc func onProdReadCntClicked(sender: ProdReadCntGestureRecognizer)
	{
		self.intSelectedProdIndex = sender.indexNo
		self.tvMappingProd.selectRow(at: IndexPath(row: sender.indexNo, section: 0), animated: true, scrollPosition: .none)
		self.strSegueType = "editProduct"
		self.performSegue(withIdentifier: "segProdInfoDialog", sender: self)
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
        if(strSaleWorkId.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_temporary_saved_data", comment: "임시 저장된 데이터가 없습니다."))
            return
        }

        Dialog.show(container: self, viewController: nil,
                    title: NSLocalizedString("common_task_init", comment: "작업초기화"),
                    message: NSLocalizedString("common_confirm_work_Init", comment: "현재 작업을 초기화 하시겠습니까 ?"),
                    okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                    okHandler: { (_) in
                        self.sendWorkInitData(saleWorkId: self.strSaleWorkId)
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
		
		if(strToBranchId.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_selected_out_cust", comment: "입고처를 선택하여 주십시오."))
			return
		}
		
		if(boolNewTagInfoExist == false)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		let strVehName		= tfVehName?.text ?? ""
		let strTradeChit	= tfTradeChit?.text ?? ""
		
		if(strSaleWorkId.isEmpty == false)
		{
			//DB로 데이터 전송 처리
			sendDataExistSaleWorkId(workState: Constants.WORK_STATE_WORKING, saleWorkId: strSaleWorkId, vehName: strVehName, tradeChit: strTradeChit, remark: "", signData: "")
		}
		else
		{
			//'SaleWorkId'발급 후, DB로 데이터 전송처리
			sendDataNoneSaleWorkId(workState: Constants.WORK_STATE_WORKING, toBranchId: strToBranchId, vehName: strVehName, tradeChit: strTradeChit, remark: "", signData: "")
		}
	}
	
	
	// 완료 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}

		
		//입고처 필수
		if(strToBranchId.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_selected_out_cust", comment: "입고처를 선택하여 주십시오."))
			return
		}
		
		// 차량번호 필수
		if(tfVehName.text?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_enter_vehicle_number", comment: "차량번호를 입력하여 주십시오."))
			return
		}
		
		// 마스터 그리드에 데이터 있는지 판단.
		if(arrRfidRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		self.performSegue(withIdentifier: "segOutSignDialog", sender: self)
	}
	
	
	func doReloadTagList(reoadStatus: Int)
	{
		
		var strEpcCode				= ""
		var strProdAssetEpcName 	= ""
		var strSerialNo 			= ""


		
		// 1) 태그데이터 초기화
		clearTagData(boolClearScreen: false)
		
		let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "supplyService:selectProdMappingOutTagList" //출고C타입용 (출고A,B타입과 다름)
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: strSaleWorkId)
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
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
				let strEpcUrn 			= clsDataRow.getString(name: "epcUrn") ?? ""
				strEpcCode				= clsDataRow.getString(name: "epcCode") ?? ""
				let strUtcTraceDate 	= clsDataRow.getString(name: "utcTraceDate") ?? ""
				let strProdAssetEpc 	= clsDataRow.getString(name: "prodAssetEpc") ?? ""
				strProdAssetEpcName		= clsDataRow.getString(name: "prodAssetEpcName") ?? ""
				let strBarcodeId 		= clsDataRow.getString(name: "barcodeId") ?? ""
				let strSaleItemSeq 		= clsDataRow.getString(name: "saleItemSeq") ?? ""
				//let strItemCode 		= clsDataRow.getString(name: "itemCode") ?? ""
				let strItemName 		= clsDataRow.getString(name: "itemName") ?? ""
				let strCnt 				= clsDataRow.getString(name: "cnt") ?? ""
				//let strTradeChit		= clsDataRow.getString(name: "tradeChit") ?? ""
				//let strVehName 			= clsDataRow.getString(name: "vehName") ?? ""
				
				// 날짜 포맷 변환
				let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate, dateFormat: "yyyyMMddHHmmss")
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
				
				// 마스터-RFID태그정보
				let clsMastItemInfo = ItemInfo()
				clsMastItemInfo.setEpcCode(epcCode: strEpcCode)
				clsMastItemInfo.setEpcUrn(epcUrn: strEpcUrn)
				clsMastItemInfo.setSerialNo(serialNo: strSerialNo)
				clsMastItemInfo.setAssetEpc(assetEpc: strProdAssetEpc)
				clsMastItemInfo.setAssetName(assetName: strProdAssetEpcName)
				clsMastItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
				clsMastItemInfo.setReadCount(readCount: 1)
				clsMastItemInfo.setReadTime(readTime: strTraceDate)
				
				//슬래이브-상품정보
				let clsSlaveItemInfo = ItemInfo()
				clsSlaveItemInfo.setEpcCode(epcCode: strEpcCode)
				clsSlaveItemInfo.setSaleItemSeq(saleItemSeq: strSaleItemSeq)
				clsSlaveItemInfo.setProdCode(prodCode: strBarcodeId)
				clsSlaveItemInfo.setProdName(prodName: strItemName)
				clsSlaveItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
				clsSlaveItemInfo.setProdReadCnt(prodReadCnt: strCnt)
				clsSlaveItemInfo.setReadTime(readTime: strTraceDate)
				
				// #1.헤시맵 생성
				if(self.clsProdContainer.containEpcCode(epcCode: strEpcCode) == false)
				{
					// #1-1.구조체 수정
					self.clsProdContainer.loadProdEpc(epcCode: strEpcCode)
					
					// #1-2.마스터 그리스 저장
					self.arrRfidRows.append(clsMastItemInfo)
				}
				
				// #2.아이템 생성-바코드ID가 있는경우
				if(strBarcodeId.isEmpty == false)
				{
					self.clsProdContainer.addItem(epcCode: strEpcCode, itemInfo: clsSlaveItemInfo)
					
					//#3.서브 그리드 저장
					self.arrProdRows.append(clsSlaveItemInfo)
				}
			}
			
			// 3)'처리량' 텍스트박스에 표시
			self.lblProcCount.text = "\(self.arrRfidRows.count)"
			
			
			// 4)그리드 업데이트
			self.tvMappingRfid?.reloadData()
			self.tvMappingProd?.reloadData()
			
			// 5)마지막 마스터 그리드가 선택되게 만들기
			self.strSelectedEpcCode = strEpcCode
			
			self.lblSerialNo?.text = strSerialNo
			self.lblAssetName?.text = strProdAssetEpcName
			
			super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
		})
	}
	
	
	// 초기화 버튼 처리, 태그리스트 재조회
    func doChangeStatus()
    {
		do
		{
			let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
			clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
			clsDataClient.SelectUrl = "supplyService:selectProdMappingOutTagList"
			clsDataClient.removeServiceParam()
			clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
			clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
			clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.strSaleWorkId)
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
				
				for clsDataRow in clsDataTable.getDataRows()
				{
					let strEpcCode			= clsDataRow.getString(name: "epcCode") ?? ""
					let strBarcodeId 		= clsDataRow.getString(name: "barcodeId") ?? ""
					let strSaleItemSeq 		= clsDataRow.getString(name: "saleItemSeq") ?? ""

					
					//마스터-RFID태그정보
					let clsMastItemInfo = ItemInfo()
					clsMastItemInfo.setEpcCode(epcCode: strEpcCode)
					clsMastItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
					
					//슬래이브-상품정보
					let clsSlaveItemInfo = ItemInfo()
					clsSlaveItemInfo.setEpcCode(epcCode: strEpcCode)
					clsSlaveItemInfo.setSaleItemSeq(saleItemSeq: strSaleItemSeq)
					clsSlaveItemInfo.setProdCode(prodCode: strBarcodeId)
					clsSlaveItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
					
					//아이템 생성-바코드ID가 있는경우
					if(strBarcodeId.isEmpty == false)
					{
						// 서브 저장 클래스 변경
						self.clsProdContainer.updateItem(epcCode: strEpcCode, prodCode: strBarcodeId, itemInfo: clsSlaveItemInfo)
					}
					else
					{
						//마스터 저장 클래스 변경
						self.clsProdContainer.updateEpc(epcCode: strEpcCode, itemInfo: clsMastItemInfo)
					}
				}

			})
		}
		catch let error
		{
            super.showSnackbar(message: NSLocalizedString("common_error_occurred_data_search", comment: "데이터 검색중 에러가 발생하였습니다."))
			print(error.localizedDescription)
		}
    }
    
    
    // 작업초기화 데이터를 전송한다.
    func sendWorkInitData(saleWorkId : String)
    {
		do
    	{
            clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
            
            let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
            clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
            clsDataClient.ExecuteUrl = "inOutService:executeOutCancelData"
            clsDataClient.removeServiceParam()
            clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
            clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
            clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
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
                        // 삭제성공
                        //그리드 삭제 및 구조체 삭제
                        DispatchQueue.main.async
                    	{
							self.clearTagData(boolClearScreen: true)
							
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
        catch let error
        {
			clsIndicator?.hide()
            super.showSnackbar(message: NSLocalizedString("srfid_save_error_try_again", comment: "에러로 인하여 RFID 데이터를 저장할수 없습니다. 잠시후 다시 시도하여 주십시오."))
			print(error.localizedDescription)
        }
    }
	
	func loadProdName(processType: String, prodCode:String, prodReadCnt: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		print("@loadProdName()")
		print(" - prodCode:\(prodCode)")
		print(" - prodReadCnt:\(prodReadCnt)")
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		
		var strProdName = ""
		do
		{
			let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
			clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
			clsDataClient.SelectUrl = "inOutService:selectMappingOutProdName"
			clsDataClient.removeServiceParam()
			clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
			clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
			clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
			clsDataClient.addServiceParam(paramName: "itemCode", value: prodCode)
			clsDataClient.selectRawData(dataCompletionHandler: { (responseData, error) in
					if let error = error {
						// 에러처리
						print(error)
						return
					}
					guard let responseData = responseData else {
						print("에러 데이터가 없음")
						return
					}
					// 성공
					if let returnCode = responseData.returnCode , returnCode > 0
					{
						let returnMessage = responseData.returnMessage ?? ""
						print("@@@@@@@@@ return RawMessage : \(returnMessage)")
						
						let dataSourceMgr = DataSourceMgr()
						dataSourceMgr.Notation = DataSourceMgr.NOTATION_NONE
						
						if (dataSourceMgr.parse(data: responseData.returnMessage!))
						{
							let clsDataTable = dataSourceMgr.getDataTable()
							let clsDataRows = clsDataTable.getDataRows()
							if(clsDataRows.count > 0)
							{
								let clsResultRow = clsDataRows[0]
								
								let strResultCode = clsResultRow.getString(name: "resultCode") ?? ""
								let strResultMsg = clsResultRow.getString(name: "resultMessage") ?? ""
								let strResultRowcount = clsResultRow.getString(name: "resultRowcount") ?? ""
								
								print("-리턴코드: \(strResultCode)")
								print("-리턴메시지: \(strResultMsg)")
								print("-리턴로우카운트: \(strResultRowcount)")
								
								if(strResultCode == Constants.PROC_RESULT_SUCCESS)
								{
									strProdName = strResultMsg
									if(strProdName.isEmpty == true)
									{
										strProdName = NSLocalizedString("msg_error_unregistered_product", comment: "상품정보없음")
									}
									
									let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
									if( processType == "addProduct")
									{
										// 상품추가
										let clsItemInfo = ItemInfo()
										clsItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED) //신규 태그 입력시 체크-DB전송관련
										clsItemInfo.setEpcCode(epcCode: self.strSelectedEpcCode)
										clsItemInfo.setProdCode(prodCode: prodCode)
										clsItemInfo.setReadTime(readTime: strCurReadTime)
										clsItemInfo.setProdReadCnt(prodReadCnt: prodReadCnt)
										clsItemInfo.setProdName(prodName: strProdName)
										self.arrProdRows.append(clsItemInfo)		//중복이 없다면 그리드용 리스트에 삽입한다.
										
										DispatchQueue.main.async
										{
											self.tvMappingProd.reloadData()
										}
										
										self.boolNewTagInfoExist = true 				//신규태그 입력 체크
										self.clsProdContainer.addItem(epcCode: self.strSelectedEpcCode, itemInfo: clsItemInfo)
									}
									else if( processType == "barcode")
									{
										let clsItemInfo = ItemInfo()
										clsItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED) //신규 태그 입력시 체크-DB전송관련
										clsItemInfo.setEpcCode(epcCode: self.strSelectedEpcCode)
										clsItemInfo.setProdCode(prodCode: prodCode)
										clsItemInfo.setReadTime(readTime: strCurReadTime)
										clsItemInfo.setProdReadCnt(prodReadCnt: "1")
										clsItemInfo.setProdName(prodName: strProdName)
										
										self.arrProdRows.append(clsItemInfo) // 중복이 없다면 그리드용 리스트에 삽입한다.
										
										//슬래이브 그리드 - 업데이트
										DispatchQueue.main.async {
											self.tvMappingProd.reloadData()
										}
										
										//헤시테이블 저장
										self.clsProdContainer.addItem(epcCode: self.strSelectedEpcCode, itemInfo: clsItemInfo)
									}
								}
								else
								{
									
									Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_error_unregistered_product", comment: "상품정보없음"))
								}
							}
						}
					}
					else
					{
						print("json 오류")
					}
			})
		}
		catch let error
		{
			super.showSnackbar(message: NSLocalizedString("msg_inspect_prod_name_error_try_again", comment: "에러로 인하여 상품명을 조회할 수 없습니다. 잠시후 다시 시도하여 주십시오."))
			print(error.localizedDescription)
		}
	}
	
	/**
	* 선택된 상품정보(바코드)를 삭제처리 한다.
	* @param strSaleItemSeq	상품SEQ
	* @param strProdCode	바코드
	*/
	func sendDeleteItemInfo(saleItemSeq: String, prodCode: String)
	{
		do
		{
			clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
			
			let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
			clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
			clsDataClient.ExecuteUrl = "inOutService:deleteItemInfo"
			clsDataClient.removeServiceParam()
			clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
			clsDataClient.addServiceParam(paramName: "itemCode", value: prodCode)
			clsDataClient.addServiceParam(paramName: "saleItemSeq", value: saleItemSeq)
			clsDataClient.executeData(dataCompletionHandler: { (data, error) in
				
				self.clsIndicator?.hide()
				
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
						// 삭제성공
						//그리드 삭제 및 구조체 삭제
						DispatchQueue.main.async
						{
							//그리드 삭제 및 구조체 삭제
							self.clsProdContainer.deleteItem(epcCode: self.strSelectedEpcCode, prodCode: self.strSelectedProdCode, removeState: Constants.REMOVE_STATE_COMPLETE)
							self.arrProdRows.removeAll()
							self.arrProdRows.append(contentsOf: self.clsProdContainer.getItemes(epcCode: self.strSelectedEpcCode))
							self.tvMappingProd.reloadData()
							
							let strMsg = NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다.")
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
		catch let error
		{
			clsIndicator?.hide()
			super.showSnackbar(message: NSLocalizedString("common_error_occurred_data_search", comment: "데이터 검색중 에러가 발생하였습니다."))
			print(error.localizedDescription)
		}
	}
	
	
	/**
	* 데이터를 서버로 전송 한다.
	* @param strWorkState			출하구분
	* @param strSaleWorkId			송장번호
	* @param strRemark				처리메모
	* @param strSignData			사인
	*/
	func sendDataExistSaleWorkId(workState: String, saleWorkId: String, vehName: String, tradeChit: String, remark: String, signData: String)
	{
		print("=================================")
		print("*sendDataExistSaleWorkId()")
		print("=================================")
		
		do
		{
			clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
			
			let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
			clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
			clsDataClient.ExecuteUrl = "inOutService:executeOutData"
			clsDataClient.removeServiceParam()
			clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
			clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
			clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
			clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
			
			clsDataClient.addServiceParam(paramName: "workState", value: workState)
			clsDataClient.addServiceParam(paramName: "saleWorkId", value: saleWorkId)
			clsDataClient.addServiceParam(paramName: "vehName", value: vehName)
			clsDataClient.addServiceParam(paramName: "barcodeId", value: "")	// 바코드ID
			clsDataClient.addServiceParam(paramName: "itemCode", value: "")		// 제품 코드
			clsDataClient.addServiceParam(paramName: "prodCnt", value: "")		// 제품 개수


			// 완료전송인경우
			if(Constants.WORK_STATE_COMPLETE == workState)
			{
				let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
				let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
				clsDataClient.addServiceParam(paramName: "workDateTime",	value: strWorkDateTime)
				clsDataClient.addServiceParam(paramName: "workerName",		value: "")
				clsDataClient.addServiceParam(paramName: "driverName",		value: "")
				clsDataClient.addServiceParam(paramName: "tradeChit",		value: tradeChit)
				clsDataClient.addServiceParam(paramName: "remark",			value: remark)
				if(signData.isEmpty == false)
				{
					clsDataClient.addServiceParam(paramName: "signData",	value: signData)		//사인데이터
				}
			}
			
			
			//상품정보 GetDataTable
			let clsDataTable = clsProdContainer.getDataTable()
			clsDataClient.executeData(dataTable:clsDataTable, dataCompletionHandler: { (data, error) in
				self.clsIndicator?.hide()
				
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
						
						let strSvrProcCount = clsDataRow.getString(name: "procCount") ?? ""
						let strSvrWorkState = clsDataRow.getString(name: "workState") ?? ""
						
						print(" -서버로부터받은처리갯수:\(strSvrProcCount)");
						print(" -서버로부터받은작업처리상태:\(strSvrWorkState)")
						
						DispatchQueue.main.async
						{
							// 현재 작업상태 확인
							if(Constants.WORK_STATE_COMPLETE == strSvrWorkState)
							{
								// 완료전송인경우
								self.clearTagData(boolClearScreen: true) // UI객체를 초기화한다.
							}
							else
							{
								//임시 저장경우
								self.boolNewTagInfoExist = false
								self.boolExistSavedInvoice = true				//'송장번호'할당여부
								
								//상품SEQ를 조회한다.
								if(self.strSaleWorkId.isEmpty == false)
								{
									self.doChangeStatus()
								}
							}
						}
						let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
						self.showSnackbar(message: strMsg)
					}
					else
					{
						
						let strErrorMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
						
						print("@@@@@@@@@ 에러메시지:\(strErrorMsg)")
					
						self.showSnackbar(message: strErrorMsg)
					
						
					}
				}
				
			})
		}
		catch let error
		{
			clsIndicator?.hide()
			
			if(Constants.WORK_STATE_WORKING == workState)
			{
				super.showSnackbar(message: NSLocalizedString("rfid_save_error_try_again", comment: "에러로 인하여 RFID 데이터를 저장할수 없습니다. 잠시후 다시 시도하여 주십시오."))
			}
			else
			{
				super.showSnackbar(message: NSLocalizedString("rfid_send_error_try_again", comment: "에러로 인하여 RFID데이터를 전송할수 없습니다. 잠시후 다시 시도하여 주십시오."))
			}
			
			print(error.localizedDescription)
		}
	}
	
	
	/**
	* 송장번호를 발급후, 데이터를 서버로 전송 한다.
	* @param workState			작업상태
	* @param strTransferCustId		입고처 정보
	* @param strVehName			차량번호
	* @param strTradeChit			전표번호
	* @param strRemark				비고
	* @param strSignData			사인
	*/
	func sendDataNoneSaleWorkId(workState: String, toBranchId: String, vehName: String, tradeChit: String, remark: String, signData: String)
	{
		print("=================================")
		print("*sendDataNoneSaleWorkId \(Constants.WEB_SVC_URL)")
		print("=================================")
		do
		{
			let clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
			clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
			clsDataClient.SelectUrl = "inOutService:selectSaleWorkId"
			clsDataClient.removeServiceParam()
			clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
			clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
			clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
			clsDataClient.addServiceParam(paramName: "toBranchId", value: toBranchId)
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
				
				for clsDataRow in clsDataTable.getDataRows()
				{
					self.strSaleWorkId = clsDataRow.getString(name: "resultSaleWorkId") ?? ""
				}

				//DB로 데이터 저장하기
				self.sendDataExistSaleWorkId(workState: workState, saleWorkId: self.strSaleWorkId, vehName: vehName, tradeChit: tradeChit, remark: remark, signData: signData)
			})
		}
		catch let error
		{
			super.showSnackbar(message: NSLocalizedString("common_error_occurred_data_search", comment: "데이터 검색중 에러가 발생하였습니다."))
			print(error.localizedDescription)
		}
	}

	func initTestProcess()
	{
		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
		

		//#1.일반정보
		strToBranchId = "170316000142";
		btnToBranchSearch.setTitle("농협물류센터(안성)", for: UIControlState.normal)
		tfVehName.text = "붕붕이 3호"
		tfTradeChit.text = "TR1234"
		lblSerialNo.text = "161028"
		strSelectedEpcCode = "3312D58E3D8100C000027504"
		lblProcCount.text = "2"

		//#2.RFID태그정보
		boolNewTagInfoExist = true

		let clsRFIDInfo1 = ItemInfo()
		clsRFIDInfo1.setEpcCode(epcCode: "3312D58E3D8100C000027504")
		clsRFIDInfo1.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsRFIDInfo1.setEpcUrn(epcUrn: "grai:95100027.1027.161028")
		clsRFIDInfo1.setSerialNo(serialNo: "161028")
		clsRFIDInfo1.setAssetEpc(assetEpc: "951000271027")
		clsRFIDInfo1.setAssetName(assetName: "RB11")
		clsRFIDInfo1.setReadCount(readCount: 1)
		clsRFIDInfo1.setReadTime(readTime: strCurReadTime)
		arrRfidRows.append(clsRFIDInfo1)
		clsProdContainer.addProdEpc(epcCode: "3312D58E3D8100C000027504")

		let clsRFIDInfo2 = ItemInfo()
		clsRFIDInfo2.setEpcCode(epcCode: "3312D58E3D8100C000027507")
		clsRFIDInfo2.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsRFIDInfo2.setEpcUrn(epcUrn: "grai:95100027.1027.161031")
		clsRFIDInfo2.setSerialNo(serialNo: "161031")
		clsRFIDInfo2.setAssetEpc(assetEpc: "951000271027")
		clsRFIDInfo2.setAssetName(assetName: "RB11")
		clsRFIDInfo2.setReadCount(readCount: 1)
		clsRFIDInfo2.setReadTime(readTime: strCurReadTime)
		arrRfidRows.append(clsRFIDInfo2)
		clsProdContainer.addProdEpc(epcCode: "3312D58E3D8100C000027507")

		tvMappingRfid.reloadData()

		//#3.바코드정보
		let clsBarcodeInfo1 = ItemInfo()
		clsBarcodeInfo1.setEpcCode(epcCode: "3312D58E3D8100C000027504")
		clsBarcodeInfo1.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsBarcodeInfo1.setProdCode(prodCode: "10012345000017")
		clsBarcodeInfo1.setProdName(prodName: "빼빼로")
		clsBarcodeInfo1.setProdReadCnt(prodReadCnt: "1")
		clsBarcodeInfo1.setReadTime(readTime: strCurReadTime)
		arrProdRows.append(clsBarcodeInfo1)
		clsProdContainer.addItem(epcCode: "3312D58E3D8100C000027504", itemInfo: clsBarcodeInfo1)
	
		let clsBarcodeInfo2 = ItemInfo()
		clsBarcodeInfo2.setEpcCode(epcCode: "3312D58E3D8100C000027504")
		clsBarcodeInfo2.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsBarcodeInfo2.setProdCode(prodCode: "10012345000024")
		clsBarcodeInfo2.setProdName(prodName: "초코파이")
		clsBarcodeInfo2.setProdReadCnt(prodReadCnt: "1");
		clsBarcodeInfo2.setReadTime(readTime: strCurReadTime);
		arrProdRows.append(clsBarcodeInfo2)
		clsProdContainer.addItem(epcCode: "3312D58E3D8100C000027504", itemInfo: clsBarcodeInfo2)

		//슬래이브 그리드 - 업데이트
		tvMappingProd.reloadData()
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

	
	func didReadTagid(_ tagid: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@")
		print("@didReadTagList()")
		print("@@@@@@@@@@@@@@@@@@@@@")
		let clsTagInfo = RfidUtil.parse(strData: tagid)
		getRfidData(clsTagInfo: clsTagInfo)
	}
	


	func didReadBarcode(_ barcode: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@")
		print("@didReadBarcode(), barcode:\(barcode)")
		print("@@@@@@@@@@@@@@@@@@@@@")
		
		let clsTagInfo = RfidUtil.TagInfo()
		clsTagInfo.setEpcCode(epcCode: barcode)
		getBarcodeData(clsTagInfo: clsTagInfo)
	}
	
	//리더기 연결성공
	func didReaderConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
		changeBtnRfidReader(true)
		
		setRederMode(ReaderSenssorMode.RFID)	//리더기 모드 초기화
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


extension ProdMappingOut
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")

        var strType = ""
        let intIdentificationSystem = UserDefaults.standard.integer(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
        if(intIdentificationSystem == Constants.IDENTIFICATION_SYSTEM_AGQR)
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
