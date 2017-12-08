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
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	
	@IBOutlet weak var btnWorkOutCustSearch: UIButton!
	
	
    @IBOutlet weak var tfVehName: UITextField!
    @IBOutlet weak var lblProcCount: UILabel!
    @IBOutlet weak var tfTradeChit: UITextField!
    
    @IBOutlet weak var lblAssetName: UILabel!
    @IBOutlet weak var lblSerialNo: UILabel!
    
    @IBOutlet weak var tvProdMappingRfid: UITableView!
	@IBOutlet weak var tvProdMappingItem: UITableView!

    //var strSaleWorkId	= ""	// 송장번호
   
    
    
    
    
    
    
//    var strMakeOrderId: String = ""
//    var intOrderWorkCnt: Int = 0
//    var intOrderReqCnt: Int = 0
//    var strProdAssetEpc: String?
//    var intCurOrderWorkCnt: Int = 0
	
	//var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	//var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
    
    
    var arrResultDataRows : Array<DataRow> = Array<DataRow>()
    
    var strToBranchId    = ""    // 출하고객사ID
    
    //==== Ver2.0.0 ====
    var strSaleWorkId = ""	/**< 송장번호ID - DB에서 할당받은 */
    
    var arrRfidRows : Array<ItemInfo> = Array<ItemInfo>()        /**< 데이터 리스트 - 마스터 ITEM데이터, 그리드 표출용 */
    var arrItemRows : Array<ItemInfo> = Array<ItemInfo>()        /**< 데이터 리스트 - 슬래이브 ITEM데이터, 그리드 표출용 */
	
	var boolNewTagInfoExist		= false	/**< 신규태그 - 신규태그가 있는지 여부 -전송용 */
	var boolExistSavedInvoice	= false	/**< 송장번호ID - DB에서 할당받았는지 여부 */
	
    var strSelectedEpcCode		= ""	/**< 선택된 시리얼의 EPC 코드    */
    var strSelectedProdCode		= ""	/**< 선택된 시리얼의 상품 코드    */
    var intSelectedProdIndex	= 0		/**< 선택된 상품의 인덱스    */
    var intSelectedIndex		= -1
    
    var clsProdContainer: ProdContainer!
	
	
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
		
		initTestProcess()
	}
	

	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		

		Dialog.show(container: self, viewController: nil,
					title: NSLocalizedString("common_delete", comment: "삭제"),
					message: "바부야",
					okTitle: NSLocalizedString("common_confirm", comment: "확인"),
					okHandler: { (_) in

						return
			},
			cancelTitle: NSLocalizedString("common_cancel", comment: "확인"), cancelHandler: nil)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*ProductMount.viewDidDisappear()")
		print("=========================================")
        
        
		arrResultDataRows.removeAll()
        
        
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
        
        lblProcCount.text = "0"
        
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
    
    // 상품추가
    @IBAction func onProductAddClicked(_ sender: UIButton)
    {
        if(self.lblSerialNo.text?.isEmpty == true)
        {
            super.showSnackbar(message: NSLocalizedString("msg_no_selected_serial_no", comment: "시리얼번호를 선택하여 주십시오."))
            return
        }
        
        // 리더기 읽기 중지
        
        //if(super.isReaderConnected() == true)
        if(super.isConnected() == true)
        {
        	stopRead()
        }

        // TODO : 팝업 열기
        //showDialog(Constants.DIALOG_PROD_INSERT)
    }
    

    // 바코드 버튼
    @IBAction func onProdBarcodeClicked(_ sender: UIButton)
    {
    }
    
	// 데이터를 clear한다.
    func clearTagData( boolClearScreen: Bool)
	{
        arrResultDataRows.removeAll()
        
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
        let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
        let strSerialNo = clsTagInfo.getSerialNo()
        let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드

        
      
//        //------------------------------------------------
//        clsTagInfo.setAssetEpc(assetEpc: strAssetEpc)
//        if(clsTagInfo.getAssetEpc().isEmpty == false)
//        {
//            guard let strAssetName = super.getAssetName(assetEpc: strAssetEpc) as? String
//                else
//            {
//                return
//            }
//            clsTagInfo.setAssetName(assetName : strAssetName)
//            print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
//        }
//        clsTagInfo.setNewTag(newTag : true)
//        clsTagInfo.setReadCount(readCount: 1)
//        clsTagInfo.setReadTime(readTime: strCurReadTime)
//        //------------------------------------------------
//
//        var boolValidAsset = false
//        var boolFindSerialNoOverlap = false
//        var boolFindAssetTypeOverlap = false
//        for clsAssetInfo in super.getAssetList()
//        {
//            print("@@@@@clsAssetInfo.assetEpc:\(clsAssetInfo.assetEpc)")
//            if(clsAssetInfo.assetEpc == strAssetEpc)
//            {
//                // 자산코드에 등록되어 있는 경우
//                print(" 동일한 자산코드 존재")
//                boolValidAsset = true
//                break;
//            }
//        }
//        print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
//        if(boolValidAsset == true)
//        {
//            // Detail 다이얼로그 전달용 태그 리스트
//            for clsTagInfo in arrTagRows
//            {
//                // 같은 시리얼번호가 있는지 체크
//                if(clsTagInfo.getSerialNo() == strSerialNo)
//                {
//                    print(" 동일한 시리얼번호 존재")
//                    boolFindSerialNoOverlap = true
//                    break;
//                }
//            }
//
//            // 시리얼번호가 중복이 안되어 있다면
//            if(boolFindSerialNoOverlap == false)
//            {
//                // 상세보기용 배열에 추가
//                arrTagRows.append(clsTagInfo)
//
//                for clsTagInfo in arrAssetRows
//                {
//                    // 같은 자산유형이 있다면 자산유형별로 조회수 증가
//                    if(clsTagInfo.getAssetEpc() == strAssetEpc)
//                    {
//                        boolFindAssetTypeOverlap = true
//                        let intCurReadCount = clsTagInfo.getReadCount()
//                        clsTagInfo.setReadCount(readCount: (intCurReadCount + 1))
//                        break;
//                    }
//                }

//                // 마스터용 배열에 추가
//                if(boolFindAssetTypeOverlap == false)
//                {
//                    arrAssetRows.append(clsTagInfo)
//                }
//
//                let intCurDataSize = arrTagRows.count
//
//                // 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
//
//                print("@@@@@@strMakeOrderId:\(strMakeOrderId)")
//
//                if(strMakeOrderId.isEmpty == false)
//                {
//                    intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
//                    lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
//                }
//            }
//
//        }

		
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
		btnWorkOutCustSearch.setTitle(NSLocalizedString("common_selection", comment: "선택"), for: .normal)
		//처리메모
		
		// TODO
		//final EditText etRemark	 = (EditText)findViewById(R.id.etRemark);
		//if(etRemark != null) etRemark.setText("");
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if(tableView == tvProdMappingRfid)
		{
			return self.arrRfidRows.count
		}
		else
		{
			return self.arrItemRows.count
		}
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if(tableView == tvProdMappingRfid)
		{
			let objCell:ProdMappingRfidCell = tableView.dequeueReusableCell(withIdentifier: "tvcProdMappingRfid", for: indexPath) as! ProdMappingRfidCell
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
			let objCell:ProdMappingItemCell = tableView.dequeueReusableCell(withIdentifier: "tvcProdMappingItem", for: indexPath) as! ProdMappingItemCell
            let clsItemInfo = arrItemRows[indexPath.row]
            objCell.lblProdCode.text = clsItemInfo.getProdCode()
            objCell.lblProdName.text = clsItemInfo.getProdName()
			
            //mClsViewWrapper.tvSaleItemSeq.setText(clsDataRow.getSaleItemSeq());
            // TODO : 언더라인 확인
            objCell.lblProdReadCnt.text = clsItemInfo.getProdReadCnt()
            objCell.lblProdReadCnt.attributedText = NSAttributedString(string: "Text", attributes:  [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            
            // TODO : 언더라인 클릭 이벤트
            /*
            if(tvAssetProdReadCntSelect != null)
            {
                //텍스트에 밑줄
                SpannableString content = new SpannableString(clsDataRow.getProdReadCnt());
                
                content.setSpan(new UnderlineSpan(), 0, content.length(), 0);
                tvAssetProdReadCntSelect.setText(content);
                
                tvAssetProdReadCntSelect.setTag(clsDataRow);
                tvAssetProdReadCntSelect.setOnClickListener(new OnClickListener()
                    {
                        @Override
                        public void onClick(View v)
                    {
                        try
                    {
                        mIntSelectedProdIndex = intPosition;    //선택된 인덱스
                        showDialog(Constants.DIALOG_PROD_INFO);
                        }
                        catch(Exception ex)
                        {
                        //Logger.i("인식수량 오류: " + ex.getMessage());
                        }
                        }
                });
            }    */
            

            objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
            objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
            objCell.btnSelection.tag = indexPath.row
            objCell.btnSelection.addTarget(self, action: #selector(onItemSelectionClicked(_:)), for: .touchUpInside)
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
            arrItemRows.removeAll()
            
            
            //선택된 RFID태그에 대한 바코드리스트
            if(self.lblSerialNo.text?.isEmpty == false)
            {
                let arrItems = clsProdContainer.getItemes(epcCode: strSelectedEpcCode)
                if(arrItems.count > 0)
                {
                    arrItemRows.append(contentsOf: arrItems)
                }
            }
            
            //슬래이브-그리드 업데이트
			tvProdMappingItem.reloadData()
            
            
            //처리량
            lblProcCount.text = "\(arrItemRows.count)"
        }
    }
    
    @objc func onItemSelectionClicked(_ sender: UIButton)
    {
		let clsDataRow = arrItemRows[sender.tag]

		//헤시맵과 그리드뷰에서 제거
		var	intRowState = clsProdContainer.deleteItem(epcCode: strSelectedEpcCode, prodCode: clsDataRow.getProdCode(), removeState: Constants.REMOVE_STATE_NORMAL);

		if( intRowState == Constants.DATA_ROW_STATE_ADDED)
		{
			arrItemRows.removeAll()
			arrItemRows.append(contentsOf: clsProdContainer.getItemes(epcCode: strSelectedEpcCode))
			tvProdMappingItem.reloadData()
		}
		else
		{
			//델리트
			let arrItemList = clsProdContainer.getItemes(epcCode: strSelectedEpcCode)
			for clsItemInfo in arrItemList
			{
				if(clsItemInfo.getProdCode() == clsDataRow.getProdCode())
				{
					strSelectedProdCode = clsDataRow.getProdCode()    //선택한 상품코드
					sendDeleteItemInfo(saleItemSeq: clsItemInfo.getSaleItemSeq(), prodCode: strSelectedProdCode)
					break
				}
			}
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
		
		var strVehName		= tfVehName?.text ?? ""
		var strTradeChit	= tfTradeChit?.text ?? ""
		
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
	
	
	// 전송
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
		
		//showDialog(Constants.DIALOG_CONFIRM_SEND);
	
	/*
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
		*/
	}
	
	
	func doReloadTagList(reoadStatus: Int)
	{
		
		var strEpcCode				= ""
		var strProdAssetEpcName 	= ""
		var strSerialNo 			= ""

		do
		{
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
                        self.arrItemRows.append(clsSlaveItemInfo)
                    }
				}
                
				// 3)'처리량' 텍스트박스에 표시
                self.lblProcCount.text = "\(self.arrRfidRows.count)"
				

				// 4)그리드 업데이트
                self.tvProdMappingRfid?.reloadData()
                self.tvProdMappingItem?.reloadData()
         
                // 5)마지막 마스터 그리드가 선택되게 만들기
                self.strSelectedEpcCode = strEpcCode
                
                self.lblSerialNo?.text = strSerialNo
                self.lblAssetName?.text = strProdAssetEpcName
                
                super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
    		})
		}
		catch let error
		{
            super.showSnackbar(message: error.localizedDescription)
			print(error.localizedDescription)
		}
	}
	
	
	// 초기화 버튼 처리, 태그리스트 재조회
    func doChangeStatus()
    {
        
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
                        // 삭제성공
                        //그리드 삭제 및 구조체 삭제
                        DispatchQueue.main.async
                    	{
							self.clearTagData(boolClearScreen: true)
							
							// TODO: 백버튼?
							//if(mBoolonBackPressed == false)
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
            super.showSnackbar(message: NSLocalizedString("srfid_save_error_try_again", comment: "에러로 인하여 RFID 데이터를 저장할수 없습니다. 잠시후 다시 시도하여 주십시오."))
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
						// 삭제성공
						//그리드 삭제 및 구조체 삭제
						DispatchQueue.main.async
						{
							//그리드 삭제 및 구조체 삭제
							self.clsProdContainer.deleteItem(epcCode: self.strSelectedEpcCode, prodCode: self.strSelectedProdCode, removeState: Constants.REMOVE_STATE_COMPLETE)
							self.arrItemRows.removeAll()
							self.arrItemRows.append(contentsOf: self.clsProdContainer.getItemes(epcCode: self.strSelectedEpcCode))
							self.tvProdMappingItem.reloadData()
							
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
						
						let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
						self.showSnackbar(message: strMsg)
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
		btnWorkOutCustSearch.setTitle("농협물류센터(안성)", for: UIControlState.normal)
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

		tvProdMappingRfid.reloadData()

		//#3.바코드정보
		let clsBarcodeInfo1 = ItemInfo()
		clsBarcodeInfo1.setEpcCode(epcCode: "3312D58E3D8100C000027504")
		clsBarcodeInfo1.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsBarcodeInfo1.setProdCode(prodCode: "10012345000017")
		clsBarcodeInfo1.setProdName(prodName: "빼빼로")
		clsBarcodeInfo1.setProdReadCnt(prodReadCnt: "1")
		clsBarcodeInfo1.setReadTime(readTime: strCurReadTime)
		arrItemRows.append(clsBarcodeInfo1)
		clsProdContainer.addItem(epcCode: "3312D58E3D8100C000027504", itemInfo: clsBarcodeInfo1)
	
		let clsBarcodeInfo2 = ItemInfo()
		clsBarcodeInfo2.setEpcCode(epcCode: "3312D58E3D8100C000027504")
		clsBarcodeInfo2.setRowState(rowState: Constants.DATA_ROW_STATE_ADDED)
		clsBarcodeInfo2.setProdCode(prodCode: "10012345000024")
		clsBarcodeInfo2.setProdName(prodName: "초코파이")
		clsBarcodeInfo2.setProdReadCnt(prodReadCnt: "1");
		clsBarcodeInfo2.setReadTime(readTime: strCurReadTime);
		arrItemRows.append(clsBarcodeInfo2)
		clsProdContainer.addItem(epcCode: "3312D58E3D8100C000027504", itemInfo: clsBarcodeInfo2)

		//슬래이브 그리드 - 업데이트
		tvProdMappingItem.reloadData()
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
