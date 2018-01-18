import UIKit
import Material
import Mosaic
import Foundation

class RootViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
	@IBOutlet weak var btnRefresh: UIButton!
	@IBOutlet weak var tvProductStock: UITableView!
	
	var clsDataClient : DataClient!
	var arcDataRows : Array<DataRow> = Array<DataRow>()
	
	open override func viewDidLoad()
	{
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        prepareToolbar()
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		super.initController()
		initViewControll()
		initDataClient()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		btnRefresh.titleLabel?.font = UIFont.fontAwesome(ofSize: 10)
		btnRefresh.setTitle(String.fontAwesomeIcon(name: .refresh), for: .normal)
		
		if(AppContext.sharedManager.getUserInfo().getAutoLogin() == true || AppContext.sharedManager.getAuthenticated() == true)
		{
//			showSnackbar(message: "스네이크바 테스트입니다.")
//			let dataClient = Mosaic.DataClient(url: Constants.WEB_SVC_URL)
//			dataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
//			dataClient.SelectUrl = "productService:selectProductOrderList"
//			dataClient.removeServiceParam()
//			dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
//			dataClient.addServiceParam(paramName: "branchId", value: "160530000045")
//			dataClient.addServiceParam(paramName: "branchCustId", value: "160530000071")
//			dataClient.addServiceParam(paramName: "userLang", value: "KR")
//			dataClient.selectData(dataCompletionHandler:
//				{ (data, error) in
//					if let error = error {
//						// 에러처리
//						print(error)
//						return
//					}
//					guard let dataTable = data else {
//						print("에러 데이터가 없음")
//						return
//					}
//
//					print("####결과값 처리")
//					let dataColumns = dataTable.getDataColumns()
//					let dataRows = dataTable.getDataRows()
//					for dataRow in dataRows
//					{
//						for dataColumn in dataColumns
//						{
//							print(" dataColumn Id:" + dataColumn.Id + " Value:" + dataRow.get(name: dataColumn.Id, defaultValue: 0).debugDescription)
//						}
//					}
//			})
//			
//			dataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
//			dataClient.SelectUrl = ""
//			dataClient.UserData = "redis.selectBranchList"
//			dataClient.removeServiceParam()
//			dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
//			dataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
//			dataClient.addServiceParam(paramName: "custType", value: "MGR")
//			dataClient.selectData(dataCompletionHandler:
//				{ (data, error) in
//					if let error = error {
//						// 에러처리
//						print(error)
//						return
//					}
//					guard let dataTable = data else {
//						print("에러 데이터가 없음")
//						return
//					}
//
//					print("####결과값 처리")
//					let dataColumns = dataTable.getDataColumns()
//					let dataRows = dataTable.getDataRows()
//					for dataRow in dataRows
//					{
//						for dataColumn in dataColumns
//						{
//							print(" dataColumn Id:" + dataColumn.Id + " Value:" + dataRow.get(name: dataColumn.Id, defaultValue: 0).debugDescription)
//						}
//					}
//			})
			
			let clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
											 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: NSLocalizedString("common_progressbar_loading_basedata", comment: "서버로 부터 기초데이터를 수신중입니다."))
			//인디케이터를 활성화 하고 왼쪽메뉴를 비활성화
			//공통코드 로딩처리 후, 뒷단에서 다시 반대로 다시 돌림
			clsIndicator.show()
			navigationDrawerController?.isEnabled = false
			
			let localData = LocalData.shared
			localData.RemoteDbEnncryptId = AppContext.sharedManager.getUserInfo().getEncryptId()
			localData.CorpId = AppContext.sharedManager.getUserInfo().getCorpId()
			localData.versionCheck(container: self, indicator: clsIndicator, navigation: navigationDrawerController)
			
			
			/*
            var mDicPallet : Dictionary<String, String> = Dictionary<String, String>()
            mDicPallet["yomile1"] = "test1"
            mDicPallet["yomile2"] = "test2"
            mDicPallet["yomile3"] = "test3"
            mDicPallet["yomile4"] = "test4"
            if(mDicPallet.index(forKey: "yomile1") == nil)
            {
               print("mDicPallet NIL")
            }
            else
            {
               print("mDicPallet NOT NIL")
            }
            if(mDicPallet.index(forKey: "yomile6") == nil)
            {
                print("yomile6 mDicPallet NIL")
            }
            else
            {
                print("yomile6 mDicPallet NOT NIL")
            }
			
            if(mDicPallet.keys.contains("yomile1"))
            {
                print("yomile1 mDicPallet contains")
            }
            if(mDicPallet.keys.contains("yomile6"))
            {
                print("yomile6 mDicPallet contains")
            }
            */
			
//			let strEpcUrn = "grai:0.95100043.1025.62"
//			let arsEpcUrn = strEpcUrn.split(".")
//			if( arsEpcUrn.count == 4)
//			{
//				let strCorpEpc	= arsEpcUrn[ 1]
//				let strAssetEpc	= arsEpcUrn[ 2]
//				let strSerialNo	= arsEpcUrn[ 3]
//				
//				let strNewAssetEpc = "\(strCorpEpc)\(strAssetEpc)"
//				
//				print("=============================================")
//				print("strCorpEpc:\(strCorpEpc)")
//				print("strNewAssetEpc:\(strNewAssetEpc)")
//				print("strSerialNo:\(strSerialNo)")
//				print("=============================================")
//			}
//			
	

            
			//print("=============================================")
			//print(" UserName : \( AppContext.sharedManager.getUserInfo().getUserName() )")
			//print("=============================================")
			
			doProductStockSearch()
			
		}
		else
		{
			self.performSegue(withIdentifier: "segLogin", sender: self)
		}
	}

	
	override func viewDidDisappear(_ animated: Bool)
	{
		arcDataRows.removeAll()
		clsDataClient = nil
		super.releaseController()
		super.viewDidDisappear(animated)
	}
	func initViewControll()
	{
		self.tvProductStock.tableFooterView = UIView(frame: CGRect.zero)
	}
	
	func initDataClient()
	{
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.SelectUrl = "productStockService:selectProductStockList"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		//clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		//clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
	}
	
	
	
	@IBAction func onRefreshClicked(_ sender: UIButton)
	{
		doProductStockSearch()
	}
	
	func doProductStockSearch()
	{
		self.arcDataRows.removeAll()
		
		//tvProductStock?.showIndicator()
		//clsDataClient.addServiceParam(paramName: "searchCondition", value: strSearchCondtion)
		//clsDataClient.addServiceParam(paramName: "searchValue", value: strSearchValue)
		clsDataClient.selectData(dataCompletionHandler: {(data, error) in
			if let error = error {
				// 에러처리
				//DispatchQueue.main.async { self.tvProductStock.hideIndicator() }
				super.showSnackbar(message: error.localizedDescription)
				return
			}
			guard let clsDataTable = data else {
				//DispatchQueue.main.async { self.tvProductStock.hideIndicator() }
				//print("에러 데이터가 없음")
				return
			}
			
			self.arcDataRows.append(contentsOf: clsDataTable.getDataRows())
			DispatchQueue.main.async
				{
					self.tvProductStock?.reloadData()
					//self.tvProductStock?.hideIndicator()
			}
		})
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arcDataRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:ProductStockCell = tableView.dequeueReusableCell(withIdentifier: "tvcProductStock", for: indexPath) as! ProductStockCell
		let clsDataRow = arcDataRows[indexPath.row]
		objCell.lblProdAssetName?.text = clsDataRow.getString(name:"prodAssetName")
		objCell.lblMoveStockCnt?.text = clsDataRow.getString(name:"moveStockCnt")
		objCell.lblStockCnt?.text = clsDataRow.getString(name:"stockCnt")
		objCell.lblReleaseCnt?.text = clsDataRow.getString(name:"releaseCnt")
		return objCell
	}

}

extension RootViewController
{
    fileprivate func prepareToolbar()
	{
        guard let tc = toolbarController else
		{
            return
        }
		
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        tc.toolbar.detail = NSLocalizedString("title_root", comment: "RRPP Trade & Tracking & Traceability Platform") 
    }
}

