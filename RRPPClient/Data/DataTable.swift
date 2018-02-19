//
//  dataColumn.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 10..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public class DataTable : NSObject, NSCopying
{
    private var mStrId : String
    private var mStrTableName: String
    private var mArlDataColumn : [DataColumn]
    private var mArlDataRow : [DataRow]
    //private var mIntDataHanderType : DataSourceMgr.DATA_HANDLER_AJAX;
    private var mIntDataHanderType : Int = 1
    
    public override init()
    {
        self.mArlDataColumn = [DataColumn]()
        self.mArlDataRow = [DataRow]()
        self.mStrId = ""
        self.mStrTableName = ""
        super.init()
    }
    
    public init(id: String)
    {
        self.mArlDataColumn = [DataColumn]()
        self.mArlDataRow = [DataRow]()
        self.mStrId = id
        self.mStrTableName = ""
        super.init()
    }
    
    public init(id: String, tableName: String)
    {
        self.mArlDataColumn = [DataColumn]()
        self.mArlDataRow = [DataRow]()
        self.mStrId = id
        self.mStrTableName = tableName
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = DataTable()
        
//        DataTable dtTable = (DataTable)super.clone();
//
//        // 먼저 클론을 넣어주고
//        dtTable.mArlDataColumn = (ArrayList<DataColumn>)mArlDataColumn.clone();
//        dtTable.mArlDataRow = (ArrayList<DataRow>)mArlDataRow.clone();
//
//
//        // 클리어 한 다음 다시 클론을 넣어줘야 함.
//        dtTable.mArlDataColumn.clear();
//        for(int intIndex = 0; intIndex < mArlDataColumn.size(); intIndex++)
//        {
//            DataColumn dcDataColumn = (DataColumn)(mArlDataColumn.get(intIndex)).clone();
//            dtTable.mArlDataColumn.add(dcDataColumn);
//        }
//
//        dtTable.mArlDataRow.clear();
//        for(int intIndex = 0; intIndex < mArlDataRow.size(); intIndex++)
//        {
//            DataRow clsRow = (DataRow)(mArlDataRow.get(intIndex)).clone();
//            dtTable.mArlDataRow.add(clsRow);
//        }
        
        return copy
        
        //TODO:: 깊은복사
        //        DataColumn drRow = (DataColumn)super.clone();
        //        return drRow;
    }
    
    public func close() -> Void
    {
        for dataColumn in self.mArlDataColumn
        {
            dataColumn.close()
        }
        
        for dataRow in self.mArlDataRow
        {
            dataRow.close()
        }
        
        self.mArlDataColumn.removeAll()
        self.mArlDataRow.removeAll()
        
        mStrId = ""
        mStrTableName = ""
    }
    
    public var Id: String {
        set { self.mStrId = newValue }
        get {return mStrId }
    }
    
    public var TableName: String {
        set { self.mStrTableName = newValue }
        get {return mStrTableName }
    }
    
    public var DataHandlerType: Int {
        set { self.mIntDataHanderType = newValue }
        get {return mIntDataHanderType }
    }
    
    public func getDataColumns() -> [DataColumn]
    {
        return self.mArlDataColumn
    }
    
    public func getDataColumn(columnName: String) -> DataColumn?
    {
        for dataColumn in self.mArlDataColumn
        {
            if(dataColumn.Id == columnName)
            {
                return dataColumn
            }
        }
        return nil
    }
    
    
    public func addDataColumn(dataColumn: DataColumn) -> Void
    {
        self.mArlDataColumn.append(dataColumn)
    }
    
    public func removeDataColumn(columnName: String) -> Void
    {
        var index = 0
        for dataColumn in self.mArlDataColumn
        {
            if(dataColumn.Id == columnName)
            {
                //remove
                self.mArlDataColumn.remove(at:index)
                return
            }
            index += 1
        }
    }
    
    public func  getDataRows() -> [DataRow]
    {
        return self.mArlDataRow;
    }
    
    public func addDataRow(dataRow: DataRow) -> Void
    {
        self.mArlDataRow.append(dataRow)
    }
    
    public func toXmlString() -> String
    {
        var resultValue = ""
        if(self.Id.isEmpty)
        {
           resultValue.append("<dataTable id='dtTable'>")
        }
        else
        {
            resultValue.append("<dataTable id='" + self.Id + "'>")
        }
        
        //-------------------------------------------------------------------
        // Data Column
        //-------------------------------------------------------------------
        resultValue.append("<cols>")
        
        for dataColumn in self.getDataColumns()
        {
            resultValue.append(dataColumn.toXmlString())
        }
        
        resultValue.append("</cols>");
    
        //-------------------------------------------------------------------
        // Data Row
        //-------------------------------------------------------------------
        for dataRow in self.getDataRows()
        {
            resultValue.append(dataRow.toXmlString())
        }
        
        resultValue.append("</rows>")
        resultValue.append("</dataTable>")
        return resultValue
    }
    
    
    /**
     * 저장할 항목을 XML형태로 리턴한다.
     * @return
     */
    
    public func getChangedData() -> String
    {
        var resultValue = ""
        if(self.Id.isEmpty)
        {
            resultValue.append("<dataTable id='dtTable'>")
        }
        else
        {
            resultValue.append("<dataTable id='" + self.Id + "'>")
        }
        
        //-------------------------------------------------------------------
        // Data Column
        //-------------------------------------------------------------------
        resultValue.append("<cols>")
        
        for dataColumn in self.getDataColumns()
        {
            resultValue.append(dataColumn.toXmlString())
        }
        
        resultValue.append("</cols>");
        
        //-------------------------------------------------------------------
        // Data Row
        //-------------------------------------------------------------------
        resultValue.append("<rows>")
        for dataRow in self.getDataRows()
        {
            resultValue.append(dataRow.getChangedRow(dataHandlerType: self.DataHandlerType))
        }
        
        resultValue.append("</rows>")
        resultValue.append("</dataTable>")
        return resultValue
      }    
}
