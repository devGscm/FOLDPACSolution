//
//  ProductOrderSearch.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 24..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class ProductOrderSearch: UIViewController
{

	var tfCurControl : UITextField!
	
	@IBOutlet weak var btnClose: UIBarButtonItem!
	@IBOutlet weak var btnStDate: UITextField!
	@IBOutlet weak var btnEnDate: UITextField!
	@IBOutlet weak var btnSearch: UIButton!
	let dpPicker = UIDatePicker()
	
	var intPageNo : Int?
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()


	override func viewDidLoad()
	{
        super.viewDidLoad()
		initViewControl()
		initDataClient()
    }

	func initViewControl()
	{
		let dtCurDate = Date()
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = "yyyy-MM-dd"
		btnEnDate.text = dfFormat.string(from: dtCurDate)
		
		//let intDateDistance = AppContext.sharedManager.getUserInfo().getDateDistance()
		let intDateDistance = 3
		
		let dtStDate = Calendar.current.date(byAdding: .day, value: -intDateDistance, to: dtCurDate)
		btnStDate.text = dfFormat.string(from: dtStDate!)
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
		clsDataClient.UserData = "productService.selectProductOrderList"
		clsDataClient.removeServiceParam()

		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "corpType", value: AppContext.sharedManager.getUserInfo().getCorpType())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getCustType())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())

		
		
		clsDataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
		clsDataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
		clsDataClient.addServiceParam(paramName: "custType", value: "MGR")
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
	
	@IBAction func onSearchClicked(_ sender: UIButton)
	{
	}
	
}
