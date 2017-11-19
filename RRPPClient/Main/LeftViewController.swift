import UIKit
import Material

import SwiftyJSON
import FontAwesome

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	struct MenuItem {
		let menuIcon : UIImage?
		let menuId : String
		let menuName : String
	}
	
	@IBOutlet weak var tvMenu: UITableView!
	@IBOutlet weak var mIvLogo: UIImageView!
	
	@IBOutlet weak var btnLogout: UIButton!
	var mLstMenuData:Array<MenuItem> = Array<MenuItem>()

	
	lazy var clsProductMountViewController: ProductMountViewController = {
		return UIStoryboard.viewController(strStoryBoardName: "Product", strIdentifier: "ProductMountViewController") as! ProductMountViewController
	}()
	
	open override func viewDidLoad()
	{
        super.viewDidLoad()
        //view.backgroundColor = Color.blue.base
		
		if let strCorpId = AppContext.sharedManager.getUserInfo().getCorpId()
		{
			print("CORPID:\(strCorpId)")
		}

		if let strCustType = AppContext.sharedManager.getUserInfo().getCustType()
		{
			print("strCustType:\(strCustType)")
		}

		
		if("moramcnt" == AppContext.sharedManager.getUserInfo().getCorpId())
		{
			print("Moram")
		}
		
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
		print(" CustType:\(strCustType)")
		if(strCustType == "ISS")
		{
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "TagSupply", menuName: "납품등록(RFID)"))
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "RfidInspect", menuName: "RFID태그검수"))
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "RfidInspect", menuName: "이력추적"))
		}
		else if(strCustType == "MGR")
		{
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "TagSupply", menuName: "납품등록(RFID)"))
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "ProductMount", menuName: "자산등록"))
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "RfidInspect", menuName: "RFID태그검수"))
			mLstMenuData.append(MenuItem(menuIcon: Icon.cm.play, menuId: "RfidInspect", menuName: "이력추적"))
		
		}
		tvMenu?.reloadData()
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return mLstMenuData.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:LeftMenuItem = tableView.dequeueReusableCell(withIdentifier: "tvcMenuItem", for: indexPath) as! LeftMenuItem
		let strtMenuItem = mLstMenuData[indexPath.row]
		
		
		objCell.lblMenuName.font = UIFont.fontAwesome(ofSize: 14)
		objCell.lblMenuName.text = "\(String.fontAwesomeIcon(name: .chevronCircleRight)) \(strtMenuItem.menuName )"
		return objCell
	}

	
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let strtMenuItem  = mLstMenuData[indexPath.row]
		
		print("strtMenuItem.menuId:\(strtMenuItem.menuId)")
		
		switch (indexPath.row)
		{
			//case 0:
				//break;
			case 1:
			
				//navigationDrawerController?.transition(to: clsProductMountViewController, completion: closeNavigationDrawer)
				//toolbarController?.transition(to: ProductMountViewController(), completion: closeNavigationDrawer)
				toolbarController?.transition(to: clsProductMountViewController, completion: closeNavigationDrawer)
				break;
			
		default:
			print("is selected");
		}
		
	}
	
	@IBAction func onLogoutClicked(_ sender: Any)
	{
		print(" LeftViewCOntroller.onLogoutClicked")
		AppContext.sharedManager.doLogout();
	
		
		//DispatchQueue.main.async {};
		navigationDrawerController?.closeLeftView()
		self.performSegue(withIdentifier: "segLogout", sender: self)
	}
	
	public func closeNavigationDrawer(result: Bool)
	{
		navigationDrawerController?.closeLeftView()
	}
}

/*
extension LeftViewController {
    fileprivate func prepareTransitionButton() {
        transitionButton = FlatButton(title: "Transition VC", titleColor: .white)
        transitionButton.pulseColor = .white
        transitionButton.addTarget(self, action: #selector(handleTransitionButton), for: .touchUpInside)
        
        view.layout(transitionButton).horizontally().center()
    }
}

extension LeftViewController {
    @objc
    fileprivate func handleTransitionButton() {
        toolbarController?.transition(to: TransitionedViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool) {
        navigationDrawerController?.closeLeftView()
    }

*/
