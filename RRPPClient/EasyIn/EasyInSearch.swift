//
//  EasyInSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 18..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class EasyInSearch: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
	
	@IBOutlet weak var tvEasyInSearch: UITableView!
	@IBOutlet weak var btnSearch: UIButton!
	@IBOutlet weak var lblSearchValue: UILabel!
	@IBOutlet weak var tfSearchValue: UITextField!
	
	var strCustType  = ""
	var ptcDataHandler : DataProtocol?
	var intPageNo  = 0
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()
	
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
		if(AppContext.sharedManager.getUserInfo().getCustType() == Constants.CUST_TYPE_MGR)
		{
			strCustType = AppContext.sharedManager.getUserInfo().getBranchCustId()
		}
		else
		{
			strCustType = AppContext.sharedManager.getUserInfo().getCustType()
		}
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "inOutService:selectSaleInWorkList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		
		// 고객사 거점 타입에 따라 "이동", "반납", "회수"로 구분함
		if(Constants.CUST_TYPE_RDC == strCustType)
		{
			clsDataClient.addServiceParam(paramName: "resaleType", value: Constants.RESALE_TYPE_GATHER) // 물류센터(RDC) - 회수입고
		}
		else if(Constants.CUST_TYPE_EXP == strCustType)
		{
			clsDataClient.addServiceParam(paramName: "resaleType", value: Constants.RESALE_TYPE_WAREHOUSING) // 계약처(EXP) - 입고
		}
		else if(Constants.CUST_TYPE_IMP == strCustType)
		{
			clsDataClient.addServiceParam(paramName: "resaleType", value: Constants.RESALE_TYPE_WAREHOUSING) // 실수요처(IMP) - 입고
		}
	}
	
	@IBAction func onSearchClicked(_ sender: UIButton)
	{
		doInitSearch()
	}
	
	func doInitSearch()
	{
		print("doInitSearch()")
		intPageNo = 0
		arcDataRows.removeAll()
		doSearch()
	}
	
	func doSearch()
	{
		intPageNo += 1
		
		tvEasyInSearch?.showIndicator()

		clsDataClient.addServiceParam(paramName: "searchCondition", value: "1")
		clsDataClient.addServiceParam(paramName: "searchValue", value: tfSearchValue?.text ?? "")
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				DispatchQueue.main.async { self.tvEasyInSearch?.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
				return
			}
			guard let clsDataTable = data else {
				DispatchQueue.main.async { self.tvEasyInSearch?.hideIndicator() }
				print("에러 데이터가 없음")
				return
			}
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async
			{
				self.tvEasyInSearch?.reloadData()
				self.tvEasyInSearch?.hideIndicator()
			}
		})
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvEasyInSearch.isIndicatorShowing() == false
		{
			doSearch()
		}
	}
	
	//	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	//	{
	//		print("* scrollViewDidEndDragging")
	//		let fltOffsetY = scrollView.contentOffset.y
	//		let fltContentHeight = scrollView.contentSize.height
	//		if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)
	//		{
	//			doSearch()
	//		}
	//	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arcDataRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:EasyInSearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcEasyInSearch", for: indexPath) as! EasyInSearchCell
		let clsDataRow = arcDataRows[indexPath.row]
		

		//objCell.lblOrderDate.text = "\(indexPath.row + 1)
		objCell.lblSaleWorkId.text = clsDataRow.getString(name: "saleWorkId")
		objCell.lblResaleBranchName.text	= clsDataRow.getString(name:"resaleBranchName")
		objCell.lblProdAssetEpcName.text	= clsDataRow.getString(name:"prodAssetEpcName")
		objCell.lblOrderReqCnt.text			= clsDataRow.getString(name:"orderReqCnt")

		objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
		objCell.btnSelection.tag = indexPath.row
		objCell.btnSelection.addTarget(self, action: #selector(onSelectionClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	@objc func onSelectionClicked(_ sender: UIButton)
	{
		let clsDataRow = arcDataRows[sender.tag]
		let strtData = ReturnData(returnType: "easyInSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		ptcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onCloseClicked(_ sender: Any)
	{
		self.dismiss(animated: true, completion: nil)
	}
}

