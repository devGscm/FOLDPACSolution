import UIKit
import Material

class RightViewController: UITableViewController {
	
	@IBOutlet weak var swRfidBeep: UISwitch!	// RFID 효과음
	@IBOutlet weak var btnRfidMask: UIButton!	// RFID 마스크
	
	open override func viewDidLoad()
	{
        super.viewDidLoad()
        //view.backgroundColor = Color.blue.base
		
		self.swRfidBeep.isOn = UserDefaults.standard.bool(forKey: Constants.RFID_BEEP_ENABLED_KEY)
		
		var strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY)
		if(strRfidMask == "")
		{
			strRfidMask = "3312"
		}
		self.btnRfidMask.setTitle(strRfidMask, for: .normal)
    }
	
	// RFID 효과음
	@IBAction func onRfidBeepChanged(_ sender: UISwitch)
	{
		let boolBeepEnabled = sender.isOn
		UserDefaults.standard.set(boolBeepEnabled, forKey: Constants.RFID_BEEP_ENABLED_KEY)
		UserDefaults.standard.synchronize()
	}
	
	
	// RFID 마스크
	@IBAction func onRfidMaskClicked(_ sender: Any)
	{
		let acDialog = UIAlertController(title: nil, message: "RFID 마스크", preferredStyle: .alert)
		acDialog.addTextField() {
			$0.text = self.btnRfidMask.titleLabel?.text;
		}
		acDialog.addAction(UIAlertAction(title: "Cancel", style: .default) { (_) in
		})
		acDialog.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
			let strValue = acDialog.textFields?[0].text
			UserDefaults.standard.setValue(strValue, forKey: Constants.RFID_MASK_KEY)
			UserDefaults.standard.synchronize()
			self.btnRfidMask.setTitle(strValue, for: .normal)
		})
		self.present(acDialog, animated: false, completion: nil)
	}
}

extension RightViewController
{
    @objc
    fileprivate func handleRootButton()
	{
        toolbarController?.transition(to: RootViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool) {
        navigationDrawerController?.closeRightView()
    }
}
