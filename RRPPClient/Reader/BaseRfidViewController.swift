//
//  BaseRfidViewController.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

//UserDefaults 에 넣기 위하여  구조체대신 클래스 Array로 선언
//또한 NSCoding 에대한 프로토콜을 구현해야 된다.
public class ReaderDevInfo: NSObject, NSCoding {
	let id: String
	let name: String
	let macAddr : String
	
	public init(id : String, name: String, macAddr: String) {
		self.id = id
		self.name = name
		self.macAddr = macAddr
	}
	public required init(coder decoder: NSCoder) {
		self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
		self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
		self.macAddr = decoder.decodeObject(forKey: "macAddr")  as? String ?? ""
	}
	
	public func encode(with coder: NSCoder) {
		coder.encode(id, forKey: "id")
		coder.encode(name, forKey: "name")
		coder.encode(macAddr, forKey: "macAddr")
	}
}

/// 지원되는 리더기 종류(현재 SWING만 지원)
public enum ReaderType : Int
{
	case SWING = 0
	case AT288 = 1
	public var description: String
	{
		if (self.rawValue == 0)
		{
			return "Swing"
		}		
		return "AT288"
	}
}

public enum ReaderSenssorMode : Int
{
	case RFID = 0
	case BARCODE = 2
}


/// 리더기 공통 응답프로토콜 선언
@objc
public protocol ReaderResponseDelegate : class {
	
	// 자체적으로 이벤트를 구조체나 클래스로 (TagInfo) 넘겨주고 싶었으나
	//objc optional 을 사용하는 경우는 일반타입만 가능하고 구조체나 클래스로 넘겨줄 수가 없음
	func didReadTagid( _ tagid : String)
	
	 @objc optional func didReadBarcode(_ barcode: String)
	
	 @objc optional func didReaderConnected()
	
	 @objc optional func didReaderDisConnected()
	
	///optional로 프로토콜 설계시 구조체 파라메터를 사용할 수 없다.
	@objc optional func didReaderScanList(id:String, name: String, macAddr: String)
	
}

/// 리더기 공통 프로토콜 선언
@objc
protocol ReaderProtocol : class {
	
	/// 초기화 는 항상 리더기 식별자와 이벤트를 전파할 delegate로 한다
	init(deviceId : String ,  delegate : ReaderResponseDelegate?)
	
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
	* 연결가능 리더기 스켄 시작
	*/
	@objc optional  func startReaderScan()
	
	/**
	* 연결가능 리더기 스켄 종료
	*/
	@objc optional  func stopReaderScan()
	
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
	* 리더기 모드 컨트롤 - 스윙센서 (RFID/바코드 구분)
	* @return boolean
	*/
	@objc optional func setReaderModeControl(_ mode : Int)
	
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
	weak var mDelegateResponse: ReaderResponseDelegate?
	var mClsReader : ReaderProtocol?
		
	override func viewDidAppear(_ animated: Bool)
	{
		
		if (AppContext.sharedManager.getUserInfo().getBranchId().isEmpty == true)
		{
			Dialog.show(container: self, title: nil, message: NSLocalizedString("rfid_no_selected_bluetooth_select_config", comment: "선택된 블루투스 장비가 없습니다."))
			
			let clsController: ClientConfig = {
				return UIStoryboard.viewController(storyBoardName: "Config", identifier: "ClientConfig") as! ClientConfig
			}()
			self.toolbarController?.transition(to: clsController, completion:	nil)
			return
		}
		
		guard let devId  = AppContext.sharedManager.getUserInfo().getReaderDevId()
			else
		{
			Dialog.show(container: self, title: nil, message: NSLocalizedString("rfid_no_selected_bluetooth_select_config", comment: "선택된 블루투스 장비가 없습니다."))
			
			let clsController: ClientConfig = {
				return UIStoryboard.viewController(storyBoardName: "Config", identifier: "ClientConfig") as! ClientConfig
			}()
			self.toolbarController?.transition(to: clsController, completion:	nil)
			return
		}
		let readerType  = AppContext.sharedManager.getUserInfo().getReaderType() as ReaderType
		
		switch readerType
		{
			case .SWING :
				self.mClsReader = SwingReader(deviceId : devId ,  delegate: mDelegateResponse)
			
			case .AT288 :
				self.mClsReader = AT288Reader(deviceId : devId ,  delegate: mDelegateResponse)
		}
	}
	
	func initRfid(_ delegateReder : ReaderResponseDelegate?)
	{
		//자산코드 및 기타 공통코드를 LocalDB에서 가져옮
		initCodeInfo()
		mDelegateResponse = delegateReder
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
	
	func getAssetName(assetEpc : String) -> String
	{
		var strAssetName  = ""
		if(arrAssetInfo.isEmpty == false)
		{
			for clsAssetInfo in arrAssetInfo
			{
				print("----- asetEpc:\(clsAssetInfo.assetEpc)")
				if(clsAssetInfo.assetEpc == assetEpc)
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
	
	func getProcMsgName( userLang: String, commCode: String) -> String
	{
		var strProcMsgName = ""
		for clsInfo in arrProcMsgInfo
		{
			if(clsInfo.commCode == commCode)
			{
				if(Constants.USER_LANG_CH == userLang)
				{
					strProcMsgName = clsInfo.commNameCh
				}
				else if(Constants.USER_LANG_EN == userLang)
				{
					strProcMsgName = clsInfo.commNameEn
				}
				else
				{
					strProcMsgName = clsInfo.commNameKr
				}
				break
			}
		}
		return strProcMsgName
	}
	
	func getSaleTypeName(userLang: String, commCode: String) -> String
	{
		var strSaleTypeName = ""
		for clsInfo in arrSaleType
		{
			if(clsInfo.commCode == commCode)
			{
				if(Constants.USER_LANG_CH == userLang)
				{
					strSaleTypeName = clsInfo.commNameCh
				}
				else if(Constants.USER_LANG_EN == userLang)
				{
					strSaleTypeName = clsInfo.commNameEn
				}
				else
				{
					strSaleTypeName = clsInfo.commNameKr
				}
				break
			}
		}
		return strSaleTypeName
	}
	
	func getReSaleTypeName(userLang: String, commCode: String) -> String
	{
		var strReSaleTypeName = ""
		for clsInfo in arrReSaleType
		{
			if(clsInfo.commCode == commCode)
			{
				if(Constants.USER_LANG_CH == userLang)
				{
					strReSaleTypeName = clsInfo.commNameCh
				}
				else if(Constants.USER_LANG_EN == userLang)
				{
					strReSaleTypeName = clsInfo.commNameEn
				}
				else
				{
					strReSaleTypeName = clsInfo.commNameKr
				}
				break
			}
		}
		return strReSaleTypeName
	}
	

	//접속가능한 Reader기를 찾기를 시작한다
	func startReaderScan()
	{
		self.mClsReader?.startReaderScan?()
	}
	
	
	func isConnected() -> Bool
	{
		if let bIsConnect = self.mClsReader?.isConnected()
		{
			return bIsConnect
		}
		return false
	}
	
	func readerConnect()
	{
		self.mClsReader?.connect()
	}
	
	func readerDisConnect()
	{
		self.mClsReader?.close()
	}
	
	func startRead()
	{
		self.mClsReader?.startRead()
	}
	
	func stopRead()
	{
		self.mClsReader?.stopRead()
	}
	
	
	/// 리더기 바코드 / RFID 모드설정
	///
	/// - Parameter mode: <#mode description#>
	func setRederMode(_ mode: ReaderSenssorMode)
	{
		self.mClsReader?.setReaderModeControl?(mode.rawValue)
	}
}
