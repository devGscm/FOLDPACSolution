//
//  ProductOrderSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 24..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class ProductOrderSearch: BaseViewController, UITableViewDataSource, UITableViewDelegate
{

	@IBOutlet weak var tvProductOrderSearch: UITableView!
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
		print(" EncId:\(AppContext.sharedManager.getUserInfo().getEncryptId())")
		print(" corpId:\(AppContext.sharedManager.getUserInfo().getCorpId())")
		print(" branchId:\(AppContext.sharedManager.getUserInfo().getBranchId())")
		print(" branchCustId:\(AppContext.sharedManager.getUserInfo().getBranchCustId())")
		print(" userLang:\(AppContext.sharedManager.getUserInfo().getUserLang())")
	
		
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "productService:selectProductOrderList"
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
		
		print("startOrderDate:\(strLocaleStDate)")
		print("endOrderDate:\(strLocaleEnDate)")
		print("pageNo:\(intPageNo)")
		print("rowPerPage:\(Constants.ROWS_PER_PAGE)")
		
		tvProductOrderSearch?.showIndicator()
		clsDataClient.addServiceParam(paramName: "startOrderDate", value: strLocaleStDate)
		clsDataClient.addServiceParam(paramName: "endOrderDate", value: strLocaleEnDate)
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				DispatchQueue.main.async { self.tvProductOrderSearch?.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
				return
			}
			guard let clsDataTable = data else {
				DispatchQueue.main.async { self.tvProductOrderSearch?.hideIndicator() }
				print("에러 데이터가 없음")
				return
			}
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async
			{
				self.tvProductOrderSearch?.reloadData()
				self.tvProductOrderSearch?.hideIndicator()
			}
		})

	}

	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvProductOrderSearch.isIndicatorShowing() == false
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
		let objCell:ProductOrderSearchCell = tableView.dequeueReusableCell(withIdentifier: "tvcProductOrderSearchCell", for: indexPath) as! ProductOrderSearchCell
		let clsDataRow = arcDataRows[indexPath.row]
		
		let strUtcOrderDate = clsDataRow.getString(name:"orderDate")
		let strLocaleOrderDate = DateUtil.utcToLocale(utcDate: strUtcOrderDate!, dateFormat: "yyyyMMddHHmmss")
		let strOrderDate = DateUtil.getConvertFormatDate(date: strLocaleOrderDate, srcFormat: "yyyyMMddHHmmss", dstFormat:"MM-dd")
		
		//objCell.lblOrderDate.text = "\(indexPath.row + 1)
		objCell.lblOrderDate.text = strOrderDate
		objCell.lblOrderReqCnt.text = clsDataRow.getString(name:"orderReqCnt")
		objCell.lblOrderCustName.text = clsDataRow.getString(name:"orderCustName")
		objCell.lblMakeOrderId.text = clsDataRow.getString(name:"makeOrderId")
		objCell.lblProdAssetEpcName.text = clsDataRow.getString(name:"prodAssetEpcName")
		objCell.lblOrderAddr.text = clsDataRow.getString(name:"oderAddr")
		
		objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnSelection.setTitle(String.fontAwesomeIcon(name:.arrowDown), for: .normal)
		objCell.btnSelection.tag = indexPath.row
		objCell.btnSelection.addTarget(self, action: #selector(onSelectionClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	@objc func onSelectionClicked(_ sender: UIButton)
	{
		let clsDataRow = arcDataRows[sender.tag]
		let strtData = ReturnData(returnType: "productOrderSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
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
