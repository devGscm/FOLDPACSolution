//
//  RfidSwing.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

//public class RfidSwing :  NSObject, SwingDelegate, SwingProtocol


//protocol :  SwingProtocolProtocol
//{
//	 func Swing_didDiscoverDevice(_ dev: SwingDevice!) {
//		print("Swing_didDiscoverDevice!!!")
//	}
//
//	 func Swing_didconnectedDevice(_ dev: SwingDevice!) {
//		print("Swing_didconnectedDevice!!!")
//	}
//
//	 func Swing_readyToCommunicate(_ dev: SwingDevice!) {
//
//		print("Swing_readyToCommunicate!!!")
//	}
//
//	 func Swing_didDisconnectDevice(_ dev: SwingDevice!) {
//		print("Swing_didDisconnectDevice!!!")
//
//	}
//
//}

//public class RfidSwing :  NSObject, SwingProtocolProtocol
public class RfidSwing :  NSObject 
{
	static var originRfidSwin = RfidSwing()
	//var gameTimer: Timer!
	
	var tagLists : [String]
	
	override init()
	{
		self.tagLists = [String]()
		super.init()
		print("init");
		
		//self.gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
		//super.init()
	}
	
	///테스트를 위하여 Timer 구현
//	@objc public func runTimedCode(){
//		print("Log View Timer Start !!!")
//		var intCount = 0
//		for tagId in tagLists
//		{
//			print(" Count:\(intCount), tagId:\(tagId)")
//		}
//	}
	
//	public func readerStatus() -> Bool {
//		print("readerStatus")
//		return true
//	}
//
//	public func reciveData(_ result: String!) {
//		print("reciveData")
//	}
//
//		//static var orgRfidSwing : RfidSwing!
//
//	public func swing_didDiscover(_ dev: SwingDevice!) {
//		print("######3Swing_didDiscoverDevice!!!")
//		print("name: \(dev.name!), identifier \(dev.identifier!) ")
//
//		//알고있는 스윙단말기 일경우 연결을 시도한다.
//		if(dev.name == "SwingU" && dev.identifier == "D32F0010-8DB8-856F-A8DF-85B3D00CF26A")
//		{
//			if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
//			{
//				swing.swingapi.stop()
//				swing.swingapi.connect(to:  dev!)
//			}
//		}
//	}
//
//	public func swing_didconnectedDevice(_ dev: SwingDevice!) {
//			print("Swing_didconnectedDevice!!!")
//	}
//
//	public func swing_ready(toCommunicate dev: SwingDevice!) {
//			print("Swing_readyToCommunicate!!!")
//
//		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
//		{
//			swing.swingapi.clear()
//
//			//스윙이 연결되어 있다면
//			if( swing.isSwingrederConnected() == true)
//			{
//				//소스와 비슷하게 리더기설정
//				swing.swing_set_inventory_mode(0)
//				swing.swing_clear_inventory()
//				//태그를 읽기 시작한다
//				swing.swing_readStart()
//			}
//		}
//
////		DispatchQueue.global().async {
////			DispatchQueue.main.async(execute: {
////				var intTimeCount = 0
////				while(intTimeCount <= 20)
////				{
////					sleep(2000)
////					print("Log View Timer Start !!!")
////					var intCount = 0
////					for tagId in self.tagLists
////					{
////						print(" Count:\(intCount), tagId:\(tagId)")
////						intCount += 1
////					}
////					intTimeCount += 1
////				}
////			})
////		}
//
//
//	}
//
//	public func swing_didDisconnectDevice(_ dev: SwingDevice!) {
//		print("Swing_didDisconnectDevice!!!")
//	}
//
//	public func doConnectRfid() -> Void
//	{
//		//weak var swing : SwingProtocol?  = SwingProtocol.sharedInstace() as! SwingProtocol
//		if let swing : SwingProtocol  = SwingProtocol.sharedInstace() as? SwingProtocol
//		{
//			swing.delegate = RfidSwing.originRfidSwin as SwingProtocolProtocol
//			//연결할 리더기를 찾는다
//			swing.swingapi.scan()
//		}
//
////		DispatchQueue.global().async {
////			DispatchQueue.main.async(execute: {
////				var intTimeCount = 0
////				while(intTimeCount <= 20)
////				{
////					sleep(2000)
////					print("Log View Timer Start !!!")
////					var intCount = 0
////					for tagId in self.tagLists
////					{
////						print(" Count:\(intCount), tagId:\(tagId)")
////						intCount += 1
////					}
////					intTimeCount += 1
////				}
////			})
////		}
//	}
//
//	public func swing_Response_TagList(_ value: String!) {
//		var trimedData = value.trimmingCharacters(in: .whitespacesAndNewlines)
//		trimedData = trimedData.replacingOccurrences(of: ">T", with: "")
//		trimedData = trimedData.replacingOccurrences(of: ">J", with: "")
//		//print("##########Read TagID: \(trimedData)")
//
//		if(tagLists.contains(trimedData) == false)
//		{
//			tagLists.append(trimedData)
//		}
//
//		var intCount = 0
//		if (self.tagLists.count >= 5 )
//		{
//			for tagId in self.tagLists
//			{
//				print(" Count:\(intCount), tagId:\(tagId)")
//				intCount += 1
//			}
//		}
//	}
}

