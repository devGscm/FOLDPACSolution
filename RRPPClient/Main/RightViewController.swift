import UIKit
import Material


class RightViewController: UITableViewController, DataProtocol
{
	var mLstRfidReader:Array<RfidReaderDialog.RfidReader> = Array<RfidReaderDialog.RfidReader>()
	
	@IBOutlet weak var btnBranch: UIButton!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var swRfidBeep: UISwitch!	// RFID 효과음
	@IBOutlet weak var btnRfidMask: UIButton!	// RFID 마스크
	@IBOutlet weak var btnRfidPower: UIButton!

	lazy var clsBranchSearchDialog: BranchSearchDialog = {
		return UIStoryboard.viewController(identifier: "BranchSearchDialog") as! BranchSearchDialog
	}()
	open override func viewDidLoad()
	{
        super.viewDidLoad()
        //view.backgroundColor = Color.blue.base
		
		// 거점선택
		let strBranch = UserDefaults.standard.string(forKey: Constants.BASE_BRANCH_KEY) ?? "Selection"
		//print("@@@@@@ Branch : \(strBranch)")
		self.btnBranch.setTitle(strBranch, for: .normal)
		
		self.swRfidBeep.isOn = UserDefaults.standard.bool(forKey: Constants.RFID_BEEP_ENABLED_KEY)
		// RFID 리더기
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 0, readerName: "Swing U"))
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 1, readerName: "AT288"))
		
		let intRfidReader = UserDefaults.standard.integer(forKey: Constants.RFID_READER_KEY)
		let strRfidReaderName = mLstRfidReader[intRfidReader].readerName
		//print("@@@@@@ RFID READER:\(intRfidReader)")
		self.btnRfidReader.setTitle(strRfidReaderName, for: .normal)
		
		// RFID 마스크
		let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
		//print("@@@@@@ RFID MASK:\(strRfidMask)")
		self.btnRfidMask.setTitle(strRfidMask, for: .normal)
		
		// RFID Power
		let strRfidPower = UserDefaults.standard.string(forKey: Constants.RFID_POWER_KEY) ?? "0"
		self.btnRfidPower.setTitle(strRfidPower, for: .normal)
		//print("@@@@@@ RFID POWER:\(strRfidPower)")
    }
	
	func recvData( returnData : ReturnData)
	{
		if(returnData.returnType == "branchSearch")
		{
			UserDefaults.standard.setValue(returnData.returnCode, forKey: Constants.BASE_BRANCH_KEY)
			UserDefaults.standard.synchronize()
			self.btnBranch.setTitle(returnData.returnCode, for: .normal)
		}
	}

	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segBranchSearch")
		{
			if let clsBranchSearchDialog = segue.destination as? BranchSearchDialog
			{
				clsBranchSearchDialog.mPtcDataHandler = self
			}
		}
	}
	
	@IBAction func onBranchClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segBranchSearch", sender: self)
	}
	/*
	@IBAction func onBranchClicked(_ sender: Any)
	{
		//clsBranchSearchDialog.contentWidth = self.view.frame.width * 1.2
		clsBranchSearchDialog.contentHeight = self.view.frame.height
		
		let acDialog = UIAlertController(title:nil, message:"거점 선택", preferredStyle: .alert)
		acDialog.setValue(clsBranchSearchDialog, forKeyPath: "contentViewController")
		let aaOkAction = UIAlertAction(title: "OK", style: .default) { (_) in

		}
		acDialog.addAction(aaOkAction)

		var height:NSLayoutConstraint = NSLayoutConstraint(item: acDialog.view,
														   attribute: NSLayoutAttribute.height,
														   relatedBy: NSLayoutRelation.equal,
														   toItem: nil,
														   attribute: NSLayoutAttribute.notAnAttribute,
														   multiplier: 1,
														   constant: self.view.frame.height * 0.9
		)
		acDialog.view.addConstraint(height)
		
		self.present(acDialog, animated: true)
	}
	*/
	@IBAction func onRfidReaderClicked(_ sender: Any)
	{
		let clsReaderDialog = RfidReaderDialog()
		clsReaderDialog.loadData(lstRfidReader: mLstRfidReader)

		let acDialog = UIAlertController(title:nil, message:"RFID 리더기", preferredStyle: .alert)
		acDialog.setValue(clsReaderDialog, forKeyPath: "contentViewController")
		
		acDialog.addAction(UIAlertAction(title: "Cancel", style: .default) { (_) in
		})
		let aaOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
			let intReaderType = clsReaderDialog.selectedRow.readerType
			let strRaderName = clsReaderDialog.selectedRow.readerName
			UserDefaults.standard.setValue(intReaderType, forKey: Constants.RFID_READER_KEY)
			UserDefaults.standard.synchronize()
			self.btnRfidReader.setTitle(strRaderName, for: .normal)
		}
		acDialog.addAction(aaOkAction)
		self.present(acDialog, animated: true)
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
			//$0.text = self.btnRfidMask.titleLabel?.text;
			let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
			$0.text = strRfidMask
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
	
	@IBAction func onRfidPowerClicked(_ sender: Any) {
		
		let clsSliderDialog = SliderDialog()
		
		let acDialog = UIAlertController(title:nil, message: "RFID Power", preferredStyle: .alert)
		
		// 컨트롤 뷰 컨트롤러를 알림창에 등록한다.
		acDialog.setValue(clsSliderDialog, forKeyPath: "contentViewController")
		
		// 슬라이더에 값을 넣어준다.
		
		let intRfidPower = Int(self.btnRfidPower.titleLabel?.text ?? "0")!
		//let intRfidPower = (self.btnRfidPower.titleLabel?.text as! NSString).integerValue
		clsSliderDialog.sliderValue = intRfidPower
		
		// OK 버튼을 추가한다.
		let aaOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
			let intValue = Int(clsSliderDialog.sliderValue)
			UserDefaults.standard.setValue(intValue, forKey: Constants.RFID_POWER_KEY)
			UserDefaults.standard.synchronize()
			self.btnRfidPower.setTitle("\(intValue)", for: .normal)
			print(">>> sliderValue = \(intValue)")
		}
		acDialog.addAction(aaOkAction)
		
		self.present(acDialog, animated: false)
	}	
}

extension RightViewController {
    @objc
    fileprivate func handleRootButton() {
        toolbarController?.transition(to: RootViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool) {
        navigationDrawerController?.closeRightView()
    }
}
