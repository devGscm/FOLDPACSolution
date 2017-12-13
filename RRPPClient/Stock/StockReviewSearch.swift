//
//  StockReviewSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class StockReviewSearch: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
	
	@IBOutlet weak var tvStockReviewSearch: UITableView!
	var tfCurControl : UITextField!
	
	@IBOutlet weak var btnStDate: UITextField!
	@IBOutlet weak var btnEnDate: UITextField!
	@IBOutlet weak var btnSearch: UIButton!
	
	var ptcDataHandler : DataProtocol?
	
	var dpPicker: UIDatePicker!
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
		btnEnDate.text = dfFormat.string(from: dtCurDate)
		
		let intDateDistance = AppContext.sharedManager.getUserInfo().getDateDistance()
		let dtStDate = Calendar.current.date(byAdding: .day, value: -intDateDistance, to: dtCurDate)
		btnStDate.text = dfFormat.string(from: dtStDate!)
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "reviewService:selectStockReviewList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
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
		
		let strLocaleStDate = StrUtil.replace(sourceText: (btnStDate?.text)!, findText: "-", replaceText: "") + "000000"
		let strLocaleEnDate = StrUtil.replace(sourceText: (btnEnDate?.text)!, findText: "-", replaceText: "") + "235959"
		
		print("strLocaleStDate:\(strLocaleStDate)")
		print("strLocaleEnDate:\(strLocaleEnDate)")
		
		
		let dtLocaleStDate = DateUtil.getFormatDate(date: strLocaleStDate, dateFormat:"yyyyMMddHHmmss")
		let dtLocaleEnDate = DateUtil.getFormatDate(date: strLocaleEnDate, dateFormat:"yyyyMMddHHmmss")
		
		if(dtLocaleStDate.timeIntervalSince1970 > dtLocaleEnDate.timeIntervalSince1970)
		{
			Dialog.show(container: self, title: nil, message: NSLocalizedString("msg_search_date_error", comment: "검색일자를 확인해 주세요."))
			return
		}
		
		clsDataClient.addServiceParam(paramName: "startReviewReqDate", value: strLocaleStDate)
		clsDataClient.addServiceParam(paramName: "endReviewReqDate", value: strLocaleEnDate)
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
			DispatchQueue.main.async { self.tvStockReviewSearch?.reloadData() }
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
		let objCell:StockReviewSearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcStockReviewSearch", for: indexPath) as! StockReviewSearchCell
		let clsDataRow = arcDataRows[indexPath.row]
		
		objCell.lblStockReviewId.text = clsDataRow.getString(name:"stockReviewId")
		let strUtcReviewReqDate = clsDataRow.getString(name:"reviewReqDate")
		if(strUtcReviewReqDate?.isEmpty == false)
		{
			let strLocaleReviewReqDate = DateUtil.utcToLocale(utcDate: strUtcReviewReqDate!, dateFormat: "yyyyMMddHHmmss")
			let strReviewReqDate = DateUtil.getConvertFormatDate(date: strLocaleReviewReqDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"yyyy-MM-dd")
			objCell.lblReviewReqDate.text = strReviewReqDate
		}
		objCell.lblProdAssetEpcName.text = clsDataRow.getString(name:"prodAssetEpcName")
		
		objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
		objCell.btnSelection.tag = indexPath.row
		objCell.btnSelection.addTarget(self, action: #selector(onSelectionClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	@objc func onSelectionClicked(_ sender: UIButton)
	{
		let clsDataRow = arcDataRows[sender.tag]
		
		let strStockReviewState = clsDataRow.getString(name:"stockReviewState")	// 재고조사 상태값
		print("@@@@strStockReviewState:\(strStockReviewState)")
		
		// 재고조사 초기화
		if(Constants.STOCK_REVIEW_STATE_WORKING == strStockReviewState)
		{
			
		}
		
		
		let strtData = ReturnData(returnType: "stockReviewSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
		ptcDataHandler?.recvData(returnData: strtData)
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onCloseClicked(_ sender: Any)
	{
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onStDateClicked(_ sender: UITextField)
	{
		createDatePicker(tfDateControl: btnStDate)
	}
	@IBAction func onEnDateClicked(_ sender: UITextField)
	{
		createDatePicker(tfDateControl: btnEnDate)
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
