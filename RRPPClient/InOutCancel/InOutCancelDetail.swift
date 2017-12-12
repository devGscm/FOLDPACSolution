//
//  InOutCancelDetail.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 8..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class InOutCancelDetail: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tvInOutCancelDetail: UITableView!

    var arcDataRows : Array<DataRow> = Array<DataRow>()
    var intA : Int      = 0
    var strSaleWorkId   = String()                 //넘겨받은 resaleOrderId
    var boolSortAsc     = true
    var intPageNo       = 0
    var clsDataClient : DataClient!
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    //=======================================
    //===== viewWillAppear()
    //=======================================
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        doInitSearch()
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
        
        
        clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectCombineInWorkListDetail"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: strSaleWorkId)
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "pageNo", value: intPageNo)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: Constants.ROWS_PER_PAGE)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                print(error)
                return
            }
            guard let clsDataTable = data else {
                //print("에러 데이터가 없음")
                return
            }
            self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
            DispatchQueue.main.async { self.tvInOutCancelDetail?.reloadData() }
        })
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

