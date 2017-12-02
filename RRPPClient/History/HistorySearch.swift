//
//  HistorySearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 2..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class HistorySearch: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!

	@IBOutlet weak var tfStDate: UITextField!
	@IBOutlet weak var tfEnDate: UITextField!

	@IBOutlet weak var btnEventCode: UIButton!
	@IBOutlet weak var btnSearch: UIButton!
	@IBOutlet weak var tvHistorySearch: UITableView!
	
	var tfCurControl : UITextField!
	var dpPicker : UIDatePicker!
	
	
	
	var intPageNo  = 0
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()


    override func viewDidLoad()
	{
        super.viewDidLoad()
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
		dpPicker = nil
		arcDataRows.removeAll()
		clsDataClient = nil
		
		super.releaseController()
		super.viewDidDisappear(animated)
	}
	
	func initViewControl()
	{
		dpPicker = UIDatePicker()
		let dtCurDate = Date()
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = "yyyy-MM-dd"
		tfEnDate.text = dfFormat.string(from: dtCurDate)
		
		let intDateDistance = AppContext.sharedManager.getUserInfo().getDateDistance()
		let dtStDate = Calendar.current.date(byAdding: .day, value: -intDateDistance, to: dtCurDate)
		tfStDate.text = dfFormat.string(from: dtStDate!)
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "stockService:selectWorkHistoryist"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		//clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
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
		
		let strLocaleStDate = StrUtil.replace(sourceText: (tfStDate?.text)!, findText: "-", replaceText: "") + "000000"
		let strLocaleEnDate = StrUtil.replace(sourceText: (tfEnDate?.text)!, findText: "-", replaceText: "") + "235959"
		
		print("strLocaleStDate:\(strLocaleStDate)")
		print("strLocaleEnDate:\(strLocaleEnDate)")
		
		
		let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
		let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
		
		if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
		{
			Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
			return
		}
		
		print("startOrderDate:\(strLocaleStDate)")
		print("endOrderDate:\(strLocaleEnDate)")
		print("pageNo:\(intPageNo)")
		print("rowPerPage:\(Constants.ROWS_PER_PAGE)")
		
		clsDataClient.addServiceParam(paramName: "startTraceDate", value: strLocaleStDate)
		clsDataClient.addServiceParam(paramName: "endTraceDate", value: strLocaleEnDate)
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
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
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async { self.tvHistorySearch?.reloadData() }
		})
		
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
		let objCell:HistorySearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcHistorySearchCell", for: indexPath) as! HistorySearchCell
		let clsDataRow = arcDataRows[indexPath.row]
		
		let strUtcTraceDate = clsDataRow.getString(name:"traceDate")
		let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate!, dateFormat: "yyyyMMddHHmmss")
		let strTraceDate = DateUtil.getConvertFormatDate(date: strLocaleTraceDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"MM-dd HH:mm")

		objCell.lblTraceDate?.text = strTraceDate
		objCell.lblAssetEpcName?.text = clsDataRow.getString(name:"assetEpcName")
		objCell.lblEventName?.text = clsDataRow.getString(name:"eventName")
		objCell.lblEventCount?.text = clsDataRow.getString(name:"eventCnt")
		objCell.lblBranchName?.text = clsDataRow.getString(name:"branchName")
		return objCell
	}
	
	@IBAction func onStDateClicked(_ sender: UITextField)
	{
		createDatePicker(tfDateControl: tfStDate)
	}
	
	@IBAction func onEnDateClicked(_ sender: UITextField){
		createDatePicker(tfDateControl: tfEnDate)
	}

	func createDatePicker(tfDateControl : UITextField)
	{
		print("@@@@@@createDatePicker")
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
	
	@objc func onDoneButtonPressed(_ sender : Any)
	{
		let dfFormatter = DateFormatter()
		dfFormatter.dateFormat = "yyyy-MM-dd"
		tfCurControl.text = dfFormatter.string(from: dpPicker.date)
		self.view.endEditing(true)
	}
}
