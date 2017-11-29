//
//  BaseRfidViewController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

@objc
protocol ReaderResponseProtocol : class {
	func didReadTagList( _ tagId : String)
	
	 @objc optional func didReaderConnected()
	
	 @objc optional func didReaderDisConnected()	
}

class BaseRfidViewController : BaseViewController, SwingProtocolProtocol
{
	var arrAssetInfo	: Array<AssetInfo> = Array<AssetInfo>()
	var arrProcMsgInfo	: Array<CodeInfo> = Array<CodeInfo>()
	var arrSaleType		: Array<CodeInfo> = Array<CodeInfo>()
	var arrReSaleType	: Array<CodeInfo> = Array<CodeInfo>()
	
	weak var mDelegate: ReaderResponseProtocol?
	
	public var delegate: ReaderResponseProtocol? {
		set { self.mDelegate = newValue }
		get {return mDelegate }
	}
		
	func initRfid()
	{
		super.initController()
		initCodeInfo()
		
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			swing.delegate = self as SwingProtocolProtocol
		}
		
		//self.delegate? = self as! ReaderResponseProtocol
	}
	
	
	//접속가능한 Reader기를 찾기를 시작한다
	func startSearchConnectableReader()
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			swing.swingapi.scan()
		}
	}
	
	//접속가능한 Reader기를 찾기를 중지한다
	func stopSearchConnectableReader()
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			swing.swingapi.stop()
		}
	}
	
	func readerIsConnected() -> Bool
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			return swing.isSwingrederConnected()
		}
		return false
	}
	
	func readerConnect()
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			//TODO:: 환경설정에서 선택된 정보를 리더기를 가저온다
			let dev : SwingDevice = SwingDevice()
			dev.identifier = "D32F0010-8DB8-856F-A8DF-85B3D00CF26A"
			
			//연결여부 체크후, 연결이안되어 있을경우 연결하려고 하였으나
			//내부적인 연결여부 isSwingrederConnected() 가 재대로 처리
			//안되는것 같다 따라서 무조건 연결처리
			swing.swingapi.connect(to:  dev)
//			if(swing.isSwingrederConnected() == false)
//			{
//				//swing.swingapi.connect(to:  dev)
//			}
		}
	}
	
	func readerDisConnect()
	{
		//TODO:: 환경설정에서 선택된 정보를 리더기를 가저온다
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			if(swing.isSwingrederConnected())
			{
				let dev : SwingDevice = SwingDevice()
				dev.identifier = "D32F0010-8DB8-856F-A8DF-85B3D00CF26A"
				swing.swingapi.disconnect(to: dev)
			}
		}
	}
	
	func startRead()
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			if(swing.isSwingrederConnected())
			{
				//소스와 비슷하게 리더기설정
				swing.swing_set_inventory_mode(0)
				swing.swing_clear_inventory()
				//태그를 읽기 시작한다
				swing.swing_readStart()
			}
		}
	}
	
	func stopRead()
	{
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			if(swing.isSwingrederConnected())
			{
				swing.swing_readStop()
			}
		}
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
	
	///////////////////////////////////////
	/// 여기서부터 RFID Swing Reader Protocal Start
	////////////////////////////////////////
	public func swing_Response_TagList(_ value: String!) {
		var trimedData = value.trimmingCharacters(in: .whitespacesAndNewlines)
		trimedData = trimedData.replacingOccurrences(of: ">T", with: "")
		trimedData = trimedData.replacingOccurrences(of: ">J", with: "")
		self.mDelegate!.didReadTagList(trimedData )
	}
	
	public func readerStatus() -> Bool {
		print("readerStatus")
		return true
	}
	
	public func reciveData(_ result: String!) {
		print("reciveData")
	}
	
	public func swing_didDiscover(_ dev: SwingDevice!) {
		print("######3Swing_didDiscoverDevice!!!")
	}
	
	public func swing_didconnectedDevice(_ dev: SwingDevice!) {
		print("Swing_didconnectedDevice!!!")
	}
	
	public func swing_ready(toCommunicate dev: SwingDevice!) {
		print("Swing_readyToCommunicate!!!")
	}
	
	public func swing_didDisconnectDevice(_ dev: SwingDevice!) {
		print("Swing_didDisconnectDevice!!!")
	}
	


}
