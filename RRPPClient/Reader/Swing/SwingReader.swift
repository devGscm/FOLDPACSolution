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
	
	private var timeoutMonitor : Timer? /// Timeout 연결 모니터링
	
	required public init(deviceId : String ,  delegate : ReaderResponseDelegate?)
	{
		self.swing = SwingProtocol.sharedInstace() as! SwingProtocol
		
		//리더기 스켄을 멈춤
		swing.swingapi.stop()
		
		self.identifier = deviceId
		self.delegate = delegate
		super.init()
		self.swing.delegate = self as SwingProtocolProtocol
	}
	
	func connect() {
		let dev : SwingDevice = SwingDevice()
		dev.identifier = self.identifier
		
		//Android 소스에서 퍼포먼스 향상을 위해 스켄을 멈춤
		//실제로 Android처럼 하면 리더기가 종료되었다가 연결할 경우 잘안되어서
		//stop 처리를 안함
		//swing.swingapi.stop()
		
		//연결여부 체크후, 연결이안되어 있을경우 연결하려고 하였으나
		//내부적인 연결여부 isSwingrederConnected() 가 재대로 처리
		//안되는것 같다 따라서 무조건 연결처리
		//print("스윙연결요청 !!!")
		self.swing.swingapi.connect(to:  dev)
		
		//타이머를 생성시켜 5초동안 연결아 안되어 있을경우 이벤트를 발생
		timeoutMonitor = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.connectTimeout(_:)), userInfo: nil, repeats: false)
	}
	
	@objc func connectTimeout(_ timer : Timer) {
		if(swing.isSwingrederConnected() == false) {
			timeoutMonitor?.invalidate()
			timeoutMonitor = nil
			self.delegate?.didRederConnectTimeOver?()
		}
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
	
	func startReaderScan()
	{
		self.swing.swingapi.scan()
	}
	
	func stopReaderScan()
	{
		self.swing.swingapi.stop()
	}
	
	// Rfid/Barcode 모드변경
	// 리더기의 읽기를 종료해야 정상적으로 바뀜
	func setReaderModeControl(_ mode : Int)
	{
		if(self.swing.isSwingrederConnected())
		{
			//리더기 읽기를 종료해야
			swing.swing_readStop()
			swing.swing_setReadMode(mode)
		}
	}
	
	func clearInventory()
	{
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
		 trimedData = trimedData.replacingOccurrences(of: "\0", with: "")
		
		if(trimedData.hasPrefix(">T"))		//태그일 경우 didReadTagid 이벤트를 발생
		{
			//trimedData = trimedData.replacingOccurrences(of: ">T", with: "")
			let indexStartOfText = trimedData.index(trimedData.startIndex, offsetBy: 6)   // ">T3000" 를 제거
			let result = trimedData[indexStartOfText...]
			self.delegate?.didReadTagid(String(result) )
		}
		else if(trimedData.hasPrefix(">J"))	//Barcode일경우 didReadBarcode 이벤트를 발생
		{
			trimedData = trimedData.replacingOccurrences(of: ">J", with: "")
			self.delegate?.didReadBarcode?(trimedData)
		}
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
		self.delegate?.didReaderScanList?(id: dev.identifier, name: dev.name, macAddr: dev.macaddress)
	}
	
	
	/// 네톰에서 구현을 안함 즉  Swing_readyToCommunicate가 호출이 되지 않음
	/// - Parameter dev: <#dev description#>
	public func swing_didconnectedDevice(_ dev: SwingDevice!) {
		print("Swing_didconnectedDevice!!!")
	}
	
	public func swing_ready ( toCommunicate dev: SwingDevice!)
	{
		print("Swing_readyToCommunicate!!!")
		//설정된 타이머가 있을경우
		if let connectTimer =  timeoutMonitor
		{
			connectTimer.invalidate()
			timeoutMonitor = nil
		}
		
		//연결이 되면 바로 리더기를 읽을 수 있도록 초기화
		//소스와 비슷하게 리더기설정
		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
		{
			swing.swing_set_inventory_mode(0)
			swing.swing_clear_inventory()
			swing.swing_readStop()			
			self.delegate?.didReaderConnected?()
		}
	}	
	
	/// 리더기 연결종료, 리더기에서도 연결종료를 시키면 해당 이벤트가 발생
	///
	/// - Parameter dev: <#dev description#>
	public func swing_didDisconnectDevice(_ dev: SwingDevice!) {
		print("Swing_didDisconnectDevice!!!")
		self.delegate?.didReaderDisConnected?()
	}
}

