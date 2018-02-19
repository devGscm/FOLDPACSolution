import UIKit
import Material
import Mosaic

class RightViewController: UITableViewController, DataProtocol
{
	
    open override func viewDidLoad()
	{
        super.viewDidLoad()
        //view.backgroundColor = Color.blue.base
    }
	
	func recvData( returnData : ReturnData)
	{

	}

	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
	
	}
}

extension RightViewController
{
    @objc
    fileprivate func handleRootButton()
	{
        toolbarController?.transition(to: RootViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool)
	{
        navigationDrawerController?.closeRightView()
    }
}
