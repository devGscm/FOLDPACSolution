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
import Mosaic

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
			showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: NSLocalizedString("login_input_id", comment: "사용자 ID입력"))
			return
		}
		if(strPasswd?.isEmpty == true)
		{
			//common_confirm
			showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: NSLocalizedString("login_input_passwd", comment: "비밀번호 입력"))
			return
		}
		
		print("objMe.swAutoLogin.isOn:\(swAutoLogin.isOn)")
		let objMe = self
		
		let dataClient = Mosaic.DataClient(url: Constants.WEB_SVC_URL)
		dataClient.loginService(userId : strUserId!, passwd : strPasswd!, mobileId : "",
								loginCompletionHandler:
			{ (login, loginError) in
				if let error = loginError {
					objMe.showLoginErrorDialog(strTitle: "에러", strMessage:  error.localizedDescription)
					return
				}
				guard let login = login else {
					print("에러 데이터가 없음")
					return
				}
				// 성공
				if let returnCode = login.returnCode
				{
					//if ( returnCode == ReturnCodeType.RETURN_CODE_OK.rawValue )
					if ( returnCode == 1)
					{
						let clsUserInfo = AppContext.sharedManager.getUserInfo()
						if let unitId = login.unitId
						{
							if(unitId.isEmpty == true)
							{
								//TODO : 다국어 처리
								objMe.showLoginErrorDialog(strTitle: "알림", strMessage: "선택된 리더기기 없습니다.")
								return
							}
						}
						
						clsUserInfo.setAutoLogin(boolAutoLogin: objMe.swAutoLogin.isOn)    // 자동로그인 여부
						
						clsUserInfo.setCorpId(strCorpId: login.corpId!)
						clsUserInfo.setCustType(strCustType: login.corpType!)
						clsUserInfo.setUserId(strUserId: strUserId!)
						clsUserInfo.setUserName(strUserName: login.userName ?? "")
						clsUserInfo.setPassword(strPassword: strPasswd!)
						clsUserInfo.setCustId(strCustId: login.custId ?? "")
						clsUserInfo.setCustType(strCustType: login.custType ?? "")
						clsUserInfo.setEncryptId(strEncryptId: login.encryptId!)
						if let version = login.version
						{
							if let intVersion = Int(version)
							{
								clsUserInfo.setVersion(intVersion: intVersion)
							}
						}
						
						clsUserInfo.setPushUseYn(strPushUseYn : login.pushUseYn ?? "N")
						
						// TODO:: 항목의 의미 업무파악
						clsUserInfo.setPreCorpId(strCorpId : "")
						clsUserInfo.setPreUserId(strPreUserId : "")
						
						clsUserInfo.setUserLang(strUserLang : login.userLang ?? "KR")
						clsUserInfo.setUnitId(strUnitId : login.unitId ?? "")
						clsUserInfo.setEventCode(strEventCode : login.eventCode ?? "")
						clsUserInfo.setBranchId(strBranchId : login.branchId ?? "")
						clsUserInfo.setBranchName(strBranchName : login.branchName ?? "")
						clsUserInfo.setBranchCustId(strBranchCustId : login.branchCustId ?? "")
						clsUserInfo.setBranchCustName(strBranchCustName : login.branchCustName ?? "")
						clsUserInfo.setParentCustId(strParentCustId : login.parentCustId ?? "")
						clsUserInfo.setBranchCustType(strBranchCustType : login.branchCustType ?? "")
						
						AppContext.sharedManager.setAuthenticated(boolAuthenticated: true)
						objMe.dismiss(animated: true, completion: nil)
						return
					}
					else
					{
						//TODO 다국어 처리되면 메세지에 따라서 처리
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
							self.showLoginErrorDialog(strTitle: "알림", strMessage: "인증오류가 발생하였습니다. 오류코드:" + String(returnCode))
						}
						
						//						DispatchQueue.global(qos: .userInitiated).async{
						//							self.showLoginErrorDialog(strTitle: "알림", strMessage: "인증오류가 발생하였습니다. 오류코드:" + String(returnCode))
						//						}
						return
					}
				}
		})
		
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

