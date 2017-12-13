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
    
    
    var clsIndicator : ProgressIndicator?
    var clsDataClient : DataClient!
    
    
    
    
    
    
    
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
        lblReaderName.text = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY)               //리더기명

        let aaa = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY) ?? ""
        print("==AAA: \(aaa)")
        
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
    //===== 공통코드 정보를 읽어온다.
    //=======================================
    func initCommonCodeList(userLang : String)
    {
        arcSaleType.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        let arrSaleType: Array<CodeInfo> = LocalData.shared.getCodeDetail(fieldValue:"SALE_TYPE", commCode:nil, viewYn:"Y", initCodeName:nil)
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
//        intPageNo += 1
//        let strSearchValue = tfSearchValue.text ?? "";
//
//        let strLocaleStDate = StrUtil.replace(sourceText: (tfStDate?.text)!, findText: "-", replaceText: "") + "000000"
//        let strLocaleEnDate = StrUtil.replace(sourceText: (tfEnDate?.text)!, findText: "-", replaceText: "") + "235959"
//
//        let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
//        let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
//
//        if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
//        {
//            Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
//            return
//        }
//
//        clsDataClient.addServiceParam(paramName: "startWorkDate", value: strLocaleStDate)
//        clsDataClient.addServiceParam(paramName: "endWorkDate", value: strLocaleEnDate)
//        clsDataClient.addServiceParam(paramName: "ioType", value: strSaleType!)
//        clsDataClient.addServiceParam(paramName: "searchCondition", value: strSearchCondtion)
//        clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
//        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
//        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
//        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
//            if let error = error {
//                // 에러처리
//                print(error)
//                return
//            }
//            guard let clsDataTable = data else {
//                //print("에러 데이터가 없음")
//                return
//            }
//            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
//            DispatchQueue.main.async{ self.tvInOutCancel?.reloadData()}
//        })
    }
    
    //=======================================
    //===== scrollViewDidEndDragging()
    //=======================================
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        let fltOffsetY = scrollView.contentOffset.y
        let fltContentHeight = scrollView.contentSize.height
        if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
        {
            doSearch()
        }
    }
    
    
    //=======================================
    //===== 입출고 구분
    //=======================================
//    @IBAction func onSaleTypeSelection(_ sender: Any) {
//        let clsDialog = ListViewDialog()
//        clsDialog.contentHeight = 150
//        clsDialog.loadData(data: arcSaleType, selectedItem: strSaleType!)
//
//        let acDialog = UIAlertController(title: NSLocalizedString("sale_type_name", comment: "입출고 구분"), message:nil, preferredStyle: .alert)
//        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
//
//        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
//            self.strSaleType = clsDialog.selectedRow.itemCode
//            let strItemName = clsDialog.selectedRow.itemName
//            self.btnSaleTypeCondition.setTitle(strItemName, for: .normal)
//        }
//        acDialog.addAction(aaOkAction)
//        self.present(acDialog, animated: true)
//    }
    
    
    //=======================================
    //===== 검색 조건
    //=======================================
//    @IBAction func onSearchCondition(_ sender: Any) {
//        let clsDialog = ListViewDialog()
//        clsDialog.loadData(data: arcSearchCondition, selectedItem: strSearchCondtion)
//        clsDialog.contentHeight = 150
//
//        let acDialog = UIAlertController(title: NSLocalizedString("common_search_condition", comment: "검색조건"), message: nil, preferredStyle: .alert)
//        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
//
//        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
//            self.strSearchCondtion = clsDialog.selectedRow.itemCode
//            let strItemName = clsDialog.selectedRow.itemName
//            self.btnSearchCondition.setTitle(strItemName, for: .normal)
//        }
//
//        acDialog.addAction(aaOkAction)
//        self.present(acDialog, animated: true)
//    }
    
    //=======================================
    //===== '검색'버튼
    //=======================================
//    @IBAction func onSearchClicked(_ sender: UIButton) {
//        doInitSearch()
//
//    }
    
    
    
    //=======================================
    //===== createDatePicker - 날짜검색
    //=======================================
//    func createDatePicker(tfDateControl : UITextField)
//    {
//        tfCurControl = tfDateControl
//
//        dpPicker.locale = Locale(identifier: "ko_KR")
//        dpPicker.datePickerMode = .date
//
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        let bbiDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonPressed))
//        toolbar.setItems([bbiDoneButton], animated: false)
//        tfDateControl.inputAccessoryView = toolbar
//        tfDateControl.inputView = dpPicker
//    }
    
    
    
    //=======================================
    //===== onDoneButtonPressed - 날짜 검색완료
    //=======================================
//    @objc func onDoneButtonPressed(_ sender : Any)
//    {
//        let dfFormatter = DateFormatter()
//        dfFormatter.dateFormat = "yyyy-MM-dd"
//        tfCurControl.text = dfFormatter.string(from: dpPicker.date)
//        self.view.endEditing(true)
//    }
    
    
    
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arcDataRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.rowHeight = 60                    //셀 크기 조정
        tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:InOutCancelCell = tableView.dequeueReusableCell(withIdentifier: "tvcInOutCancel", for: indexPath) as! InOutCancelCell
        let clsDataRow = arcDataRows[indexPath.row]
        
        let strUtcTraceDate = clsDataRow.getString(name:"workDate")
        let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
        let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"MM/dd")
        let strTraceTime = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"HH:mm")
        
        
//        objCell.lblRowNo?.text = clsDataRow.getString(name:"rowNo")
//        objCell.lblWorkDate?.text = strTraceDate
//        objCell.lblWorkTime?.text = strTraceTime
//        objCell.lblInoutCustName?.text = clsDataRow.getString(name:"inoutCustName")
//        objCell.lblIoTypeName?.text = clsDataRow.getString(name:"ioTypeName")
//        objCell.lblWorkId?.text = clsDataRow.getString(name:"workId")
//
//        //유형라벨(버튼)
//        objCell.btnAssetEpcName.setTitle(clsDataRow.getString(name:"assetEpcName"), for: .normal)
//        objCell.btnAssetEpcName.tag = indexPath.row
//        objCell.btnAssetEpcName.addTarget(self, action: #selector(onItemSelectionClicked(_:)), for: .touchUpInside)
//        objCell.lblCompleteWorkCnt?.text = clsDataRow.getString(name:"completeWorkCnt")
//
//
//        //취소버튼
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
//        //'유형'그리드 버튼
//        if(segue.identifier == "segInOutCancelDetailCell")
//        {
//            if let clsDialog = segue.destination as? InOutCancelDetail
//            {
//                if let btnAssetEpcName = sender as? UIButton
//                {
//                    //print("==btnAssetEpcName: \(btnAssetEpcName.tag)")
//                    let clsAssetEpc = self.arcDataRows[btnAssetEpcName.tag]
//                    let saleOrderId = clsAssetEpc.getString(name:"workId")
//
//                    //print("==saleOrderId: \(saleOrderId!)")
//                    clsDialog.strSaleWorkId = saleOrderId!      //상세리스트에 표출할 ResaleOrderId 전달
//                }
//            }
//        }
//            //'취소'그리드 버튼
//        else if(segue.identifier == "segOutMemoDialog")
//        {
//            if let clsDialog = segue.destination as? OutMemoDialog
//            {
//                clsDialog.ptcDataHandler = self
//                if let btnAssetEpcName = sender as? UIButton
//                {
//                    let clsDataRow = self.arcDataRows[btnAssetEpcName.tag]
//                    arrClickedDataRow.ioType = clsDataRow.getString(name:"ioType") ?? ""
//                    arrClickedDataRow.workId = clsDataRow.getString(name:"workId") ?? ""
//                    arrClickedDataRow.workerName = clsDataRow.getString(name:"workerName") ?? ""
//                }
//            }
//        }
    }
    
    
    
    //TODO:
    func recvData(returnData: ReturnData) {
        
    }
    
    
    func didReadTagid(_ tagid: String) {}

    
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


