import UIKit
import Material

import SwiftyJSON
import FontAwesome

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	struct MenuItem {
		let menuId : String
		let menuName : String
	}
	
	@IBOutlet weak var tvMenu: UITableView!
	@IBOutlet weak var mIvLogo: UIImageView!
	
	@IBOutlet weak var btnLogout: UIButton!
	var arrMenuData:Array<MenuItem> = Array<MenuItem>()
   
    lazy var clsRootController: RootViewController = {
        return UIStoryboard.viewController(identifier: "RootViewController") as! RootViewController
    }()

    
	open override func viewDidLoad()
	{
        
		super.viewDidLoad()
		//view.backgroundColor = Color.blue.base
		
		//mIvLogo.layer.borderWidth = 1
		mIvLogo.layer.masksToBounds = false
		mIvLogo.layer.cornerRadius = mIvLogo.frame.height / 2
		mIvLogo.clipsToBounds = true
		//  prepareTransitionButton()
		
		
		
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		print(" LeftViewCOntroller.viewDidAppear")
		makeMenuItem()
	}
	
	public func makeMenuItem() -> Void
	{
		arrMenuData.removeAll()
		
		let strCustType = AppContext.sharedManager.getUserInfo().getCustType()
		print("=============================================")
		print(" strCustType : \( AppContext.sharedManager.getUserInfo().getCustType() )")
		print("=============================================")
		
		if(strCustType == "ISS")
		{
			arrMenuData.append(MenuItem(menuId: "TagSupply", menuName: "납품등록(RFID)"))
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: "RFID태그검수"))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: "이력추적"))
		}
		else if(strCustType == "MGR")
		{
			// 관리회사(MGR)
			arrMenuData.append(MenuItem(menuId: "TagSupply", menuName: "납품등록(RFID)"))
			arrMenuData.append(MenuItem(menuId: "ProductMount", menuName: NSLocalizedString("title_product_mount", comment: "자산등록")))
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: "RFID태그검수"))
            
            let strIdentificationSystem = UserDefaults.standard.string(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
            if(strIdentificationSystem == Constants.IDENTIFICATION_SYSTEM_AGQR)
            {
                
            }
            
            //UserDefaults.standard.setValue(intIdentificationSystemType, forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
            arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_sale_c", comment: "출고C")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
            arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: "이력추적"))
		}
        
        arrMenuData.append(MenuItem(menuId: "ClientConfig", menuName: NSLocalizedString("title_client_config", comment: "환경설정")))
		tvMenu?.reloadData()
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return arrMenuData.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:LeftMenuItem = tableView.dequeueReusableCell(withIdentifier: "tvcMenuItem", for: indexPath) as! LeftMenuItem
		let strtMenuItem = arrMenuData[indexPath.row]
		objCell.lblMenuName.font = UIFont.fontAwesome(ofSize: 14)
		objCell.lblMenuName.text = "\(String.fontAwesomeIcon(name: .chevronCircleRight)) \(strtMenuItem.menuName )"
		return objCell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        let strtMenuItem  = arrMenuData[indexPath.row]
        
        print("==== LeftViewController::tableView ====: \(strtMenuItem.menuId)")
		switch (strtMenuItem.menuId)
		{
			case "ProductMount" :
				let clsController: ProductMount = {
                    print("==== ProductMount ====")
					return UIStoryboard.viewController(storyBoardName: "Product", identifier: "ProductMount") as! ProductMount
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
				break
			case "RfidInspect" :
				let clsController: RfidInspect = {
                    print("==== RfidInspect ====")
					return UIStoryboard.viewController(storyBoardName: "Tag", identifier: "RfidInspect") as! RfidInspect
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
				break
			
			case "ProdMappingOut" :
                
                // 출고C(출하)
				let clsController: ProdMappingOut = {
                    print("==== ProdMappingOut ====")
					return UIStoryboard.viewController(storyBoardName: "ProdMapping", identifier: "ProdMappingOut") as! ProdMappingOut
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
				break
			
			case "WorkHistorySearch" :
				let clsController: HistorySearch = {
                    print("==== WorkHistorySearch ====")
					return UIStoryboard.viewController(storyBoardName: "History", identifier: "HistorySearch") as! HistorySearch
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
				break

            //입출고취소
            case "InOutCancel" :
                let clsController: InOutCancel = {
                    print("==== InOutCancel ====")
                    return UIStoryboard.viewController(storyBoardName: "InOutCancel", identifier: "InOutCancel") as! InOutCancel
                }()
                toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
                break
            
        	case "ClientConfig" :
                let clsController: ClientConfig = {
                    return UIStoryboard.viewController(storyBoardName: "Config", identifier: "ClientConfig") as! ClientConfig
                }()
                toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
            	break
			default:
				print("is selected");
		}
		
	}
	
	@IBAction func onLogoutClicked(_ sender: Any)
	{
		print(" LeftViewCOntroller.onLogoutClicked")
		AppContext.sharedManager.doLogout();
		navigationDrawerController?.closeLeftView()
        
        // 로그아웃전에 루트뷰로 전환하여 로그인후 루트뷰가 나오도록 수정
		toolbarController?.transition(to: clsRootController, completion: closeNavigationDrawer)
		//self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
		
        
		self.performSegue(withIdentifier: "segLogout", sender: self)
	}
	
	public func closeNavigationDrawer(result: Bool)
	{
		navigationDrawerController?.closeLeftView()
	}
}

