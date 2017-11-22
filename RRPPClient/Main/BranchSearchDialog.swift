//
//  BranchSearchDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 21..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class BranchSearchDialog: UIViewController, UITableViewDataSource, UITableViewDelegate
{

	@IBOutlet weak var tvBranch: UITableView!
	
	var contentWidth : CGFloat {
		get
		{
			return self.preferredContentSize.width
		}
		set
		{
			self.preferredContentSize.width = newValue
		}
	}
	
	var contentHeight : CGFloat {
		get
		{
			return self.preferredContentSize.height
		}
		set
		{
			self.preferredContentSize.height = newValue
		}
	}
	
	var mClsDataClient : DataClient!
	var mArcDataRows : Array<DataRow> = Array<DataRow>()
    override func viewDidLoad()
	{
        super.viewDidLoad()
		initDataClient()
		
		doSearch()
	}

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }
	
	func initDataClient()
	{
		mClsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		
		mClsDataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
		mClsDataClient.UserData = "redis.selectBranchList"
		mClsDataClient.removeServiceParam()
		mClsDataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
		mClsDataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
		mClsDataClient.addServiceParam(paramName: "custType", value: "MGR")
	}
	func doSearch()
	{
		var objMe = self
		
		mClsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				print(error)
				return
			}
			guard let clsDataTable = data else {
				print("에러 데이터가 없음")
				return
			}
			
			print("####결과값 처리")
			let dataColumns = clsDataTable.getDataColumns()
			self.mArcDataRows = clsDataTable.getDataRows()
			for dataRow in self.mArcDataRows
			{
				for dataColumn in dataColumns
				{
					print(" dataColumn Id:" + dataColumn.Id + " Value:" + dataRow.get(name: dataColumn.Id, defaultValue: 0).debugDescription)
				}
			}
			/*
			for clsDataRow in mClsDataTable.getDataRows()
			{
				//let strBranchId  = clsDataRow.getString(name: "branchId")
			
			
				print("  Value:" + clsDataRow.get(name: "branchId", defaultValue: 0).debugDescription)
			
			
				//print("BranchId1:\(strBranchId)")


			}*/
			
			DispatchQueue.main.async {
				self.tvBranch?.reloadData()
			}
			
		})
	}
	

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return mArcDataRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:BranchSearchItem = tableView.dequeueReusableCell(withIdentifier: "tvcBranchSearchItem", for: indexPath) as! BranchSearchItem
		let clsDataRow = mArcDataRows[indexPath.row]
		objCell.lblBranchCustType.text = clsDataRow.getString(name:"branchCustTypeName")
		objCell.lblBranchId.text = clsDataRow.getString(name:"branchId")
		objCell.lblBranchName.text = clsDataRow.getString(name:"branchName")
		return objCell
	}

}
