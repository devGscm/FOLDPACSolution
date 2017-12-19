//
//  SwingReader.swift
//   RRPPClient
//
//  Created by redmoon on 2017. 12. 1..
//  Copyright © 2017년 redmoon. All rights reserved.
//

import Foundation

public class AT288Reader : NSObject, ReaderProtocol 
{
	let atReder : SwingProtocol
	let identifier : String
	let delegate : ReaderResponseDelegate?
	let viewControl : BaseViewController
	
	required public init(viewControl: BaseViewController, deviceId : String ,  delegate : ReaderResponseDelegate?)
	{
		self.viewControl = viewControl
		self.atReder = SwingProtocol.sharedInstace() as! SwingProtocol
		self.identifier = deviceId
		self.delegate = delegate
		super.init()
	}
		
	func connect() {
		print("at288  connect")
	}
	
	func close() {
		print("at288  close")
	}
	
	func startRead() {
		print("at288  startRead")
	}
	
	func stopRead() {
		print("at288  stopRead")
	}
	
	func isConnected() -> Bool {
		print("at288  isConnected")
		return false
	}
	
	func initReader() {
		print("at288  initReader")
	}
	
	////////////////////////////////////////////////////////////////////////////
	/// 여기서 부터 delegate Protocol 구현
	////////////////////////////////////////////////////////////////////////////
	}


