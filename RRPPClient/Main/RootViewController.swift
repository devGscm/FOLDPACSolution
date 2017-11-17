import UIKit
import Material

class RootViewController: UIViewController
{
	
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
				print("로그인 성공")
			
		}
		else
		{
			self.performSegue(withIdentifier: "segLogin", sender: self)
		}
	}
}

extension RootViewController
{
    fileprivate func prepareToolbar() {
        guard let tc = toolbarController else {
            return
        }
        
        tc.toolbar.title = "RRPP TRA"
        tc.toolbar.detail = "Build Beautiful Software"
    }
}
