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

class UserLogin: UIViewController
{
	
	@IBOutlet weak var swAutoLogin: UISwitch!
	@IBOutlet weak var ivBackground: UIImageView!
	@IBOutlet weak var tfUserId: UITextField!
	@IBOutlet weak var tfPasswd: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
	//@IBOutlet weak var vwAutoLogin: UIView!
	
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
		//let strLogin:String? = String.fontAwesomeIcon(name:.lock) + " 로그인"
		//btnLogin.setTitle(strLogin, for: .normal)
		
		//Dialog.show(viewController: self, title: "", message: "해보시다.", okTitle:"OK", okHandler: nil)

	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	
	@IBAction func onSwitchChanged(_ sender: UISwitch)
	{
//		if(sender.isOn)
//		{
//			self.view.backgroundColor = UIColor.red
//		}
//		else
//		{
//			self.view.backgroundColor = UIColor.black
//		}
	}
	
	@IBAction func doLogin(_ sender: Any)
	{
		print("*UserLogin.doLogin()")
		
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
		
		let dataClient = Mosaic.DataClient(container:self, url: Constants.WEB_SVC_URL)
		dataClient.loginService(userId : strUserId!, passwd : strPasswd!, mobileId : "", loginCompletionHandler:
			{ (login, loginError) in
				if let error = loginError {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
						self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: "Login Error Reason:" + String(error.localizedDescription) )
					}
					return
				}
				guard let login = login else {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
						self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: "Return doesn't  Value")
					}
					return
				}
				// 성공
				if let returnCode = login.returnCode
				{
					if ( returnCode == Constants.RETURN_CODE_SUCCESS)
					{
						let clsUserInfo = AppContext.sharedManager.getUserInfo()
						if let unitId = login.unitId
						{
							if(unitId.isEmpty == true)
							{
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
									self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"),
															  strMessage: NSLocalizedString("rfid_reader_no_device_id", comment: "선택된 리더기가 없습니다."))
								}
								return
							}
						}
						
						clsUserInfo.setAutoLogin(boolAutoLogin: objMe.swAutoLogin.isOn)    // 자동로그인 여부
						
						clsUserInfo.setCorpId(strCorpId: login.corpId!)
						//clsUserInfo.setCustType(custType: login.corpType!)
						clsUserInfo.setUserId(strUserId: strUserId!)
						clsUserInfo.setUserName(strUserName: login.userName ?? "")
						clsUserInfo.setPassword(strPassword: strPasswd!)
						clsUserInfo.setCustId(strCustId: login.custId ?? "")
						clsUserInfo.setCustType(custType: login.custType ?? "")
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
						clsUserInfo.setBranchId(branchId : login.branchId ?? "")
						clsUserInfo.setBranchName(branchName : login.branchName ?? "")
						clsUserInfo.setBranchCustId(branchCustId : login.branchCustId ?? "")
						clsUserInfo.setBranchCustName(branchCustName : login.branchCustName ?? "")
						clsUserInfo.setParentCustId(strParentCustId : login.parentCustId ?? "")
						clsUserInfo.setBranchCustType(branchCustType : login.branchCustType ?? "")
						
						AppContext.sharedManager.setAuthenticated(boolAuthenticated: true)
						objMe.dismiss(animated: true, completion: nil)
						//toolbarController?
						return
					}
					else
					{
						//TODO 다국어 처리되면 메세지에 따라서 처리
						var rtnMessage : String = ""
						switch returnCode
						{
							case ReturnCodeType.RETURN_CODE_NOT_ATTACH_UNIT.rawValue :
								rtnMessage = NSLocalizedString("return_message_not_attach_unit", comment: "사용가능한 리더기정보 등록여부를 확인하여 주십시오. ")
							case ReturnCodeType.RETURN_CODE_ENTER_USER_ID.rawValue :
								rtnMessage = NSLocalizedString("return_message_enter_your_user_id", comment: "아이디를 입력하여 주십시오. ")
							case ReturnCodeType.RETURN_CODE_ENTER_PASSWORD.rawValue :
								rtnMessage = NSLocalizedString("return_message_enter_your_password", comment: "패스워드를 입력하여 주십시오. ")
							case ReturnCodeType.RETURN_CODE_VERIFY_LOGIN_INFO.rawValue :
								rtnMessage = NSLocalizedString("return_message_verify_login_info", comment: "로그인 정보를 다시 확인하여 주십시오.")
							case ReturnCodeType.RETURN_CODE_DISABLED_USER.rawValue :
								rtnMessage = NSLocalizedString("return_message_disabled_user", comment: "사용 중지된 사용자입니다. ")
							case ReturnCodeType.RETURN_CODE_NOT_RRPP_USER.rawValue :
								rtnMessage = NSLocalizedString("return_message_upis_user_not_able_use", comment: "RRPP 사용자가 아님 ")
							case ReturnCodeType.RETURN_CODE_PK_VIOLATION.rawValue :
								//TODO: 다국어 정의
								rtnMessage = "중복키 오류"
							default :
								rtnMessage = "알수없는 오류코드발생"
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
							self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"),
													  strMessage: rtnMessage)
						}
						return
					}
				}
		})
		
	}
	
	private func showLoginErrorDialog(strTitle:String, strMessage:String)
	{
		let acController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
		let aaOkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
		acController.addAction(aaOkAction)
		self.present(acController, animated: true, completion: nil)
	}
}



extension UserLogin: SwitchDelegate {
	func switchDidChangeState(control: Switch, state: SwitchState) {
		print("Switch changed state to: ", .on == state ? "on" : "off")
	}
}

