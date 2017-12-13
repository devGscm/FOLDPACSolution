//
//  EpcInfo.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 6..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


public class EpcInfo : NSObject
{
    var mIntRowState    = -1
    var mStrEpcCode    = ""
    var arrItemData:Array<ItemInfo> = Array<ItemInfo>()
   
    
    func addProdEpc(epcCode: String)
	{
    	self.mStrEpcCode = epcCode;
    	self.mIntRowState = Constants.DATA_ROW_STATE_ADDED
    }
    
    func loadProdEpc(epcCode: String)
	{
    	self.mStrEpcCode = epcCode
    	self.mIntRowState = Constants.DATA_ROW_STATE_UNCHANGED
    }
    
    public func addItem(strEpcCode: String, itemInfo: ItemInfo)
	{
		arrItemData.append(itemInfo)
    }
	
	public func removeItem(index: Int)
	{
		arrItemData.remove(at: index)
	}
	
    func getItemes() -> Array<ItemInfo>
	{
 		return self.arrItemData
    }
	
	func removeAllItems()
	{
		self.arrItemData.removeAll()
	}
	
	func setItemes( itemes: Array<ItemInfo>)
	{
		self.arrItemData.append(contentsOf: itemes)
	}
	
    func getEpcCode() -> String
	{
 		return mStrEpcCode
    }
    
    func setRowState(rowState: Int)
	{
    	self.mIntRowState = rowState
    }
    
    func getRowState() -> Int
	{
		return mIntRowState
    }
}
