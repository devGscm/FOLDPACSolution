//
//  DataSourceMgr.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 10..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//
import SWXMLHash
import Foundation

public class DataSourceMgr : NSObject
{
    public static let    NOTATION_NONE                   = 0
    public static let    NOTATION_CAMEL_TO_UNDERSOCRE    = 1
    public static let    NOTATION_UNDERSOCRE_TO_CAMEL    = 2
    
    public static let DATA_HANDLER_AJAX       = 1    // Ajax
    public static let DATA_HANDLER_WCF        = 2    // WCF
    public static let DATA_HANDLER_RESTFUL    = 3    // Restful
    
    
    private var mClsDataTable : DataTable?
    private var mIntNotation : Int = DataSourceMgr.NOTATION_CAMEL_TO_UNDERSOCRE
    private var mIntDataHanderType : Int = DataSourceMgr.DATA_HANDLER_AJAX
    
    public override init()
    {
        self.mClsDataTable = DataTable()
        self.mIntNotation = DataSourceMgr.NOTATION_CAMEL_TO_UNDERSOCRE
        self.mIntDataHanderType = DataSourceMgr.DATA_HANDLER_AJAX
        super.init()
    }
    
    public var Notation: Int {
        set { self.mIntNotation = newValue }
        get { return self.mIntNotation }
    }
    
    public func parse(data: String) -> Bool
    {
        let sourceData = data.replacingOccurrences(of: "&", with: "&amp;")
        let xml = SWXMLHash.config {
            config in
            config.shouldProcessLazily = false
        }.parse(sourceData)

        if let strDataTableId : String =  xml["dataTable"][0].element?.attribute(by: "id")?.text
        {
            self.mClsDataTable?.TableName = strDataTableId
        }
        
        var strId       = ""
        var strTitle    = ""
        var strType      = ""
        var strSize     = "0"
        var strKeyColumn = "False"
        var strUpdateColumn = "False"
        var strAutoIncrement = "False"
        var strCanXlsExport    = "True"
        
        print("##########xml start###########")
        print(data)
        print("##########xml end###########")
        
        for elem in xml["dataTable"]["cols"]["col"].all
        {
            if let colVal = elem.element?.attribute(by: "id")?.text
            {
                strId = colVal
            }
            if let colVal = elem.element?.attribute(by: "title")?.text
            {
                strTitle = colVal
            }
            if let colVal = elem.element?.attribute(by: "type")?.text
            {
                strType = colVal
            }
            if let colVal = elem.element?.attribute(by: "size")?.text
            {
                strSize = colVal
            }
            if let colVal = elem.element?.attribute(by: "keyColumn")?.text
            {
                strKeyColumn = colVal
            }
            if let colVal = elem.element?.attribute(by: "updateColumn")?.text
            {
                strUpdateColumn = colVal
            }
            if let colVal = elem.element?.attribute(by: "autoIncrement")?.text
            {
                strAutoIncrement = colVal
            }
            if let colVal = elem.element?.attribute(by: "canXlsExport")?.text
            {
                strCanXlsExport = colVal
            }
            
            print("parse Id:" + strId + ", Type:" + strType + ", Size:" + strSize + ", KeyColumn:" + strKeyColumn + ",UpdateColumn:" + strUpdateColumn + ", AutoIncrement:" + strAutoIncrement)
            
            self.mClsDataTable!.addDataColumn(dataColumn: DataColumn(id: strId, type: strType, size: strSize, keyColumn: strKeyColumn, updateColumn: strUpdateColumn, autoIncrement: strAutoIncrement, canXlsExport: strCanXlsExport, title: strTitle))
            
        }
        
        var dataColumns =  mClsDataTable?.getDataColumns()
        
        for elem in xml["dataTable"]["rows"]["row"].all
        {
            let dataRow : DataRow = DataRow()
            if let colVal = elem.element?.attribute(by: "state")?.text
            {
                dataRow.State = Int(colVal) ?? 0
            }
            if let colVal = elem.element?.attribute(by: "rowKeyNo")?.text
            {
                dataRow.RowKeyNo = Int(colVal) ?? 0
            }
            if let rowData = elem.element?.text
            {
                let arsRecord = rowData.components(separatedBy: DataRow.DELIM_DATASET_RECORD)
                var index : Int = 0
                for record in arsRecord
                {
                    if index < dataColumns!.count
                    {
                        let dataCol = dataColumns![index]
                        let recordDecode = QueryMaker.htmlDecode(srcText: record)
                        dataRow.addRow(name: dataCol.Id, value: recordDecode)
                        index += 1
                    }
                }
            }
            self.mClsDataTable!.addDataRow(dataRow: dataRow)
        }
        return true
    }

    public func  getDataColumn(columnName: String) -> DataColumn?
    {
        return self.mClsDataTable!.getDataColumn(columnName: columnName)
    }
    
    public func getDataRows() -> [DataRow]
    {
        return self.mClsDataTable!.getDataRows()
    }
    
    public func getDataSource() -> String
    {
        return self.mClsDataTable!.toXmlString()
    }
    
    public func getDataTable() -> DataTable
    {
        return self.mClsDataTable!
    }
    
    public func getChangedData() -> String
    {
        return self.mClsDataTable!.getChangedData()
    }
}
