//
//  LoginViewController.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 15..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material
import FontAwesome

class LoginViewController: UIViewController
{

	@IBOutlet weak var swAutoLogin: UISwitch!
	@IBOutlet weak var ivBackground: UIImageView!
	@IBOutlet weak var tfUserId: UITextField!
	@IBOutlet weak var tfPasswd: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
	//@IBOutlet weak var vwAutoLogin: UIView!
	
	var mClsProgressBar: ProgressDialog!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		view.sendSubview(toBack: ivBackground)
		
		//let swAutoLogin = Switch(state: .off, style: .light, size: .small)
		//swAutoLogin.delegate = self
		
		//mClsProgressBar = ProgressDialog(delegate: self)
		//mClsProgressBar.SetDialogBackground(UIColor.white)
		//mClsProgressBar.SetDialogColor(UIColor.black)
		//mClsProgressBar.Show(true, strMessage:"Loading...")
		
		btnLogin.titleLabel?.font = UIFont.fontAwesome(ofSize:18)
		let strLogin:String? = String.fontAwesomeIcon(name:.lock) + " 로그인"
		btnLogin.setTitle(strLogin, for: .normal)
    }
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	@IBAction func onSwitchChanged(_ sender: UISwitch)
	{
		if(sender.isOn)
		{
			self.view.backgroundColor = UIColor.red
		}
		else
		{
			self.view.backgroundColor = UIColor.black
		}
	}
	
	@IBAction func doLogin(_ sender: Any)
	{
		print("*LoginViewController.doLogin()")
		
		let strUserId = tfUserId.text;
		let strPasswd = tfPasswd.text;

		if(strUserId?.isEmpty == true)
		{
			showLoginErrorDialog(strTitle: "에러", strMessage: "사용자ID를 입력하시기 바랍니다.")
			return;
		}
		if(strPasswd?.isEmpty == true)
		{
			showLoginErrorDialog(strTitle: "에러", strMessage: "비밀번호를 입력하시기 바랍니다.")
			return;
		}

		print("objMe.swAutoLogin.isOn:\(swAutoLogin.isOn)")
		let objMe = self
		var acController = UIAlertController(title: "RRPP", message: "3G 및 LTE 네트워크 사용시 가입하신 요금제에 따라 비용이 과금됩니다.", preferredStyle: UIAlertControllerStyle.alert)
		let aaOkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (self) in
			
			// 테스트
			let clsUserInfo = AppContext.sharedManager.getUserInfo()
			clsUserInfo.setAutoLogin(boolAutoLogin: objMe.swAutoLogin.isOn)	// 자동로그인 여부
			clsUserInfo.setCorpId(strCorpId: "logisallcm")
			clsUserInfo.setCustType(strCustType: "MGR")
			clsUserInfo.setUserId(strUserId: "rp11")
			AppContext.sharedManager.setAuthenticated(boolAuthenticated: true)
			objMe.dismiss(animated: true, completion: nil)
		}
		acController.addAction(aaOkAction)
		self.present(acController, animated: true, completion: nil)
		

		
	}
	
	private func showLoginErrorDialog(strTitle:String, strMessage:String)
	{
		var acController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
		let aaOkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
		acController.addAction(aaOkAction)
		self.present(acController, animated: true, completion: nil)
	}
}



extension LoginViewController: SwitchDelegate {
	func switchDidChangeState(control: Switch, state: SwitchState) {
		print("Switch changed state to: ", .on == state ? "on" : "off")
	}
}
