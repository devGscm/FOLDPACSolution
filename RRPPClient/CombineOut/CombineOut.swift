//
//  CombineOut.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic

class CombineOut: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
    @IBOutlet weak var lblUserName: UILabel!            //작업자
    @IBOutlet weak var lblBranchInfo: UILabel!          //거점
    @IBOutlet weak var lblReaderName: UILabel!          //리더명
    @IBOutlet weak var btnRfidReader: UIButton!         //연결
    
    @IBOutlet weak var btnSelectWorkType: UIButton!     //구분
    @IBOutlet weak var btnSaleWorkId: UIButton!         //송장선택
    @IBOutlet weak var btnBarcodeSearch: UIButton!      //바코드
    
    @IBOutlet weak var tfVehName: UITextField!          //차량번호
    
    @IBOutlet weak var lblOrderCustName: UILabel!       //입고처
    @IBOutlet weak var lblDeliBranchName: UILabel!      //출고처

    @IBOutlet weak var lblAssetEpcName: UILabel!        //유형
    @IBOutlet weak var lblAssignCount: UILabel!         //출고예정
    
    @IBOutlet weak var lblProcCount: UILabel!           //처리량
    @IBOutlet weak var lblRemainCount: UILabel!         //미처리량
    @IBOutlet weak var tvCombineOut: UITableView!       //테이블뷰
    
    
    
    
    var clsIndicator : ProgressIndicator?
    var clsDataClient : DataClient!
    var mStrSaleWorkId = String()                        //송장번호
    var mStrProdAssetEpc = String()                      //유형
    var mIntProcCount = Int()                            //처리량
    var mIntWorkAssignCount = Int()                      //출고량
    var mBoolNewTagInfoExist = Bool()
    var arrResultDataRows : Array<DataRow> = Array<DataRow>()
    var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    
    
    
    
    
    
    var tfCurControl : UITextField!
    var dpPicker : UIDatePicker!
    
    var intPageNo  = 0

    var arcDataRows : Array<DataRow> = Array<DataRow>()
    var arcSaleType : Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strSaleType : String?
    
    var arcSearchCondition:Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strSearchCondtion = String()
    
    var intSelectedIndex = -1
    var strRecvSaleOrderId = String()
    
    //=======================================
    //=====  viewDidLoad()
    //=======================================
    override func viewDidLoad()
    {
        print("=========================================")
        print("*CombineOut.viewDidLoad()")
        print("=========================================")
        super.viewDidLoad()
    }
    
    //=======================================
    //=====  didReceiveMemoryWarning()
    //=======================================
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //=======================================
    //===== viewWillAppear()
    //=======================================
    override func viewWillAppear(_ animated: Bool)
    {
        print("=========================================")
        print("*CombineOut.viewWillAppear()")
        print("=========================================")
        super.viewWillAppear(animated)
        super.initController()
        
        prepareToolbar()        //툴바 타이틀 설정
        initViewControl()       //뷰 컨트롤 초기화
        initSelectWorkType()

    }
    
    
    //=======================================
    //===== viewDidDisappear()
    //=======================================
    override func viewDidDisappear(_ animated: Bool)
    {
        arcDataRows.removeAll()
        arcSearchCondition.removeAll()
        
        clsIndicator = nil
        clsDataClient = nil
        
        super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    
    //=======================================
    //===== initViewControl()
    //=======================================
    func initViewControl()
    {
        clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
                                         indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
        
        lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()                                 //작업자
        lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()                             //거점
        //lblReaderName.text = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY)             //리더기명
        lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()                          //리더기명
        
        btnSaleWorkId.setTitle(NSLocalizedString("sale_work_id_selection", comment: "송장선택"), for: .normal)
        btnBarcodeSearch.setTitle(NSLocalizedString("common_barcode_search", comment: "바코드"), for: .normal)
        
        //공통코드 조회
        initCommonCodeList(userLang: AppContext.sharedManager.getUserInfo().getUserLang())
        self.strSaleType = ""
        
    }
    
    
    
    
    //=======================================
    //===== '구분' 셀렉트박스
    //=======================================
    @IBAction func onSelectWorkType(_ sender: UIButton) {
        let clsDialog = ListViewDialog()
        clsDialog.contentHeight = 150
        clsDialog.loadData(data: arcSaleType, selectedItem: strSaleType!)
        
        let acDialog = UIAlertController(title: NSLocalizedString("sale_type_name", comment: "구분"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.strSaleType = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
            self.btnSelectWorkType.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    //=======================================
    //===== '구분' 셀렉트박스 0번으로 선택
    //=======================================
    func initSelectWorkType()
    {
        //구분을 0번째 아이템으로 설정.
        if(arcSaleType.count > 0)
        {
            btnSelectWorkType.setTitle(arcSaleType[0].itemName, for: .normal)
            strSaleType = arcSaleType[0].itemCode
        }
    }
    
    
    //=======================================
    //===== 공통코드 정보를 읽어온다.
    //=======================================
    func initCommonCodeList(userLang : String)
    {
        //arcSaleType.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        let strCustType = AppContext.sharedManager.getUserInfo().getCustType()
        
        var ctUserCustType = LocalData.CustType.PMK
        if(strCustType == Constants.CUST_TYPE_PMK) { ctUserCustType = .PMK }
        else if(strCustType == Constants.CUST_TYPE_RDC) { ctUserCustType = .RDC }
        else if(strCustType == Constants.CUST_TYPE_EXP) { ctUserCustType = .EXP }
        else if(strCustType == Constants.CUST_TYPE_IMP) { ctUserCustType = .IMP }
        
        let arrSaleType: Array<CodeInfo> = LocalData.shared.getSaleTypeCodeDetail(fieldValue:"SALE_TYPE", saleResale: .Sale, custType: ctUserCustType, initCodeName:nil)
        
        for clsInfo in arrSaleType
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
            else
            {
                strCommName = clsInfo.commNameKr
            }
            arcSaleType.append(ListViewDialog.ListViewItem(itemCode: clsInfo.commCode, itemName: strCommName))
        }
    }
    
    
    
    //=======================================
    //===== initDataClient()
    //=======================================
    func initDataClient()
    {
        clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectWorkCombineInOutCancelList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
    }
    
    
    //=======================================
    //===== doInitSearch()
    //=======================================
    func doInitSearch()
    {
        intPageNo = 0
        self.arcDataRows.removeAll()
        self.doSearch()
    }
    
    
    //=======================================
    //===== doSearch()
    //=======================================
    func doSearch()
    {

    }
   
    
    
  
    
    
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.arrAssetRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableView.rowHeight = 65                    //셀 크기 조정
        tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:CombineOutCell = tableView.dequeueReusableCell(withIdentifier: "tvcCombineOut", for: indexPath) as! CombineOutCell
        
        let clsTagInfo = arrAssetRows[indexPath.row]
        
        objCell.lblAssetEpcName.text = clsTagInfo.getAssetName()
        objCell.lblAssignCnt.text = String(clsTagInfo.getWorkAssignCount())
        objCell.lblProcCnt.text = String(clsTagInfo.getProcCount())
        objCell.lblRemainCnt.text = String(clsTagInfo.getRemainCount())
        
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
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
    //===== '유형'버튼
    //=======================================
    @objc func onItemSelectionClicked(_ sender: UIButton)
    {
//        self.intSelectedIndex = sender.tag
//        self.performSegue(withIdentifier: "segInOutCancelDetailCell", sender: self)
    }
    

    //=======================================
    //===== 'Prepare' - Segue처리
    //=======================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
        if(segue.identifier == "segCombineOutWorkList")
        {
            if let clsDialog = segue.destination as? CombineOutWorkList
            {
                clsDialog.ptcDataHandler = self
                clsDialog.strWorkType = strSaleType!     //구분
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
                    clsDialog.loadData(arcTagInfo : arrData)
                }
            }
        }
    }
    
    
    
    //=======================================
    //===== 씬(Scene)데이터 수신
    //=======================================
    func recvData(returnData: ReturnData)
    {
        if(returnData.returnType == "CombineOutWorkList")
        {
            if(returnData.returnRawData != nil)
            {
                let clsDataRow  = returnData.returnRawData as! DataRow
                if(mStrSaleWorkId != clsDataRow.getString(name: "saleWorkId") ?? "")
                {
                    //화면정보 초기화
                    clearTagData(true)
                    
                    let clsDataRow = returnData.returnRawData as! DataRow
                    
                    //팝업에서 넘어온 데이터를 넣는다.
                    mStrSaleWorkId          = clsDataRow.getString(name: "saleWorkId") ?? ""
                    let strOrderCustName    = clsDataRow.getString(name: "orderCustName") ?? ""
                    let strDeliBranchName   = clsDataRow.getString(name: "deliBranchName") ?? ""
                    mIntWorkAssignCount     = clsDataRow.getInt(name: "workAssignCnt") ?? 0
                    mIntProcCount           = clsDataRow.getInt(name: "procCnt") ?? 0
                    let strVehName          = clsDataRow.getString(name: "vehName") ?? ""
                    mStrProdAssetEpc        = clsDataRow.getString(name: "prodAssetEpc") ?? ""
                    let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                    let intRemainCnt        = clsDataRow.getInt(name: "remainCnt") ?? 0

                    //화면에 정보표시
                    btnSaleWorkId.setTitle(mStrSaleWorkId, for: .normal)
                    lblOrderCustName.text   = strOrderCustName
                    lblDeliBranchName.text  = strDeliBranchName
                    lblAssignCount.text     = String(mIntWorkAssignCount)
                    lblProcCount.text       = String(mIntProcCount)
                    tfVehName.text          = strVehName
                    lblAssetEpcName.text    = strProdAssetEpcName
                    lblRemainCount.text     = String(intRemainCnt)
                    
                    //선택된 '송장정보' 내용조회
                    doSearchWorkListDetail()
                }
                
                
                
            }
        }
        
    }

    
    
    func doSearchWorkListDetail()
    {
        clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectCombineOutWorkListDetail"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: mStrSaleWorkId)
        
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error
            {
                //에러처리
                DispatchQueue.main.async { self.tvCombineOut?.hideIndicator() }
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else
            {
                DispatchQueue.main.async { self.tvCombineOut?.hideIndicator() }
                print("에러 데이터가 없음")
                return
            }
            
            //DB에서 리스트 조회값 받음
            for clsDataRow in clsDataTable.getDataRows()
            {
                //let strSaleWorkId       = clsDataRow.getString(name: "saleWorkId") ?? ""
                let strProcCnt          = clsDataRow.getString(name: "procCnt") ?? ""
                let strWorkAssignCnt    = clsDataRow.getString(name: "workAssignCnt") ?? ""
                let strRemainCnt        = clsDataRow.getString(name: "remainCnt") ?? ""
                let strProdAssetEpc     = clsDataRow.getString(name: "prdAssetEpc") ?? ""
                let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                                    
                //그리드용 자료구조에 넣기
                let clsTagInfo = RfidUtil.TagInfo()
                clsTagInfo.setProcCount(Int(strProcCnt)!)
                clsTagInfo.setWorkAssignCount(Int(strWorkAssignCnt)!)
                clsTagInfo.setRemainCount(Int(strRemainCnt)!)
                clsTagInfo.setAssetEpc(strProdAssetEpc)
                clsTagInfo.setAssetName(strProdAssetEpcName)
                
                
                
                //그리드 리스트에 추가
                self.arrAssetRows.append(clsTagInfo)
            }
            DispatchQueue.main.async
            {
                self.tvCombineOut?.reloadData()
                self.tvCombineOut?.hideIndicator()
            }
        })
    }
    
    
    func getRfidData( clsTagInfo : RfidUtil.TagInfo)
    {
        let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
        let strSerialNo = clsTagInfo.getSerialNo()
        let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드
        
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
                self.mBoolNewTagInfoExist = true
                
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
                
                // 입력창 내용 갱신(처리량증가/미처리량감소)
                var intRemainCount: Int = Int(lblRemainCount?.text ?? "0")! // 미처리량
                if intRemainCount > 0
                {
                    intRemainCount = intRemainCount - 1
                    //lblRemainCount.text = "\(intRemainCount)"
                    lblRemainCount.text = String(intRemainCount)
                }
                
                self.mIntProcCount = Int(lblProcCount?.text ?? "0")! + 1 // 처리량
                lblProcCount?.text = String(mIntProcCount)
                
                
                //5)그리드 리스에 내용 갱신
                for clsTagInfo in arrAssetRows
                {
                    // 같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
                    if(strAssetEpc == clsTagInfo.getAssetEpc())
                    {
                        clsTagInfo.setProcCount((clsTagInfo.getProcCount() + 1)) // 처리량 증가
                        clsTagInfo.setRemainCount((clsTagInfo.getRemainCount() - 1)) // 미처리량 감소
                    }
                }
            }
        }
        DispatchQueue.main.async { self.tvCombineOut?.reloadData() }
    }
    
    
    
    
    //=======================================
    //===== 화면 및 데이터 리스트 클리어
    //=======================================
    func clearTagData(_ clearScreen: Bool )
    {
        mBoolNewTagInfoExist = false
        arrTagRows.removeAll()
        arrAssetRows.removeAll()
        
        DispatchQueue.main.async
        {
            self.tvCombineOut?.reloadData()      //테이블뷰 클리어
        }
        
        if(clearScreen == true)
        {
            mStrSaleWorkId = ""
            mStrProdAssetEpc = ""
            mIntProcCount = 0
            mIntWorkAssignCount = 0
            
            self.tfVehName.text = ""            //차량번호
            self.lblOrderCustName.text = ""     //입고처
            self.lblDeliBranchName.text = ""    //배송거점
            self.lblAssetEpcName.text = ""      //유형
            self.lblAssignCount.text = ""       //출고예정
            self.lblProcCount.text = ""         //처리량
            self.lblRemainCount.text = ""       //미처리량
        }
        
        //RFID리더기 초기화
        super.clearInventory()
    }
    
    
    
    
    //=======================================
    //===== '송장선택'버튼
    //=======================================
    @IBAction func onSaleWorkIdClicked(_ sender: Any)
    {
        self.performSegue(withIdentifier: "segCombineOutWorkList", sender: self)
    }
    
    
    
    //리더기 관련 이벤트및 처리 시작
    
    //=======================================
    //===== 리더기 연결 클릭이벤트
    //=======================================
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
    //리더기 관련 이벤트및 처리 끝
    
    
    //=======================================
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
                    self.doReloadTagList()    // 초기화
                }
                else
                {
                    self.clearTagData(false)
                    super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
                }
            },
            cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
    }
    
    
    //=======================================
    //===== 초기화 버튼 처리, 태그 리스트 재조회
    //======================================
    func doReloadTagList()
    {
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectSaleOutWorkList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.mStrSaleWorkId)
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
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
                let strOrderCustName            = clsDataRow.getString(name: "orderCustName") ?? ""
                
                
                
//                self.strResaleOrderId            = clsDataRow.getString(name: "resaleOrderId") ?? ""            //구매주문ID
//                self.mStrSaleWorkId                 = clsDataRow.getString(name: "saleWorkId") ?? ""                //송장번호
//
//                self.intOrderReqCount             = clsDataRow.getInt(name: "orderReqCnt") ?? 0
//                self.intProcCount                = clsDataRow.getInt(name: "procCnt") ?? 0                    //처리량
//                self.intNoreadCnt                = clsDataRow.getInt(name: "noreadCnt") ?? 0                //미인식
//                //let strVehName                    = clsDataRow.getString(name: "resaleVehName") ?? ""            //차량번호
//
//                self.strWorkerName                = clsDataRow.getString(name: "workerName") ?? ""            //작업자명
//                self.strProdAssetEpc            = clsDataRow.getString(name: "prodAssetEpc") ?? ""                //유형
//
//
//                var intRemainCnt                = self.intOrderReqCount - self.intProcCount            //미처리량
//                if(intRemainCnt < 0)
//                {
//                    intRemainCnt = 0                                        //미처리량 0이하는 0
//                }
//
//                self.lblResaleBranchName.text    = clsDataRow.getString(name: "resaleBranchName") ?? ""            // 출고처
//                self.btnSaleWorkId.setTitle(self.strSaleWorkId, for: .normal)    // 송장번호
//                self.lblOrderReqCount.text        = "\(self.intOrderReqCnt)"        // 입고예정수량
//                self.lblProcCount.text            = "\(self.intProcCount)"        // 처리량
//                self.lblDriverName.text            = clsDataRow.getString(name: "resaleDriverName") ?? ""            // 납품자
//                self.lblProdAssetEpcName.text    = clsDataRow.getString(name: "prodAssetEpcName") ?? ""            // 유형명
//                self.lblRemainCount.text        = "\(intRemainCnt)"        // 미처리량
//
//                //2) 태그데이터 초기화
//                self.clearTagData(clearScreen: false)
//
//
//                //3)조회 및 그리드 리스트에 표시
//
//                self.doSearchWorkListDetail()        //선택된 '송장정보' 내용 조회
//                self.doSearchTagList()                //선택된 '송장정보'에 대한 태그리스트
//
//                self.boolWorkListSelected = true    //송장 선택 여부
//                super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
            }
        })
    }
    
    
    
    
    
    
    
}
    
    


//=======================================
//===== 툴바 타이틀
//======================================
extension CombineOut
{
    fileprivate func prepareToolbar()
    {
        guard let tc = toolbarController else {
            return
        }
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        tc.toolbar.detail = NSLocalizedString("title_work_out_delivery", comment: "출고")
    }
}


