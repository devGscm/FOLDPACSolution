import UIKit
import Material
import Mosaic

class RootViewController: BaseViewController
{
	lazy var mClsRightController: RightViewController = {
		return UIStoryboard.viewController(identifier: "RightViewController") as! RightViewController
	}()
	
    open override func viewDidLoad()
	{
		print("@@@@@@@@@@@@@@@@@@@@")
		print(" RootViewController")
		print("@@@@@@@@@@@@@@@@@@@@")
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
		
        prepareToolbar()
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
	
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
			localData.versionCheck(indicator: clsIndicator, navigation: navigationDrawerController)

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
            

            
			//print("=============================================")
			//print(" UserName : \( AppContext.sharedManager.getUserInfo().getUserName() )")
			//print("=============================================")
			
		}
		else
		{
			self.performSegue(withIdentifier: "segLogin", sender: self)
		}
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

