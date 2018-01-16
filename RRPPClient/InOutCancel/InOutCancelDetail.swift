//
//  InOutCancelDetail.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 8..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class InOutCancelDetail: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tvInOutCancelDetail: UITableView!

    var arcDataRows : Array<DataRow> = Array<DataRow>()
	var strIoType		= ""
    var strSaleWorkId   = ""                 //넘겨받은 resaleOrderId
    var boolSortAsc     = true
    var intPageNo       = 0
    var clsDataClient : DataClient!
    
	
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
		
	}
	func initDataClient()
	{
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		if(strIoType == Constants.INOUT_TYPE_INPUT)
		{
			print(" - 입고")
			clsDataClient.SelectUrl = "inOutService:selectCombineInWorkListDetail"
		}
		else
		{
			print(" - 출고")
			clsDataClient.SelectUrl = "inOutService:selectCombineOutWorkListDetail"
		}
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "saleWorkId", value: strSaleWorkId)
		clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
	}

    
    //=======================================
    //===== doInitSearch()
    //=======================================
    func doInitSearch()
    {
        print("##[InOutCancelDetail]->doInitSearch()")
        intPageNo = 0
        arcDataRows.removeAll()
        doSearch()
    }
    
    //=======================================
    //===== doSearch()
    //=======================================
    func doSearch()
    {
        intPageNo += 1
        print("==[InOutCancelDetail]->strSaleWorkId: \(strSaleWorkId)")
		self.tvInOutCancelDetail?.showIndicator()
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
				DispatchQueue.main.async { self.tvInOutCancelDetail?.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else {
				DispatchQueue.main.async { self.tvInOutCancelDetail?.hideIndicator() }
				//print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async
			{
				self.tvInOutCancelDetail?.reloadData()
				self.tvInOutCancelDetail?.hideIndicator()
			}
        })
    }
    
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		let boolLargeContent = (scrollView.contentSize.height > scrollView.frame.size.height)
		let fltViewableHeight = boolLargeContent ? scrollView.frame.size.height : scrollView.contentSize.height
		let boolBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - fltViewableHeight + 50)
		if boolBottom == true && tvInOutCancelDetail.isIndicatorShowing() == false
		{
			doSearch()
		}
	}
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arcDataRows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let objCell:InOutCancelDetailCell = tableView.dequeueReusableCell(withIdentifier: "tvcInOutCancelDetail", for: indexPath) as! InOutCancelDetailCell

        let clsDataRow = arcDataRows[indexPath.row]
        
        objCell.lblRowNo?.text = clsDataRow.getString(name:"rowNo")
        objCell.lblProdAssetEpcName?.text = clsDataRow.getString(name:"prodAssetEpcName")
        objCell.lblWorkAssignCnt?.text = clsDataRow.getString(name:"workAssignCnt")
        objCell.lblProdCnt?.text = clsDataRow.getString(name:"procCnt")
        objCell.lblRemainCnt?.text = clsDataRow.getString(name:"remainCnt")

        return objCell
    }
    
    //=======================================
    //===== 다이얼로그 종료버튼
    //=======================================
    @IBAction func onCloseClicked(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

