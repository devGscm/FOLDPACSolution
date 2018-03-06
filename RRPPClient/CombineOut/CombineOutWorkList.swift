//
//  CombineOutWorkList.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 14..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//


import UIKit

class CombineOutWorkList: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tvCombineOutWorkList: UITableView!   //테이블 뷰
    @IBOutlet weak var btnStDate: UITextField!              //검색 시작일
    @IBOutlet weak var btnEnDate: UITextField!              //검색 종료일
    @IBOutlet weak var tfSearchValue: UITextField!          //입고처
    
    var tfCurControl : UITextField!                         //달력
    var ptcDataHandler : DataProtocol?
    
    var dpPicker: UIDatePicker!
    var intPageNo  = 0
    var clsDataClient : DataClient!
    var arcDataRows : Array<DataRow> = Array<DataRow>()
    var strWorkType = String()                              //넘겨받은 WorkType
    
    
    
    
    //=======================================
    //===== viewDidLoad()
    //=======================================
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() //키보드 숨기기
    }
    
    //=======================================
    //===== viewWillAppear()
    //=======================================
    override func viewWillAppear(_ animated: Bool)
    {
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
        clsDataClient = nil
        
        super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    //=======================================
    //===== 뷰 초기화 컨트롤러
    //=======================================
    func initViewControl()
    {
        dpPicker = UIDatePicker()
        let dtCurDate = Date()
        let dfFormat = DateFormatter()
        dfFormat.dateFormat = "yyyy-MM-dd"
        btnEnDate.text = dfFormat.string(from: dtCurDate)
        
        let intDateDistance = AppContext.sharedManager.getUserInfo().getDateDistance()
        let dtStDate = Calendar.current.date(byAdding: .day, value: -intDateDistance, to: dtCurDate)
        btnStDate.text = dfFormat.string(from: dtStDate!)
		
		// 테이블뷰 셀표시 지우기
		tvCombineOutWorkList.tableFooterView = UIView(frame: CGRect.zero)
    }

    
    
    
    
    
    
    //=======================================
    //===== doInitSearch()
    //=======================================
    func doInitSearch()
    {
        intPageNo = 0
        arcDataRows.removeAll()
        doSearch()
    }
    
    
    
    //=======================================
    //===== initDataClient()
    //=======================================
    func initDataClient()
    {
        print(" EncId:\(AppContext.sharedManager.getUserInfo().getEncryptId())")
        print(" corpId:\(AppContext.sharedManager.getUserInfo().getCorpId())")
        print(" branchId:\(AppContext.sharedManager.getUserInfo().getBranchId())")
        print(" branchCustId:\(AppContext.sharedManager.getUserInfo().getBranchCustId())")
        print(" userLang:\(AppContext.sharedManager.getUserInfo().getUserLang())")
        
        clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectSaleOutWorkList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleType", value: strWorkType)        //'구분'정보
        
    }
    
    //=======================================
    //===== 검색
    //=======================================
    func doSearch()
    {
        intPageNo += 1
        let strSearchValue = tfSearchValue.text ?? "";
        
        let strLocaleStDate = StrUtil.replace(sourceText: (btnStDate?.text)!, findText: "-", replaceText: "") + "000000"
        let strLocaleEnDate = StrUtil.replace(sourceText: (btnEnDate?.text)!, findText: "-", replaceText: "") + "235959"
        
        //print("strLocaleStDate:\(strLocaleStDate)")
        //print("strLocaleEnDate:\(strLocaleEnDate)")
        
        
        let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
        let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
        
        if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
        {
            Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
            return
        }
        
        tvCombineOutWorkList.showIndicator()
        clsDataClient.addServiceParam(paramName: "startDeliDate", value: strLocaleStDate)
        clsDataClient.addServiceParam(paramName: "endDeliDate", value: strLocaleEnDate)
        clsDataClient.addServiceParam(paramName: "searchCondition", value: "1")
        clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)

        /*
        print("=========================================")
        print("== strtDelidate:\(strLocaleStDate)")
        print("== endDeliDate:\(strLocaleEnDate)")
        print("== pageNo:\(intPageNo)")
        print("== rowPerPage:\(Constants.ROWS_PER_PAGE)")
        print("== strSearchValue:\(strSearchValue)")
        print("=========================================")
        */
        
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                DispatchQueue.main.async { self.tvCombineOutWorkList?.hideIndicator() }
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else {
                DispatchQueue.main.async { self.tvCombineOutWorkList?.hideIndicator() }
                print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async
                {
                    self.tvCombineOutWorkList?.reloadData()
                    self.tvCombineOutWorkList?.hideIndicator()
            }
        })
    }
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arcDataRows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        tableView.rowHeight = 70                     //셀 크기 조정
        //tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:CombineOutWorkListCell = tableView.dequeueReusableCell(withIdentifier: "tvcCombineOutWorkList", for: indexPath) as! CombineOutWorkListCell
        let clsDataRow = arcDataRows[indexPath.row]
        let strUtcTraceDate = clsDataRow.getString(name:"deliDate")
        let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
        let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"YYYY/MM/dd")
        
        
        objCell.lblSaleWorkId?.text = clsDataRow.getString(name:"saleWorkId")
        objCell.lblAssetEpcName?.text = clsDataRow.getString(name:"prodAssetEpcName")
        objCell.lblOrderReqDate?.text = strTraceDate
        objCell.lblWorkAssignCnt?.text = clsDataRow.getString(name:"workAssignCnt")
        objCell.lblResaleBranchName?.text = clsDataRow.getString(name:"deliBranchName")
        objCell.lblResaleAddr?.text = clsDataRow.getString(name:"deliAddr")
        
        //선택버튼
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 17)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(onSelectionClicked(_:)), for: .touchUpInside)
        
        return objCell
    }
    
    
    
    //=======================================
    //===== '선택'버튼
    //=======================================
    @IBAction func onSelectionClicked(_ sender: UIButton)
    {
        let clsDataRow = arcDataRows[sender.tag]
        let strtData = ReturnData(returnType: "CombineOutWorkList", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
        
        //print("===========onSelectionClick: \(strtData)")
        
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
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
    //===== 기간-시작일자
    //=======================================
    @IBAction func onStDateClicked(_ sender: Any)
    {
        createDatePicker(tfDateControl: btnStDate)
    }
    
    //=======================================
    //===== 기간-종료일자
    //=======================================
    @IBAction func onEnDateClicked(_ sender: Any)
    {
        createDatePicker(tfDateControl: btnEnDate)
    }
    
    //=======================================
    //===== '검색' 버튼
    //=======================================
    @IBAction func onSearchClicked(_ sender: Any)
    {
        doInitSearch()
    }
    
    
    //=======================================
    //===== 'X' - 종료 버튼
    //=======================================
    @IBAction func onCloseClicked(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}


