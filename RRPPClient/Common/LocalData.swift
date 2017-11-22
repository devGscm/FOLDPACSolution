//
//  LocalData.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 11. 22..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import Mosaic
import SQLite

class LocalData {
	static let shared = LocalData()
	let dbPath : String
	var remoteDbEnncryptId: String?
	
	let mMobUpdateInfo : Table
	let mUcd : Expression<String>
	let mUdt : Expression<Int64>
	let mRef : Expression<Int64>
	
	let mCodeMast : Table
	let mFieldValue : Expression<String>
	let mFieldName : Expression<String>
	let mRemark : Expression<String?>
	
	let mCodeDetail : Table
	let mCommCode : Expression<String>
	let mCommNameKr : Expression<String?>
	let mCommNameEn : Expression<String?>
	let mCommNameCh : Expression<String?>
	let mCommRef1 : Expression<String?>
	let mCommRef2 : Expression<String?>
	let mCommRef3 : Expression<String?>
	let mCommOrder : Expression<Int64?>
	let mViewYn : Expression<String?>
	
	private init() {
		let currPath = NSSearchPathForDirectoriesInDomains(	.documentDirectory, .userDomainMask, true).first!
		self.dbPath = currPath + "/" + "rrppLocaldb.sqlite3"
		
		self.mMobUpdateInfo = Table("MOB_UPDATE_INFO")
		self.mUcd = Expression<String>("ucd")
		self.mUdt = Expression<Int64>("udt")
		self.mRef = Expression<Int64>("ref")
		
		self.mCodeMast = Table("CODE_MAST")
		self.mFieldValue = Expression<String>("fieldValue")
		self.mFieldName = Expression<String>("fieldName")
		self.mRemark = Expression<String?>("remark")
		
		self.mCodeDetail = Table("CODE_DETAIL")
		self.mCommCode = Expression<String>("commCode")
		self.mCommNameKr = Expression<String?>("commNameKr")
		self.mCommNameEn = Expression<String?>("commCodeEn")
		self.mCommNameCh = Expression<String?>("commCodeCh")
		self.mCommRef1 = Expression<String?>("commRef1")
		self.mCommRef2 = Expression<String?>("commRef2")
		self.mCommRef3 = Expression<String?>("commRef3")
		self.mCommOrder = Expression<Int64?>("commOrder")
		self.mViewYn = Expression<String?>("viewYn")
	}
	
	public var RemoteDbEnncryptId: String? {
		set { self.remoteDbEnncryptId = newValue }
		get {return remoteDbEnncryptId }
	}
	
	private func creatDb() -> Void
	{
		do {
			let db = try Connection(self.dbPath)
			
			//버전정보 업데이트 체크
			try db.run(mMobUpdateInfo.create(ifNotExists: false ) { table in
				table.column(mUcd, primaryKey: true)
				table.column(mUdt)
				table.column(mRef)
			})
			
			//공통코드 마스터
			try db.run(mCodeMast.create(ifNotExists: false ) { table in
				table.column(mFieldValue, primaryKey: true)
				table.column(mFieldName)
				table.column(mRemark)
			})
			
			//공통코드 디테일
			try db.run(mCodeDetail.create(ifNotExists: false ) { table in
				table.column(mFieldValue, primaryKey: true)
				table.column(mCommCode, primaryKey:true)
				table.column(mCommNameKr)
				table.column(mCommNameEn)
				table.column(mCommNameCh)
				table.column(mCommRef1)
				table.column(mCommRef2)
				table.column(mCommRef3)
				table.column(mCommOrder)
				table.column(mViewYn)
			})
			
		} catch {
			print("local table create exeption: \(error)")
		}
	}
	
	public func versionCheck(remoteDbUserInfo: String) -> Void
	{
		//if self.RemoteDbEnncryptId
		let dataClient = Mosaic.DataClient(url: Constants.WEB_SVC_URL)		
		dataClient.UserInfo = remoteDbUserInfo
		dataClient.UserData = "app.update.selectUpdateItemList"
		dataClient.removeServiceParam()
		dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
		dataClient.addServiceParam(paramName: "appId", value: "rrpp-client")
		dataClient.selectData(dataCompletionHandler:
			{ (data, error) in
				if let error = error {
					// 에러처리
					print(error)
					return
				}
				guard let dataTable = data else {
					print("에러 데이터가 없음")
					return
				}
				
				print("####결과값 처리")
				let dataColumns = dataTable.getDataColumns()
				let dataRows = dataTable.getDataRows()
				do
				{
					let db = try Connection(self.dbPath)
					for dataRow in dataRows
					{
						
						let updateCode = dataRow.getString(name:"ucd")!
						let updateDate = dataRow.getInt(name:"udt")!
						let ref = dataRow.getInt(name:"ref")!
						
						let count = try db.scalar(self.mMobUpdateInfo.filter(self.mUcd != updateCode ).count)
						if( count > 0 )
						{
							if let row = try db.pluck(self.mMobUpdateInfo)
							{
								print(" >>>>>>> localDb updateCode :" + row[self.mUcd])
							}
						}
						else
						{
							try db.run(self.mMobUpdateInfo.insert(self.mUcd <- updateCode, self.mUdt <- Int64(updateDate),
									   self.mRef <- Int64(ref)))
						}
					}
				} catch {
					print("local mobUpdateInfo fail: \(error)")
				}
		})

				
//			{ (data, error) in
//				if let error = error {
//					// 에러처리
//					print(error)
//					return
//				}
//				guard let dataTable = data else {
//					print("에러 데이터가 없음")
//					return
//				}
//
//				print("####결과값 처리")
//				let dataColumns = dataTable.getDataColumns()
//				let dataRows = dataTable.getDataRows()
//
//				do
//				{
//					let db = try Connection(self.dbPath)
//
//					for dataRow in dataRows
//					{
//
//						let updateCode = try dataRow.getString(name:"ucd")
//						let updateDate = try dataRow.getIntValue(name:"udt")
//						let ref = try dataRow.getIntValue(name:"ref")
//
//						let count = try db.scalar(mMobUpdateInfo.filter(mUcd != updateCode ).count)
//						if( count > 0 )
//						{
//
//						}
//						else
//						{
//							try db.run(users.insert(email <- "alice@mac.com", name <- "Alice"))
//						}
//					}
//				}
//		})
		
		
		
	}
	
	private func updateNewVersiion(upateCode: String, updateDate: Int, ref : Int, bIsInser : Bool ) -> Void
	{
		
	}
}

