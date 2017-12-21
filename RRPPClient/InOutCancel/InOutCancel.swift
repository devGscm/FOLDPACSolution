//
//  InOutCancelProcess.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic

class InOutCancel: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
    //== ReaderRespnseDelegate
    func didReadTagid(_ tagid: String) { }
    
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBranchInfo: UILabel!
    @IBOutlet weak var tfStDate: UITextField!
    @IBOutlet weak var tfEnDate: UITextField!
    @IBOutlet weak var btnSaleTypeCondition: UIButton!
    @IBOutlet weak var btnSearchCondition: UIButton!
    @IBOutlet weak var tfSearchValue: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tvInOutCancel: UITableView!
    @IBOutlet weak var btnSelect: UIButton!
    

    //== 취소 처리용
    struct ClickedDataRow
    {
        var ioType : String         /**< 입출고타입 **/
        var workId : String         /**< 작업ID   **/
        var workerName : String     /**< 작업자명  **/
        var remark : String         /**< 비고     **/
        
        init()
        {
            ioType = ""
            workId = ""
            workerName = ""
            remark = ""
        }
    }

    var arrClickedDataRow = ClickedDataRow()
    var clsIndicator : ProgressIndicator?
    
    
    var tfCurControl : UITextField!
    var dpPicker : UIDatePicker!
    
    var intPageNo  = 0
    var clsDataClient : DataClient!
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
        print("*InOutCancel.viewDidLoad()")
        print("=========================================")
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
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
        print("*InOutCancel.viewWillAppear()")
        print("=========================================")
        super.viewWillAppear(animated)
        super.initController()
        
        prepareToolbar()        //툴바 타이틀 설정
        initViewControl()       //뷰 컨트롤 초기화
        initDataClient()        //데이터 컨트롤 초기화
        doInitSearch()          //조회
        
        self.initRfid( self as ReaderResponseDelegate )
    }
    

    //=======================================
    //===== viewDidDisappear()
    //=======================================
    override func viewDidDisappear(_ animated: Bool)
    {
        dpPicker = nil
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
        
        lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
        lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
        
        dpPicker = UIDatePicker()
        let dtCurDate = Date()
        let dfFormat = DateFormatter()
        dfFormat.dateFormat = "yyyy-MM-dd"
        tfEnDate.text = dfFormat.string(from: dtCurDate)
        
        let intDateDistance = AppContext.sharedManager.getUserInfo().getDateDistance()
        let dtStDate = Calendar.current.date(byAdding: .day, value: -intDateDistance, to: dtCurDate)
        tfStDate.text = dfFormat.string(from: dtStDate!)
        makeEventCodeList(userLang: AppContext.sharedManager.getUserInfo().getUserLang())
        self.strSaleType = ""
        
        //셀렉트박스-검색조건
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "0", itemName: NSLocalizedString("easy_cust_name", comment: "고객사명")))
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "1", itemName: NSLocalizedString("easy_cust_key", comment: "고객사ID")))
        strSearchCondtion = "0"
        btnSearchCondition.setTitle(NSLocalizedString("easy_cust_name", comment: "고객사명"), for: .normal)
        
    }

    
    //=======================================
    //===== makeEventCodeList()
    //=======================================
    func makeEventCodeList(userLang : String)
    {
        arcSaleType.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        let arrSaleType: Array<CodeInfo> = LocalData.shared.getCodeDetail(fieldValue:"IO_TYPE", commCode:nil, viewYn:"Y", initCodeName:nil)
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
        intPageNo += 1
        let strSearchValue = tfSearchValue.text ?? "";
        
        let strLocaleStDate = StrUtil.replace(sourceText: (tfStDate?.text)!, findText: "-", replaceText: "") + "000000"
        let strLocaleEnDate = StrUtil.replace(sourceText: (tfEnDate?.text)!, findText: "-", replaceText: "") + "235959"
        
        let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
        let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
        
        if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
        {
            Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
            return
        }
        
        //== 테스트 데이터
        //strLocaleStDate = "20170626050000"
        //strLocaleEnDate = "20170726050000"
        
        //print("startOrderDate:\(strLocaleStDate)")
        //print("endOrderDate:\(strLocaleEnDate)")
        //print("pageNo:\(intPageNo)")
        //print("rowPerPage:\(Constants.ROWS_PER_PAGE)")
        tvInOutCancel?.showIndicator()
        clsDataClient.addServiceParam(paramName: "startWorkDate", value: strLocaleStDate)
        clsDataClient.addServiceParam(paramName: "endWorkDate", value: strLocaleEnDate)
        clsDataClient.addServiceParam(paramName: "ioType", value: strSaleType!)
        clsDataClient.addServiceParam(paramName: "searchCondition", value: strSearchCondtion)
        clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                DispatchQueue.main.async { self.tvInOutCancel.hideIndicator() }
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else {
                DispatchQueue.main.async { self.tvInOutCancel.hideIndicator() }
                //print("에러 데이터가 없음")
                return
            }
            
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async
            {
                self.tvInOutCancel?.reloadData()
                self.tvInOutCancel?.hideIndicator()
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
        let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
        let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
        if boolBottom == true && tvInOutCancel.isIndicatorShowing() == false
        {
            doSearch()
        }
    }
    
    //=======================================
    //===== scrollViewDidEndDragging()
    //=======================================
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
//    {
//        //print("* scrollViewDidEndDragging")
//        let fltOffsetY = scrollView.contentOffset.y
//        let fltContentHeight = scrollView.contentSize.height
//        if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
//        {
//            //doSearch()
//
//            //DispatchQueue.main.async
//            //{
//                    //DB재조회
//                self.doInitSearch()
//            //}
//        }
//    }
    
    
    //=======================================
    //===== 기간-시작일자
    //=======================================
    @IBAction func onStDateClicked(_ sender: Any) {
        createDatePicker(tfDateControl: tfStDate)
    }
    
    //=======================================
    //===== 기간-종료일자
    //=======================================
    @IBAction func onEnDateClicked(_ sender: Any) {
        createDatePicker(tfDateControl: tfEnDate)
    }
    
    //=======================================
    //===== 입출고 구분
    //=======================================
    @IBAction func onSaleTypeSelection(_ sender: Any) {
        let clsDialog = ListViewDialog()
        clsDialog.contentHeight = 150
        clsDialog.loadData(data: arcSaleType, selectedItem: strSaleType!)
        
        let acDialog = UIAlertController(title: NSLocalizedString("sale_type_name", comment: "입출고 구분"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.strSaleType = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
            self.btnSaleTypeCondition.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    
    //=======================================
    //===== 검색 조건
    //=======================================
    @IBAction func onSearchCondition(_ sender: Any) {
        let clsDialog = ListViewDialog()
        clsDialog.loadData(data: arcSearchCondition, selectedItem: strSearchCondtion)
        clsDialog.contentHeight = 150
        
        let acDialog = UIAlertController(title: NSLocalizedString("common_search_condition", comment: "검색조건"), message: nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.strSearchCondtion = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
            self.btnSearchCondition.setTitle(strItemName, for: .normal)
        }
        
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    //=======================================
    //===== '검색'버튼
    //=======================================
    @IBAction func onSearchClicked(_ sender: UIButton) {
        doInitSearch()
        
    }
  
    
    
    //=======================================
    //===== createDatePicker - 날짜 검색
    //=======================================
    func createDatePicker(tfDateControl : UITextField)
    {
        tfCurControl = tfDateControl
        
        dpPicker.locale = Locale(identifier: "ko_KR")
        dpPicker.datePickerMode = .date
		let dfFormatter = DateFormatter()
		dfFormatter.dateFormat = "yyyy-MM-dd"
		if let selDate = dfFormatter.date(from: tfDateControl.text ?? "")
		{
			dpPicker.date = selDate
		}
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let bbiDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonPressed))
        toolbar.setItems([bbiDoneButton], animated: false)
        tfDateControl.inputAccessoryView = toolbar
        tfDateControl.inputView = dpPicker
    }
    
    
    
    //=======================================
    //===== onDoneButtonPressed - 날짜 검색완료
    //=======================================
    @objc func onDoneButtonPressed(_ sender : Any)
    {
        let dfFormatter = DateFormatter()
        dfFormatter.dateFormat = "yyyy-MM-dd"
        tfCurControl.text = dfFormatter.string(from: dpPicker.date)
        self.view.endEditing(true)
    }
    
    
    
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arcDataRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.rowHeight = 60                    //셀 크기 조정
        //tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:InOutCancelCell = tableView.dequeueReusableCell(withIdentifier: "tvcInOutCancel", for: indexPath) as! InOutCancelCell        
        let clsDataRow = arcDataRows[indexPath.row]
        
        let strUtcTraceDate = clsDataRow.getString(name:"workDate")
        let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
        let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"MM/dd")
        let strTraceTime = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"HH:mm")

        
        objCell.lblRowNo?.text = clsDataRow.getString(name:"rowNo")
        objCell.lblWorkDate?.text = strTraceDate
        objCell.lblWorkTime?.text = strTraceTime
        objCell.lblInoutCustName?.text = clsDataRow.getString(name:"inoutCustName")
        objCell.lblIoTypeName?.text = clsDataRow.getString(name:"ioTypeName")
        objCell.lblWorkId?.text = clsDataRow.getString(name:"workId")

        //유형라벨(버튼)
        objCell.btnAssetEpcName.setTitle(clsDataRow.getString(name:"assetEpcName"), for: .normal)
        objCell.btnAssetEpcName.tag = indexPath.row
        objCell.btnAssetEpcName.addTarget(self, action: #selector(onItemSelectionClicked(_:)), for: .touchUpInside)
        objCell.lblCompleteWorkCnt?.text = clsDataRow.getString(name:"completeWorkCnt")


        //취소버튼
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 17)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.trashO), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(onItemCancelClicked(_:)), for: .touchUpInside)
        
        return objCell
    }

    //=======================================
    //===== '유형'버튼
    //=======================================
    @objc func onItemSelectionClicked(_ sender: UIButton)
    {
        self.intSelectedIndex = sender.tag
        self.performSegue(withIdentifier: "segInOutCancelDetailCell", sender: self)
    }
    
    
    // Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //'유형'그리드 버튼
        if(segue.identifier == "segInOutCancelDetailCell")
        {
            if let clsDialog = segue.destination as? InOutCancelDetail
            {
                if let btnAssetEpcName = sender as? UIButton
                {
                    //print("==btnAssetEpcName: \(btnAssetEpcName.tag)")
                    let clsAssetEpc = self.arcDataRows[btnAssetEpcName.tag]
                    let saleOrderId = clsAssetEpc.getString(name:"workId")
                    
                    //print("==saleOrderId: \(saleOrderId!)")
                    clsDialog.strSaleWorkId = saleOrderId!      //상세리스트에 표출할 ResaleOrderId 전달
                }
            }
        }
        //'취소'그리드 버튼
        else if(segue.identifier == "segOutMemoDialog")
        {
            if let clsDialog = segue.destination as? OutMemoDialog
            {
                clsDialog.ptcDataHandler = self
                if let btnAssetEpcName = sender as? UIButton
                {
                    let clsDataRow = self.arcDataRows[btnAssetEpcName.tag]
                    arrClickedDataRow.ioType = clsDataRow.getString(name:"ioType") ?? ""
                    arrClickedDataRow.workId = clsDataRow.getString(name:"workId") ?? ""
                    arrClickedDataRow.workerName = clsDataRow.getString(name:"workerName") ?? ""
                }
            }
        }
    }
    
    //=======================================
    //===== '취소'버튼
    //=======================================
    @IBAction func onItemCancelClicked(_ sender: UIButton)
    {
        //print("======= 취소버튼 =====")
        //self.performSegue(withIdentifier: "segOutMemoDialog", sender: self)
    }
    
    //=======================================
    //===== '취소'버튼 다이얼로그로 부터 수신 데이터
    //=======================================
    func recvData( returnData : ReturnData)
    {
        if(returnData.returnType == "outMemoDialog")
        {
            // 상품정보 수정
            if(returnData.returnRawData != nil)
            {
                let clsDataRow = returnData.returnRawData as! DataRow
                arrClickedDataRow.remark = clsDataRow.getString(name: "remark") ?? ""
                
                if(arrClickedDataRow.workId.isEmpty == false)
                {
                    print("=============================================")
                    print("==== IO타입: \(arrClickedDataRow.ioType)")
                    print("==== 작업번호: \(arrClickedDataRow.workId)")
                    print("==== 작업자명: \(arrClickedDataRow.workerName)")
                    print("==== 비고: \(arrClickedDataRow.remark)")
                    print("=============================================")
                    
                    //취소처리
                    sendCancelData(arrClickedDataRow.ioType, arrClickedDataRow.workId, arrClickedDataRow.workerName, arrClickedDataRow.remark)
                }
            }
        }
    }
    
    
    
    /**
     * 선택된 데이터를 취소처리한다.
     * @param strIoType             구분
     * @param strSaleWorkId         송장번호
     * @param strWorkerName         작업자
     * @param strRemark             기타메모
     */
    func sendCancelData(_ strIoType: String,_ strSaleWorkId: String,_ strWorkerName: String,_ strRemark: String)
    {
        print("=================================")
        print("##[InOutCancel]->sendCancelData()")
        print("=================================")
        
        clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
        
        let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
        let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
        
        
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()

        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
        clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
        clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        
        clsDataClient.addServiceParam(paramName: "ioType", value: strIoType)
        clsDataClient.addServiceParam(paramName: "workDateTime", value: strWorkDateTime)
        clsDataClient.addServiceParam(paramName: "workerName", value: strWorkerName)
        clsDataClient.addServiceParam(paramName: "remark", value: strRemark)
        
        if(strIoType == Constants.INOUT_TYPE_INPUT)
        {
            clsDataClient.ExecuteUrl = "inOutService:executeInCancelData"
            clsDataClient.addServiceParam(paramName: "resaleOrderId", value: strSaleWorkId)
        }
        else
        {
            clsDataClient.ExecuteUrl = "inOutService:executeOutCancelData"
            clsDataClient.addServiceParam(paramName: "saleWorkId", value: strSaleWorkId)
        }
    
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
            
            let clsResultDataRows = clsResultDataTable.getDataRows()
            if(clsResultDataRows.count > 0)
            {
                let clsDataRow = clsResultDataRows[0]
                let strResultCode = clsDataRow.getString(name: "resultCode")
                //let strResultMsg = clsDataRow.getString(name: "resultMessage") ?? ""
                
                print(" -strResultCode:\(strResultCode!)")
                if(Constants.PROC_RESULT_SUCCESS == strResultCode)
                {
                    //삭제성공
                    //그리드 삭제 및 구조체 삭제
                    DispatchQueue.main.async
                    {
                        let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
                        self.showSnackbar(message: strMsg)
                        
                        //DB재조회
                        self.doInitSearch()
                    }
                }
                else
                {
                    let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
                    
                    if((Constants.PROC_RESULT_ERROR_NO_REGISTERED_READERS == strResultCode) || (Constants.PROC_RESULT_ERROR_NO_MATCH_BRANCH_CUST_INFO == strResultCode))
                    {
                        super.showSnackbar(message: NSLocalizedString("common_error", comment: "에러"))
                    }
                    else
                    {
                        self.showSnackbar(message: strMsg)
                    }

                }
             }
        })
    }
}




//=======================================
//===== 툴바 타이틀
//=======================================
extension InOutCancel
{
    fileprivate func prepareToolbar()
    {
        guard let tc = toolbarController else {
            return
        }
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        tc.toolbar.detail = NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")
    }
}

