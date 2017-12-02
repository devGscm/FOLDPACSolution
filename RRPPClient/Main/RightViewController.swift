import UIKit
import Material
import Mosaic

class RightViewController: UITableViewController, DataProtocol
{
	var mLstRfidReader:Array<RfidReaderDialog.RfidReader> = Array<RfidReaderDialog.RfidReader>()
    var mLstIdentificationSystem:Array<IdentificationSystemDialog.IdentificationSystem> = Array<IdentificationSystemDialog.IdentificationSystem>()
    
	@IBOutlet weak var btnBranch: UIButton!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var swRfidBeep: UISwitch!	                //RFID 효과음
	@IBOutlet weak var btnRfidMask: UIButton!	                //RFID 마스크
	@IBOutlet weak var btnRfidPower: UIButton!

    @IBOutlet weak var btnIdentificationSystem: UIButton! //상품식별체계
    
    open override func viewDidLoad()
	{
        super.viewDidLoad()
        //view.backgroundColor = Color.blue.base
		
		// 거점선택
		let strBranch = UserDefaults.standard.string(forKey: Constants.BASE_BRANCH_KEY) ?? "Selection"
		//print("@@@@@@ Branch : \(strBranch)")
		self.btnBranch.setTitle(strBranch, for: .normal)
		
        
        //상품식별체계
        mLstIdentificationSystem.append(IdentificationSystemDialog.IdentificationSystem(IdentificationSystemType: 0, IdentificationSystemName: "ITF-14 바코드"))
        mLstIdentificationSystem.append(IdentificationSystemDialog.IdentificationSystem(IdentificationSystemType: 1, IdentificationSystemName: "농산물 QR코드"))

		let intIdentificationSystem = UserDefaults.standard.integer(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
        let strIdentificationSystemName = mLstIdentificationSystem[intIdentificationSystem].IdentificationSystemName
        
        print("@@@@@@ ID-SYSTEM:\(intIdentificationSystem)")
        self.btnIdentificationSystem.setTitle(strIdentificationSystemName, for: .normal)

        
        
        
        //효과음
		self.swRfidBeep.isOn = UserDefaults.standard.bool(forKey: Constants.RFID_BEEP_ENABLED_KEY)
        
		// RFID 리더기
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 0, readerName: NSLocalizedString("rfid_reader_swing_u", comment: "Swing U")))
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 1, readerName: NSLocalizedString("rfid_reader_at288", comment: "AT288")))
		
		let intRfidReader = UserDefaults.standard.integer(forKey: Constants.RFID_READER_TYPE_KEY)
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
		// 거점 선택
		if(returnData.returnType == "branchSearch")
		{
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strBranchId = clsDataRow.getString(name:"branchId") ?? ""
				let strBranchName = clsDataRow.getString(name:"branchName") ?? ""
				let strBranchCustId = clsDataRow.getString(name:"branchCustId") ?? ""
				let strBranchCustType = clsDataRow.getString(name:"branchCustType") ?? ""
				let strBranchCustName = clsDataRow.getString(name:"branchCustName") ?? ""
				let strInAgreeYn = clsDataRow.getString(name:"inAgreeYn") ?? ""
			
				let clsUserInfo = AppContext.sharedManager.getUserInfo()
				clsUserInfo.setBranchId(branchId: strBranchId)
				clsUserInfo.setBranchName(branchName: strBranchName)
				clsUserInfo.setBranchCustId(branchCustId: strBranchCustId)
				clsUserInfo.setBranchCustType(branchCustType: strBranchCustType)
				clsUserInfo.setBranchCustName(branchCustName: strBranchCustName)
				clsUserInfo.setInAgreeYn(inAgreeYn: strInAgreeYn)
			
			
				print("@@@@@@@@@@@@@ strBranchID:\(strBranchId)" )
				UserDefaults.standard.setValue(strBranchId, forKey: Constants.BASE_BRANCH_KEY)
				UserDefaults.standard.synchronize()
				self.btnBranch.setTitle(strBranchName, for: .normal)
			}
		}
	}

	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segBranchSearch")
		{
			if let clsBranchSearchDialog = segue.destination as? BranchSearchDialog
			{
				clsBranchSearchDialog.ptcDataHandler = self
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
    
    //상품식별체계
    @IBAction func onIdentificationSystemClicked(_ sender: UIButton) {
        let clsIdentificationSystemDialog = IdentificationSystemDialog()
        clsIdentificationSystemDialog.loadData(lstIdentificationSystem: mLstIdentificationSystem)
        
        let acDialog = UIAlertController(title:nil, message: NSLocalizedString("preference_identification_system", comment: "상품식별체계"), preferredStyle: .alert)
        acDialog.setValue(clsIdentificationSystemDialog, forKeyPath: "contentViewController")
        
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
        })
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            let intIdentificationSystemType = clsIdentificationSystemDialog.selectedRow.IdentificationSystemType
            let strIdentificationSystemName = clsIdentificationSystemDialog.selectedRow.IdentificationSystemName
            UserDefaults.standard.setValue(intIdentificationSystemType, forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
            UserDefaults.standard.synchronize()
            self.btnIdentificationSystem.setTitle(strIdentificationSystemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    
	@IBAction func onRfidReaderClicked(_ sender: Any)
	{
		let clsReaderDialog = RfidReaderDialog()
		clsReaderDialog.loadData(lstRfidReader: mLstRfidReader)

		let acDialog = UIAlertController(title:nil, message: NSLocalizedString("preference_rfid_reader", comment: "RFID 리더기"), preferredStyle: .alert)
		acDialog.setValue(clsReaderDialog, forKeyPath: "contentViewController")
		
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
		})
		let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			let intReaderType = clsReaderDialog.selectedRow.readerType
			let strRaderName = clsReaderDialog.selectedRow.readerName
			UserDefaults.standard.setValue(intReaderType, forKey: Constants.RFID_READER_TYPE_KEY)
			UserDefaults.standard.setValue(strRaderName, forKey: Constants.RFID_READER_NAME_KEY)
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
		let acDialog = UIAlertController(title: nil, message: NSLocalizedString("preference_rfid_mask", comment: "RFID 마스크"), preferredStyle: .alert)
		acDialog.addTextField() {
			//$0.text = self.btnRfidMask.titleLabel?.text;
			let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
			$0.text = strRfidMask
		}
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
		})
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			let strValue = acDialog.textFields?[0].text
			UserDefaults.standard.setValue(strValue, forKey: Constants.RFID_MASK_KEY)
			UserDefaults.standard.synchronize()
			self.btnRfidMask.setTitle(strValue, for: .normal)
		})
		self.present(acDialog, animated: false, completion: nil)
	}
	
	@IBAction func onRfidPowerClicked(_ sender: Any)
	{
		let clsSliderDialog = SliderDialog()
		let intRfidPower = Int(self.btnRfidPower.titleLabel?.text ?? "0")!
		//print("@@@@@intRfidPower = \(intRfidPower)")
		clsSliderDialog.sliderValue = intRfidPower
		Dialog.show(container: self, viewController: clsSliderDialog, title: nil,
						message: NSLocalizedString("preference_rfid_power", comment: "RFID Power"),
						okTitle: NSLocalizedString("common_confirm", comment: "확인"),
						okHandler: { (_) in
							let intValue = Int(clsSliderDialog.sliderValue)
							UserDefaults.standard.setValue(intValue, forKey: Constants.RFID_POWER_KEY)
							UserDefaults.standard.synchronize()
							self.btnRfidPower.setTitle("\(intValue)", for: .normal)
							print(">>> sliderValue = \(intValue)")
						},
						cancelTitle: NSLocalizedString("common_cancel", comment: "취소"),
						cancelHandler: nil)
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
