/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material


class RightViewController: UITableViewController
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
		
		self.swRfidBeep.isOn = UserDefaults.standard.bool(forKey: Constants.RFID_BEEP_ENABLED_KEY)
		// RFID 리더기
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 0, readerName: "Swing U"))
		mLstRfidReader.append(RfidReaderDialog.RfidReader(readerType: 1, readerName: "AT288"))
		
		let intRfidReader = UserDefaults.standard.integer(forKey: Constants.RFID_READER_KEY)
		let strRfidReaderName = mLstRfidReader[intRfidReader].readerName
		print("@@@@@@ RFID READER:\(intRfidReader)")
		self.btnRfidReader.setTitle(strRfidReaderName, for: .normal)
		
		// RFID 마스크
		let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
		print("@@@@@@ RFID MASK:\(strRfidMask)")
		self.btnRfidMask.setTitle(strRfidMask, for: .normal)
		
		// RFID Power
		let strRfidPower = UserDefaults.standard.string(forKey: Constants.RFID_POWER_KEY) ?? "0"
		self.btnRfidPower.setTitle(strRfidPower, for: .normal)
		print("@@@@@@ RFID POWER:\(strRfidPower)")
    }
	
	
	@IBAction func onBranchClicked(_ sender: Any)
	{
		//clsBranchSearchDialog.contentWidth = self.view.frame.width * 1.2
		clsBranchSearchDialog.contentHeight = self.view.frame.height
		
		let acDialog = UIAlertController(title:nil, message:"거점 선택", preferredStyle: .alert)
		acDialog.setValue(clsBranchSearchDialog, forKeyPath: "contentViewController")
		let aaOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
			/*
			let intReaderType = clsReaderDialog.selectedRow.readerType
			let strRaderName = clsReaderDialog.selectedRow.readerName
			UserDefaults.standard.setValue(intReaderType, forKey: Constants.RFID_READER_KEY)
			UserDefaults.standard.synchronize()
			self.btnRfidReader.setTitle(strRaderName, for: .normal)
			*/
		}
		acDialog.addAction(aaOkAction)
		
		/*
		var height:NSLayoutConstraint = NSLayoutConstraint(item: acDialog.view,
														   attribute: NSLayoutAttribute.height,
														   relatedBy: NSLayoutRelation.equal,
														   toItem: nil,
														   attribute: NSLayoutAttribute.notAnAttribute,
														   multiplier: 1,
														   constant: self.view.frame.height * 0.9
		)
		acDialog.view.addConstraint(height)*/
		
		self.present(acDialog, animated: true)
	}
	
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
