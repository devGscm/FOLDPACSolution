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
			showSnackbar(message: "스네이크바 테스트입니다.")
			
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
		
			print("로그인 성공")
			let localData = LocalData.shared
			localData.RemoteDbEnncryptId = AppContext.sharedManager.getUserInfo().getEncryptId()
			localData.CorpId = AppContext.sharedManager.getUserInfo().getCorpId()
			localData.versionCheck()
			
			
			//               01234567890123456789012
//            let strEpcUrn = "grai:0.95100043.1025.62"
//
//            let intIndex = strEpcUrn.lastIndex(of: ".") + 1
//            let intLength = strEpcUrn.length - intIndex
//
//            let strTest = strEpcUrn.substring(intIndex, length: intLength)
//            print("=============================================")
//             print("strEpcUrn.length:\(strEpcUrn.length)")
//            print("intIndex:\(intIndex)")
//            print("strTest:\(strTest)")
//            print("=============================================")
            

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

