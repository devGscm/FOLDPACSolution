//
//  LocalData.swift
//   RRPPClient
//
//  Created by MORAMCNT on 2017. 11. 22..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import Material
import Mosaic
import SQLite

struct CodeInfo {
	let corpId : String			/**< 회사ID **/
	let fieldValue : String		/**< 필드값 **/
	let commCode : String		/**< 공통코드 **/
	let commNameKr : String		/**< 공통코드명(한) **/
	let commNameEn : String		/**< 공통코드명(영) **/
	let commNameCh : String		/**< 공통코드명(중) **/
    let commNameJp : String     /**< 공통코드명(일) **/
	let commRef1 : String		/**< 참조값1 **/
	let commRef2 : String		/**< 참조값2 **/
	let commRef3 : String		/**< 참조값3 **/
	let remark : String			/**< 비고 **/
	let commOrder : Int			/**< 정렬순번 **/
	let viewYn	 : String		/**< 보기여부 **/
	public var description: String
	{
		return """
		corpId:\(corpId), fieldValue:\(fieldValue),
		commCode:\(commCode), commNameKr:\(commNameKr),
		commNameEn:\(commNameEn), commNameCh:\(commNameCh),
		commRef1:\(commRef1), commRef2:\(commRef2), commRef3:\(commRef3),
		commOrder:\(commOrder), viewYn:\(viewYn),
		remark:\(remark)
		"""
	}
}

struct UnitInfo {
	let unitId : String		/**< 장치ID 	**/
	let unitName : String	/**< 장치명 	**/
	let eventCode : String	/**< 이벤트코드	**/
	let branchId : String	/**< 거점ID		**/
	let branchName : String	/**< 거점명		**/
	let coordX : Double		/**< X좌표 		**/
	let coordY : Double		/**< Y좌표 		**/
	public var description: String
	{
		return """
		unitId:\(unitId), unitName:\(unitName),
		eventCode:\(eventCode), branchId:\(branchId),
		branchName:\(branchName),
		coordX:\(coordX), coordY:\(coordY)
		"""
	}
}

struct AssetInfo {
	let assetEpc : String			/**< 자산EPC코드	**/
	let assetCateCode : String		/**< 자산구분코드	**/
	let assetTypeCode : String		/**< 자산유형코드	**/
	let assetTypeName : String		/**< 자산유형명		**/
	let assetName : String			/**< 자산명			**/
	let remark : String				/**< 기타설명 		**/
	public var description: String
	{
		return """
		assetEpc:\(assetEpc), assetCateCode:\(assetCateCode),
		assetTypeCode:\(assetTypeCode), assetTypeName:\(assetTypeName),
		assetTypeName:\(assetTypeName), assetName:\(assetName),
		remark:\(remark)
		"""
	}
}

struct CustInfo {
	let custId : String			/**< 고객사ID	**/
	let corpId : String			/**< 회사ID		**/
	let parentCustId : String	/**< 상위고객사ID	**/
	let custType : String		/**< 고객사구분		**/
	let custName : String		/**< 고객사명		**/
	let custKey : String		/**< 고객사KEY		**/
	let epcLock : String		/**< EPC잠금번호	**/
	let custEpc : String		/**< 고객사EPC코드	**/
	let useYn : String			/**< 사용여부		**/
	public var description: String
	{
		return """
		custId:\(custId), corpId:\(corpId),
		parentCustId:\(parentCustId), custType:\(custType),
		custName:\(custName), custKey:\(custKey),
		epcLock:\(epcLock), custEpc:\(custEpc), useYn:\(useYn)
		"""
	}
}

class LocalData {
	
	enum SaleResaleType
	{	case Sale, Resale }
	
	enum CustType : String
	{
		case PMK = "PMK", RDC = "RDC", EXP = "EXP", IMP = "IMP"
	}
	
	static let shared = LocalData()
	
	let dbPath : String
	var mRemoteDbEnncryptId: String
	var mCorpId: String
	
	let mTblMobUpdateInfo : Table
	let mColUcd : Expression<String>
	let mColUdt : Expression<Int64>
	let mColRef : Expression<Int64>
	
	let mTblCodeMast : Table
	let mColFieldValue : Expression<String>
	let mColFieldName : Expression<String>
	let mColRemark : Expression<String?>
	
	let mTblCodeMastCorp : Table
	let mColCorpId : Expression<String>
	
	let mTblCodeDetail : Table
	let mColCommCode : Expression<String>
	let mColCommNameKr : Expression<String?>
	let mColCommNameEn : Expression<String?>
	let mColCommNameCh : Expression<String?>
	let mColCommRef1 : Expression<String?>
	let mColCommRef2 : Expression<String?>
	let mColCommRef3 : Expression<String?>
	let mColCommOrder : Expression<Int64?>
	let mColViewYn : Expression<String?>
	
	let mTblCodeDetailCorp : Table
	
	let mTblUnitInfo : Table
	let mColUnitId : Expression<String>
	let mColUnitName : Expression<String?>
	let mColEventCode : Expression<String?>
	let mColBranchId : Expression<String?>
	let mColBranchName : Expression<String?>
	let mColCoordX : Expression<Double?>
	let mColCoordY : Expression<Double?>
	
	let mTblAssetInfo : Table
	let mColAssetEpc : Expression<String>
	let mColAssetCateCode : Expression<String?>
	let mColAssetTypeCode : Expression<String?>
	let mColAssetTypeName : Expression<String?>
	let mColAssetName : Expression<String?>
	
	let mTblCustMast : Table
	let mColCustId : Expression<String>
	let mColParentCustId : Expression<String?>
	let mColCustType : Expression<String?>
	let mColCustName : Expression<String?>
	let mColCustKey : Expression<String?>
	let mColEpcLock : Expression<String?>
	let mColCustEpc : Expression<String?>
	let mColUseYn : Expression<String?>
	
	private init() {
		mRemoteDbEnncryptId = ""
		mCorpId = ""
		
		let currPath = NSSearchPathForDirectoriesInDomains(	.documentDirectory, .userDomainMask, true).first!
		self.dbPath = currPath + "/" + "rrppLocaldb.sqlite3"
		
		self.mTblMobUpdateInfo = Table("MOB_UPDATE_INFO")
		self.mColUcd = Expression<String>("UCD")
		self.mColUdt = Expression<Int64>("UDT")
		self.mColRef = Expression<Int64>("REF")
		
		self.mTblCodeMast = Table("CODE_MAST")
		self.mColFieldValue = Expression<String>("FIELD_VALUE")
		self.mColFieldName = Expression<String>("FIELD_NAME")
		self.mColRemark = Expression<String?>("REMARK")
		
		self.mTblCodeMastCorp = Table("CODE_MAST_CORP")
		self.mColCorpId =  Expression<String>("CORP_ID")
		
		self.mTblCodeDetail = Table("CODE_DETAIL")
		self.mColCommCode = Expression<String>("COMM_CODE")
		self.mColCommNameKr = Expression<String?>("COMM_NAME_KR")
		self.mColCommNameEn = Expression<String?>("COMM_NAME_EN")
		self.mColCommNameCh = Expression<String?>("COMM_NAME_CH")
		self.mColCommRef1 = Expression<String?>("COMM_REF1")
		self.mColCommRef2 = Expression<String?>("COMM_REF2")
		self.mColCommRef3 = Expression<String?>("COMM_REF3")
		self.mColCommOrder = Expression<Int64?>("COMM_ORDER")
		self.mColViewYn = Expression<String?>("VIEW_YN")
		
		self.mTblCodeDetailCorp = Table("CODE_DETAIL_CORP")
		
		self.mTblUnitInfo = Table("UNIT_INFO")
		self.mColUnitId = Expression<String>("UNIT_ID")
		self.mColUnitName = Expression<String?>("UNIT_NAME")
		self.mColEventCode = Expression<String?>("EVENT_CODE")
		self.mColBranchId = Expression<String?>("BRANCH_ID")
		self.mColBranchName = Expression<String?>("BRANCH_NAME")
		self.mColCoordX = Expression<Double?>("COORD_X")
		self.mColCoordY = Expression<Double?>("COORD_Y")
		
		self.mTblAssetInfo = Table("ASSET_INFO")
		self.mColAssetEpc = Expression<String>("ASSET_EPC")
		self.mColAssetCateCode = Expression<String?>("ASSET_CATE_CODE")
		self.mColAssetTypeCode = Expression<String?>("ASSET_TYPE_CODE")
		self.mColAssetTypeName = Expression<String?>("ASSET_TYPE_NAME")
		self.mColAssetName = Expression<String?>("ASSET_NAME")
		
		self.mTblCustMast = Table("CUST_MAST")
		self.mColCustId = Expression<String>("CUST_ID")
		self.mColParentCustId = Expression<String?>("PARENT_CUST_ID")
		self.mColCustType = Expression<String?>("CUST_TYPE")
		self.mColCustName = Expression<String?>("CUST_NAME")
		self.mColCustKey = Expression<String?>("CUST_KEY")
		self.mColEpcLock = Expression<String?>("EPC_LOCK")
		self.mColCustEpc = Expression<String?>("CUST_EPC")
		self.mColUseYn = Expression<String?>("USE_YN")
		
		
		//DB 테이블이 없으면 생성
		self.createDb()
	}
	
	public var CorpId: String {
		set { self.mCorpId = newValue }
		get {return self.mCorpId }
	}
	
	public var RemoteDbEnncryptId: String {
		set { self.mRemoteDbEnncryptId = newValue }
		get {return self.mRemoteDbEnncryptId }
	}
	
	
	
	/// 로컬테이블 생성(없을경우 )
	private func createDb() -> Void
	{
		do {
			let db = try Connection(self.dbPath)
			
			////try db.run(mTblMobUpdateInfo.drop())
			////try db.run(mTblCodeMast.drop())
			////try db.run(mTblCodeDetail.drop())
			
			//버전정보 업데이트 체크
			try db.run(mTblMobUpdateInfo.create(ifNotExists:true ) { table in
				table.column(mColUcd, primaryKey: true)
				table.column(mColUdt)
				table.column(mColRef)
			})
			
			//공통코드 마스터
			try db.run(mTblCodeMast.create(ifNotExists: true ) { table in
				table.column(mColFieldValue, primaryKey: true)
				table.column(mColFieldName)
				table.column(mColRemark)
			})
			
			//공통코드 마스터 회사별
			try db.run(mTblCodeMastCorp.create(ifNotExists: true ) { table in
				table.column(mColCorpId)
				table.column(mColFieldValue)
				table.column(mColFieldName)
				table.column(mColRemark)
				table.primaryKey(mColCorpId, mColFieldValue)
			})
			
			//공통코드 디테일
			try db.run(mTblCodeDetail.create(ifNotExists: true ) { table in
				table.column(mColFieldValue)
				table.column(mColCommCode)
				table.column(mColCommNameKr)
				table.column(mColCommNameEn)
				table.column(mColCommNameCh)
				table.column(mColCommRef1)
				table.column(mColCommRef2)
				table.column(mColCommRef3)
				table.column(mColCommOrder)
				table.column(mColViewYn)
				table.primaryKey(mColFieldValue, mColCommCode)
			})
			
			//공통코드 디테일 회사별
			try db.run(mTblCodeDetailCorp.create(ifNotExists: true ) { table in
				table.column(mColCorpId)
				table.column(mColFieldValue)
				table.column(mColCommCode)
				table.column(mColCommNameKr)
				table.column(mColCommNameEn)
				table.column(mColCommNameCh)
				table.column(mColCommRef1)
				table.column(mColCommRef2)
				table.column(mColCommRef3)
				table.column(mColCommOrder)
				table.primaryKey(mColCorpId, mColFieldValue, mColCommCode)
			})
			
			//단말기 정보
			try db.run(mTblUnitInfo.create(ifNotExists: true ) { table in
				table.column(mColUnitId, primaryKey: true)
				table.column(mColUnitName)
				table.column(mColEventCode)
				table.column(mColBranchId)
				table.column(mColBranchName)
				table.column(mColCoordX)
				table.column(mColCoordY)
			})
			
			//자산정보
			try db.run(mTblAssetInfo.create(ifNotExists: true ) { table in
				table.column(mColAssetEpc, primaryKey: true)
				table.column(mColAssetCateCode)
				table.column(mColAssetTypeCode)
				table.column(mColAssetTypeName)
				table.column(mColAssetName)
				table.column(mColRemark)
			})
			
			//고객사정보
			try db.run(mTblCustMast.create(ifNotExists: true ) { table in
				table.column(mColCustId, primaryKey: true)
				table.column(mColCorpId)
				table.column(mColParentCustId)
				table.column(mColCustType)
				table.column(mColCustName)
				table.column(mColCustKey)
				table.column(mColEpcLock)
				table.column(mColCustEpc)
				table.column(mColUseYn)
			})
			
		} catch {
			print("local table create exeption!!!: \(error)")
		}
	}
	
	/// 각 항목별 데이터를 원격 DB에 접속하여 데이터를 가져온다
	///
	/// - Parameters:
	///   - remoteDbUserInfo: <#remoteDbUserInfo description#>
	///   - corpId:
	///   - db: <#db description#>
	///   - updateCode: <#updateCode description#>
	///   - updateDate: <#updateDate description#>
	///   - ref: <#ref description#>
	///   - bIsInsert: <#bIsInsert description#>
	private func changeNewVersion(container: UIViewController, remoteDbUserInfo: String, corpId: String, db: Connection, updateCode: String, updateDate: Int, ref : Int, bIsInsert : Bool, disPatchGrp : DispatchGroup ) -> Void
	{
		
		let dataClient = Mosaic.DataClient(container: container, url: Constants.WEB_SVC_URL)
		
		//TODO:: 아라의 코드중 self를 objMe로 대체
		let objMe = self
		
		//완료처리를 위하여 디스페쳐 그룹을 설정한다.
		disPatchGrp.enter()
		switch updateCode
		{
			case "CODE_MAST" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectCodeMastList"
				dataClient.removeServiceParam()
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
						do
						{
							try db.run(objMe.mTblCodeMast.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(objMe.mTblCodeMast.insert(objMe.mColFieldValue <- dataRow.getString(name:"fieldValue")!
																		, objMe.mColFieldName <- dataRow.getString(name:"fieldName")!,
																		 objMe.mColRemark <- dataRow.getString(name:"remark")!)
								)
							}
	//								//For Test
	//								for rows in try db.prepare(self.mTblCodeMast) {
	//									print("mColFieldValue: \(rows[self.mColFieldValue]), mColFieldName: \(rows[self.mColFieldName]), mColRemark: \(rows[self.mColRemark]!)")
	//								}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			
		case "CODE_MAST_CORP" :
			dataClient.UserInfo = remoteDbUserInfo
			dataClient.UserData = "app.update.selectCodeMastCorpList"
			dataClient.removeServiceParam()
			dataClient.addServiceParam(paramName: "corpId", value: corpId)
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
					do
					{
						try db.run(objMe.mTblCodeMastCorp.delete())
						for dataRow in dataTable.getDataRows()
						{
							try db.run(objMe.mTblCodeMastCorp.insert(self.mColCorpId <- dataRow.getString(name:"corpId")!,
								 objMe.mColFieldValue <- dataRow.getString(name:"fieldValue")!,
								 objMe.mColFieldName <- dataRow.getString(name:"fieldName")!,
								 objMe.mColRemark <- dataRow.getString(name:"remark")!
								)
							)
						}
						//For Test
						//for rows in try db.prepare(self.mTblCodeMastCorp) {
						//	print("mColCorpId: \(rows[self.mColCorpId]), mColFieldValue: \(rows[self.mColFieldValue]), mColFieldName: \(rows[self.mColFieldName]), mColRemark: \(rows[self.mColRemark]!)")
						//	}
						
						/// 비동기로 처리 되므로 개별적으로 Update
						if(bIsInsert)
						{
							print("insert mobUpdateInfo")
							try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																	 objMe.mColRef <- Int64(ref)))
						}
						else{
							print("update mobUpdateInfo")
							// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
							let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
							try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
						}
					} catch {
						print("local mobUpdateInfo fail: \(error)")
					}
					
					//왼료처리를 위하여 디스페쳐를 나간다.
					disPatchGrp.leave()
				})
			
			case "CODE_DETAIL" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectCodeDetailList"
				dataClient.removeServiceParam()
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
						do
						{
							try db.run(objMe.mTblCodeDetail.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(self.mTblCodeDetail.insert(objMe.mColFieldValue <- dataRow.getString(name:"fieldValue")!,
																	  objMe.mColCommCode <- dataRow.getString(name:"commCode")!,
																	  objMe.mColCommNameKr <- dataRow.getString(name:"commNameKr")!,
																	  objMe.mColCommNameEn <- dataRow.getString(name:"commNameEn")!,
																	  objMe.mColCommNameCh <- dataRow.getString(name:"commNameCh")!,
																	  objMe.mColCommRef1 <- dataRow.getString(name:"commRef1")!,
																	  objMe.mColCommRef2 <- dataRow.getString(name:"commRef2")!,
																	  objMe.mColCommRef3 <- dataRow.getString(name:"commRef3")!,
																	  objMe.mColCommOrder <- Int64((dataRow.getInt(name:"commOrder") ?? 0)!),
																	  objMe.mColViewYn <- dataRow.getString(name:"viewYn")!
																)
												)
								
								//For Test
//								if let testCode =  dataRow.getString(name:"commCode")
//								{
//									if(testCode == "RS4030")
//									{
//										if let testName = dataRow.getString(name:"commNameKr")
//										{
//												print(" \(testName) ")
//										}
//									}
//								}
							}
									//For Test
//									for rows in try db.prepare(self.mTblCodeDetail) {
//										print("""
//											mColFieldValue: \(rows[self.mColFieldValue]), mColCommCode: \(rows[self.mColCommCode]),
//											mColCommNameKr: \(rows[self.mColCommNameKr]!),mColCommNameEn: \(rows[self.mColCommNameEn]!),
//											mColCommNameCh: \(rows[self.mColCommNameCh]!), mColCommRef1: \(rows[self.mColCommRef1]!)
//											mColCommRef2: \(rows[self.mColCommRef2]!), mColCommRef3: \(rows[self.mColCommRef3]!),
//											mColCommOrder: \(rows[self.mColCommOrder]!), mColViewYn: \(rows[self.mColViewYn]!)
//											""")
//
//										if(rows[objMe.mColCommCode] == "RS4030")
//										{
//											if let testName = rows[objMe.mColCommNameKr]
//											{
//												print(" \(testName) ")
//											}
//										}
//									}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			
			case "CODE_DETAIL_CORP" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectCodeDetailCorpList"
				dataClient.removeServiceParam()
				dataClient.addServiceParam(paramName: "corpId", value: corpId)
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
						do
						{
							try db.run(objMe.mTblCodeDetailCorp.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(objMe.mTblCodeDetailCorp.insert(objMe.mColCorpId <- dataRow.getString(name:"corpId")!,
																	 objMe.mColFieldValue <- dataRow.getString(name:"fieldValue")!,
																	  objMe.mColCommCode <- dataRow.getString(name:"commCode")!,
																	  objMe.mColCommNameKr <- dataRow.getString(name:"commNameKr")!,
																	  objMe.mColCommNameEn <- dataRow.getString(name:"commNameEn")!,
																	  objMe.mColCommNameCh <- dataRow.getString(name:"commNameCh")!,
																	  objMe.mColCommRef1 <- dataRow.getString(name:"commRef1")!,
																	  objMe.mColCommRef2 <- dataRow.getString(name:"commRef2") ?? "",
																	  objMe.mColCommRef3 <- dataRow.getString(name:"commRef3") ?? "",
																	  objMe.mColCommOrder <- Int64((dataRow.getInt(name:"commOrder") ?? 0))
									)
								)
							}
							//For Test
	//								for rows in try db.prepare(self.mTblCodeDetailCorp) {
	//									print("""
	//										mColCorpId: \(rows[self.mColCorpId])
	//										mColFieldValue: \(rows[self.mColFieldValue]), mColCommCode: \(rows[self.mColCommCode]),
	//										mColCommNameKr: \(rows[self.mColCommNameKr]!),mColCommNameEn: \(rows[self.mColCommNameEn]!),
	//										mColCommNameCh: \(rows[self.mColCommNameCh]!), mColCommRef1: \(rows[self.mColCommRef1]!),
	//										mColCommRef2: \(rows[self.mColCommRef2]!), mColCommRef3: \(rows[self.mColCommRef3]!),
	//										mColCommOrder: \(rows[self.mColCommOrder]!)
	//										""")
	//								}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
							
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			
			case "UNIT_INFO" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectUnitInfoList"
				dataClient.removeServiceParam()
				dataClient.addServiceParam(paramName: "corpId", value: corpId)
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
						do
						{
							try db.run(objMe.mTblUnitInfo.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(objMe.mTblUnitInfo.insert(self.mColUnitId <- dataRow.getString(name:"unitId")!,
																		  objMe.mColUnitName <- dataRow.getString(name:"unitName")!,
																		  objMe.mColEventCode <- dataRow.getString(name:"eventCode") ?? "",
																		  objMe.mColBranchId <- dataRow.getString(name:"branchId") ?? "",
																		  objMe.mColBranchName <- dataRow.getString(name:"branchName") ?? "",
																		  objMe.mColCoordX <- dataRow.getDouble(name:"coordX") ?? 0,
																		  objMe.mColCoordY <- dataRow.getDouble(name:"coordY") ?? 0
									)
								)
							}
							//For Test
	//									for rows in try db.prepare(self.mTblUnitInfo) {
	//										print("""
	//											mColUnitId: \(rows[self.mColUnitId]), mColUnitName: \(rows[self.mColUnitName]!),
	//											mColEventCode: \(rows[self.mColEventCode]!),mColBranchId: \(rows[self.mColBranchId]!),
	//											mColBranchName: \(rows[self.mColBranchName]!),
	//											mColCoordX: \(rows[self.mColCoordX]!), 	mColCoordY: \(rows[self.mColCoordY]!)
	//											""")
	//									}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			
			case "ASSET_INFO" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectAssetInfoList"
				dataClient.removeServiceParam()
				dataClient.addServiceParam(paramName: "corpId", value: corpId)
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
						do
						{
							try db.run(objMe.mTblAssetInfo.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(objMe.mTblAssetInfo.insert(self.mColAssetEpc <- dataRow.getString(name:"assetEpc")!,
																	objMe.mColAssetCateCode <- dataRow.getString(name:"assetCateCode")!,
																	objMe.mColAssetTypeCode <- dataRow.getString(name:"assetTypeCode") ?? "",
																	objMe.mColAssetTypeName <- dataRow.getString(name:"assetTypeName") ?? "",
																	objMe.mColAssetName <- dataRow.getString(name:"assetName") ?? "",
																	objMe.mColRemark <- dataRow.getString(name:"remark") ?? ""
									)
								)
							}
							//For Test
	//								for rows in try db.prepare(self.mTblAssetInfo) {
	//									print("""
	//										mColAssetEpc: \(rows[self.mColAssetEpc]), mColAssetCateCode: \(rows[self.mColAssetCateCode]!),
	//										mColAssetTypeCode: \(rows[self.mColAssetTypeCode]!),mColAssetTypeName: \(rows[self.mColAssetTypeName]!),
	//										mColAssetName: \(rows[self.mColAssetName]!), mColRemark: \(rows[self.mColRemark]!)
	//										""")
	//								}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
							
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			
			case "CUST_MAST" :
				dataClient.UserInfo = remoteDbUserInfo
				dataClient.UserData = "app.update.selectCustMastList"
				dataClient.removeServiceParam()
				dataClient.addServiceParam(paramName: "corpId", value: corpId)
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
						do
						{
							try db.run(objMe.mTblCustMast.delete())
							for dataRow in dataTable.getDataRows()
							{
								try db.run(objMe.mTblCustMast.insert(self.mColCustId <- dataRow.getString(name:"custId")!,
																	 objMe.mColCorpId <- dataRow.getString(name:"corpId")!,
																	 objMe.mColParentCustId <- dataRow.getString(name:"parentCustId") ?? "",
																	 objMe.mColCustType <- dataRow.getString(name:"custType") ?? "",
																	 objMe.mColCustName <- dataRow.getString(name:"custName") ?? "",
																	 objMe.mColCustKey <- dataRow.getString(name:"custKey") ?? "",
																	 objMe.mColEpcLock <- dataRow.getString(name:"epcLock") ?? "",
																	 objMe.mColCustEpc <- dataRow.getString(name:"custEpc") ?? "",
																	 objMe.mColUseYn <- dataRow.getString(name:"useYn") ?? ""
									)
								)
							}
							//For Test
	//								for rows in try db.prepare(self.mTblCustMast) {
	//									print("""
	//										mColCustId: \(rows[self.mColCustId]), mColCorpId: \(rows[self.mColCorpId]),
	//										mColParentCustId: \(rows[self.mColParentCustId]!),mColCustType: \(rows[self.mColCustType]!),
	//										mColCustName: \(rows[self.mColCustName]!), mColCustKey: \(rows[self.mColCustKey]!),
	//										mColEpcLock: \(rows[self.mColEpcLock]!), mColCustEpc: \(rows[self.mColCustEpc]!)
	//										mColUseYn: \(rows[self.mColUseYn]!)
	//										""")
	//								}
							
							/// 비동기로 처리 되므로 개별적으로 Update
							if(bIsInsert)
							{
								print("insert mobUpdateInfo")
								try db.run(objMe.mTblMobUpdateInfo.insert(objMe.mColUcd <- updateCode, objMe.mColUdt <- Int64(updateDate),
																		 objMe.mColRef <- Int64(ref)))
							}
							else{
								print("update mobUpdateInfo")
								// filter문을 사용하면 적요잉 안됨. filter 대신에 where 구문을 사용해야됨
								let updateState = objMe.mTblMobUpdateInfo.where(objMe.mColUcd == updateCode)
								try db.run(updateState.update(objMe.mColUdt <- Int64(updateDate), objMe.mColRef <- Int64(ref)))
							}
						} catch {
							print("local mobUpdateInfo fail: \(error)")
						}
						
						//왼료처리를 위하여 디스페쳐를 나간다.
						disPatchGrp.leave()
				})
			default:
				print(" 업데이트 항목에 대한 구현이 없음. 코드: \(updateCode)")
				disPatchGrp.leave()
		}
	}
	
	/// 원격 Db와 버전체크 버전체크후, 데이터를 가져와서 동기화
	public func versionCheck(container: UIViewController, indicator: ProgressIndicator, navigation: NavigationDrawerController? ) -> Void
	{
		if(self.mRemoteDbEnncryptId.isEmpty)
		{
			print("원격연결정보가 없습니다. 확인해 주세요.")
			return
		}
		
		if(self.mCorpId.isEmpty)
		{
			print("조회할 회사 정보가 없습니다. 확인해 주세요.")
			return
		}
		
		//모든 Dispatch 쓰레드가 종료되기를 기다린다.
		let clsDispatchGrp = DispatchGroup()
		
		let dataClient = Mosaic.DataClient(container: container, url: Constants.WEB_SVC_URL)
		dataClient.UserInfo = self.mRemoteDbEnncryptId
		dataClient.UserData = "app.update.selectUpdateItemList"
		dataClient.removeServiceParam()
		dataClient.addServiceParam(paramName: "corpId", value: self.mCorpId)
		dataClient.addServiceParam(paramName: "appId", value: "rrpp-client")
		dataClient.selectData(dataCompletionHandler:
			{ (data, error) in
				if let error = error {
					// 에러처리
					DispatchQueue.main.async {
						indicator.show(message:error.localizedDescription)
					}
					sleep(5)
					indicator.hide()
					return
				}
				guard let dataTable = data else {
					print("에러 데이터가 없음")
					indicator.hide()
					navigation?.isEnabled = true
					return
				}
				
				let dataRows = dataTable.getDataRows()
				do
				{
					let db = try Connection(self.dbPath)
					//################
					//for Test 업데잍 정보를 삭제하면 전체데이터를 다시 받음. 테스트를 하기 위해서는
					// 아래의 코드의 주석을 제거
					//try db.run(self.mTblMobUpdateInfo.delete())
					//################
					
					for dataRow in dataRows
					{
						let updateCode = dataRow.getString(name:"ucd")!
						let updateDate = dataRow.getInt(name:"udt")!
						let ref = dataRow.getInt(name:"ref")!
						
						let localUpdateInfoQuery = self.mTblMobUpdateInfo.select(self.mColUdt).filter(self.mColUcd == updateCode )
						if let localRow = try db.pluck(localUpdateInfoQuery)
						{
							if(updateDate > localRow[self.mColUdt])
							{
								print("update date  org: \(updateDate), new:\(localRow[self.mColUdt])")
								self.changeNewVersion(container: container, remoteDbUserInfo: self.mRemoteDbEnncryptId, corpId: self.mCorpId, db: db, updateCode: updateCode, updateDate: updateDate, ref : ref,  bIsInsert : false , disPatchGrp : clsDispatchGrp)
							}
						}
						else
						{
							self.changeNewVersion(container: container, remoteDbUserInfo: self.mRemoteDbEnncryptId, corpId: self.mCorpId, db: db, updateCode: updateCode, updateDate: updateDate, ref : ref,  bIsInsert : true , disPatchGrp : clsDispatchGrp)
						}
					}
					
				} catch {
					print("local mobUpdateInfo fail: \(error)")
				}
				
				//모든데이터가 다 받을수 있도록 대기한다
				clsDispatchGrp.notify(queue: .main) {
					indicator.hide()
					navigation?.isEnabled = true
				}
		})
	}
	
	/// 공통코드 가져오기
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetail(fieldValue: String, initCodeName : String?) -> [CodeInfo]
	{
		return self.getCodeDetail(fieldValue, nil, nil, nil, nil, nil, initCodeName)
	}
	
	/// 공통코드 가져오기
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - commCode: <#commCode description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetail(fieldValue: String, commCode: String?, initCodeName : String?) -> [CodeInfo]
	{
		return self.getCodeDetail(fieldValue, commCode, nil, nil, nil, nil, initCodeName)
	}
	
	///  공통코드 가져오기
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - commCode: <#commCode description#>
	///   - viewYn: <#viewYn description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetail(fieldValue: String, commCode: String?, viewYn: String, initCodeName : String?) -> [CodeInfo]
	{
		return self.getCodeDetail(fieldValue, commCode, nil, nil, nil, viewYn, initCodeName)
	}
	
	///  공통코드 가져오기
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - commCode: <#commCode description#>
	///   - commRef1: <#commRef1 description#>
	///   - commRef2: <#commRef2 description#>
	///   - commRef3: <#commRef3 description#>
	///   - viewYn: <#viewYn description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetail(_ fieldValue: String, _ commCode: String?, _ commRef1: String?,  _ commRef2 : String?, _ commRef3 : String?,
								  _ viewYn :String?, _ initCodeName : String?) -> [CodeInfo]
	{
		var codeInfos = [CodeInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			var searchQuery = self.mTblCodeDetail.select(mTblCodeDetail[*])
		
			if(fieldValue.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColFieldValue == fieldValue )
			}
			if(commCode != nil && commCode!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColCommCode == commCode! )
			}
			if(commRef1 != nil && commRef1!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColCommRef1 == commRef1! )
			}
			if(commRef2 != nil && commRef2!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColCommRef2 == commRef2! )
			}
			if(commRef3 != nil && commRef3!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColCommRef3 == commRef3! )
			}
			if(viewYn != nil && viewYn!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColViewYn == viewYn! )
			}
			searchQuery = searchQuery.order(self.mColCommOrder.asc)
			
			if( initCodeName != nil && initCodeName!.isEmpty == false)
			{
				let codeInfo = CodeInfo(corpId: "", fieldValue: "", commCode: "",
										commNameKr: initCodeName!, commNameEn: initCodeName!,
										commNameCh: initCodeName!, commRef1: "",
										commRef2: "", commRef3: "",
										remark: "",commOrder: 0,
										viewYn: "Y")
				codeInfos.append(codeInfo)
			}
			
			for dbCode in try db.prepare(searchQuery)
			{
				let codeInfo = CodeInfo(corpId: "", fieldValue: dbCode[self.mColFieldValue], commCode: dbCode[self.mColCommCode] ,
							  commNameKr: dbCode[self.mColCommNameKr] ?? "", commNameEn: dbCode[self.mColCommNameEn] ?? "",
							  commNameCh: dbCode[self.mColCommNameCh] ?? "", commRef1: dbCode[self.mColCommRef1] ?? "",
							  commRef2: dbCode[self.mColCommRef2] ?? "", commRef3: dbCode[self.mColCommRef3] ?? "",
							  remark: "",commOrder: Int(dbCode[self.mColCommOrder] ?? 0),
							  viewYn: dbCode[self.mColViewYn] ?? "Y")
				codeInfos.append(codeInfo)
			}
			
			//For debuggig
//			for tempCodeInfo in codeInfos
//			{
//				print(tempCodeInfo)
//			}
			
			return codeInfos
		}
		catch
		{
			print("getCodeDetailList Error: \(error)")
		}
		return codeInfos
	}
	
	/// 회사별  공통코드 가져오기
	///
	/// - Parameters:
	///   - corpId: <#corpId description#>
	///   - fieldValue: <#fieldValue description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetailCorp(corpId: String, fieldValue: String, initCodeName : String?) -> [CodeInfo]
	{
		return self.getCodeDetailCorp(corpId, fieldValue, nil, initCodeName)
	}
	
	/// 회사별 공통코드 가져오기
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - commCode: <#commCode description#>
	///   - commRef1: <#commRef1 description#>
	///   - commRef2: <#commRef2 description#>
	///   - commRef3: <#commRef3 description#>
	///   - viewYn: <#viewYn description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getCodeDetailCorp(_ corpId: String, _ fieldValue: String, _ commCode: String?, _ initCodeName : String?) -> [CodeInfo]
	{
		var codeInfos = [CodeInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			var searchQuery = self.mTblCodeDetailCorp.select(mTblCodeDetailCorp[*])
			searchQuery = searchQuery.filter(self.mColCorpId == corpId )
			
			if(fieldValue.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColFieldValue == fieldValue )
			}
			if(commCode != nil && commCode!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColCommCode == commCode! )
			}
			
			searchQuery = searchQuery.order(self.mColCommOrder.asc)
			
			if( initCodeName != nil && initCodeName!.isEmpty == false)
			{
				let codeInfo = CodeInfo(corpId: corpId, fieldValue: "", commCode: "",
										commNameKr: initCodeName!, commNameEn: initCodeName!,
										commNameCh: initCodeName!, commRef1: "",
										commRef2: "", commRef3: "",
										remark: "",commOrder: 0,
										viewYn: "Y")
				codeInfos.append(codeInfo)
			}
			
			for dbCode in try db.prepare(searchQuery)
			{
				let codeInfo = CodeInfo(corpId: dbCode[self.mColCorpId], fieldValue: dbCode[self.mColFieldValue], commCode: dbCode[self.mColCommCode] ,
										commNameKr: dbCode[self.mColCommNameKr] ?? "", commNameEn: dbCode[self.mColCommNameEn] ?? "",
										commNameCh: dbCode[self.mColCommNameCh] ?? "", commRef1: dbCode[self.mColCommRef1] ?? "",
										commRef2: dbCode[self.mColCommRef2] ?? "", commRef3: dbCode[self.mColCommRef3] ?? "",
										remark: "",commOrder: Int(dbCode[self.mColCommOrder] ?? 0),
										viewYn: dbCode[self.mColViewYn] ?? "Y")
				codeInfos.append(codeInfo)
			}
			//For debuggig
//						for tempCodeInfo in codeInfos
//						{
//							print(tempCodeInfo)
//						}
		}
		catch
		{
			print("getCodeDetailList Error: \(error)")
		}
		return codeInfos
	}
	
	/// 장치정보를 가져온다
	///
	/// - Parameter searchValue: <#searchValue description#>
	/// - Returns: <#return value description#>
	public func getUnitInfo(searchValue : String?) -> [UnitInfo]
	{
		var unitInfos = [UnitInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			var searchQuery = self.mTblUnitInfo.select(mTblUnitInfo[*])
			if(searchValue != nil && searchValue!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColUnitName.like("%" + searchValue! + "%"))
			}
			searchQuery = searchQuery.order(self.mColUnitName.asc)
			
			for dbCode in try db.prepare(searchQuery)
			{
				let unitInfo = UnitInfo(unitId: dbCode[self.mColUnitId], unitName: dbCode[self.mColUnitName] ?? "",
										eventCode: dbCode[self.mColEventCode] ?? "", branchId: dbCode[self.mColBranchId] ?? "",
										branchName: dbCode[self.mColBranchName] ?? "",
										coordX: dbCode[self.mColCoordX] ?? 0, coordY:  dbCode[self.mColCoordY] ?? 0)
				unitInfos.append(unitInfo)
			}
			//For debuggig
//			for tempCodeInfo in unitInfos
//			{
//				print(tempCodeInfo)
//			}
		}
		catch
		{
			print("getUnitInfo Error: \(error)")
		}
		return unitInfos
	}
	
	/// 자산정보를 가져온다
	///
	/// - Parameter searchValue: <#searchValue description#>
	/// - Returns: <#return value description#>
	public func getAssetInfo(searchValue : String?) -> [AssetInfo]
	{
		var assetInfos = [AssetInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			var searchQuery = self.mTblAssetInfo.select(mTblAssetInfo[*])
			if(searchValue != nil && searchValue!.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColAssetName.like("%" + searchValue! + "%"))
			}
			searchQuery = searchQuery.order(self.mColAssetName.asc)
			
			for dbCode in try db.prepare(searchQuery)
			{
				let assetInfo = AssetInfo(assetEpc: dbCode[self.mColAssetEpc], assetCateCode: dbCode[self.mColAssetCateCode] ?? "",
										  assetTypeCode: dbCode[self.mColAssetTypeCode] ?? "", assetTypeName: dbCode[self.mColAssetTypeName] ?? "",
										  assetName: dbCode[self.mColAssetName] ?? "", remark: "")
				
				assetInfos.append(assetInfo)
			}
			//For debuggig
//			for tempCodeInfo in assetInfos
//			{
//				print(tempCodeInfo)
//			}
		}
		catch
		{
			print("getAssetInfo Error: \(error)")
		}
		return assetInfos
	}
	
	
	/// 법인고객사 정보를 가져온다
	///
	/// - Returns: <#return value description#>
	public func getCustInfo() -> [CustInfo]
	{
		var custInfos = [CustInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			let searchQuery = self.mTblCustMast.select(mTblCustMast[*])
												.filter(self.mColUseYn == "Y")
												.filter(self.mColCustType == "CMP")
												.order(self.mColCustName.asc)
			
			let searchQuerySub = self.mTblCustMast.select(mColParentCustId)
													.filter(self.mColCustType == "ADM")
			
			var bIsExist = false
			for dbCode in try db.prepare(searchQuery)
			{
				bIsExist = false
				for dbCodeSub in try db.prepare(searchQuerySub)
				{
					if(dbCode[self.mColCustId] == dbCodeSub[self.mColParentCustId])
					{
						bIsExist = true
					}
				}
				
				if( bIsExist == false)
				{
					let custInfo = CustInfo(custId: dbCode[self.mColCustId], corpId: dbCode[self.mColCorpId],
											parentCustId: dbCode[self.mColParentCustId] ?? "", custType: dbCode[self.mColCustType] ?? "",
											custName: dbCode[self.mColCustName] ?? "", custKey: dbCode[self.mColCustKey] ?? "",
											epcLock: dbCode[self.mColEpcLock] ?? "", custEpc: dbCode[self.mColCustEpc] ?? "",
											useYn: dbCode[self.mColUseYn] ?? "")
					custInfos.append(custInfo)
				}
			}
			//For debuggig
//			for tempCodeInfo in custInfos
//			{
//				print(tempCodeInfo)
//			}
		}
		catch
		{
			print("getCustInfo Error: \(error)")
		}
		return custInfos
	}
	
	
	/// SALE_TYPE에 대한 공통코드를 리턴한다.
	///
	/// - Parameters:
	///   - fieldValue: <#fieldValue description#>
	///   - saleResale: <#saleResale description#>
	///   - custType: <#custType description#>
	///   - initCodeName: <#initCodeName description#>
	/// - Returns: <#return value description#>
	public func getSaleTypeCodeDetail(fieldValue : String,  saleResale : SaleResaleType, custType: CustType, initCodeName : String?) -> [CodeInfo]
	{
		var codeInfos = [CodeInfo]()
		do
		{
			let db = try Connection(self.dbPath)
			var searchQuery = self.mTblCodeDetail.select(mTblCodeDetail[*])
			if(fieldValue.isEmpty == false)
			{
				searchQuery = searchQuery.filter(self.mColFieldValue == fieldValue )
			}
			
			if (saleResale == .Sale)
			{
				switch custType
				{
					case .PMK:
						searchQuery = searchQuery.filter(["01", "02"].contains(self.mColCommCode) )
					case .RDC:
						searchQuery = searchQuery.filter(["01", "02"].contains(self.mColCommCode) )
					case .EXP :
						searchQuery = searchQuery.filter(["05"].contains(self.mColCommCode) )
					case .IMP :
						searchQuery = searchQuery.filter(["05"].contains(self.mColCommCode) )
				}
			}
			else
			{
				switch custType
				{
				case .PMK:
					searchQuery = searchQuery.filter(["02"].contains(self.mColCommCode) )
				case .RDC:
					searchQuery = searchQuery.filter(["02", "03", "04"].contains(self.mColCommCode) )
				case .EXP :
					searchQuery = searchQuery.filter(["01", "05"].contains(self.mColCommCode) )
				case .IMP :
					searchQuery = searchQuery.filter(["05"].contains(self.mColCommCode) )
				}
			}
			searchQuery = searchQuery.order(self.mColCommOrder.asc)
			
			if( initCodeName != nil && initCodeName!.isEmpty == false)
			{
				let codeInfo = CodeInfo(corpId: "", fieldValue: "", commCode: "",
										commNameKr: initCodeName!, commNameEn: initCodeName!,
										commNameCh: initCodeName!, commRef1: "",
										commRef2: "", commRef3: "",
										remark: "",commOrder: 0,
										viewYn: "Y")
				codeInfos.append(codeInfo)
			}
			
			for dbCode in try db.prepare(searchQuery)
			{
				let codeInfo = CodeInfo(corpId: "", fieldValue: dbCode[self.mColFieldValue], commCode: dbCode[self.mColCommCode] ,
										commNameKr: dbCode[self.mColCommNameKr] ?? "", commNameEn: dbCode[self.mColCommNameEn] ?? "",
										commNameCh: dbCode[self.mColCommNameCh] ?? "", commRef1: dbCode[self.mColCommRef1] ?? "",
										commRef2: dbCode[self.mColCommRef2] ?? "", commRef3: dbCode[self.mColCommRef3] ?? "",
										remark: "",commOrder: Int(dbCode[self.mColCommOrder] ?? 0),
										viewYn: dbCode[self.mColViewYn] ?? "Y")
				codeInfos.append(codeInfo)
			}
			
			//For debuggig
//			for tempCodeInfo in codeInfos
//			{
//				print(tempCodeInfo)
//			}
			return codeInfos
		}
		catch
		{
			print("getSaleTypeCodeDetail Error: \(error)")
		}
		return codeInfos
	}
}

