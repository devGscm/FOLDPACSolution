//
//  WorkEasyOutCustSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 4..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class WorkCustSearch: BaseViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var btnParentCust: UIButton!	// 법인
    @IBOutlet weak var btnCustType: UIButton!	// 고객사유형
    @IBOutlet weak var btnSearchCondition: UIButton!	// 검색조건
    
    @IBOutlet weak var tfSearchValue: UITextField!
    @IBOutlet weak var tvWorkCustSearch: UITableView!
  
	var ptcDataHandler : DataProtocol?
	var intPageNo  = 0
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()
   
    
    var arcParentCust :Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strParentCustId = ""
  
    var arcCustType :Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strCustTypeId = ""
    
    var arcSearchCondition:Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var strSearchCondtion = ""


	var inOutType = ""	// IN/OUT 구분
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
        
        //다른 화면 터치시 키보드 숨기기
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        super.initController()
        
        initViewControl()
        initDataClient()
		doInitSearch()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        
        arcParentCust.removeAll()
        arcCustType.removeAll()
        arcSearchCondition.removeAll()
        
        arcDataRows.removeAll()
        clsDataClient = nil
        super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    func initViewControl()
    {
        initCustMastList()
		strParentCustId = ""
        btnParentCust.setTitle(NSLocalizedString("common_select_all", comment: "전체"), for: .normal)
        
        arcCustType.append(ListViewDialog.ListViewItem(itemCode: "0", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        arcCustType.append(ListViewDialog.ListViewItem(itemCode: "1", itemName: NSLocalizedString("easy_cust_division_rpc", comment: "물류센터(RDC)")))
        arcCustType.append(ListViewDialog.ListViewItem(itemCode: "2", itemName: NSLocalizedString("easy_cust_division_exp", comment: "계약처(EXP)")))
        arcCustType.append(ListViewDialog.ListViewItem(itemCode: "3", itemName: NSLocalizedString("easy_cust_division_imp", comment: "실수요처(IMP)")))
		strCustTypeId = ""
        btnCustType.setTitle(NSLocalizedString("common_select_all", comment: "전체"), for: .normal)
        
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "0", itemName: NSLocalizedString("easy_cust_name", comment: "고객사명")))
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "1", itemName: NSLocalizedString("easy_cust_key", comment: "고객사ID")))
        strSearchCondtion = "0"
        btnSearchCondition.setTitle(NSLocalizedString("easy_cust_name", comment: "고객사명"), for: .normal)

    }
    
    func initCustMastList()
    {
        arcParentCust.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        let arrParentCust: Array<CustInfo> = LocalData.shared.getCustInfo()
        for clsInfo in arrParentCust
        {
            arcParentCust.append(ListViewDialog.ListViewItem(itemCode: clsInfo.custId, itemName: clsInfo.custName))
        }
        
    }
    
    func initDataClient()
    {
        clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		
        
        print("===========인아웃: \(inOutType)")
        
		if(inOutType == Constants.INOUT_TYPE_OUTPUT)
		{
	        clsDataClient.UserData = "app.sales.work.selectWorkEasyOutCustList"
		}
		else
		{
			clsDataClient.UserData = "app.sales.work.selectWorkEasyInCustList"
		}
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
    }
    
    func doInitSearch()
    {
        intPageNo = 0
        arcDataRows.removeAll()
        doSearch()
    }
    
    func doSearch()
    {
        intPageNo += 1
        let strSearchValue = tfSearchValue?.text ?? "";

        clsDataClient.addServiceParam(paramName: "parentCustId", value: strParentCustId)
        clsDataClient.addServiceParam(paramName: "branchCustType", value: strCustTypeId)
        clsDataClient.addServiceParam(paramName: "searchCondition", value: strSearchCondtion)
        clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async { self.tvWorkCustSearch?.reloadData() }
        })
    }
    
    // 법인 클릭
    @IBAction func onParentCustClicked(_ sender: UIButton)
    {
        let clsDialog = ListViewDialog()
        clsDialog.loadData(data: arcParentCust, selectedItem: strParentCustId)
        clsDialog.contentHeight = 150
        
        let acDialog = UIAlertController(title: NSLocalizedString("easy_parent_cust_name", comment: "법인"), message: nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.strParentCustId = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
            self.btnParentCust.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
  
    // 고객사 유형
    @IBAction func onCustTypeClicked(_ sender: UIButton)
    {
        let clsDialog = ListViewDialog()
        clsDialog.loadData(data: arcCustType, selectedItem: strCustTypeId)
        clsDialog.contentHeight = 150
        
        let acDialog = UIAlertController(title: NSLocalizedString("combine_work_type", comment: "구분"), message: nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.strCustTypeId = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
            self.btnCustType.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    @IBAction func onSearchConditionClicked(_ sender: UIButton)
    {
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
    

    @IBAction func onSearchClicked(_ sender: UIButton)
    {
        doInitSearch()
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        print("* scrollViewDidEndDragging")
        let fltOffsetY = scrollView.contentOffset.y
        let fltContentHeight = scrollView.contentSize.height
        if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
        {
            doSearch()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     	return self.arcDataRows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:WorkCustSearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcWorkCustSearch", for: indexPath) as! WorkCustSearchCell
		let clsDataRow = arcDataRows[indexPath.row]
        
        objCell.lblParentCustName.text = clsDataRow.getString(name:"parentCustName")
        objCell.lblCustTypeName.text = clsDataRow.getString(name:"custTypeName")
        objCell.lblCustId.text = clsDataRow.getString(name:"custId")
        objCell.lblCustName.text = clsDataRow.getString(name:"custName")
     
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(onSelectionClicked(_:)), for: .touchUpInside)

    	return objCell
    }
    
    @objc func onSelectionClicked(_ sender: UIButton)
    {
        let clsDataRow = arcDataRows[sender.tag]
        let strtData = ReturnData(returnType: "workCustSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseClick(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
