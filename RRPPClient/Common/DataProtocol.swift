//
//  DataProtocol.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 22..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

struct ReturnData
{
	let returnType : String
	let returnCode : String?
	let returnMesage : String?
	let returnRawData : NSObject?
}

protocol DataProtocol
{
	func recvData(returnData : ReturnData)
}
