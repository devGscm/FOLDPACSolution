//
//  ProdContainer.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 6..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import Mosaic

public class ProdContainer
{
    var mDicPallet : Dictionary<String, NSObject> = Dictionary<String, NSObject>()
   
    func clear()
	{
    	mDicPallet.removeAll()
    }
    
    func containEpcCode(epcCode: String) -> Bool
	{
		return mDicPallet.keys.contains(epcCode)
    }
    
    /**
     * 상품리스트 클래스에 RFID태그 정보를 추가 한다.
     * @param epcCode EPC코드(헤시맵 키)
     */
    func addProdEpc(epcCode: String)
    {
        if(mDicPallet.keys.contains(epcCode) == false)
        {
        	let clsEpcInfo = EpcInfo()
            clsEpcInfo.addProdEpc(epcCode: epcCode)
 			//입력받은 EPC코드를 KEY로 하여, 리스트를 만든다.
            mDicPallet[epcCode] = clsEpcInfo
        }
    }

    /**
     * 상품리스트 클래스에서 RFID태그 정보를 읽어온다.
     * @param epcCode EPC코드(헤시맵 키)
     */
    func loadProdEpc(epcCode : String)
	{
        if(mDicPallet.keys.contains(epcCode) == false)
        {
            let clsEpcInfo = EpcInfo()
            clsEpcInfo.loadProdEpc(epcCode: epcCode)

        	//입력받은 EPC코드를 KEY로 하여, 리스트를 만든다.
            mDicPallet[epcCode] = clsEpcInfo
        }
    }

    /**
     * 리스트에 ItemInfo클래스를 저장
     * @param epcCode     EPC코드(해시맵 키)
     * @param itemInfo    상품정보 클래스
     */
    func addItem(epcCode: String, itemInfo: ItemInfo)
	{
		print("=====================================")
		print("*addItem()")
		print("=====================================")
		print(" -epcCode:\(epcCode)")
 		let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo

//		var arrItemList = clsEpcInfo.getItemes()
//		print(" -epcCode:\(epcCode)")
//		arrItemList.append(itemInfo)
		
		// 위 안드로이드 코딩을 아래와 같이 바꿈
		
		clsEpcInfo.addItem(strEpcCode: epcCode, itemInfo: itemInfo)
		
		print(" -clsEpcInfo.getItemes().count:\(clsEpcInfo.getItemes().count)")
		
	}

    /**
     * 클래스에 있는 Item(서브)정보를 변경한다.
     * @param epcCode     EPC코드(해시맵 키)
     * @param itemInfo    상품정보 클래스
     */
    func updateItem(epcCode: String, prodCode: String, itemInfo: ItemInfo)
	{
        let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo
		var arrItemList = clsEpcInfo.getItemes()
        for (index, clsItem) in arrItemList.enumerated()
        {
            if(prodCode.isEmpty == false)
            {
                if(clsItem.getEpcCode() == epcCode &&  clsItem.getProdCode() == prodCode)
                {
                    if(itemInfo.getProdReadCnt().isEmpty == false)
                    {
                        // 인식수량
                        clsItem.setProdReadCnt(prodReadCnt: itemInfo.getProdReadCnt())
                    }
                    
                    if(itemInfo.getRowState() > -1)
                    {
                        // 태그신규 여부(RowState)
                        clsItem.setRowState(rowState: itemInfo.getRowState())
                    }
                    
                    if(itemInfo.getSaleItemSeq().isEmpty == false)
                    {
                        //상품SEQ
                        clsItem.setSaleItemSeq(saleItemSeq : itemInfo.getSaleItemSeq())
                    }
                    arrItemList[index] = clsItem
                    break
                }
            }
        }
    }

    /**
     * 클래스에 있는 EPC(마스터)정보를 변경한다.
     * @param epcCode     EPC코드(해시맵 키)
     * @param itemInfo    상품정보 클래스
     */
    func updateEpc(epcCode: String, itemInfo : ItemInfo)
	{
        let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo
        if(clsEpcInfo.getEpcCode() == epcCode)
        {
            if(itemInfo.getRowState() > -1)
            {
                //태그신규 여부(RowState)
                clsEpcInfo.setRowState(rowState: itemInfo.getRowState())
            }
        }
    }

    /**
     * 헤시맵에서 Item제거
     * @param epcCode         EPC코드(해시맵 키)
     * @param itemInfo        상품정보코드
     */
    func deleteItem(epcCode: String, prodCode: String, removeState: Int) -> Int
    {
		print("=====================================")
		print("*deleteItem()")
		print("=====================================")
		print(" -epcCode:\(epcCode)")
		print(" -prodCode:\(prodCode)")
		
        var intReturnRowState = 0
        let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo
		var arrItemList = clsEpcInfo.getItemes()
		
		print(" -arrItemList.count:\(arrItemList.count)")
		
        
        for (index, clsItem) in arrItemList.enumerated()
        {
			print("@@@@@@@@@@ epcCode:\(clsItem.getEpcCode()), ProdCode:\(clsItem.getProdCode())")
            if(clsItem.getEpcCode() == epcCode && clsItem.getProdCode() == prodCode)
            {
                if(removeState == Constants.REMOVE_STATE_NORMAL)
                {
                    if(clsItem.getRowState() == Constants.DATA_ROW_STATE_ADDED)
                    {
                        //자료구조에서 삭제
                        arrItemList.remove(at: index)
                        intReturnRowState = Constants.DATA_ROW_STATE_ADDED
                        break
                    }
                    else
                    {
                        intReturnRowState = Constants.DATA_ROW_STATE_DELETED
                        break
                    }
				}
				else if(removeState == Constants.REMOVE_STATE_COMPLETE)
				{
                    //자료구조에서 삭제
                    arrItemList.remove(at: index)
                }
            }
        }
		
		// 배열을 초기화하고 다시 집어넣는다.
		var arrNewItemData:Array<ItemInfo> = Array<ItemInfo>()
		arrNewItemData.append(contentsOf: arrItemList)
		clsEpcInfo.removeAllItems()
		clsEpcInfo.setItemes(itemes: arrNewItemData)
        return intReturnRowState
    }
    

    /**
     * 해시맵에 저장된 리스트 읽기
     * @param epcCode     EPC코드(해시맵 키)
     */
    func getItemes(epcCode: String) -> Array<ItemInfo>
    {
        let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo
        return clsEpcInfo.getItemes()
    }

    /**
     * 헤시맵에서 Item제거
     * @param epcCode         EPC코드(해시맵 키)
     * @param prodCode        상품정보코드
     */
    func removeItem(epcCode: String, prodCode: String)
    {
		let clsEpcInfo = mDicPallet[epcCode] as! EpcInfo
        var arrItemList = clsEpcInfo.getItemes()
        for (index, clsItem) in arrItemList.enumerated()
        {
            if(clsItem.getEpcCode() == epcCode && clsItem.getProdCode() == prodCode)
            {
                //자료구조에서 삭제
                arrItemList.remove(at: index)
                break
            }
        }
    }


    /**
     * EPC정보 업데이트
     * @param epcCode         EPC코드(해시맵 키)
     * @param itemInfo        상품정보코드
     */
//    func updateEpc(epcCode: String, clsEpcInfo: EpcInfo)
//    {
//        let clsFindEpcInfo = mDicPallet[epcCode] as! EpcInfo
//        if(clsFindEpcInfo != nil)
//        {
//            clsFindEpcInfo = clsEpcInfo
//        }
//    }

    /**
     * 전송용으로 DataTable을 만든다.
     * @return clsTable            데이터 테이블
     */
    func getDataTable() -> DataTable
    {
        let clsDataTable = DataTable()
        clsDataTable.Id = "WORK_OUT"
        
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "traceDateTime", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "barcodeId", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "itemCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "prodCnt", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "saleItemSeq", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
 
        for (strKey, value) in mDicPallet
        {
            let clsEpcInfo = value as! EpcInfo
            let arrItemList = clsEpcInfo.getItemes()
            if(arrItemList.count > 0)
            {
                //서브 그리드에 - 입력된 바코드 정보가 있는경우
                for clsItem in arrItemList
                {
                    if(clsItem.getRowState() != Constants.DATA_ROW_STATE_UNCHANGED)
                    {
                        let strTraceDate = DateUtil.localeToUtc(localeDate: clsItem.getReadTime(), dateFormat: "yyyyMMddHHmmss");

                        let clsDataRow = DataRow()
                        clsDataRow.State = clsItem.getRowState()
                        clsDataRow.addRow(name: "epcCode", value: clsItem.getEpcCode())
                        clsDataRow.addRow(name: "traceDateTime", value: strTraceDate)
                        clsDataRow.addRow(name: "barcodeId", value: clsItem.getProdCode())
                        clsDataRow.addRow(name: "itemCode", value: clsItem.getProdCode())
                        clsDataRow.addRow(name: "prodCnt", value: clsItem.getProdReadCnt())
                        clsDataRow.addRow(name: "saleItemSeq", value: clsItem.getSaleItemSeq())
                        clsDataTable.addDataRow(dataRow: clsDataRow)
                    }
                }
            }
            else
            {
                if(clsEpcInfo.getRowState() != Constants.DATA_ROW_STATE_UNCHANGED)
                {
                    let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
                    let strUtcCurReadTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")

                    // 서브 그리드에 - 바코드 정보가 없는경우
                    let clsDataRow = DataRow()
                    clsDataRow.State = clsEpcInfo.getRowState()
                    clsDataRow.addRow(name: "epcCode", value: strKey)
                    clsDataRow.addRow(name: "traceDateTime", value: strUtcCurReadTime)
                    clsDataRow.addRow(name: "barcodeId", value: "")
                    clsDataRow.addRow(name: "itemCode", value: "")
                    clsDataRow.addRow(name: "prodCnt", value: "0")
                    clsDataTable.addDataRow(dataRow: clsDataRow)
                }
            }
        }
        return clsDataTable
    }
 
}
