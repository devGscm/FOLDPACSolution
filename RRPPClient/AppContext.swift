//
//  AppContext.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 13..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import Foundation

class AppContext
{
	var mClsUserInfo : UserInfo
	var mBoolAuthenticated : Bool = false
	
	static let sharedManager: AppContext = {
		let instance = AppContext()
		print("@@@@AppContex Instance")
		return instance
	}()
	//static let sharedManager = AppContext()
	init()
	{
		print("============================")
		print("AppContext init")
		print("============================")
		mClsUserInfo = UserInfo()
		//mClsUserInfo.setCustType(strCustType: "")
	}
	
	func setAuthenticated(boolAuthenticated : Bool)
	{
		mBoolAuthenticated = boolAuthenticated
	}
	
	func getAuthenticated() -> Bool
	{
		return mBoolAuthenticated
	}
	
	func doLogout()
	{
		if(mClsUserInfo.getAutoLogin() == true)
		{
			
		}
		else
		{
			setAuthenticated(boolAuthenticated: false)
			mClsUserInfo.setCorpId(strCorpId: "")
			mClsUserInfo.setUserId(strUserId: "")
			
		}
	}
	
	func getUserInfo() -> UserInfo
	{
		return mClsUserInfo
	}
	
	
	
}
