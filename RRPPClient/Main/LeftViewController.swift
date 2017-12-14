import UIKit
import Material

import SwiftyJSON
import FontAwesome

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	struct MenuItem
	{
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

	var clsController : UIViewController?
	
	var intMenuIndex = -1
	var intOldMenuIndex = -1
    
	open override func viewDidLoad()
	{
		super.viewDidLoad()
		//view.backgroundColor = Color.blue.base
		
		//mIvLogo.layer.borderWidth = 1
		mIvLogo.layer.masksToBounds = false
		mIvLogo.layer.cornerRadius = mIvLogo.frame.height / 2
		mIvLogo.clipsToBounds = true
		
		
		// 옵져버 패턴 : 응답대기
		NotificationCenter.default.addObserver(self, selector: #selector(makeLeftMenu), name: NSNotification.Name(rawValue: "makeLeftMenu"), object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		print(" LeftViewCOntroller.viewDidAppear")
		makeLeftMenu()
	}
	
	@objc public func makeLeftMenu()
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
			
			arrMenuData.append(MenuItem(menuId: "CombineOut", menuName: NSLocalizedString("title_work_sale_a", comment: "출고A")))
			// 입고(입고A : 주문서 있는 입고)
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
			
			arrMenuData.append(MenuItem(menuId: "CombineOut", menuName: NSLocalizedString("title_work_sale_a", comment: "출고A")))
			// 이동/반납입고 (입고A : 주문서 있는 입고)
			// 회수 입고 ( 입고B : 지시서 없는 입고)
			// 선별/보관
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
			// 납품입고 (입고A : 지시서 있는 입고)
			// 출고 (출고B : 지시서 없는 출고)
			// 입고 (입고B : 지시서 없는 입고)
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
			
			// 출고 (출고B : 지시서 없는 출고)
			// 입고 (입고B : 지시서 없는 입고)
			arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_out_product", comment: "상품매핑")))
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
			
			// 입고 (입고A : 지시서 있는 입고)
			// 출고 (출고B : 지시서 없는 출고)
			// 입고 (입고B : 지시서 없는 입고)
            arrMenuData.append(MenuItem(menuId: "ProdMappingOut", menuName: NSLocalizedString("title_work_sale_c", comment: "출고C")))
			
			arrMenuData.append(MenuItem(menuId: "EventClean", menuName: NSLocalizedString("title_event_clean", comment: "세척")))
			arrMenuData.append(MenuItem(menuId: "EventDestory", menuName: NSLocalizedString("title_event_destory", comment: "폐기")))
			arrMenuData.append(MenuItem(menuId: "WorkHistorySearch", menuName: NSLocalizedString("title_work_history_search", comment: "작업내역조회")))
            arrMenuData.append(MenuItem(menuId: "InOutCancel", menuName: NSLocalizedString("title_work_inout_cancel", comment: "입출고취소")))
			arrMenuData.append(MenuItem(menuId: "StockReview", menuName: NSLocalizedString("title_stock_review", comment: "재고실사")))
			arrMenuData.append(MenuItem(menuId: "RfidTrackingService", menuName: NSLocalizedString("title_rfid_tracking_service", comment: "이력추적")))
			// 선별/보관
			arrMenuData.append(MenuItem(menuId: "RfidInspect", menuName: NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")))
		}
		
        arrMenuData.append(MenuItem(menuId: "ClientConfig", menuName: NSLocalizedString("title_client_config", comment: "환경설정")))
		
		DispatchQueue.main.async
		{
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
		objCell.lblMenuName.font = UIFont.fontAwesome(ofSize: 14)
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
				// 자산등록 (장착)
				clsController = { () -> ProductMount in
					return UIStoryboard.viewController(storyBoardName: "Product", identifier: "ProductMount") as! ProductMount
				}()
				
//				let clsController: ProductMount = {
//                    print("==== ProductMount ====")
//					return UIStoryboard.viewController(storyBoardName: "Product", identifier: "ProductMount") as! ProductMount
//				}()

				break

			
            case "CombineOut" :
                //출고A
                clsController = { () -> CombineOut in
                    return UIStoryboard.viewController(storyBoardName: "CombineOut", identifier: "CombineOut") as! CombineOut
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
                // 출고C(출하)
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
			
//		case "BranchSearch" :
//
//			clsController = { () -> BranchSearchDialog in
//				return UIStoryboard.viewController(storyBoardName: "Config", identifier: "BranchSearchDialog") as! BranchSearchDialog
//			}()
//			break
			default:
				print("is selected");
		}
		toolbarController?.move(to: clsController!, completion: closeNavigationDrawer)
		//toolbarController?.transition(to: clsController!, completion: closeNavigationDrawer)
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

