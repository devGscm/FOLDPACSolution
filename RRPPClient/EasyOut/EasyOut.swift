//
//  EasyOut.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 19..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic
import BarcodeScanner

class EasyOut: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBranchInfo: UILabel!
    @IBOutlet weak var lblReaderName: UILabel!
    @IBOutlet weak var btnRfidReader: UIButton!
    
    @IBOutlet weak var btnWorkCustSearch: UIButton!
    @IBOutlet weak var tfVehName: UITextField!
    @IBOutlet weak var tfTradeChit: UITextField!
    @IBOutlet weak var lblProcCount: UILabel!
    @IBOutlet weak var tvEasyOut: UITableView!
    
    
    var mIntProcCount               = 0            /**< 처리량 */
    var mBoolNewTagInfoExist        = false        /**< 신규태그 - 신규태그가 있는지 여부 -전소용 */
    
    var mBoolExistSavedInvoice      = false        /**< 송장번호ID - DB에서 할당받았는지 여부 */
    var mStrSaleWorkId              = ""           /**< 송장번호 */
    
    var mStrTransferCustId          = ""           /**< 출하고객사ID */
    var strTitle                    = ""
    
    var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    
    var clsIndicator : ProgressIndicator?
    var clsDataClient : DataClient!

    
    //=======================================
    //=====  setTitle()
    //=======================================
    func setTitle(title: String)
    {
        self.strTitle = title
    }
    
    //=======================================
    //=====  viewDidLoad()
    //=======================================
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
		// 옵져버 패턴 : 응답대기(AppDelegate.swift의 applicationWillTerminate에서 전송)
		NotificationCenter.default.addObserver(self, selector: #selector(onAppTerminate), name: NSNotification.Name(rawValue: "onAppTerminate"), object: nil)
    }
    
    
    //=======================================
    //=====  viewWillAppear()
    //=======================================
    override func viewWillAppear(_ animated: Bool)
    {
        print("=========================================")
        print("*EasyOut.viewWillAppear()")
        print("=========================================")
        super.viewWillAppear(animated)
        prepareToolbar()
        
        //RFID를 처리할 델리게이트 지정
        self.initRfid(self as ReaderResponseDelegate )
        
        initViewControl()
    }
    
    
    //=======================================
    //=====  viewDidAppear()
    //=======================================
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
	
	
	@objc public func onAppTerminate()
	{
		print("=========================================")
		print("*EasyIn.onAppTerminate()")
		print("=========================================")
		
		// 작업 취소처리
		if(self.mStrSaleWorkId.isEmpty == false)
		{
			self.sendWorkInitDataSync(saleWorkId: self.mStrSaleWorkId)
		}
	}
	
	override func didUnload(to viewController: UIViewController, completion: ((Bool) -> Void)? = nil)
	{
		print("=========================================")
		print("*EasyIn.didUnload()")
		print("=========================================")
		
		if(self.mStrSaleWorkId.isEmpty == false)
		{
			// TransitionController에서 다른화면으로 이동못하도록 false 처리를 한다.
			super.setUnload(unload: false)
			
			Dialog.show(container: self, viewController: nil,
						title: NSLocalizedString("common_confirm", comment: "확인"),
						message: NSLocalizedString("easy_process_exist_message", comment: "임시 저장된 데이터가 지워집니다. 종료 하시겠습니까?"),
						okTitle: NSLocalizedString("common_confirm", comment: "확인"),
						okHandler: { (_) in
							
							// 작업 취소처리
							self.sendWorkInitData(saleWorkId: self.mStrSaleWorkId, showMessage: true)
							
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
    
    
    //=======================================
    //=====  viewDidDisappear()
    //=======================================
    override func viewDidDisappear(_ animated: Bool)
    {
        print("=========================================")
        print("*EasyOut.viewDidDisappear()")
        print("=========================================")
        
        self.mIntProcCount = 0
        self.mBoolNewTagInfoExist = false
        self.mBoolExistSavedInvoice = false
        self.mStrSaleWorkId = ""
        self.mStrTransferCustId = ""
        
        arrAssetRows.removeAll()
        arrTagRows.removeAll()
        clsIndicator = nil
        clsDataClient = nil
        
        super.destoryRfid()
        super.viewDidDisappear(animated)
    }
    
    
    //=======================================
    //=====  initViewControl()
    //=======================================
    func initViewControl()
    {
        clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
                                         indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
        
        lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
        lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
        lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
        lblProcCount.text = String(mIntProcCount)
    }
    
    
    //=======================================
    //===== 세규어로 데이터 전달
    //=======================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "segWorkCustSearch")
        {
            //고객사 조회
            if let clsDialog = segue.destination as? WorkCustSearch
            {
                clsDialog.inOutType = Constants.INOUT_TYPE_OUTPUT   //출고
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
                    
                    //해당 자산코드만 필터링하여 배열을 재생성하여 전달
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
    
    

    //=======================================
    //===== 팝업 다이얼로그로 부터 데이터 수신
    //=======================================
    func recvData(returnData : ReturnData)
    {
        if(returnData.returnType == "workCustSearch")           //고객사 조회
        {
            if(returnData.returnRawData != nil)
            {
                //송장번호가 있는경우, 새로운 입고처가 들어오면 기존 데이터를 삭제한다.
                if(mBoolExistSavedInvoice == true)
                {
                    clearTagData(true)
                }
                let clsDataRow = returnData.returnRawData as! DataRow
                let strCustName = clsDataRow.getString(name: "custName") ?? ""
                self.mStrTransferCustId = clsDataRow.getString(name: "branchId") ?? ""
                self.btnWorkCustSearch.setTitle(strCustName, for: .normal)                  //입고처
            }
        }
        else if(returnData.returnType == "outSignDialog")       //'사인'-완료전송
        {
            //전송
            if(returnData.returnRawData != nil)
            {
                let clsDataRow      = returnData.returnRawData as! DataRow
                let strRemark       = clsDataRow.getString(name: "remark") ?? ""
                let strSignData     = clsDataRow.getString(name: "signData") ?? ""
                let strVehName      = tfVehName?.text ?? ""
                let strTradeChit    = tfTradeChit?.text ?? ""
                
                if self.mStrSaleWorkId.isEmpty == false
                {
                    //송장번호 O, DB로 데이터 전송 처리
                    sendDataExistSaleWorkId(Constants.WORK_STATE_COMPLETE, mStrSaleWorkId, strVehName, strTradeChit, strRemark, strSignData)
                }
                else
                {
                    //송장번호 X , 송장번호(SaleWorkId) 발급후 DB로 데이터 전송 처리
                    sendDataNoneSaleWorkId(Constants.WORK_STATE_COMPLETE, mStrTransferCustId, strVehName, strTradeChit, strRemark, strSignData);
                }
            }
        }
    }
    

    //=======================================
    //===== 데이터를 clear한다.
    //=======================================
    func clearTagData(_ clearScreen : Bool)
    {
        self.mBoolNewTagInfoExist = false       //신규태그 입력 체크, 전송용
        arrTagRows.removeAll()
        arrAssetRows.removeAll()
        
        DispatchQueue.main.async
        {
            self.tvEasyOut?.reloadData()
        }
        
        if(clearScreen == true)
        {
            DispatchQueue.main.async
            {
                self.mStrSaleWorkId             = ""
                self.mIntProcCount              = 0
                self.mStrTransferCustId         = ""
                self.mBoolExistSavedInvoice     = false     //'송장번호'할당여부
                self.lblProcCount.text          = "0"       //처리수량
                self.tfVehName.text             = ""        //차량번호
                self.tfTradeChit.text           = ""        //전표번호
                self.btnWorkCustSearch.setTitle(NSLocalizedString("title_easy_cust_selection", comment: "고객사 선택"), for: .normal)
            }
        }
        
        //RFID리더기 초기화
        super.clearInventory()
    }
    
    
    //=======================================
    //===== RFID 태그데이터
    //=======================================
    func getRfidData(clsTagInfo : RfidUtil.TagInfo)
    {
        let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
        let strSerialNo = clsTagInfo.getSerialNo()
        let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드
        
        var boolFindAbnormal            = false;
        var boolFindInvalidAssetEpc     = false;
        var boolFindAssetTypeOverlap    = false;
        
        //태그정보 리스트에 저장
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
        
        //시스템에 등록된 AssetEpc 와 AssetEpc 비교
        for clsAssetInfo in super.getAssetList()
        {
            print("====== [1]자산코드: \(strAssetEpc) :: \(clsAssetInfo.assetEpc)")
            if(clsAssetInfo.assetEpc == strAssetEpc)
            {
                boolFindInvalidAssetEpc = false;
                break;
            }
            else
            {
                //자산코드 없음
                boolFindInvalidAssetEpc = true;
                print("====== [2]자산코드 없음 ======")
            }
        }
        
        
        
        //시스템에 동일한 자산코드가 있을때만 진행
        if(boolFindInvalidAssetEpc == false)
        {
            //중복 시리얼 확인 - 전달용 태그 리스트
            for clsTagInfo in arrTagRows
            {
                //같은 시리얼번호가 있는지 체크
                if(clsTagInfo.getSerialNo() == strSerialNo)
                {
                    print("동일한 시리얼번호 존재")
                    boolFindAbnormal = true;
                    break;
                }
            }
            
            //중복 자산 확인 - 그리드 리스트에 내용 갱신
            for clsTagInfo in arrAssetRows
            {
                //print("========== [1]처리량 증가/미처리량 감소 ==============")
                //let strCheckAssetEpc  = clsTagInfo.getAssetEpc()
                //print("===strAssetEpc: \(strAssetEpc) :: \(strCheckAssetEpc) ")
                //print("================================================")
                
                
                //같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
                if(strAssetEpc == clsTagInfo.getAssetEpc())
                {
                    boolFindAssetTypeOverlap = true;
                    
                    if(boolFindAbnormal == false)
                    {
                        clsTagInfo.setReadCount((clsTagInfo.getReadCount() + 1))        //증복된것이 있다면 조회수를 업데이트한다.
                    }
                    break;
                }
            }
            
            //이상이 없다면 삽입한다.
            if(boolFindAbnormal == false)
            {
                print("======== 태그 이상없음!! =========")
                
                //신규태그 입력 체크
                self.mBoolNewTagInfoExist = true
                
                //전송용 리스트에 추가
                arrTagRows.append(clsTagInfo)
                
                //그리드 리스트에 추가
                if(boolFindAssetTypeOverlap == false)
                {
                    arrAssetRows.append(clsTagInfo)
                }
                
                //입력창 내용 갱신(처리량증가/미처리량감소)
                mIntProcCount = Int(lblProcCount?.text ?? "0")!     //처리량
                mIntProcCount = mIntProcCount + 1
                lblProcCount.text = String(mIntProcCount)
                
                
//                    //5)그리드 리스에 내용 갱신
//                    for clsTagInfo in arrAssetRows
//                    {
//                        // 같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
//                        if(strAssetEpc == clsTagInfo.getAssetEpc())
//                        {
//                            clsTagInfo.setProcCount((clsTagInfo.getProcCount() + 1)) // 처리량 증가
//                            clsTagInfo.setRemainCount((clsTagInfo.getRemainCount() - 1)) // 미처리량 감소
//                        }
//                    }
            }
        }
        DispatchQueue.main.async { self.tvEasyOut?.reloadData() }
    }
    
    
    
    //=========================== [리더기 관련 이벤트및 처리 시작] ================================

    //=======================================
    //===== 리더기 연결 클릭이벤트
    //=======================================
    @IBAction func onRfidReaderClicked(_ sender: UIButton)
    {
        print("====[onRfidReaderClicked]====")
        if(sender.isSelected == false)
        {
            showSnackbar(message: NSLocalizedString("rfid_connecting_reader", comment: "RFID 리더기에 연결하는 중 입니다."))
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
        print("====[didReadTagid]====")
        let clsTagInfo = RfidUtil.parse(strData: tagid)
        getRfidData(clsTagInfo: clsTagInfo)
    }
    
    //리더기 연결성공
    func didReaderConnected()
    {
        print("====[didReaderConnected]====")
        showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
        changeBtnRfidReader(true)
    }
    
    //리더기 연결종로
    func didReaderDisConnected()
    {
        print("====[didReaderDisConnected]====")
        showSnackbar(message: NSLocalizedString("rfid_connection_terminated", comment: "연결이 종료되었습니다."))
        changeBtnRfidReader(false)
    }
    
    //리더기 연결 타임오바
    func didRederConnectTimeOver()
    {
        print("====[didRederConnectTimeOver]====")
        showSnackbar(message: NSLocalizedString("rfid_not_connect_reader", comment: "RFID 리더기에 연결할수 없습니다."))
        changeBtnRfidReader(false)
    }
    
    //리더기 연결 여부에 따른 버튼에대한 상태값 변경
    func changeBtnRfidReader(_ isConnected : Bool)
    {
        print("====[changeBtnRfidReader]====")
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
    //리더기 관련 이벤트및 처리 끝
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrAssetRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //tableView.allowsSelection = false           //셀 선택안되게 막음
        let objCell:EasyOutCell = tableView.dequeueReusableCell(withIdentifier: "tvcEasyOut", for: indexPath) as! EasyOutCell
        let clsTagInfo = arrAssetRows[indexPath.row]
        
        objCell.lblAssetName.text = clsTagInfo.getAssetName()
        objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
        
        objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        objCell.btnDetail.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
        objCell.btnDetail.tag = indexPath.row
        objCell.btnDetail.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
        return objCell
    }

    
    //=======================================
    //===== RFID 태그 목록 보기
    //=======================================
    @objc func onTagListClicked(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "segTagDetailList", sender: self)
    }
    
    

    //=======================================
    //===== 초기화 버튼 처리, 태그 리스트 재조회
    //=======================================
    func doReloadTagList()
    {
        // 1) 태그리스트 초기화
        clearTagData(false)
        
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "supplyService:selectSaleOutTagList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.mStrSaleWorkId)
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
            
            DispatchQueue.main.async
            {
                self.lblProcCount.text = "\(intDataRowsSize)"           //처리량
            }
            
            if( intDataRowsSize > 0)
            {
                for clsDataRow in clsDataTable.getDataRows()
                {
                    let strEpcCode              = clsDataRow.getString(name: "epcCode") ?? ""
                    let strEpcUrn               = clsDataRow.getString(name: "epcUrn") ?? ""
                    let strUtcTraceDate         = clsDataRow.getString(name: "utcTraceDate") ?? ""
                    let strProdAssetEpcName     = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                    let strProdAssetEpc         = clsDataRow.getString(name: "prodAssetEpc") ?? ""
                    let strTradeChit            = clsDataRow.getString(name: "tradeChit") ?? ""
                    let strVehName              = clsDataRow.getString(name: "vehName") ?? ""
                    
                    
                    //DB에서 조회된 태그 데이터 전달용 리스트에 저장
                    let clsTagInfo = RfidUtil.TagInfo()
                    clsTagInfo.setEpcCode(strEpcCode)
                    clsTagInfo.setAssetName(strProdAssetEpcName)
                    if(strEpcUrn.isEmpty == false)
                    {
                        clsTagInfo.setEpcUrn(strEpcUrn)
                        let arsEpcUrn = strEpcUrn.split(".")
                        if( arsEpcUrn.count == 4)
                        {
                            let strSerialNo = arsEpcUrn[3]
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
                    self.tvEasyOut.reloadData()
                }
            }
        })
    }
    
    
    //======================================
    //===== '초기화'버튼
    //======================================
    @IBAction func onClearAllClicked(_ sender: UIButton)
    {
        Dialog.show(container: self, viewController: nil,
                    title: NSLocalizedString("common_delete", comment: "삭제"),
                    message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
                    okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                    okHandler: { (_) in
                        if(self.mStrSaleWorkId.isEmpty == false)
                        {
                            self.doReloadTagList()              //초기화
                        }
                        else
                        {
                            self.clearTagData(true)
                            super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
                        }
        },
        cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
    }
    
    
    
    //======================================
    //===== '작업초기화'버튼
    //======================================
    @IBAction func onWorkInitClick(_ sender: UIButton)
    {
        if(mStrSaleWorkId.isEmpty == true)
        {
            //  Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_temporary_saved_data", comment: "임시 저장된 데이터가 없습니다."))
            //  return
            
            //'초기화'처리
            Dialog.show(container: self, viewController: nil,
                        title: NSLocalizedString("common_delete", comment: "삭제"),
                        message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
                        okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                        okHandler: { (_) in
                            if(self.mStrSaleWorkId.isEmpty == false)
                            {
                                self.doReloadTagList()              //초기화
                            }
                            else
                            {
                                self.clearTagData(true)
                                super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
                            }
                        },
                        cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
        }
        
        Dialog.show(container: self, viewController: nil,
                    title: NSLocalizedString("common_task_init", comment: "작업초기화"),
                    message: NSLocalizedString("common_confirm_work_Init", comment: "현재 작업을 초기화 하시겠습니까 ?"),
                    okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                    okHandler: { (_) in
                        self.sendWorkInitData(saleWorkId: self.mStrSaleWorkId, showMessage: true)
        },
                    cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
    }
    
    
    
    //=======================================
    //===== 작업초기화 데이터를 전송한다
    //======================================
    func sendWorkInitData(saleWorkId: String, showMessage: Bool)
    {
        clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
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

            let clsResultDataRows = clsResultDataTable.getDataRows()
            if(clsResultDataRows.count > 0)
            {
                let clsDataRow = clsResultDataRows[0]
                let strResultCode = clsDataRow.getString(name: "resultCode")
                
                print(" -strResultCode:\(strResultCode!)")
                
                if(Constants.PROC_RESULT_SUCCESS == strResultCode)
                {
                    //그리드 삭제 및 구조체 삭제
                    //DispatchQueue.main.async
                    //{
                        self.clearTagData(true)
                    
                        if(super.getUnload() == true)
                        {
                            if(showMessage == true)
                            {
                                let strMsg = NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다.")
                                self.showSnackbar(message: strMsg)
                            }
                        }
                    //}
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
    

	func sendWorkInitDataSync(saleWorkId: String)
	{
		let dsSemaphore = DispatchSemaphore(value: 0)
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "inOutService:executeOutCancelData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: saleWorkId)
		clsDataClient.executeData(dataCompletionHandler: { (data, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
				dsSemaphore.signal()
				return
			}
			guard let clsResultDataTable = data else {
				print("에러 데이터가 없음")
				dsSemaphore.signal()
				return
			}
			
			let clsResultDataRows = clsResultDataTable.getDataRows()
			if(clsResultDataRows.count > 0)
			{
				let clsDataRow = clsResultDataRows[0]
				let strResultCode = clsDataRow.getString(name: "resultCode")
				
				print(" -strResultCode:\(strResultCode!)")
				dsSemaphore.signal()
			}
		})
		_ = dsSemaphore.wait(timeout: .distantFuture)
	}
	
    //======================================
    //===== '임시저장'버튼
    //======================================
    @IBAction func onTempSaveClick(_ sender: UIButton)
    {
        if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
            return
        }
     
        //입고처 정보확인
        if(self.mStrTransferCustId.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_selected_out_cust", comment: "입고처를 선택하여 주십시오."))
            return
        }

        if(self.mBoolNewTagInfoExist == false)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
            return
        }
        

        let strVehName      = self.tfVehName?.text ?? ""
        let strTradeChit    = self.tfTradeChit.text ?? ""
        
        if(self.mStrSaleWorkId.isEmpty == false)
        {
            //송장번호 O, DB로 데이터 전송 처리
            sendDataExistSaleWorkId(Constants.WORK_STATE_WORKING, mStrSaleWorkId, strVehName, strTradeChit, "", "")
        }
        else
        {
            //송장번호 X , 송장번호(SaleWorkId) 발급후 DB로 데이터 전송 처리
            sendDataNoneSaleWorkId(Constants.WORK_STATE_WORKING, mStrTransferCustId, strVehName, strTradeChit, "", "");
        }

    }
    
    
    
    
    //======================================
    //===== '완료전송'버튼
    //======================================
    @IBAction func onSendClicked(_ sender: UIButton)
    {
        //단말기ID 필수
        if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
            return
        }
        
        //입고처 정보확인
        if(self.mStrTransferCustId.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_no_selected_out_cust", comment: "입고처를 선택하여 주십시오."))
            return
        }
        
        //차량번호 필수
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //======================================
    //===== DB로 데이터 전송처리
    //======================================
    func sendDataExistSaleWorkId(_ workState: String,_ saleWorkId: String,_ vehName: String,_ tradeChit: String,_ remark : String,_ signData: String)
    {
        clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
        
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.ExecuteUrl = "inOutService:executeOutData"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId",          value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userId",          value: AppContext.sharedManager.getUserInfo().getUserId())
        clsDataClient.addServiceParam(paramName: "workState",       value: workState)
        clsDataClient.addServiceParam(paramName: "saleWorkId",      value: saleWorkId)
        clsDataClient.addServiceParam(paramName: "vehName",         value: vehName)
        clsDataClient.addServiceParam(paramName: "branchId",        value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "unitId",          value: AppContext.sharedManager.getUserInfo().getUnitId())
        clsDataClient.addServiceParam(paramName: "barcodeId",       value: "")                      //바코드ID
        clsDataClient.addServiceParam(paramName: "itemCode",        value: "")                      //제품 코드
        clsDataClient.addServiceParam(paramName: "prodCnt",         value: "")                      //제품 개수
        
        // 완료전송 및(강제)완료전송 경우
        if(Constants.WORK_STATE_COMPLETE == workState)
        {
            let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
            let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
            clsDataClient.addServiceParam(paramName: "workDateTime",    value: strWorkDateTime)
            clsDataClient.addServiceParam(paramName: "workerName",      value: "")
            clsDataClient.addServiceParam(paramName: "driverName",      value: "")
            clsDataClient.addServiceParam(paramName: "tradeChit",       value: tradeChit)
            clsDataClient.addServiceParam(paramName: "remark",          value: remark)
            if(signData.isEmpty == false)
            {
                clsDataClient.addServiceParam(paramName: "signData",    value: signData)        //사인데이터
            }
        }
        
        let clsDataTable : DataTable = DataTable()
        
        clsDataTable.Id = "WORK_OUT"
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
            print("=========[4]DB로 데이터 전송처리 =====")
            let clsResultDataRows = clsResultDataTable.getDataRows()
            if(clsResultDataRows.count > 0)
            {
                let clsDataRow = clsResultDataRows[0]
                let strResultCode = clsDataRow.getString(name: "resultCode")
                
                print(" -strResultCode:\(strResultCode!)")
                if(Constants.PROC_RESULT_SUCCESS == strResultCode)
                {
                    let strSvrWorkState = clsDataRow.getString(name: "workState")
                    //print("-서버로부터 받은 처리갯수: \(strSvrProcCount)")
                    //print("-서버로부터 받은 작업처리상태:  \(strSvrWorkState)!")

                    //DispatchQueue.main.async
                    //{
                        //전송 성공인 경우
                        for clsInfo in self.arrTagRows
                        {
                            if(clsInfo.getNewTag() == true)
                            {
                                clsInfo.setNewTag(false)        //태그상태 NEW -> OLD로 변경
                            }
                        }
                        self.mBoolNewTagInfoExist = false
                        self.mBoolExistSavedInvoice = true      //송장번호 할당여부
                    
                        //현재 작업상태가 완료전송인경우
                        if(Constants.WORK_STATE_COMPLETE == strSvrWorkState)
                        {
                            //송장정보관련 UI객체를 초기화한다.
                            self.clearTagData(true)
                        }
                        let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
                    
                        self.showSnackbar(message: strMsg)
                    //}
                }
                else
                {
                    let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)

                    if((Constants.PROC_RESULT_ERROR_NO_REGISTERED_READERS == strResultCode) || (Constants.PROC_RESULT_ERROR_NO_MATCH_BRANCH_CUST_INFO == strResultCode))
                    {
                        //super.showSnackbar(message: NSLocalizedString("common_error", comment: "에러"))
                         self.showSnackbar(message: strMsg)
                    }
                    else
                    {
                        self.showSnackbar(message: strMsg)
                    }
                    
                    if(self.mStrSaleWorkId.isEmpty == false)
                    {
                        //완료전송 처리중 오류시 발번받은 송장번호 초기화
                        self.sendWorkInitData(saleWorkId: self.mStrSaleWorkId, showMessage: false)       //초기화
                    }
                }
            }
        })
    }
    
    
    //=======================================
    //===== 송장번호를 발급후, DB로 데이터 전송처리
    //======================================
    func sendDataNoneSaleWorkId(_ workState: String,_ tansferCustId: String,_ vehName: String,_ tradeChit: String,_ remark: String,_ signData: String)
    {
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectSaleWorkId"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName:"corpId",       value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName:"userId",       value: AppContext.sharedManager.getUserInfo().getUserId())
        clsDataClient.addServiceParam(paramName:"branchId",     value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName:"toBranchId",   value: tansferCustId)
        
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
            if(clsDataTable.getDataRows().count > 0)
            {
                let clsDataRow = clsDataTable.getDataRows()[0]
                self.mStrSaleWorkId = clsDataRow.getString(name: "resultSaleWorkId") ?? ""      //서버에서 발급받은 송장번호
                
                //DB로 데이터 전송처리
                self.sendDataExistSaleWorkId(workState, self.mStrSaleWorkId, vehName, tradeChit, remark, signData)
            }
        })
    }
}


extension EasyOut
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
            tc.toolbar.detail = NSLocalizedString("title_work_out_delivery", comment: "출고")
        }
    }
}
