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
import Foundation

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
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	
	@IBAction func onSwitchChanged(_ sender: UISwitch)
	{
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
		
		//print("objMe.swAutoLogin.isOn:\(swAutoLogin.isOn)")
		//let objMe = self
		
		let dataClient = Mosaic.DataClient(container:self, url: Constants.WEB_SVC_URL)
		
		//IOS 에서는 사용자의 전화번호를 얻는것이 보안상 금지되어 있다 따라서 항상
		//임시 번호인 99999999999 만 입력
		//만약 디폴트 전화번호를 입력하지 않으면 웹서비스에서 거점항목을 가져오지 못한다.
		//서버의 main.login.xml 의 actionLogin 참조
		//전달하는 파라메터 전화번호와 상관은 없음.
		let mobileId = "99999999999"
		dataClient.loginService(userId : strUserId!, passwd : strPasswd!, mobileId : mobileId, loginCompletionHandler:
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
					
					// 언어체크
					let arrLang = UserDefaults.standard.object(forKey: "AppleLanguages") as! Array<String>
					var strCurAppleLang = arrLang.first ?? "en"
					print(" - 현재 언어(Full):\(strCurAppleLang)" )
					if(strCurAppleLang.length > 2)
					{
						strCurAppleLang = strCurAppleLang.substring(0, length: 2)
					}
					print(" - 현재 언어:\(strCurAppleLang)" )
					
					var strUserLang = login.userLang ?? "EN"
					if(strUserLang == "EN")
					{
						strUserLang = "en"
					}
					else if(strUserLang == "CH")
					{
						strUserLang = "zh"
					}
					else if(strUserLang == "KR")
					{
						strUserLang = "ko"
					}
					else if(strUserLang == "JP")
					{
						strUserLang = "ja"
					}
					

					if ( returnCode == Constants.RETURN_CODE_SUCCESS)
					{
						
						// 시스템 언어와 서버에서 받은 사용자의 언어가 다르다면 시스템언어를 서버에서 받은언어로 대체하고 종료
						if(strCurAppleLang != strUserLang)
						{
							Dialog.show(container: self, viewController: nil,
								title: NSLocalizedString("login_change_language_confirm", comment: "확인"),
								message: NSLocalizedString("login_change_language", comment: "사용자 언어를 적용하려면 앱을 종료하고 다시 시작해야 합니다. 종료하시겠습니까?"),
								okTitle: NSLocalizedString("login_change_language_confirm", comment: "확인"),
								okHandler: { (_) in
									
									// 시스템 언어 변경
									UserDefaults.standard.removeObject(forKey: "AppleLanguages")
									UserDefaults.standard.set([strUserLang], forKey: "AppleLanguages")
									UserDefaults.standard.synchronize()
									
									// 종료
									exit(0)
							},
							cancelTitle: NSLocalizedString("login_change_language_cancel", comment: "취소"), cancelHandler: { (_) in
								self.loginSuccess(login: login)
							})
						}
						else
						{	
							self.loginSuccess(login: login)
						}
					
					}
					else
					{
						// 시스템 언어와 서버에서 받은 사용자의 언어가 다르다면 시스템언어를 서버에서 받은언어로 대체하고 종료
						if(strCurAppleLang != strUserLang)
						{
							Dialog.show(container: self, viewController: nil,
										title: NSLocalizedString("login_change_language_confirm", comment: "확인"),
										message: NSLocalizedString("login_change_language", comment: "사용자 언어를 적용하려면 앱을 종료하고 다시 시작해야 합니다. 종료하시겠습니까?"),
										okTitle: NSLocalizedString("login_change_language_confirm", comment: "확인"),
										okHandler: { (_) in
											
											// 시스템 언어 변경
											UserDefaults.standard.removeObject(forKey: "AppleLanguages")
											UserDefaults.standard.set([strUserLang], forKey: "AppleLanguages")
											UserDefaults.standard.synchronize()
											
											// 종료
											exit(0)
							},
										cancelTitle: NSLocalizedString("login_change_language_cancel", comment: "취소"), cancelHandler: { (_) in
											self.loginFail(returnCode: returnCode)
							})
						}
						else
						{
							self.loginFail(returnCode: returnCode)
						}
						
						
					}
				}
		})
	}
	
	func loginFail(returnCode: Int)
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
			self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"), strMessage: rtnMessage)
		}
	}
	
	func loginSuccess(login : Login)
	{
		if let unitId = login.unitId
		{
			if(unitId.isEmpty == true)
			{
				//여기가 호출이 안될것임. 웹서비스 소스상 사용자 unit가 설정이 없으면
				//자체적으로 성공메새지를 안보내고 RETURN_CODE_NOT_ATTACH_UNIT 로 보냄
				//안드로이드용 소스를 따라서 한것으로 향후 해당 루틴은 삭제해도 될것 같음.
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // in half a second...
					self.showLoginErrorDialog(strTitle: NSLocalizedString("common_error", comment: "에러"),
											  strMessage: NSLocalizedString("rfid_no_selected_readers", comment: "선택된 리더기가 없습니다."))
				}
				return
			}
		}
        
        let clsUserInfo = AppContext.sharedManager.getUserInfo()
        
        DispatchQueue.main.async
        {
            let strUserId = self.tfUserId.text;
            let strPasswd = self.tfPasswd.text;
            
			clsUserInfo.setAutoLogin(boolAutoLogin: self.swAutoLogin.isOn)    // 자동로그인 여부
            clsUserInfo.setUserId(strUserId: strUserId!)
            clsUserInfo.setPassword(strPassword: strPasswd!)
		}
		clsUserInfo.setCorpId(strCorpId: login.corpId!)
		clsUserInfo.setCorpType(strCorpType: login.corpType ?? "")
		clsUserInfo.setUserName(strUserName: login.userName ?? "")

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
		self.dismiss(animated: true, completion: nil)
	}
	
	private func showLoginErrorDialog(strTitle:String, strMessage:String)
	{
		let acController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
		let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: UIAlertActionStyle.default, handler: nil)
		acController.addAction(aaOkAction)
		self.present(acController, animated: true, completion: nil)
	}
}



extension UserLogin: SwitchDelegate {
	func switchDidChangeState(control: Switch, state: SwitchState) {
		print("Switch changed state to: ", .on == state ? "on" : "off")
	}
}

