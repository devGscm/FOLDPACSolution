//
//  BranchSearchDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 21..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic
import Material

class BranchSearchDialog: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tvBranch: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSearchCondition: UIButton!
    @IBOutlet weak var tfSearchValue: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    var arcSearchCondition:Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    
    var intPageNo  = 0
    
    //var boolInitSearch = false
    var clsDataClient : DataClient!
    var arcDataRows : Array<DataRow> = Array<DataRow>()
    var ptcDataHandler : DataProtocol?
    var strSearchCondtion = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
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
		arcDataRows.removeAll()
		clsDataClient = nil
		super.releaseController()
		super.viewDidDisappear(animated)
	}
	
    
    func initViewControl()
    {
		
		
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "0", itemName: NSLocalizedString("preference_branch_name", comment: "거점명")))
        arcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "1", itemName: NSLocalizedString("preference_branch_key", comment: "거점ID")))
        strSearchCondtion = "0"
        self.btnSearchCondition.setTitle(NSLocalizedString("preference_branch_name", comment: "거점명"), for: .normal)
		
		// 테이블뷰 셀표시 지우기
		tvBranch.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    @IBAction func onSearchConditionClicked(_ sender: UIButton)
    {
        let clsDialog = ListViewDialog()
        clsDialog.loadData(data: arcSearchCondition, selectedItem: strSearchCondtion)
        clsDialog.contentHeight = 150
        
        let acDialog = UIAlertController(title: NSLocalizedString("common_search_condition", comment: "검색조건"), message: nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			self.strSearchCondtion = clsDialog.selectedRow?.itemCode ?? ""
			let strItemName = clsDialog.selectedRow?.itemName ?? ""
            self.btnSearchCondition.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    @IBAction func onSearchClicked(_ sender: UIButton)
    {
        doInitSearch()
    }
    
    
    func initDataClient()
    {
		
//		print("============================================")
//		print("*initDataClient")
//		print(" corpType:\(AppContext.sharedManager.getUserInfo().getCorpType())")
//		print(" custType:\(AppContext.sharedManager.getUserInfo().getCustType())")
//		print("============================================")
		
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.UserData = "redis.selectBranchList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "corpType", value: AppContext.sharedManager.getUserInfo().getCorpType())
        clsDataClient.addServiceParam(paramName: "custType", value: AppContext.sharedManager.getUserInfo().getCustType())
        clsDataClient.addServiceParam(paramName: "parentCustId", value: AppContext.sharedManager.getUserInfo().getParentCustId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
    }
    
    func doInitSearch()
    {
        print("doInitSearch()")
        intPageNo = 0
        arcDataRows.removeAll()
        
        //boolInitSearch = true
        
        //let strSearchValue = tfSearchValue.text;
        /*
         if(strSearchValue?.isEmpty == true)
         {
         showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: NSLocalizedString("login_input_id", comment: "사용자 ID입력"))
         return
         }*/
        doSearch()
    }
    
    func doSearch()
    {
        intPageNo += 1
        let strSearchValue = tfSearchValue.text ?? "";
        print("============================================")
        print("doSearch(), PageNo:\(intPageNo)")
        print("============================================")
		
		self.tvBranch.showIndicator()
		
        clsDataClient.addServiceParam(paramName: "searchCondition", value: strSearchCondtion)
        clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
				DispatchQueue.main.async { self.tvBranch.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else {
				
				DispatchQueue.main.async { self.tvBranch.hideIndicator() }
				print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			
           	DispatchQueue.main.async
            {
				self.tvBranch?.reloadData()
				//self.boolInitSearch = false
				self.tvBranch.hideIndicator()
            }
        })
    }

	
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvBranch.isIndicatorShowing() == false
		{
			doSearch()
		}
	}

	/*
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	{
	print("* scrollViewDidEndDragging")
	let fltOffsetY = scrollView.contentOffset.y
	let fltContentHeight = scrollView.contentSize.height
	if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
	{
	doSearch()
	}
	} */
//     func scrollViewDidScroll(_ scrollView: UIScrollView)
//     {
//		 print("* ScrollViewDidSroll, initSearch:\(boolInitSearch)")
//		 let fltOffsetY = scrollView.contentOffset.y
//		 let fltContentHeight = scrollView.contentSize.height
//		 if boolInitSearch == false && fltOffsetY > 10 && (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
//		 {
//			 doSearch()
//		 }
//     }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arcDataRows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let objCell:BranchSearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcBranchSearch", for: indexPath) as! BranchSearchCell
        let clsDataRow = arcDataRows[indexPath.row]
        //objCell.lblBranchCustType.text = "\(indexPath.row + 1)"
        objCell.lblBranchCustType.text = clsDataRow.getString(name:"branchCustTypeName")
		objCell.lblBranchId.text = clsDataRow.getString(name:"branchId")
        objCell.lblBranchName.text = clsDataRow.getString(name:"branchName")
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(BranchSearchDialog.onSelectionClicked(_:)), for: .touchUpInside)
        return objCell
    }
    
    @objc func onSelectionClicked(_ sender: UIButton)
    {
        let clsDataRow = arcDataRows[sender.tag]
        let strtData = ReturnData(returnType: "branchSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseClicked(_ sender: UIButton)
    {
        let strtData = ReturnData(returnType: "branchSearch", returnCode: "01", returnMesage: nil, returnRawData: nil )
        
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
    }
}


