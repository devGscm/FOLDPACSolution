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
    var arrAssetERows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    
    
    
    
    
    
    
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
        clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
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
        return self.arcDataRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.rowHeight = 65                    //셀 크기 조정
        tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:CombineOutWorkListCell = tableView.dequeueReusableCell(withIdentifier: "tvcCombineOutWorkList", for: indexPath) as! CombineOutWorkListCell
//        let clsDataRow = arcDataRows[indexPath.row]
//
//        let strUtcTraceDate = clsDataRow.getString(name:"deliDate")
//        let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
//        let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"YYYY/MM/dd")
//
//
//        objCell.lblSaleWorkId?.text = clsDataRow.getString(name:"saleWorkId")
//        objCell.lblAssetEpcName?.text = clsDataRow.getString(name:"prodAssetEpcName")
//        objCell.lblOrderReqDate?.text = strTraceDate
//        objCell.lblWorkAssignCnt?.text = clsDataRow.getString(name:"workAssigCnt")
//        objCell.lblResaleBranchName?.text = clsDataRow.getString(name:"deliBranchName")
//        objCell.lblResaleAddr?.text = clsDataRow.getString(name:"deliAddr")
//
//        //선택버튼
//        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 17)
//        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.trashO), for: .normal)
//        objCell.btnSelection.tag = indexPath.row
//        objCell.btnSelection.addTarget(self, action: #selector(onItemCancelClicked(_:)), for: .touchUpInside)
        
        return objCell
    }
    
    //=======================================
    //===== '유형'버튼
    //=======================================
    @objc func onItemSelectionClicked(_ sender: UIButton)
    {
//        self.intSelectedIndex = sender.tag
//        self.performSegue(withIdentifier: "segInOutCancelDetailCell", sender: self)
    }
    
    
    // Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "segCombineOutWorkList")
        {
            if let clsDialog = segue.destination as? CombineOutWorkList
            {
                clsDialog.ptcDataHandler = self
                clsDialog.strWorkType = strSaleType!     //구분
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
    
    
    func didReadTagid(_ tagid: String) {}

    
    
    func doSearchWorkListDetail()
    {
        clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
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
                let strSaleWorkId       = clsDataRow.getString(name: "saleWorkId") ?? ""
                let strProcCnt          = clsDataRow.getString(name: "procCnt") ?? ""
                let strWorkAssignCnt    = clsDataRow.getString(name: "workAssignCnt") ?? ""
                let strRemainCnt        = clsDataRow.getString(name: "remainCnt") ?? ""
                let strProdAssetEpc     = clsDataRow.getString(name: "prdAssetEpc") ?? ""
                let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                                    
                
                let clsEpcInfo = RfidUtil.TagInfo()
                //clsEpcInfo.
                
                //arrAssetERows
                
                
//                if(strEpcUrn.isEmpty == false)
//                {
//                    let intIndex = strEpcUrn.lastIndex(of: ".") + 1
//                    let intLength = strEpcUrn.length - intIndex
//
//                    strSerialNo = strEpcUrn.substring(intIndex, length: intLength)
//                    print("=============================================")
//                    print("strSerialNo:\(strSerialNo)")
//                    print("=============================================")
//                }
//
//                // 마스터-RFID태그정보
//                let clsMastItemInfo = ItemInfo()
//                clsMastItemInfo.setEpcCode(epcCode: strEpcCode)
//                clsMastItemInfo.setEpcUrn(epcUrn: strEpcUrn)
//                clsMastItemInfo.setSerialNo(serialNo: strSerialNo)
//                clsMastItemInfo.setAssetEpc(assetEpc: strProdAssetEpc)
//                clsMastItemInfo.setAssetName(assetName: strProdAssetEpcName)
//                clsMastItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
//                clsMastItemInfo.setReadCount(readCount: 1)
//                clsMastItemInfo.setReadTime(readTime: strTraceDate)
//
//                //슬래이브-상품정보
//                let clsSlaveItemInfo = ItemInfo()
//                clsSlaveItemInfo.setEpcCode(epcCode: strEpcCode)
//                clsSlaveItemInfo.setSaleItemSeq(saleItemSeq: strSaleItemSeq)
//                clsSlaveItemInfo.setProdCode(prodCode: strBarcodeId)
//                clsSlaveItemInfo.setProdName(prodName: strItemName)
//                clsSlaveItemInfo.setRowState(rowState: Constants.DATA_ROW_STATE_UNCHANGED)
//                clsSlaveItemInfo.setProdReadCnt(prodReadCnt: strCnt)
//                clsSlaveItemInfo.setReadTime(readTime: strTraceDate)
//
//                // #1.헤시맵 생성
//                if(self.clsProdContainer.containEpcCode(epcCode: strEpcCode) == false)
//                {
//                    // #1-1.구조체 수정
//                    self.clsProdContainer.loadProdEpc(epcCode: strEpcCode)
//
//                    // #1-2.마스터 그리스 저장
//                    self.arrRfidRows.append(clsMastItemInfo)
//                }
//
//                // #2.아이템 생성-바코드ID가 있는경우
//                if(strBarcodeId.isEmpty == false)
//                {
//                    self.clsProdContainer.addItem(epcCode: strEpcCode, itemInfo: clsSlaveItemInfo)
//
//                    //#3.서브 그리드 저장
//                    self.arrProdRows.append(clsSlaveItemInfo)
//                }
            }
            
            
            
            
            
            
            

            DispatchQueue.main.async
            {
                    self.tvCombineOut?.reloadData()
                    self.tvCombineOut?.hideIndicator()
            }
        })
        
        
        
        
    }
    
    
    func clearTagData(_ boolClearScreen: Bool )
    {
        mBoolNewTagInfoExist = false
        arrResultDataRows.removeAll()
        //arrTagListRowParcel.removeAll()
        //arrTagListRow.removeAll()
        
        tvCombineOut?.reloadData()      //테이블뷰 클리어
        
        if(boolClearScreen == true)
        {
            mStrSaleWorkId = ""
            mStrProdAssetEpc = ""
            mIntProcCount = 0
            mIntWorkAssignCount = 0
            
            self.tfVehName.text = ""
            self.lblOrderCustName.text = ""
            self.lblDeliBranchName.text = ""
            self.lblAssetEpcName.text = ""
            self.lblAssignCount.text = ""
            self.lblProcCount.text = ""
            self.lblRemainCount.text = ""
        }
        
        super.clearInventory()
    }
    
    
    
    
    //=======================================
    //===== '송장선택'버튼
    //=======================================
    @IBAction func onSaleWorkIdClicked(_ sender: Any)
    {
        self.performSegue(withIdentifier: "segCombineOutWorkList", sender: self)
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


