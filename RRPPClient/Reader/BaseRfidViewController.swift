//
//  BaseRfidViewController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

struct RederDevInfo {
	var id : String
	var name : String
}

/// 지원되는 리더기 종류(현재 SWING만 지원)
enum ReaderType {
	case SWING
	case AT288
}

/// 리더기 공통 응답프로토콜 선언
@objc
public protocol ReaderResponseDelegate : class {
	func didReadTagList( _ tagId : String)
	
	 @objc optional func didReaderConnected()
	
	 @objc optional func didReaderDisConnected()	
}

/// 리더기 공통 프로토콜 선언
@objc
protocol ReaderProtocol : class {
	
	/// 초기화 는 항상 리더기 식별자와 이벤트를 전파할 delegate로 한다
	init(deviceId : String ,  delegate : ReaderResponseDelegate?)
	
	/**
	* 리더기를 체크한다. (블루투스 가능여부도 판단)
	*/
	func checkReader()
	
	/**
	* 리더기에 연결한다.
	*/
	func connect()
	
	/**
	* 리더기에서 연결을 종료한다.
	*/
	func close()
	
	/**
	* 읽기를 시작한다.
	*/
	func startRead()
	
	/**
	* 읽기를 종료한다.
	*/
	func stopRead()
	
	/**
	* 연결되었는지 여부를 리턴한다.
	* @return 연결되었는지여부
	*/
	func isConnected() -> Bool
	
	/**
	* 리더기 초기화
	*/
	func initReader()
	
	
	////////////////////////////////////////////////////
	// 여기서 부터 optional protocol 설정
	////////////////////////////////////////////////////
	/**
	* 인벤토리 모드를 설정한다.
	* @param intMode 모드
	*/
	@objc optional  func setInventoryMode(_ mode: Int)
	
	/**
	* 인벤토리를 초기화한다.
	*/
	@objc optional func clearInventory()
	
	
	/**
	* 리더기 소멸
	*/
	@objc optional func  destroyReader()
	
	/**
	* 리더기 볼륨 컨트롤 - 스윙센서
	* @return boolean
	*/
	@objc optional func setReaderVolumeControl(mode: Int,  level: Int) -> Bool
	
	/**
	* 리더기 RF파워를 리턴한다.
	*/
	@objc optional func getRFPowerControl() -> Int
	
	/**
	* 리더기 RF파워 컨트롤 - 스윙센서
	*/
	@objc optional func  setRFPowerControl(_ attenuation : Int)
	
//	/**
//	* 센서태그의 UID를 리턴한다
//	*/
//	String getRFIDTagUid();
//
//	/**
//	* 센서태그의 데이터를 리턴한다
//	*/
//	String getRFIDTagData();
	
	/**
	* 리더기 볼륨 컨트롤 - 스윙센서
	* @return boolean
	*/
	@objc optional func   readerTempDataSync(_ blLarge_memory : Bool)
	
	/**
	* 리더기 모드 컨트롤 - 스윙센서
	* @return boolean
	*/
	@objc optional func   setReaderModeControl(_ mode : Int);
	
	/**
	* 리더기의 태그리포트[A],[N]모드를 컨트롤한다.
	* @return boolean
	*/
	@objc optional func  setTagReportModeControl(_ mode : Int)
	
	/**
	* 리더기의 모드변경(RFID/QR코드)에 대한 비프음
	*/
	@objc optional func playBeepReadModeChange()
	
//	/**
//	* 리더기 연결여부 확인
//	*/
//	boolean isReaderConnected();
//	
}


/// BaseRfidViewController 클래스 구현시작
class BaseRfidViewController : BaseViewController
{
	var arrAssetInfo	: Array<AssetInfo> = Array<AssetInfo>()
	var arrProcMsgInfo	: Array<CodeInfo> = Array<CodeInfo>()
	var arrSaleType		: Array<CodeInfo> = Array<CodeInfo>()
	var arrReSaleType	: Array<CodeInfo> = Array<CodeInfo>()
	
	//해당 클레스를 참조하는 서브클래스에서 이벤트 수신을 위하여
	//응답 프로토클을 정의 기존 네톰에서 정의한 이벤트를 수신하면
	//해당 프로토콜의 정의한 이벤트로 다시 재전송 즉  네톰이벤트 ---> 신규정의이벤트
	weak var delegateReder: ReaderResponseDelegate?
	var reader : ReaderProtocol?
	
	func initRfid(_ type : ReaderType, id : String,	delegateReder : ReaderResponseDelegate?)
	{
		super.initController()
		switch type
		{
			case .SWING :
				self.reader = SwingReader(deviceId : id ,  delegate: delegateReder)
			
			case .AT288 :
				self.reader = AT288Reader(deviceId : id ,  delegate: delegateReder)
		}
		
		//자산코드 및 기타 공통코드를 LocalDB에서 가져옮
		initCodeInfo()
	}
	
	func destoryRfid()
	{
		super.releaseController()
	}
	
	func initCodeInfo()
	{
		print("=======================================")
		print("*BaseRfidViewController.initCodeInfo")
		print("=======================================")
		arrAssetInfo	= LocalData.shared.getAssetInfo(searchValue: nil)
		arrProcMsgInfo	= LocalData.shared.getCodeDetail(fieldValue: "DB_PROC_MSG", initCodeName: nil)
		arrSaleType		= LocalData.shared.getCodeDetail(fieldValue: "SALE_TYPE", initCodeName: nil)
		arrReSaleType	= LocalData.shared.getCodeDetail(fieldValue: "RESALE_TYPE", initCodeName: nil)
		
		var intDataDistance = Constants.DATE_SEARCH_DISTANCE
		
		var arrDataDistance: Array<CodeInfo> = LocalData.shared.getCodeDetail(fieldValue: "DATE_SEARCH", initCodeName: nil)
		if(arrDataDistance.count > 0)
		{
			let clsInfo = arrDataDistance[0]
			if(clsInfo.commCode.isEmpty == false)
			{
				intDataDistance = Int(clsInfo.commCode)!
				print("@@@@@@@@@ intDatadisance:\(intDataDistance)")
				AppContext.sharedManager.getUserInfo().setDateDistance(dateDistance: intDataDistance)
			}
		}
	}
	
	func releaseCodeInfo()
	{
		arrAssetInfo.removeAll()
		arrProcMsgInfo.removeAll()
		arrSaleType.removeAll()
		arrReSaleType.removeAll()		
	}
	
	func getAssetName(strAsset : String) -> String
	{
		var strAssetName  = ""
		if(arrAssetInfo.isEmpty == false)
		{
			for clsAssetInfo in arrAssetInfo
			{
				print("----- asetEpc:\(clsAssetInfo.assetEpc)")
				if(clsAssetInfo.assetEpc == strAsset)
				{
					strAssetName = clsAssetInfo.assetName
					print("----- strAssetName:\(strAssetName)")
					break;
				}
			}
		}
		return strAssetName
	}
	
	func getAssetList() -> Array<AssetInfo>
	{
		return arrAssetInfo
	}
	
	//접속가능한 Reader기를 찾기를 시작한다
	func checkReader()
	{
		self.reader!.checkReader()
	}
	
	
	func isConnected() -> Bool
	{
		return self.reader!.isConnected()
	}
	
	func readerConnect()
	{
		self.reader!.connect()
	}
	
	func readerDisConnect()
	{
		self.reader!.close()
	}
	
	func startRead()
	{
		self.reader!.startRead()
	}
	
	func stopRead()
	{
		self.reader!.stopRead()
	}
}
