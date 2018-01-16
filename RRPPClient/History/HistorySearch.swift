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

	var arcEventCode: Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
	var strEventCode  = ""

    override func viewDidLoad()
	{
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
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
        prepareToolbar()
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
		self.strEventCode = ""	
		//self.btnEventCode.setTitle(NSLocalizedString("common_select_all", comment: "전체"), for: .normal)
	}
	
	func makeEventCodeList(userLang : String)
	{
		arcEventCode.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
		let arrEventCode: Array<CodeInfo> = LocalData.shared.getCodeDetail(fieldValue:"EVENT_CODE", commCode:nil, viewYn:"Y", initCodeName:nil)
		for clsInfo in arrEventCode
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
            else if(Constants.USER_LANG_JP == userLang)
            {
                strCommName = clsInfo.commNameJp
            }
			else
			{
				strCommName = clsInfo.commNameKr
			}
			arcEventCode.append(ListViewDialog.ListViewItem(itemCode: clsInfo.commCode, itemName: strCommName))
		}
	}
	
	func initDataClient()
	{
		
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "stockService:selectWorkHistoryist"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		//clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
	}
	
	@IBAction func onEventCodeClicked(_ sender: UIButton)
	{
		let clsDialog = ListViewDialog()
		clsDialog.loadData(data: arcEventCode, selectedItem: strEventCode)
        clsDialog.contentHeight = 150
				
		let acDialog = UIAlertController(title: NSLocalizedString("rfid_event_code", comment: "이벤트구분"), message:nil, preferredStyle: .alert)
		acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
		
		let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			self.strEventCode = clsDialog.selectedRow?.itemCode ?? ""
			let strItemName = clsDialog.selectedRow?.itemName ?? ""
			self.btnEventCode.setTitle(strItemName, for: .normal)
		}
		acDialog.addAction(aaOkAction)
		self.present(acDialog, animated: true)

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
		
		tvHistorySearch?.showIndicator()
		clsDataClient.addServiceParam(paramName: "startTraceDate", value: strLocaleStDate)
		clsDataClient.addServiceParam(paramName: "endTraceDate", value: strLocaleEnDate)
		clsDataClient.addServiceParam(paramName: "eventCode", value: strEventCode)
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				DispatchQueue.main.async { self.tvHistorySearch?.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
				return
			}
			guard let clsDataTable = data else {
				DispatchQueue.main.async { self.tvHistorySearch?.hideIndicator() }
				print("에러 데이터가 없음")
				return
			}
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async
			{
				self.tvHistorySearch?.reloadData()
				self.tvHistorySearch?.hideIndicator()
			}
		})
		
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvHistorySearch.isIndicatorShowing() == false
		{
			doSearch()
		}
	}
	
//	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
//	{
//		print("* scrollViewDidEndDragging")
//		let fltOffsetY = scrollView.contentOffset.y
//		let fltContentHeight = scrollView.contentSize.height
//		if (fltOffsetY >= fltContentHeight - scrollView.frame.size.height)yyy
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
        //tableView.allowsSelection = false           //셀 선택안되게 막음
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
	
	@objc func onDoneButtonPressed(_ sender : Any)
	{
		let dfFormatter = DateFormatter()
		dfFormatter.dateFormat = "yyyy-MM-dd"
		tfCurControl.text = dfFormatter.string(from: dpPicker.date)
		self.view.endEditing(true)
	}
}

extension HistorySearch
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_work_history_search", comment: "작업내역조회")
	}
}
