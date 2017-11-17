//
//  UserInfo.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 13..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import Foundation


class UserInfo
{


	/**
	* 자동로그인 여부를 리턴한다.
	* @return 자동로그인 여부
	*/
	func getAutoLogin() -> Bool			{ return UserDefaults.standard.bool(forKey: "autoLogin") }
	
	/**
	* 회사ID 를 리턴한다.
	* @return 회사ID
	*/
	func getCorpId() -> String?			{ return UserDefaults.standard.string(forKey: "corpId") }
	

	/**
	* 회사구분을 리턴한다.
	* @return 회사구분
	*/
	func getCorpType() -> String?		{ return UserDefaults.standard.string(forKey: "corpType") }
	
	/**
	* 사용자ID를 리턴한다.
	* @return 사용자ID
	*/
	func getUserId() -> String?			{ return UserDefaults.standard.string(forKey: "userId") }
	
	/**
	* 패스워드를 리턴한다.
	* @return 패스워드
	*/
	func getPassword() -> String?		{ return UserDefaults.standard.string(forKey: "password") }
	
	
	/**
	* 고객사ID를 리턴한다.
	* @return 고객사ID
	*/
	func getCustId() -> String?			{ return UserDefaults.standard.string(forKey: "custId") }
	
	
	/**
	* 고객사 구분을 리턴한다.
	* @return 고객사 구분
	*/
	func getCustType() -> String?		{ return UserDefaults.standard.string(forKey: "custType") }
	
	
	/**
	* 사용자명을 리턴한다.
	* @return 사용자명
	*/
	func getUserName() -> String?		{ return UserDefaults.standard.string(forKey: "userName") }
	
	/**
	* 사용자 암호화 ID를 리턴한다.
	* @return 사용자 암호화 ID
	*/
	func getEncryptId() -> String?		{ return UserDefaults.standard.string(forKey: "encryptId") }
	
	/**
	* 버전을 리턴한다.
	* @return 버전
	*/
	func getVersion() -> Int			{ return UserDefaults.standard.integer(forKey: "version") }
	
	
	/**
	* 푸시사용여부를 리턴한다.
	* @return 푸시사용여부
	*/
	func getPushUseYn() -> String?		{ return UserDefaults.standard.string(forKey: "pushUseYn") }
	
	/**
	* 이전 로그인 회사ID를 리턴한다.
	* @return 이전 로그인 회사ID
	*/
	func getPreCorpId() -> String?		{ return UserDefaults.standard.string(forKey: "preCorpId") }
	
	/**
	* 이전 로그인 사용자ID를 리턴한다.
	* @return 이전 로그인 사용자ID
	*/
	func getPreUserId() -> String?		{ return UserDefaults.standard.string(forKey: "preUserId") }
	
	
	/**
	* 사용자 언어를 리턴한다.
	* @return 사용자 언어
	*/
	func getUserLang() -> String?		{ return UserDefaults.standard.string(forKey: "userLang") ?? "KR" }
	
	/**
	* 장치ID를 리턴한다.
	* @return 장치ID
	*/
	func getUnitId() -> String?			{ return UserDefaults.standard.string(forKey: "unitId") }
	
	
	/**
	* 이벤트코드를 리턴한다.
	* @return 이벤트코드
	*/
	func getEventCode() -> String?		{ return UserDefaults.standard.string(forKey: "eventCode") }
	
	/**
	* 거점ID를 리턴한다.
	* @return 거점ID
	*/
	func getBranchId() -> String?		{ return UserDefaults.standard.string(forKey: "branchId") }
	
	/**
	* 거점명을 리턴한다.
	* @return 거점명
	*/
	func getBranchName() -> String?		{ return UserDefaults.standard.string(forKey: "branchName") }
	
	
	/**
	* 거점고객사ID를 리턴한다.
	* @return 거점고객사ID
	*/
	func getBranchCustId() -> String?		{ return UserDefaults.standard.string(forKey: "branchCustId") }
	
	/**
	* 거점고객사명을 리턴한다.
	* @return 거점고객사명
	*/
	func getBranchCustName() -> String?		{ return UserDefaults.standard.string(forKey: "branchCustName") }
	
	
	/**
	* 상위고객사ID을 리턴한다.
	* @return 상위고객사ID
	*/
	func getParentCustId() -> String?		{ return UserDefaults.standard.string(forKey: "parentCustId") }
	
	
	/**
	* 거점의 고객사 구분을 리턴한다.
	* @return 거점의 고객사 구분
	*/
	func getBranchCustType() -> String?		{ return UserDefaults.standard.string(forKey: "branchCustType") }
	
	
	/**
	* 공통코드 정보 업데이트 일자를 리턴한다.
	* @return 공통코드 업데이트 일자
	*/
	func getCodeMastUpdateDate() -> Int64?		{ return UserDefaults.standard.object(forKey: "codeMastUpdateDate") as? Int64 }
	
	
	/**
	* 공통코드 상세 정보 업데이트 일자를 리턴한다.
	* @return 공통코드 상세 업데이트 일자
	*/
	func getCodeDetailUpdateDate() -> Int64?	{ return UserDefaults.standard.object(forKey: "codeDetailUpdateDate") as? Int64 }
	
	/**
	* 회사별 공통코드 정보 업데이트 일자를 리턴한다.
	* @return 회사별 공통코드 업데이트 일자
	*/
	func getCodeMastCorpUpdateDate() -> Int64?	{ return UserDefaults.standard.object(forKey: "codeMastCorpUpdateDate") as? Int64 }
	
	
	/**
	* 회사별 공통코드 상세 정보 업데이트 일자를 리턴한다.
	* @return 회사별 공통코드 상세 업데이트 일자
	*/
	func getCodeDetailCorpUpdateDate() -> Int64?	{ return UserDefaults.standard.object(forKey: "codeDetailCorpUpdateDate") as? Int64 }
	
	/**
	* 장치 정보 업데이트 일자를 리턴한다.
	* @return 장치정보 업데이트 일자
	*/
	func getUnitInfoUpdateDate() -> Int64?		{ return UserDefaults.standard.object(forKey: "unitInfoUpdateDate") as? Int64 }
	
	/**
	* 자산 정보 업데이트 일자를 리턴한다.
	* @return 자산정보 업데이트 일자
	*/
	func getAssetInfoUpdateDate() -> Int64?		{ return UserDefaults.standard.object(forKey: "assetInfoUpdateDate") as? Int64 }
	
	
	/**
	* 고객사 정보 업데이트 일자를 리턴한다.
	* @return 고객사 정보 업데이트 일자
	*/
	func getCustMastUpdateDate() -> Int64?		{ return UserDefaults.standard.object(forKey: "custMastUpdateDate") as? Int64 }
	
	
	
	/**
	* 날짜 검색 구간을 리턴한다.
	* @return 날짜 검색 구간
	*/
	func getDateDistance() -> Int		{ return UserDefaults.standard.integer(forKey: "dateDistance") ?? Constants.DATE_SEARCH_DISTANCE }
	
	
	/**
	* 입고자동승인여부를 리턴한다.
	* @return 입고자동승인여부
	*/
	func getInAgreeYn() -> String?		{ return UserDefaults.standard.string(forKey: "inAgreeYn") }
	
	
	
	
	/**
	* 자동로그인 여부를 설정한다.
	* @param boolAutoLogin 자동로그인 여부
	*/
	func setAutoLogin(boolAutoLogin : Bool)
	{
		UserDefaults.standard.set(boolAutoLogin, forKey: "autoLogin")
	}
	
	/**
	* 회사ID를 설정한다.
	* @param strCorpId 회사ID
	*/
	func setCorpId(strCorpId : String)
	{
		UserDefaults.standard.set(strCorpId, forKey: "corpId")
	}
	
	/**
	* 회사구분을 설정한다.
	* @param strCorpType 회사구분
	*/
	func setCorpType(strCorpType : String)
	{
		UserDefaults.standard.set(strCorpType, forKey: "corpType")
	}
	
	/**
	* 사용자ID를 설정한다.
	* @param strUserId 사용자ID
	*/
	func setUserId(strUserId : String)
	{
		UserDefaults.standard.set(strUserId, forKey: "userId")
	}
	
	/**
	* 사용자명을 설정한다.
	* @param strUserName 사용자명
	*/
	func setUserName(strUserName : String)
	{
		UserDefaults.standard.set(strUserName, forKey: "userName")
	}
	
	/**
	* 패스워드를 설정한다.
	* @param strPassword 패스워드
	*/
	func setPassword(strPassword : String)
	{
		UserDefaults.standard.set(strPassword, forKey: "password")
	}
	
	
	/**
	* 고객사ID를 설정한다.
	* @param strCustId 고객사ID
	*/
	func setCustId(strCustId : String)
	{
		UserDefaults.standard.set(strCustId, forKey: "custId")
	}
	
	
	/**
	* 고객사구분을 설정한다.
	* @param strCustType 고객사구분
	*/
	func setCustType(strCustType : String)
	{
		UserDefaults.standard.set(strCustType, forKey: "custType")
	}
	
	/**
	* 사용자 암호화 ID를 설정한다.
	* @param strEncryptId 사용자 암호화 ID
	*/
	func setEncryptId(strEncryptId : String)
	{
		UserDefaults.standard.set(strEncryptId, forKey: "encryptId")
	}
	
	/**
	* 버전을 설정한다.
	* @param intVersion 버전
	*/
	func setVersion(intVersion : Int)
	{
		UserDefaults.standard.set(intVersion, forKey: "version")
	}
	
	/**
	* 푸시사용여부를 설정한다.
	* @param strPushUseYn 푸시사용여부
	*/
	func setPushUseYn(strPushUseYn : String)
	{
		UserDefaults.standard.set(strPushUseYn, forKey: "pushUseYn")
	}
	
	/**
	* 이전로그인  회사ID를 설정한다.
	* @param strCorpId 이전로그인 회사ID
	*/
	func setPreCorpId(strCorpId : String)
	{
		UserDefaults.standard.set(strCorpId, forKey: "preCorpId")
	}
	
	/**
	* 이전로그인 사용자ID를 설정한다.
	* @param strPreUserId 이전로그인 사용자ID
	*/
	func setPreUserId(strPreUserId : String)
	{
		UserDefaults.standard.set(strPreUserId, forKey: "preUserId")
	}
	
	
	/**
	* 사용자 언어를 설정한다.
	* @param strUserLang 사용자 언어
	*/
	func setUserLang(strUserLang : String)
	{
		UserDefaults.standard.set(strUserLang, forKey: "userLang")
	}
	
	
	/**
	* 장치ID를 설정한다.
	* @param strUnitId 장치ID
	*/
	func setUnitId(strUnitId : String)
	{
		UserDefaults.standard.set(strUnitId, forKey: "unitId")
	}
	
	
	/**
	* 이벤트코드 설정한다.
	* @param strEventCode 이벤트코드
	*/
	func setEventCode(strEventCode : String)
	{
		UserDefaults.standard.set(strEventCode, forKey: "eventCode")
	}
	
	/**
	* 거점ID를 설정한다.
	* @param strBranchId 거점ID
	*/
	func setBranchId(strBranchId : String)
	{
		UserDefaults.standard.set(strBranchId, forKey: "branchId")
	}
	
	/**
	* 거점명를 설정한다.
	* @param strBranchName 거점명
	*/
	func setBranchName(strBranchName : String)
	{
		UserDefaults.standard.set(strBranchName, forKey: "branchName")
	}
	
	
	/**
	* 거점고객사ID를 설정한다.
	* @param strBranchCustId 거점고객사ID
	*/
	func setBranchCustId(strBranchCustId : String)
	{
		UserDefaults.standard.set(strBranchCustId, forKey: "branchCustId")
	}
	
	/**
	* 거점고객사명를 설정한다.
	* @param strBranchCustName 거점고객사명
	*/
	func setBranchCustName(strBranchCustName : String)
	{
		UserDefaults.standard.set(strBranchCustName, forKey: "branchCustName")
	}
	
	
	/**
	* 상위고객사ID를 설정한다.
	* @param strParentCustId 상위고객사ID
	*/
	func setParentCustId(strParentCustId : String)
	{
		UserDefaults.standard.set(strParentCustId, forKey: "parentCustId")
	}
	
	
	/**
	* 거점의 고객사구분을 설정한다.
	* @param strBranchCustType 거점의 고객사구분
	*/
	func setBranchCustType(strBranchCustType : String)
	{
		UserDefaults.standard.set(strBranchCustType, forKey: "branchCustType")
	}
	
	/**
	* 공통코드정보 업데이트일자를 설정한다.
	* @param lngCodeMastUpdtDate 공통코드정보 업데이트일자
	*/
	func setCodeMastUpdateDate(lngCodeMastUpdtDate : Int64)
	{
		UserDefaults.standard.set(lngCodeMastUpdtDate, forKey: "codeMastUpdateDate")
	}
	
	/**
	* 공통코드상세정보 업데이트일자를 설정한다.
	* @param lngCodeDetailUpdtDate 공통코드상세정보 업데이트일자
	*/
	func setCodeDetailUpdateDate(lngCodeDetailUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngCodeDetailUpdtDate, forKey: "codeDetailUpdateDate")
	}
	
	/**
	* 회사별 공통코드정보 업데이트일자를 설정한다.
	* @param lngCodeMastCorpUpdtDate 회사별 공통코드정보 업데이트일자
	*/
	func setCodeMastCorpUpdateDate(lngCodeMastCorpUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngCodeMastCorpUpdtDate, forKey: "codeMastCorpUpdateDate")
	}
	
	/**
	* 회사별 공통코드상세정보 업데이트일자를 설정한다.
	* @param lngCodeDetailCorpUpdtDate 회사별 공통코드상세정보 업데이트일자
	*/
	func setCodeDetailCorpUpdateDate(lngCodeDetailCorpUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngCodeDetailCorpUpdtDate, forKey: "codeDetailCorpUpdateDate")
	}
	
	
	/**
	* 장치정보 업데이트일자를 설정한다.
	* @param lngUnitInfoUpdtDate 장치정보 업데이트일자
	*/
	func setUnitInfoUpdateDate(lngUnitInfoUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngUnitInfoUpdtDate, forKey: "unitInfoUpdateDate")
	}
	
	/**
	* 자산정보 업데이트일자를 설정한다.
	* @param lngAssetInfoUpdtDate 자산정보 업데이트일자
	*/
	func setAssetInfoUpdateDate(lngAssetInfoUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngAssetInfoUpdtDate, forKey: "assetInfoUpdateDate")
	}
	
	/**
	* 고객사 정보 업데이트일자를 설정한다.
	* @param lngCustMastUpdtDate 자산정보 업데이트일자
	*/
	func setCustMastUpdateDate(lngCustMastUpdtDate: Int64)
	{
		UserDefaults.standard.set(lngCustMastUpdtDate, forKey: "custMastUpdateDate")
	}
	
	/**
	* 날짜 검색 구간을 설정한다.
	* @param intDateDistance 날짜 검색 구간
	*/
	func setDateDistance(intDateDistance : Int)
	{
		UserDefaults.standard.set(intDateDistance, forKey: "dateDistance")
	}
	
	
	/**
	* 입고자동승인여부를 설정한다.
	* @param strInAgreeYn 입고자동승인여부
	*/
	func setInAgreeYn(strInAgreeYn : String)
	{
		UserDefaults.standard.set(strInAgreeYn, forKey: "inAgreeYn")
	}	
}
