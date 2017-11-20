//
//  web.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 7..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public enum UserType : String
{
	case USER_TYPE_UPIS = "1"
	case USE_TYPE_RRPP = "2"
}

public enum ReturnCodeType : Int
{
	case RETURN_CODE_AUTH_FAIL  = -1
	case RETURN_CODE_FAIL       = 0
	case RETURN_CODE_OK         = 1
	
	case  RETURN_CODE_NOT_ATTACH_UNIT			= 94			/**< 응답코드: 사용가능한 리더기정보 등록여부를 확인하여 주십시오. **/
	case	 RETURN_CODE_ENTER_USER_ID				= 95			/**< 응답코드: 아이디를 입력하여 주십시오. **/
	case RETURN_CODE_ENTER_PASSWORD			= 96			/**< 응답코드: 패스워드를 입력하여 주십시오. **/
	case RETURN_CODE_VERIFY_LOGIN_INFO			= 97			/**< 응답코드: 로그인 정보를 다시 확인하여 주십시오. **/
	case RETURN_CODE_DISABLED_USER				= 98			/**< 응답코드: 사용 중지된 사용자입니다. **/
	case RETURN_CODE_NOT_RRPP_USER				= 99			/**< 응답코드: RRPP 사용자가 아님 **/
	case RETURN_CODE_PK_VIOLATION					= 23000	/**< 응답코드:중복키 에러 **/
}

public enum BackendError: Error {
	case paramError(reason: String)
	case urlError(reason: String)
	case sessionError(reason: String)
	case objectSerialization(reason: String)
}

public struct Login: Codable {
	//var userId: String
	public var userName: String?
	public var custEpc: String?
	public var encryptId: String?
	public var corpEpc: String?
	public var branchId: String?
	public var custType: String?
	public var custId: String?
	public var epcLock: String?
	public var branchName: String?
	public var userLang: String?
	public var custName: String?
	public var eventCode: String?
	public var branchCustId: String?
	public var parentCustId: String?
	public var branchCustType: String?
	public var corpType: String?
	public var corpId: String?
	public var branchCustName: String?
	public var unitId: String?
	public var version: String?
	public var pushUseYn: String?
	public var returnMessage: String?
	public var returnCode: Int?
	//
	//  ["custEpc": 95100027, "pushUseYn": N, "encryptId": xxOxOsU93/PvK/NN7DZmZw==, "corpEpc": <null>, "branchId": 161220000122, "custType": MGR,
	//  "custId": 160530000070, "returnCode": 1, "inAgreeYn": Y, "userName": RRPP팀, "epcLock": 36697577, "branchName": 가락 물류센터(간이), "userLang": KR,
	//  "custName": 한국파렛트풀, "eventCode": , "branchCustId": 161220000164, "parentCustId": 150801000003, "version": 2, "branchCustType": RDC,
	//  "returnMessage": , "corpType": BIZ, "corpId": logisallcm, "branchCustName": 가락 물류센터(간이), "unitId": KM-SW001]
	
	
	init?(json: [String: Any])
	{
		guard let userName = json["userName"] as? String,
			let custEpc = json["custEpc"] as? String,
			let encryptId = json["encryptId"] as? String,
			//        let corpEpc = json["corpEpc"] as? String,
			let branchId = json["branchId"] as? String,
			let custType = json["custType"] as? String,
			let custId = json["custId"] as? String,
			let epcLock = json["epcLock"] as? String,
			let branchName = json["branchName"] as? String,
			let userLang = json["userLang"] as? String,
			let custName = json["custName"] as? String,
			let eventCode = json["eventCode"] as? String,
			let branchCustId = json["branchCustId"] as? String,
			let parentCustId = json["parentCustId"] as? String,
			let branchCustType = json["branchCustType"] as? String,
			let corpType = json["corpType"] as? String,
			let corpId = json["corpId"] as? String,
			let branchCustName = json["branchCustName"] as? String,
			let unitId = json["unitId"] as? String,
			let version = json["version"] as? String,
			let pushUseYn = json["pushUseYn"] as? String,
			let returnCode = json["returnCode"] as? Int,
			let returnMessage = json["returnMessage"] as? String
			else {
				return nil
		}
		//self.userId = userId
		self.userName = userName
		self.custEpc = custEpc
		self.encryptId = encryptId
		//        self.corpEpc = corpEpc
		self.branchId = branchId
		self.custType = custType
		self.custId = custId
		self.epcLock = epcLock
		self.branchName = branchName
		self.userLang  = userLang
		self.custName = custName
		self.eventCode = eventCode
		self.branchCustId = branchCustId
		self.parentCustId = parentCustId
		self.branchCustType = branchCustType
		self.corpType = corpType
		self.corpId = corpId
		self.branchCustName = branchCustName
		self.unitId = unitId
		self.version = version
		self.pushUseYn = pushUseYn
		self.returnMessage = returnMessage
		self.returnCode = returnCode
	}
	
	//  ["custEpc": 95100027, "pushUseYn": N, "encryptId": xxOxOsU93/PvK/NN7DZmZw==, "corpEpc": <null>, "branchId": 161220000122, "custType": MGR,
	//  "custId": 160530000070, "returnCode": 1, "inAgreeYn": Y, "userName": RRPP팀, "epcLock": 36697577, "branchName": 가락 물류센터(간이), "userLang": KR,
	//  "custName": 한국파렛트풀, "eventCode": , "branchCustId": 161220000164, "parentCustId": 150801000003, "version": 2, "branchCustType": RDC,
	//  "returnMessage": , "corpType": BIZ, "corpId": logisallcm, "branchCustName": 가락 물류센터(간이), "unitId": KM-SW001]
}


public struct ResponseData: Codable {
	public var returnCode: Int?
	public var returnMessage: String?
	
	init?(json: [String: Any])
	{
		guard let returnCode = json["returnCode"] as? Int,
			let returnMessage = json["returnMessage"] as? String
			else {
				return nil
		}
		self.returnCode = returnCode
		self.returnMessage = returnMessage
	}
}

public class DataClient
{
	let mStrPathLogin = "/websvc/loginService.json"
	let mStrPathData = "/websvc/dataService/data.json"
	
	var mStrServiceUrlSelect = "dataService:selectWsList"
	var mStrServiceUrlUrlExecute = "dataService:executeWsData"
	
	var mStrWebSvcLocation : String
	
	var mStrUsreInfo : String?
	var mStrUserData : String?
	var mMapParam :  [String : String] = [String : String]()
	var mStrMode : String?
	
	//Init구현
	public convenience init () {
		self.init(url: "http://192.168.0.213:8080")
	}
	
	public init(url webSvcLocaiton: String)
	{
		self.mStrWebSvcLocation = webSvcLocaiton
	}
	
	//GetSet구현
	public var UserInfo: String? {
		set { mStrUsreInfo = newValue }
		get {return mStrUsreInfo }
	}
	
	public var Mode: String? {
		set { mStrMode = newValue }
		get {return mStrMode }
	}
	
	public var UserData: String? {
		set { mStrUserData = newValue }
		get {return mStrUserData }
	}
	
	public var ExecuteUrl: String {
		set { mStrServiceUrlUrlExecute = newValue }
		get {return mStrServiceUrlUrlExecute }
	}
	
	public var SelectUrl: String {
		set { mStrServiceUrlSelect = newValue }
		get {return mStrServiceUrlSelect }
	}
	
	public func removeServiceParam() -> Void
	{
		mMapParam.removeAll()
	}
	
	public func addServiceParam(paramName:String, value:Any) -> Void
	{
		//중복된키 제거
		mMapParam.removeValue(forKey: paramName)
		mMapParam[paramName] = String(describing: value)
	}
	
	//각 처리 함수구현
	//로그인처리
	public func loginService(userId : String, passwd : String, mobileId : String?,
							 loginCompletionHandler: @escaping (Login?, Error?) -> Void) -> Void
	{
		
		var dicParam : [String: String] = ["usertype" : "2", "userid" : userId, "passwd" : passwd]
		if let strTempMobileId = mobileId
		{
			dicParam["mobileid"] = strTempMobileId
		}
		let dicReqParam = ["requestLogin" : dicParam]
		guard let requestUrl = URL(string: mStrWebSvcLocation + mStrPathLogin) else
		{
			print("Error: cannot create URL")
			let error = BackendError.urlError(reason: "잘못된 URL")
			loginCompletionHandler(nil, error)
			return
		}
		
		let session = URLSession.shared
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		request.timeoutInterval = 10    //타이머 설정
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: dicReqParam, options: .prettyPrinted)
		} catch let error {
			let error = BackendError.sessionError(reason: "알수없는 서비스 오류:" + error.localizedDescription)
			loginCompletionHandler(nil, error)
		}
		
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
			guard error == nil else {
				let error = BackendError.sessionError(reason: error.debugDescription)
				loginCompletionHandler(nil, error)
				return
			}
			
			guard let responseData = data else {
				print("Error: did not receive data")
				let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
				loginCompletionHandler(nil, error)
				return
			}
			
			do {
				if let loginJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
				{
					if let login = Login(json: loginJSON) {
						print(loginJSON)
						loginCompletionHandler(login, nil)
					} else {
						print(responseData)
						let error = BackendError.objectSerialization(reason: "JSON 처리오류, DATA:" + loginJSON.debugDescription)
						loginCompletionHandler(nil, error)
					}
				}
			} catch {
				loginCompletionHandler(nil, error)
				return
			}
		})
		task.resume()
		return
	}
	
	public func selectRawData(dataCompletionHandler: @escaping (ResponseData?, Error?) -> Void) -> Void
	{
		var dicParam : [String: String] = ["usertype" : "2", "mode" : "R"]
		guard let strUserInfo = self.mStrUsreInfo, !strUserInfo.isEmpty else
		{
			let error = BackendError.paramError(reason: "인증정보[UserInfo]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["userinfo"] = strUserInfo
		print("strUserInfo!!" + strUserInfo)
		
		guard let strUserData = self.mStrUserData , !strUserData.isEmpty else
		{
			let error = BackendError.paramError(reason: "요청 비즈니스 서비스정보[UserData]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["userdata"] = strUserData
		
		var strServiceUrl = self.mStrServiceUrlSelect
		strServiceUrl.append("?")
		for (key, value) in self.mMapParam
		{
			strServiceUrl.append(key + "=" + value)
			strServiceUrl.append("&")
		}
		//제일 마지막 & 제거
		strServiceUrl.remove(at: strServiceUrl.index(before: strServiceUrl.endIndex))
		dicParam["serviceurl"] = strServiceUrl
		
		guard let requestUrl = URL(string: self.mStrWebSvcLocation + self.mStrPathData) else
		{
			print("Error: cannot create URL")
			let error = BackendError.urlError(reason: "잘못된 URL")
			dataCompletionHandler(nil, error)
			return
		}
		
		let dicReqParam = ["requestData" : dicParam]
		let session = URLSession.shared
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		request.timeoutInterval = 10    //타이머 설정 10초
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: dicReqParam, options: .prettyPrinted)
		} catch let error {
			print(error.localizedDescription)
			let error = BackendError.sessionError(reason: "알수없는 서비스 오류:" + error.localizedDescription)
			dataCompletionHandler(nil, error)
		}
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
			guard error == nil else {
				let error = BackendError.sessionError(reason: error.debugDescription)
				dataCompletionHandler(nil, error)
				return
			}
			
			guard let responseData = data else {
				print("Error: did not receive data")
				let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
				dataCompletionHandler(nil, error)
				return
			}
			
			do {
				if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
				{
					if let responseData = ResponseData(json: responseJSON) {
						print(responseJSON)
						dataCompletionHandler(responseData, nil)
					} else {
						print(responseData)
						let error = BackendError.objectSerialization(reason: "JSON 처리오류, DATA:" + responseJSON.debugDescription)
						dataCompletionHandler(nil, error)
					}
				}
			} catch {
				dataCompletionHandler(nil, error)
				return
			}
		})
		task.resume()
		return
	}
	
	public func selectData(dataCompletionHandler: @escaping (DataTable?, Error?) -> Void) -> Void
	{
		var dicParam : [String: String] = ["usertype" : "2", "mode" : "R"]
		guard let strUserInfo = self.mStrUsreInfo, !strUserInfo.isEmpty else
		{
			let error = BackendError.paramError(reason: "인증정보[UserInfo]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["userinfo"] = strUserInfo
		print("strUserInfo!!" + strUserInfo)
		
		guard let strUserData = self.mStrUserData , !strUserData.isEmpty else
		{
			let error = BackendError.paramError(reason: "요청 비즈니스 서비스정보[UserData]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["userdata"] = strUserData
		
		var strServiceUrl = self.mStrServiceUrlSelect
		strServiceUrl.append("?")
		for (key, value) in self.mMapParam
		{
			strServiceUrl.append(key + "=" + value)
			strServiceUrl.append("&")
		}
		//제일 마지막 & 제거
		strServiceUrl.remove(at: strServiceUrl.index(before: strServiceUrl.endIndex))
		dicParam["serviceurl"] = strServiceUrl
		
		guard let requestUrl = URL(string: self.mStrWebSvcLocation + self.mStrPathData) else
		{
			print("Error: cannot create URL")
			let error = BackendError.urlError(reason: "잘못된 URL")
			dataCompletionHandler(nil, error)
			return
		}
		
		let dicReqParam = ["requestData" : dicParam]
		let session = URLSession.shared
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		request.timeoutInterval = 10    //타이머 설정 10초
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: dicReqParam, options: .prettyPrinted)
		} catch let error {
			print(error.localizedDescription)
			let error = BackendError.sessionError(reason: "알수없는 서비스 오류:" + error.localizedDescription)
			dataCompletionHandler(nil, error)
		}
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
			guard error == nil else {
				let error = BackendError.sessionError(reason: error.debugDescription)
				dataCompletionHandler(nil, error)
				return
			}
			
			guard let responseData = data else {
				print("Error: did not receive data")
				let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
				dataCompletionHandler(nil, error)
				return
			}
			
			do {
				if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
				{
					if let responseData = ResponseData(json: responseJSON)
					{
						//print(responseJSON)
						if( responseData.returnCode! == ReturnCodeType.RETURN_CODE_OK.rawValue)
						{
							let dataSourceMgr = DataSourceMgr()
							dataSourceMgr.Notation = DataSourceMgr.NOTATION_NONE
							if (dataSourceMgr.parse(data: responseData.returnMessage!))
							{
								let dataTable = dataSourceMgr.getDataTable()
								dataCompletionHandler(dataTable, nil)
								return
							}
						}
						else
						{
							print("응답데이터가 없음!!")
						}
						
						let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
						dataCompletionHandler(nil, error)
					}
					else
					{
						print(responseData)
						let error = BackendError.objectSerialization(reason: "JSON 처리오류, DATA:" + responseJSON.debugDescription)
						dataCompletionHandler(nil, error)
					}
				}
			} catch {
				dataCompletionHandler(nil, error)
				return
			}
		})
		task.resume()
		return
	}
	
	public func executeTransaction(mode: String, xmlDocument: String,
								   dataCompletionHandler: @escaping (DataTable?, Error?) -> Void) -> Void
	{
		var dicParam : [String: String] = ["usertype" : "2"]
		guard let strUserInfo = self.mStrUsreInfo, !strUserInfo.isEmpty else
		{
			let error = BackendError.paramError(reason: "인증정보[UserInfo]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["userinfo"] = strUserInfo
		print("strUserInfo!!" + strUserInfo)
		
		if(xmlDocument.isEmpty == false)
		{
			dicParam["userdata"] = xmlDocument
		}
		
		if(mode.isEmpty)
		{
			let error = BackendError.paramError(reason: "처리할 Mode가 없습니다.[mode]가 없습니다.")
			dataCompletionHandler(nil, error)
			return
		}
		dicParam["mode"] = mode
		
		var strServiceUrl = self.mStrServiceUrlUrlExecute
		strServiceUrl.append("?")
		for (key, value) in self.mMapParam
		{
			strServiceUrl.append(key + "=" + value)
			strServiceUrl.append("&")
		}
		//제일 마지막 & 제거
		strServiceUrl.remove(at: strServiceUrl.index(before: strServiceUrl.endIndex))
		dicParam["serviceurl"] = strServiceUrl
		
		guard let requestUrl = URL(string: self.mStrWebSvcLocation + self.mStrPathData) else
		{
			print("Error: cannot create URL")
			let error = BackendError.urlError(reason: "잘못된 URL")
			dataCompletionHandler(nil, error)
			return
		}
		
		let dicReqParam = ["requestData" : dicParam]
		let session = URLSession.shared
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		request.timeoutInterval = 10    //타이머 설정 10초
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: dicReqParam, options: .prettyPrinted)
		} catch let error {
			print(error.localizedDescription)
			let error = BackendError.sessionError(reason: "알수없는 서비스 오류:" + error.localizedDescription)
			dataCompletionHandler(nil, error)
		}
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
			guard error == nil else {
				let error = BackendError.sessionError(reason: error.debugDescription)
				dataCompletionHandler(nil, error)
				return
			}
			
			guard let responseData = data else {
				print("Error: did not receive data")
				let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
				dataCompletionHandler(nil, error)
				return
			}
			
			do {
				if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
				{
					if let responseData = ResponseData(json: responseJSON)
					{
						//print(responseJSON)
						if( responseData.returnCode! == ReturnCodeType.RETURN_CODE_OK.rawValue)
						{
							let dataSourceMgr = DataSourceMgr()
							dataSourceMgr.Notation = DataSourceMgr.NOTATION_NONE
							if (dataSourceMgr.parse(data: responseData.returnMessage!))
							{
								let dataTable = dataSourceMgr.getDataTable()
								dataCompletionHandler(dataTable, nil)
								return
							}
						}
						else
						{
							print("응답데이터가 없음!!")
						}
						
						let error = BackendError.objectSerialization(reason: "응답데이터가 없습니다.")
						dataCompletionHandler(nil, error)
					}
					else
					{
						print(responseData)
						let error = BackendError.objectSerialization(reason: "JSON 처리오류, DATA:" + responseJSON.debugDescription)
						dataCompletionHandler(nil, error)
					}
				}
			} catch {
				dataCompletionHandler(nil, error)
				return
			}
		})
		task.resume()
		return
	}
	
	public func executeData(dataTable : DataTable?,
							dataCompletionHandler: @escaping (DataTable?, Error?) -> Void) -> Void
	{
		var strData : String = ""
		if let execTable = dataTable
		{
			strData = execTable.getChangedData()
		}
		self.executeTransaction(mode: "S", xmlDocument: strData, dataCompletionHandler: dataCompletionHandler)
	}
	
	public func executeData(dataCompletionHandler: @escaping (DataTable?, Error?) -> Void) -> Void
	{
		self.executeData(dataTable: nil, dataCompletionHandler: dataCompletionHandler)
	}
	
}



