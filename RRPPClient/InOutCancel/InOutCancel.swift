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

class InOutCancel: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBranchInfo: UILabel!
    @IBOutlet weak var tfStDate: UITextField!
    @IBOutlet weak var tfEnDate: UITextField!
    @IBOutlet weak var btnSaleTypeCondition: UIButton!
    @IBOutlet weak var btnSearchCondition: UIButton!
    @IBOutlet weak var tfSearchValue: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tvInOutCancel: UITableView!
    
    var tfCurControl : UITextField!
    var dpPicker : UIDatePicker!
    
    var intPageNo  = 0
    var clsDataClient : DataClient!
    var arcDataRows : Array<DataRow> = Array<DataRow>()
    var arcSaleType : Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strSaleType : String?
    
    var arcSearchCondition:Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strSearchCondtion = ""
    
    
    //=======================================
    //=====  viewDidLoad()
    //=======================================
    override func viewDidLoad()
    {
        print("=========================================")
        print("*InOutCancel.viewDidLoad()")
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
        print("*InOutCancel.viewWillAppear()")
        print("=========================================")
        super.viewWillAppear(animated)
        super.initController()
        
        initViewControl()
        initDataClient()
        doInitSearch()
    }
    

    //=======================================
    //===== viewDidDisappear()
    //=======================================
    override func viewDidDisappear(_ animated: Bool)
    {
        dpPicker = nil
        arcDataRows.removeAll()
        arcSearchCondition.removeAll()
        clsDataClient = nil
        
        super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    
    //=======================================
    //===== initViewControl()
    //=======================================
    func initViewControl()
    {
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
        print("doInitSearch()")
        intPageNo = 0
        arcDataRows.removeAll()
        doSearch()
    }
    
    
    //=======================================
    //===== doSearch()
    //=======================================
    func doSearch()
    {
        intPageNo += 1
        let strSearchValue = tfSearchValue.text ?? "";
        
        var strLocaleStDate = StrUtil.replace(sourceText: (tfStDate?.text)!, findText: "-", replaceText: "") + "000000"
        var strLocaleEnDate = StrUtil.replace(sourceText: (tfEnDate?.text)!, findText: "-", replaceText: "") + "235959"
        
        let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
        let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
        
        if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
        {
            Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
            return
        }
        
        strLocaleStDate = "20170626050000"
        strLocaleEnDate = "20170726050000"
        
        print("startOrderDate:\(strLocaleStDate)")
        print("endOrderDate:\(strLocaleEnDate)")
        print("pageNo:\(intPageNo)")
        print("rowPerPage:\(Constants.ROWS_PER_PAGE)")
        
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
                print(error)
                return
            }
            guard let clsDataTable = data else {
                //print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async { self.tvInOutCancel?.reloadData() }
        })
    }
    
    //=======================================
    //===== scrollViewDidEndDragging()
    //=======================================
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        //print("* scrollViewDidEndDragging")
        let fltOffsetY = scrollView.contentOffset.y
        let fltContentHeight = scrollView.contentSize.height
        if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
        {
            doSearch()
        }
    }
    
    
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

            //print("== self.strSaleType: \(self.strSaleType!) :: \(strItemName) ==")
            
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
            
            print("== strSearchCondtion: \(self.strSearchCondtion) :: \(strItemName)")
            
            self.btnSearchCondition.setTitle(strItemName, for: .normal)
        }
        
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    //=======================================
    //===== '검색'버튼
    //=======================================
    @IBAction func onSearchClicked(_ sender: UIButton) {
        print("==== 검색버튼 ====")
        print("================")
        
        doInitSearch()
        
    }
    
    //=======================================
    //===== createDatePicker
    //=======================================
    func createDatePicker(tfDateControl : UITextField)
    {
        //print("@@@@@@createDatePicker")
        tfCurControl = tfDateControl
        
        dpPicker.locale = Locale(identifier: "ko_KR")
        dpPicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let bbiDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonPressed))
        toolbar.setItems([bbiDoneButton], animated: false)
        tfDateControl.inputAccessoryView = toolbar
        tfDateControl.inputView = dpPicker
    }
    
    
    
    //=======================================
    //===== onDoneButtonPressed
    //=======================================
    @objc func onDoneButtonPressed(_ sender : Any)
    {
        let dfFormatter = DateFormatter()
        dfFormatter.dateFormat = "yyyy-MM-dd"
        tfCurControl.text = dfFormatter.string(from: dpPicker.date)
        self.view.endEditing(true)
    }
    
    
    
    
    
    //=======================================
    //=====
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arcDataRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell:InOutCancelCell = tableView.dequeueReusableCell(withIdentifier: "tvcInOutCancel", for: indexPath) as! InOutCancelCell
        let clsDataRow = arcDataRows[indexPath.row]
        
        let strUtcTraceDate = clsDataRow.getString(name:"traceDate")
        let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
        let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"MM-dd HH:mm")

        
        
        objCell.lblWorkDate?.text = strTraceDate
        
//        objCell.lblAssetEpcName?.text = clsDataRow.getString(name:"assetEpcName")
//        objCell.lblEventName?.text = clsDataRow.getString(name:"eventName")
//        objCell.lblEventCount?.text = clsDataRow.getString(name:"eventCnt")
//        objCell.lblBranchName?.text = clsDataRow.getString(name:"branchName")
        
        
        return objCell
    }
    
    
    
}

extension InOutCancel
{
    fileprivate func prepareToolbar()
    {
        guard let tc = toolbarController else {
            return
        }
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        
        if(AppContext.sharedManager.getUserInfo().getCustType() == "MGR")
        {
            tc.toolbar.detail = NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")
        }
    }
}

