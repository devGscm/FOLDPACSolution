//
//  SwingReader.swift
//   RRPPClient
//
//  Created by redmoon on 2017. 12. 1..
//  Copyright © 2017년 redmoon. All rights reserved.
//

import Foundation

public class SwingReader : NSObject, ReaderProtocol, SwingProtocolProtocol
{
	let swing : SwingProtocol
	let identifier : String
	let delegate : ReaderResponseDelegate?
	
	required public init(deviceId : String ,  delegate : ReaderResponseDelegate?)
	{
		self.swing = SwingProtocol.sharedInstace() as! SwingProtocol
		self.identifier = deviceId
		self.delegate = delegate
		super.init()
		
		self.swing.delegate = self as SwingProtocolProtocol
		
	}
	
	func checkReader() {
		self.swing.swingapi.scan()
	}
	
	
	
	func connect() {
		let dev : SwingDevice = SwingDevice()
		//dev.identifier = "D32F0010-8DB8-856F-A8DF-85B3D00CF26A"
		dev.identifier = self.identifier
		
		//Android 소스에서 퍼포먼스 향상을 위해 스켄을 멈춤
		swing.swingapi.stop()
		
		//연결여부 체크후, 연결이안되어 있을경우 연결하려고 하였으나
		//내부적인 연결여부 isSwingrederConnected() 가 재대로 처리
		//안되는것 같다 따라서 무조건 연결처리
		print("스윙연결요청 !!!")
		self.swing.swingapi.connect(to:  dev)
	}
	
	func close() {
		if(swing.isSwingrederConnected())
		{
			swing.swing_readStop()
			swing.swing_clear_inventory()
			
			//설정대기 시간을 줘야지 읽기 종료및 인벤토리 클리어가 제대로 된다.
			//2초간 delay
			sleep(2)
		}
		
		let dev : SwingDevice = SwingDevice()
		dev.identifier = self.identifier
		self.swing.swingapi.disconnect(to: dev)
	}
	
	func startRead() {
		if(swing.isSwingrederConnected())
		{
			//소스와 비슷하게 리더기설정
			self.swing.swing_clear_inventory()
			//태그를 읽기 시작한다
			swing.swing_readStart()
		}
	}
	
	func stopRead() {
		if(self.swing.isSwingrederConnected())
		{
			self.swing.swing_readStop()
		}
	}
	
	func isConnected() -> Bool {
		return self.swing.isSwingrederConnected()
	}
	
	func initReader() {
		if(self.swing.isSwingrederConnected())
		{
			swing.swing_readStop()
			swing.swing_clear_inventory()
		}
	}
	
	////////////////////////////////////////////////////////////////////////////
	/// 여기서 부터 Swing delegate Protocol 구현
	////////////////////////////////////////////////////////////////////////////
	
	
	public func swing_Response_TagList(_ value: String!) {
		var trimedData = value.trimmingCharacters(in: .whitespacesAndNewlines)
		trimedData = trimedData.replacingOccurrences(of: ">T", with: "")
		trimedData = trimedData.replacingOccurrences(of: ">J", with: "")
		self.delegate?.didReadTagList(trimedData )
		
	}
	
	public func readerStatus() -> Bool {
		print("readerStatus")
		return true
	}
	
	public func reciveData(_ result: String!) {
		print("reciveData")
	}
	
	public func swing_didDiscover(_ dev: SwingDevice!) {
		print("######Swing_didDiscoverDevice!!!")
	}
	
	
	/// 네톰에서 구현을 안함 즉  Swing_readyToCommunicate가 호출이 되지 않음
	/// - Parameter dev: <#dev description#>
	public func swing_didconnectedDevice(_ dev: SwingDevice!) {
		print("Swing_didconnectedDevice!!!")
	}
	
	public func swing_ready ( toCommunicate dev: SwingDevice!) {
		print("Swing_readyToCommunicate!!!")
		
		//연결이 되면 바로 리더기를 읽을 수 있도록 초기화
		//소스와 비슷하게 리더기설정
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			swing.swing_set_inventory_mode(0)
			swing.swing_clear_inventory()
			swing.swing_readStart()
			print("##############swing is connected \(swing.isSwingrederConnected())");
			
		}
		self.delegate?.didReaderConnected?()
	}
	
	
	/// 리더기 연결종료, 리더기에서도 연결종료를 시키면 해당 이벤트가 발생
	///
	/// - Parameter dev: <#dev description#>
	public func swing_didDisconnectDevice(_ dev: SwingDevice!) {
		print("Swing_didDisconnectDevice!!!")
		self.delegate?.didReaderDisConnected?()
	}
}

