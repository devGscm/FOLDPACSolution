import UIKit
import Material
import Mosaic
import SwiftyJSON
import FontAwesome

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	struct MenuItem
	{
		let menuId : String
		let menuName : String
	}
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchName: UILabel!
	
	@IBOutlet weak var tvMenu: UITableView!
	@IBOutlet weak var mIvLogo: UIImageView!
	
	@IBOutlet weak var btnLogout: UIButton!
	
	@IBOutlet weak var lblVersion: UILabel!	// 현재 앱버전
	
	var arrMenuData:Array<MenuItem> = Array<MenuItem>()
   
    lazy var clsRootController: RootViewController = {
        return UIStoryboard.viewController(identifier: "RootViewController") as! RootViewController
    }()

	var clsController : UIViewController?
	
	var intMenuIndex = -1
	var intOldMenuIndex = -1
	
    
	open override func viewDidLoad()
	{
		super.viewDidLoad()
		//view.backgroundColor = Color.blue.base
		
		//mIvLogo.layer.borderWidth = 1
		self.mIvLogo.layer.masksToBounds = false
		self.mIvLogo.layer.cornerRadius = mIvLogo.frame.height / 2
		self.mIvLogo.clipsToBounds = true
		let tgrLogo = UITapGestureRecognizer(target: self, action: #selector((onLogoClicked)))
		self.mIvLogo.addGestureRecognizer(tgrLogo)
		self.mIvLogo.isUserInteractionEnabled = true
		
		
		// 옵져버 패턴 : 응답대기(왼쪽메뉴재생성)
		NotificationCenter.default.addObserver(self, selector: #selector(doMakeLeftMenu), name: NSNotification.Name(rawValue: "doMakeLeftMenu"), object: nil)
		
		// 옵져버 패턴 : 응답대기(로그아웃처리)
		NotificationCenter.default.addObserver(self, selector: #selector(doLogoutNewLogin), name: NSNotification.Name(rawValue: "doLogoutNewLogin"), object: nil)
		
		// 옵져버 패턴 : 응답대기(Home 이동)
		NotificationCenter.default.addObserver(self, selector: #selector(doMoveHome), name: NSNotification.Name(rawValue: "doMoveHome"), object: nil)
		
		// 테이블뷰 셀표시 지우기
		tvMenu.tableFooterView = UIView(frame: CGRect.zero)
	}
	
	
	@objc func onLogoClicked(sender: UITapGestureRecognizer)
	{
		doMoveHome()
	}
	
	@objc public func doMoveHome()
	{
		DispatchQueue.main.async
		{
			// 메뉴선택이 안되도록 한다.
			self.tvMenu.selectRow(at: IndexPath(row: -1, section: 0), animated: true, scrollPosition: .none)
			self.navigationDrawerController?.closeLeftView()
			//self.toolbarController?.transition(to: self.clsRootController, completion: self.closeNavigationDrawer)
			self.toolbarController?.move(to: self.clsRootController, completion: self.closeNavigationDrawer)
			
			// 화면 종료처리
			//NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onAppTerminate"), object: nil)
		}
	}
	
	
	
	override func viewDidAppear(_ animated: Bool)
	{
		print(" LeftViewCOntroller.viewDidAppear")
		lblUserName?.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchName?.text = AppContext.sharedManager.getUserInfo().getBranchName()
		
		let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
		let appVersion = nsObject as! String
		lblVersion?.text = appVersion
		doMakeLeftMenu()
	}
	
	@objc public func doMakeLeftMenu()
	{
		arrMenuData.removeAll()
		
		let strBranchCustType = AppContext.sharedManager.getUserInfo().getBranchCustType()
		print("=============================================")
		print(" strBranchCustType : \( strBranchCustType) )")
		print("=============================================")
		
		if(strBranchCustType == "ISS")
		{
			//==============================================
			// 태그공급회사
			//==============================================
			arrMenuData.append(MenuItem(menuId: "TagSupply", menuName: NSLocalizedString("title_tag_supply", comment: "납품등록(RFID)")))
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")))
		}
		else if(strBranchCustType == "PMK")
		{
			//==============================================
			// 생산처 (파렛트 제작회사)
			//==============================================
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")))
			arrMenuData.append(MenuItem(menuId: "ProductMount", menuName: NSLocalizedString("title_product_mount", comment: "자산등록")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			
			arrMenuData.append(MenuItem(menuId: "CombineOut", menuName: NSLocalizedString("title_work_out_delivery", comment: "출고")))
			arrMenuData.append(MenuItem(menuId: "CombineIn", menuName: NSLocalizedString("title_work_in_warehouse", comment: "입고")))

			arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")))
			arrMenuData.append(MenuItem(menuId: "EventDestory", menuName: NSLocalizedString("title_event_destory", comment: "폐기")))
		}
		else if(strBranchCustType == "RDC")
		{
			//==============================================
			// 물류센터
			//==============================================
			
			arrMenuData.append(MenuItem(menuId: "CombineOut", menuName: NSLocalizedString("title_work_out_delivery", comment: "출고")))
			arrMenuData.append(MenuItem(menuId: "CombineIn", menuName: NSLocalizedString("title_work_in_move_return", comment: "이동/반납입고")))
			
			// 회수 입고 ( 입고B : 지시서 없는 입고)
			arrMenuData.append(MenuItem(menuId: "EasyIn", menuName: NSLocalizedString("title_work_in_gather", comment: "회수입고")))
			
			arrMenuData.append(MenuItem(menuId: "EventSelectStore", menuName: NSLocalizedString("title_event_select_store", comment: "선별/보관")))
			arrMenuData.append(MenuItem(menuId: "EventClean", menuName: NSLocalizedString("title_event_clean", comment: "세척")))
			arrMenuData.append(MenuItem(menuId: "EventDestory", menuName: NSLocalizedString("title_event_destory", comment: "폐기")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
			arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")))
		}
		else if(strBranchCustType == "EXP")
		{
			//==============================================
			// 계약처
			//==============================================
			arrMenuData.append(MenuItem(menuId: "CombineIn", menuName: NSLocalizedString("title_work_in_delivery", comment: "납품입고")))

            //출고 (출고B : 지시서 없는 출고)
            arrMenuData.append(MenuItem(menuId: "EasyOut", menuName: NSLocalizedString("title_work_out_delivery", comment: "출고")))
            
			//입고 (입고B : 지시서 없는 입고)
			arrMenuData.append(MenuItem(menuId: "EasyIn", menuName: NSLocalizedString("title_work_in_warehouse", comment: "입고")))
			
			arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_out_product", comment: "상품매핑")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
		}
		else if(strBranchCustType == "IMP")
		{
			//==============================================
			// 실수요처
			//==============================================
			
			//출고 (출고B : 지시서 없는 출고)
			arrMenuData.append(MenuItem(menuId: "EasyOut", menuName: NSLocalizedString("title_work_out_delivery", comment: "출고")))
            
			//입고 (입고B : 지시서 없는 입고)
			arrMenuData.append(MenuItem(menuId: "EasyIn", menuName: NSLocalizedString("title_work_in_warehouse", comment: "입고")))
			
			
			
			
			arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_out_release", comment: "상품매핑")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
		}

		else if(strBranchCustType == "MGR")
		{
			//==============================================
			// 관리회사(MGR)
			//==============================================
			arrMenuData.append(MenuItem(menuId: "TagSupply", menuName: NSLocalizedString("title_tag_supply", comment: "납품등록(RFID)")))
			arrMenuData.append(MenuItem(menuId: "ProductMount", menuName: NSLocalizedString("title_product_mount", comment: "자산등록")))
			arrMenuData.append(MenuItem(menuId: "CombineOut", menuName: NSLocalizedString("title_work_sale_a", comment: "출고A")))
			arrMenuData.append(MenuItem(menuId: "CombineIn", menuName: NSLocalizedString("title_work_resale_a", comment: "입고A")))
			
			//출고 (출고B : 지시서 없는 출고)
            arrMenuData.append(MenuItem(menuId: "EasyOut", menuName: NSLocalizedString("title_work_sale_b", comment: "출고B")))
            
			//입고 (입고B : 지시서 없는 입고)
			arrMenuData.append(MenuItem(menuId: "EasyIn", menuName: NSLocalizedString("title_work_resale_b", comment: "입고B")))
			
            arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_sale_c", comment: "출고C")))
			
			arrMenuData.append(MenuItem(menuId: "EventClean", menuName: NSLocalizedString("title_event_clean", comment: "세척")))
			arrMenuData.append(MenuItem(menuId: "EventDestory", menuName: NSLocalizedString("title_event_destory", comment: "폐기")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
            arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")))
			arrMenuData.append(MenuItem(menuId: "EventSelectStore", menuName: NSLocalizedString("title_event_select_store", comment: "선별/보관")))
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")))
		}

        arrMenuData.append(MenuItem(menuId: "ClientConfig", menuName: NSLocalizedString("title_client_config", comment: "환경설정")))
		
		DispatchQueue.main.async
		{
			// 거점명도 바꾼다.
			self.lblBranchName?.text = AppContext.sharedManager.getUserInfo().getBranchName()
			
			self.tvMenu?.reloadData()
		}
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return arrMenuData.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:LeftMenuItem = tableView.dequeueReusableCell(withIdentifier: "tvcMenuItem", for: indexPath) as! LeftMenuItem
		let strtMenuItem = arrMenuData[indexPath.row]
		objCell.lblMenuName.font = UIFont.fontAwesome(ofSize: 16)
		objCell.lblMenuName.text = "\(String.fontAwesomeIcon(name: .chevronCircleRight)) \(strtMenuItem.menuName )"
		return objCell
	}

	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		print("============================================")
		print("*LeftViewController:: tableView, willSelectRowAt")
		print("============================================")
		
        let strtMenuItem  = arrMenuData[indexPath.row]
		self.intMenuIndex = indexPath.row
		
		switch (strtMenuItem.menuId)
		{
			case "TagSupply" :
				// 납품등록(RFID)
				clsController = { () -> TagSupply in
					return UIStoryboard.viewController(storyBoardName: "Tag", identifier: "TagSupply") as! TagSupply
				}()
			break
			
			case "RfidInspect" :
				// 검수
				clsController = { () -> RfidInspect in
					return UIStoryboard.viewController(storyBoardName: "Tag", identifier: "RfidInspect") as! RfidInspect
				}()
				break
			case "RfidTrackingService" :
				// 이력추적
				clsController = { () -> RfidTrackingService in
					return UIStoryboard.viewController(storyBoardName: "Tag", identifier: "RfidTrackingService") as! RfidTrackingService
				}()
				break
			
			case "ProductMount" :
				//자산등록 (장착)
				clsController = { () -> ProductMount in
					return UIStoryboard.viewController(storyBoardName: "Product", identifier: "ProductMount") as! ProductMount
				}()
				break

			
            case "CombineOut" :
                clsController = { () -> CombineOut in
                    return UIStoryboard.viewController(storyBoardName: "CombineOut", identifier: "CombineOut") as! CombineOut
                }()
                break
			
			case "CombineIn" :
				clsController = { () -> CombineIn in
					let clsCombineIn = UIStoryboard.viewController(storyBoardName: "CombineIn", identifier: "CombineIn") as! CombineIn
					clsCombineIn.setTitle(title: strtMenuItem.menuName)
					return clsCombineIn
				}()
				break
            
            case "EasyOut" :
                clsController = { () -> EasyOut in
                    let clsEasyOut = UIStoryboard.viewController(storyBoardName: "EasyOut", identifier: "EasyOut") as! EasyOut
                    clsEasyOut.setTitle(title: strtMenuItem.menuName)
                    return clsEasyOut
                }()
            break
            
			case "EasyIn" :
				clsController = { () -> EasyIn in
					let clsEasyIn = UIStoryboard.viewController(storyBoardName: "EasyIn", identifier: "EasyIn") as! EasyIn
					clsEasyIn.setTitle(title: strtMenuItem.menuName)
					return clsEasyIn
				}()
				break
			
			case "EventSelectStore" :
				// 선별/보관
				clsController = { () -> EventSelectStore in
					return UIStoryboard.viewController(storyBoardName: "Event", identifier: "EventSelectStore") as! EventSelectStore
				}()
				break
			
			case "EventClean" :
				// 세척
				clsController = { () -> EventOther in
					let clsEventOther = UIStoryboard.viewController(storyBoardName: "Event", identifier: "EventOther") as! EventOther
					clsEventOther.setEventType(eventType: Constants.EVENT_CODE_CLEAN)
					return clsEventOther
				}()
				break
			
			case "EventDestory" :
				// 폐기
				clsController = { () -> EventOther in
					let clsEventOther = UIStoryboard.viewController(storyBoardName: "Event", identifier: "EventOther") as! EventOther
					clsEventOther.setEventType(eventType: Constants.EVENT_CODE_DESTORY)
					return clsEventOther
				}()
				break
			
			case "ProdMappingOut" :
                //출고C(출하)
				clsController = { () -> ProdMappingOut in
					return UIStoryboard.viewController(storyBoardName: "ProdMapping", identifier: "ProdMappingOut") as! ProdMappingOut
				}()
				break
			
			case "WorkHistorySearch" :
				clsController = { () -> HistorySearch in
					return UIStoryboard.viewController(storyBoardName: "History", identifier: "HistorySearch") as! HistorySearch
				}()
				break
            
            case "InOutCancel" :
				//입출고취소
				clsController = { () -> InOutCancel in
                    return UIStoryboard.viewController(storyBoardName: "InOutCancel", identifier: "InOutCancel") as! InOutCancel
                }()
                break
			
			case "StockReview" :
				// 재고실사
				clsController = { () -> StockReview in
					return UIStoryboard.viewController(storyBoardName: "Stock", identifier: "StockReview") as! StockReview
				}()
				break
			

        	case "ClientConfig" :
				clsController = { () -> ClientConfig in
                    return UIStoryboard.viewController(storyBoardName: "Config", identifier: "ClientConfig") as! ClientConfig
                }()

            	break
			

			default:
				print("is selected");
		}
        //유료서비스가 아닌경우 진입.
		if(strtMenuItem.menuId == "ProdMappingOut" && AppContext.sharedManager.getUserInfo().getBranchUltravisYn() == "N")
		{
			Dialog.show(container: self, title: NSLocalizedString("common_confirm", comment: "확인"), message: NSLocalizedString("msg_charged_service", comment: "유료 서비스입니다.서비스 사용계역여부를 확인 부탁드립니다."))
		}
		else
        {
            toolbarController?.move(to: clsController!, completion: closeNavigationDrawer)
            //toolbarController?.transition(to: clsController!, completion: closeNavigationDrawer)
        }
	}
	
	@IBAction func onLogoutClicked(_ sender: Any)
	{
		print(" LeftViewCOntroller.onLogoutClicked")
		DispatchQueue.main.async
		{
			AppContext.sharedManager.doLogout();
			self.navigationDrawerController?.closeLeftView()
			// 로그아웃전에 루트뷰로 전환하여 로그인후 루트뷰가 나오도록 수정
			
			self.toolbarController?.transition(to: self.clsRootController, completion: self.closeNavigationDrawer)
			self.performSegue(withIdentifier: "segLogout", sender: self)
		}
	}
	
	@objc public func doLogoutNewLogin()
	{
		print("==================================")
		print("*LeftviewController.doLogoutNewLogin")
		print("==================================")
		
		DispatchQueue.main.async
		{
			AppContext.sharedManager.getUserInfo().setAutoLogin(boolAutoLogin: false)
			AppContext.sharedManager.doLogout();
			self.navigationDrawerController?.closeLeftView()
			// 로그아웃전에 루트뷰로 전환하여 로그인후 루트뷰가 나오도록 수정
			self.toolbarController?.transition(to: self.clsRootController, completion: self.closeNavigationDrawer)
			self.performSegue(withIdentifier: "segLogout", sender: self)
		}
	}
	
	
	public func closeNavigationDrawer(result: Bool)
	{
		if(result == true)
		{
			intOldMenuIndex = intMenuIndex
		}
		else
		{
			// 취소를 누른경우 이전 메뉴로 돌아간다.
			if(self.intOldMenuIndex > -1)
			{
				 self.tvMenu.selectRow(at: IndexPath(row: self.intOldMenuIndex, section: 0), animated: true, scrollPosition: .none)
			}
		}
		navigationDrawerController?.closeLeftView()
	}
	
	
}

