import UIKit
import Material
import Mosaic
import Foundation

class RootViewController: BaseViewController
{
    open override func viewDidLoad()
	{
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        prepareToolbar()
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
		if(AppContext.sharedManager.getUserInfo().getAutoLogin() == true || AppContext.sharedManager.getAuthenticated() == true)
		{
			
			let clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
											 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: NSLocalizedString("common_progressbar_loading_basedata", comment: "서버로 부터 기초데이터를 수신중입니다."))
			//인디케이터를 활성화 하고 왼쪽메뉴를 비활성화
			//공통코드 로딩처리 후, 뒷단에서 다시 반대로 다시 돌림
			clsIndicator.show()
			navigationDrawerController?.isEnabled = false
			
			//서버와 통신하여 체크후, 최신 기초데이터 업데이트
			let localData = LocalData.shared
			localData.RemoteDbEnncryptId = AppContext.sharedManager.getUserInfo().getEncryptId()
			localData.CorpId = AppContext.sharedManager.getUserInfo().getCorpId()
			localData.versionCheck(container: self, indicator: clsIndicator, navigation: navigationDrawerController)
			
//			//App의 빌드버전을 구한다 버전체크 후, Update
//			let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
//			let appVersion = nsObject as! String
//			//print(appVersion)
//			let remoteAppVersion = localData.getIOSAppVersion()
//			if(remoteAppVersion > appVersion)
//			{
//				print(remoteAppVersion)
//			}

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

