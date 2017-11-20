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
		print("AppContext init")
		mClsUserInfo = UserInfo()
		mClsUserInfo.setCustType(strCustType: "")
	}
	
	func getUserInfo() -> UserInfo
	{
		return mClsUserInfo
	}
	
	func setAuthenticated(boolAuthenticated : Bool)
	{
		mBoolAuthenticated = boolAuthenticated
	}
	
	func getAuthenticated() -> Bool
	{
		return mBoolAuthenticated
	}
	
	
	func doTest()
	{
		print("@@@@ AppContext.doTest()")
	}
	
	
}
