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
	var mArrMenuData:Array<MenuItem> = Array<MenuItem>()
	
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
		let strCustType = AppContext.sharedManager.getUserInfo().getCustType()
		print("=============================================")
		print(" strCustType : \( AppContext.sharedManager.getUserInfo().getCustType() )")
		print("=============================================")
		
		if(strCustType == "ISS")
		{
			mArrMenuData.append(MenuItem(menuId: "TagSupply", menuName: "납품등록(RFID)"))
			mArrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: "RFID태그검수"))
			mArrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: "이력추적"))
		}
		else if(strCustType == "MGR")
		{
			mArrMenuData.append(MenuItem(menuId: "TagSupply", menuName: "납품등록(RFID)"))
			mArrMenuData.append(MenuItem(menuId: "ProductMount", menuName: NSLocalizedString("title_product_mount", comment: "자산등록")))
			mArrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: "RFID태그검수"))
			mArrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: "이력추적"))
		}
		tvMenu?.reloadData()
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return mArrMenuData.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:LeftMenuItem = tableView.dequeueReusableCell(withIdentifier: "tvcMenuItem", for: indexPath) as! LeftMenuItem
		let strtMenuItem = mArrMenuData[indexPath.row]
		objCell.lblMenuName.font = UIFont.fontAwesome(ofSize: 14)
		objCell.lblMenuName.text = "\(String.fontAwesomeIcon(name: .chevronCircleRight)) \(strtMenuItem.menuName )"
		return objCell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let strtMenuItem  = mArrMenuData[indexPath.row]
		switch (strtMenuItem.menuId)
		{
			case "ProductMount" :
				let clsController: ProductMount = {
					return UIStoryboard.viewController(storyBoardName: "Product", identifier: "ProductMount") as! ProductMount
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)
			break;
			case "RfidInspect" :
				let clsController: RfidInspect = {
					return UIStoryboard.viewController(storyBoardName: "Tag", identifier: "RfidInspect") as! RfidInspect
				}()
				toolbarController?.transition(to: clsController, completion: closeNavigationDrawer)

		default:
			print("is selected");
		}
		
	}
	
	@IBAction func onLogoutClicked(_ sender: Any)
	{
		print(" LeftViewCOntroller.onLogoutClicked")
		AppContext.sharedManager.doLogout();
		navigationDrawerController?.closeLeftView()
		self.performSegue(withIdentifier: "segLogout", sender: self)
	}
	
	public func closeNavigationDrawer(result: Bool)
	{
		navigationDrawerController?.closeLeftView()
	}
}

