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

class BranchSearchDialog: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	
	@IBOutlet weak var tvBranch: UITableView!
	@IBOutlet weak var btnClose: UIButton!
	
	@IBOutlet weak var btnSearchCondition: UIButton!
	@IBOutlet weak var tfSearchValue: UITextField!
	
	@IBOutlet weak var btnSearch: UIButton!
	
	var mArcSearchCondition:Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
	
	//	var contentWidth : CGFloat {
	//		get
	//		{
	//			return self.preferredContentSize.width
	//		}
	//		set
	//		{
	//			self.preferredContentSize.width = newValue
	//		}
	//	}
	//
	//	var contentHeight : CGFloat {
	//		get
	//		{
	//			return self.preferredContentSize.height
	//		}
	//		set
	//		{
	//			self.preferredContentSize.height = newValue
	//		}
	//	}
	
	var intPageNo  = 0
	let intPageSize  = 20
	var intTotalCount = 0
	var boolLoading = false
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()
	var mPtcDataHandler : DataProtocol?
	var mStrSearchCondtion : String?
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		initDataClient()
		initViewControl()
		
		doInitSearch()
	}
	
	func initViewControl()
	{
		mArcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "0", itemName: "거점명"))
		mArcSearchCondition.append(ListViewDialog.ListViewItem(itemCode: "1", itemName: "거점ID"))
		
		mStrSearchCondtion = "0"
		self.btnSearchCondition.setTitle("거점명", for: .normal)
	}
	
	
	@IBAction func onSearchConditionClicked(_ sender: UIButton)
	{
		let clsDialog = ListViewDialog()
		clsDialog.contentHeight = 150
		clsDialog.loadData(data: mArcSearchCondition)
		
		let acDialog = UIAlertController(title:nil, message:"검색조건", preferredStyle: .alert)
		acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
		
		let aaOkAction = UIAlertAction(title: "확인", style: .default) { (_) in
			self.mStrSearchCondtion = clsDialog.selectedRow.itemCode
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
	
	
	func initDataClient()
	{
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		//clsDataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.UserData = "redis.selectBranchList"
		clsDataClient.removeServiceParam()
		
		//clsDataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
		//clsDataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
		//clsDataClient.addServiceParam(paramName: "custType", value: "MGR")
		
		
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
		let strSearchValue = tfSearchValue.text;
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
		let strSearchValue = tfSearchValue.text;
		print("============================================")
		print("doSearch(), PageNo:\(intPageNo)")
		print("============================================")
	
		clsDataClient.addServiceParam(paramName: "searchCondition", value: mStrSearchCondtion!)
		clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue!)
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: intPageSize)
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
			
			self.intTotalCount = clsDataTable.getDataRows().count
			
			print("doSearch(),TotalCount:\(self.intTotalCount)")
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			if(self.intTotalCount > 0)
			{
				DispatchQueue.main.async
				{
					self.tvBranch?.reloadData()
				}
			}
		})
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arcDataRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:BranchSearchItem = tableView.dequeueReusableCell(withIdentifier: "tvcBranchSearchItem", for: indexPath) as! BranchSearchItem
		let clsDataRow = arcDataRows[indexPath.row]
		//objCell.lblBranchCustType.text = "\(indexPath.row + 1)"
		objCell.lblBranchCustType.text = clsDataRow.getString(name:"branchCustTypeName")
		objCell.lblBranchName.text = clsDataRow.getString(name:"branchName")
		objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
		objCell.btnSelection.tag = indexPath.row
		objCell.btnSelection.addTarget(self, action: #selector(BranchSearchDialog.onSelectionClicked(_:)), for: .touchUpInside)
		
		print("tableView(),TotalCount:\(self.intTotalCount), DataRowCount:\(self.arcDataRows.count )")
		
		let intLastCell = self.arcDataRows.count - 1
		if(indexPath.row == intLastCell)
		{
			doSearch()
		}
		return objCell
	}
	
	@objc func onSelectionClicked(_ sender: UIButton)
	{
		let clsDataRow = arcDataRows[sender.tag]
		//let strBranchId = clsDataRow.getString(name:"branchId") ?? ""
		//let strBranchName = clsDataRow.getString(name:"branchName") ?? ""
		let strtData = ReturnData(returnType: "branchSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		mPtcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
		
	}
	
	@IBAction func onCloseClicked(_ sender: UIButton)
	{
		let strtData = ReturnData(returnType: "branchSearch", returnCode: "01", returnMesage: nil, returnRawData: nil )
		
		mPtcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
	}
}

