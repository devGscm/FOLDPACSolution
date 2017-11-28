//
//  BaseRfidViewController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit


class BaseRfidViewController : BaseViewController
{
	var arrAssetInfo	: Array<AssetInfo> = Array<AssetInfo>()
	var arrProcMsgInfo	: Array<CodeInfo> = Array<CodeInfo>()
	var arrSaleType		: Array<CodeInfo> = Array<CodeInfo>()
	var arrReSaleType	: Array<CodeInfo> = Array<CodeInfo>()
	
	func initRfid()
	{
		super.initController()
		initCodeInfo()
	}
	
	func startRfid()
	{
		
	}
	
	func stopRead()
	{
		
	}
	
	func stopRfid()
	{
		
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

}
