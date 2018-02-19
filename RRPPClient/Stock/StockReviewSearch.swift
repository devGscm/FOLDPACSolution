//
//  StockReviewSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

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
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
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
		
		// 테이블뷰 셀표시 지우기
		tvStockReviewSearch.tableFooterView = UIView(frame: CGRect.zero)
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
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
		
		self.tvStockReviewSearch?.showIndicator()
		clsDataClient.addServiceParam(paramName: "startReviewReqDate", value: strLocaleStDate)
		clsDataClient.addServiceParam(paramName: "endReviewReqDate", value: strLocaleEnDate)
		clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
		clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				DispatchQueue.main.async { self.tvStockReviewSearch?.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
				return
			}
			guard let clsDataTable = data else {
				DispatchQueue.main.async { self.tvStockReviewSearch?.hideIndicator() }
				print("에러 데이터가 없음")
				return
			}
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async
			{
				self.tvStockReviewSearch?.reloadData()
				self.tvStockReviewSearch?.hideIndicator()
			}
		})
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvStockReviewSearch.isIndicatorShowing() == false
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
	}*/
	
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
	
    //==== 재고실사번호 선택
	@objc func onSelectionClicked(_ sender: UIButton)
	{
		let clsDataRow = arcDataRows[sender.tag]
		
		let strStockReviewId	= clsDataRow.getString(name:"화") ?? ""	    //재고조사ID
		let strStockReviewState	= clsDataRow.getString(name:"stockReviewState") ?? ""	//재고조사 상태값
		print("@@@@strStockReviewState:\(strStockReviewState) @@@@@@@@@@@@@@")
		
        //20180122-이은미과장님 요청으로 '수정2안'로 변경
        /*
        //재고조사 초기화
		if(Constants.STOCK_REVIEW_STATE_WORKING == strStockReviewState)
		{
			sendStockReviewInitData(stockReviewId: strStockReviewId, dataRow: clsDataRow)
		}
		else
		{
			let strtData = ReturnData(returnType: "stockReviewSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
			ptcDataHandler?.recvData(returnData: strtData)
			self.dismiss(animated: true, completion: nil)
		}
        */
        
        //수정2안
        let strtData = ReturnData(returnType: "stockReviewSearch", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
	}
	
    
    //==== 재고조사 초기화
	func send화tockReviewInitData(stockReviewId: String, dataRow: DataRow)
	{
		print("@@@@sendStockReviewInitData @@@@@@@@@@@@@@")
		
		let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "reviewService:executeStockReviewInitData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
		clsDataClient.addServiceParam(paramName: "stockReviewId", value: stockReviewId)
		clsDataClient.selectRawData(dataCompletionHandler: { (responseData, error) in
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
				print(error)
				self.dismiss(animated: true, completion: nil)
				return
			}
			guard let responseData = responseData else {
				print("에러 데이터가 없음")
				self.dismiss(animated: true, completion: nil)
				return
			}
			// 성공
			if let returnCode = responseData.returnCode , returnCode > 0
			{
				let returnMessage = responseData.returnMessage ?? ""
				print("@@@@@@@@@ return RawMessage : \(returnMessage)")
				
				let dataSourceMgr = DataSourceMgr()
				dataSourceMgr.Notation = DataSourceMgr.NOTATION_NONE
				
				if (dataSourceMgr.parse(data: responseData.returnMessage!))
				{
					let clsDataTable = dataSourceMgr.getDataTable()
					let clsDataRows = clsDataTable.getDataRows()
					if(clsDataRows.count > 0)
					{
						let clsResultRow = clsDataRows[0]
						
						let strResultCode = clsResultRow.getString(name: "resultCode") ?? ""
						let strResultMsg = clsResultRow.getString(name: "resultMessage") ?? ""
						
						print("-리턴코드: \(strResultCode)")
						print("-리턴메시지: \(strResultMsg)")
						
						if(strResultCode == Constants.PROC_RESULT_SUCCESS)
						{
							let strtData = ReturnData(returnType: "stockReviewSearch", returnCode: nil, returnMesage: nil, returnRawData: dataRow)
							self.ptcDataHandler?.recvData(returnData: strtData)
						}
					}
				}
			}
			else
			{
				print("json 오류")
			}
			self.dismiss(animated: true, completion: nil)
		})
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

