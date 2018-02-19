//
//  QueryMaker.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 10..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public class QueryMaker : NSObject, NSCopying
{
    public static let   DATABASE_TYPE_ORACLE            = 1
    public static let   DATABASE_TYPE_MSSQL             = 2
    public static let   DATABASE_TYPE_MYSQL             = 3
    public static let   DATABASE_TYPE_MARIADB           = 4
    
    public static let   DATABASE_NAME_ORACLE            = "ORACLE"
    public static let   DATABASE_NAME_MSSQL             = "MSSQL"
    public static let   DATABASE_NAME_MYSQL             = "MYSQL"
    public static let   DATABASE_NAME_MARIADB           = "MARIADB"
    
    public static let   DATA_TYPE_DATETIME              = "datetime"
    public static let   DATA_TYPE_DATE                  = "date"
    public static let   DATA_TYPE_TIME                  = "time"
    
    public static let   DATA_TYPE_SHORT                 = "short"
    public static let   DATA_TYPE_INT                   = "int"
    public static let   DATA_TYPE_LONG                  = "long"
    public static let   DATA_TYPE_FLOAT                 = "float"
    public static let   DATA_TYPE_DOUBLE                = "double"
    public static let   DATA_TYPE_DECIMAL               = "decimal"
    
    private var mIntDataBaseType : Int        = DATABASE_TYPE_ORACLE
    private var mStrDataBaseName : String     = DATABASE_NAME_ORACLE
    private var mStrTableName : String  = ""
    
    public override init()
    {
        self.mIntDataBaseType    = QueryMaker.DATABASE_TYPE_ORACLE
        self.mStrDataBaseName    = QueryMaker.DATABASE_NAME_ORACLE
        self.mStrTableName = ""
        super.init()
    }
    
    public init(tableName : String)
    {
        self.mIntDataBaseType    = QueryMaker.DATABASE_TYPE_ORACLE
        self.mStrDataBaseName    = QueryMaker.DATABASE_NAME_ORACLE
        self.mStrTableName = tableName
        super.init()
    }
    
    public init(dataBaseName : String, tableName: String)
    {
        super.init()
        self.mIntDataBaseType    = self.getDataBaseTypeFromName(dataBaseName: dataBaseName)
        self.mStrTableName       = tableName
        
    }
    
    public var DataBaseName: String {
        set {
            self.mStrDataBaseName = newValue
            self.mIntDataBaseType =  self.getDataBaseTypeFromName(dataBaseName: newValue)
        }
        get {return self.mStrDataBaseName }
    }
    
    public var TableName: String {
        set { self.mStrTableName = newValue }
        get { return self.mStrTableName }
    }
    
    private func getDataBaseTypeFromName(dataBaseName: String) -> Int
    {
        self.mStrDataBaseName = dataBaseName.uppercased()
        var intDbType : Int = QueryMaker.DATABASE_TYPE_ORACLE
        if(QueryMaker.DATABASE_NAME_ORACLE == dataBaseName )
        {
            intDbType = QueryMaker.DATABASE_TYPE_ORACLE
        }
        else if(QueryMaker.DATABASE_NAME_MSSQL == dataBaseName)
        {
            intDbType = QueryMaker.DATABASE_TYPE_MSSQL
        }
        else if(QueryMaker.DATABASE_NAME_MYSQL == dataBaseName)
        {
            intDbType = QueryMaker.DATABASE_TYPE_MYSQL
        }
        else if(QueryMaker.DATABASE_NAME_MARIADB == dataBaseName)
        {
            intDbType = QueryMaker.DATABASE_TYPE_MARIADB
        }
        return intDbType
    }
    
    private func getDataBaseNameFromType(dataBaseType: Int) -> String
    {
        self.mIntDataBaseType = dataBaseType
        var strDataBaseName : String = QueryMaker.DATABASE_NAME_ORACLE
        if(QueryMaker.DATABASE_TYPE_ORACLE == mIntDataBaseType)
        {
            strDataBaseName = QueryMaker.DATABASE_NAME_ORACLE
        }
        else if(QueryMaker.DATABASE_TYPE_MSSQL == mIntDataBaseType)
        {
            strDataBaseName = QueryMaker.DATABASE_NAME_MSSQL
        }
        else if(QueryMaker.DATABASE_TYPE_MYSQL == mIntDataBaseType)
        {
            strDataBaseName = QueryMaker.DATABASE_NAME_MYSQL
        }
        else if(QueryMaker.DATABASE_TYPE_MARIADB == mIntDataBaseType)
        {
            strDataBaseName = QueryMaker.DATABASE_NAME_MARIADB
        }
        return strDataBaseName
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
    
    private func convertMSSQLData(clsColumn : DataColumn, data: String) -> String
    {
        var strReturnData : String = ""
        let strColumnType : String = clsColumn.ColType
        
        if( QueryMaker.DATA_TYPE_DATETIME == strColumnType || QueryMaker.DATA_TYPE_DATE == strColumnType || QueryMaker.DATA_TYPE_TIME == strColumnType)
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            if let dateTemp = formatter.date(from: data)
            {
                formatter.dateFormat = "yyyyMMdd HH:mm:ss"
                strReturnData = "CONVERT(datetime,'" + formatter.string(from: dateTemp) + "',20)"
            }
            
        }
        else if( QueryMaker.DATA_TYPE_SHORT == strColumnType || QueryMaker.DATA_TYPE_INT == strColumnType || QueryMaker.DATA_TYPE_LONG == strColumnType
            || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_DECIMAL == strColumnType)
        {
            if(data == "")
            {
                strReturnData = "null";
            }
            else
            {
                strReturnData = self.getFormatNumber(data: data, columnSize : clsColumn.Size)
            }
        }
        else
        {
            strReturnData = "'" + data + "'"
        }
        return strReturnData
    }
    
    private func convertOracleData(clsColumn : DataColumn, data: String) -> String
    {
        var strReturnData : String = ""
        let strColumnType : String = clsColumn.ColType
        
        if( QueryMaker.DATA_TYPE_DATETIME == strColumnType || QueryMaker.DATA_TYPE_DATE == strColumnType || QueryMaker.DATA_TYPE_TIME == strColumnType)
        {
            strReturnData = "TO_DATE('" + data + "','YYYYMMDDHH24MISS')"
        }
        else if( QueryMaker.DATA_TYPE_SHORT == strColumnType || QueryMaker.DATA_TYPE_INT == strColumnType || QueryMaker.DATA_TYPE_LONG == strColumnType
            || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_DECIMAL == strColumnType)
        {
            if(data == "")
            {
                strReturnData = "null";
            }
            else
            {
                strReturnData = self.getFormatNumber(data: data, columnSize : clsColumn.Size)
            }
        }
        else
        {
            strReturnData = "'" + data + "'"
        }
        return strReturnData
    }
    
    private func convertMySQLData(clsColumn : DataColumn, data: String) -> String
    {
        var strReturnData : String = ""
        let strColumnType : String = clsColumn.ColType
        
        if( QueryMaker.DATA_TYPE_DATETIME == strColumnType || QueryMaker.DATA_TYPE_DATE == strColumnType || QueryMaker.DATA_TYPE_TIME == strColumnType)
        {
            strReturnData = "STR_TO_DATE('" + data + "','%Y%m%d%H%i%s')"
        }
        else if( QueryMaker.DATA_TYPE_SHORT == strColumnType || QueryMaker.DATA_TYPE_INT == strColumnType || QueryMaker.DATA_TYPE_LONG == strColumnType
            || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_FLOAT == strColumnType || QueryMaker.DATA_TYPE_DECIMAL == strColumnType)
        {
            if(data == "")
            {
                strReturnData = "null";
            }
            else
            {
                strReturnData = self.getFormatNumber(data: data, columnSize : clsColumn.Size)
            }
        }
        else
        {
            strReturnData = "'" + data + "'"
        }
        return strReturnData
    }
    
    public func getQuery(tableName: String, columnList: [DataColumn], dataRow: DataRow) -> String
    {
        self.mStrTableName = tableName
        return self.getQuery(columnList: columnList, dataRow: dataRow)
    }
    
    /**
     * 특수문자를 인코딩한다.
     * @param strSrcText 원문
     * @return   변환된 텍스트
     */
    public static func htmlEncode(srcText : String) -> String
    {
        if (srcText.isEmpty)
        {
            return ""
        }
        var strResult = srcText
        strResult = strResult.replacingOccurrences(of: "&", with: "&amp;")
        strResult = strResult.replacingOccurrences(of: "<", with: "&lt;")
        strResult = strResult.replacingOccurrences(of: ">", with: "&qt;")
        strResult = strResult.replacingOccurrences(of: "\"", with: "&quot;")
        strResult = strResult.replacingOccurrences(of: "'", with: "&#039;")
        return strResult
    }
    
    /**
     * 특수문자를 디코딩한다.
     * @param strSrcText
     * @return java.lang.String
     */
    public static func htmlDecode(srcText: String) -> String
    {
        if (srcText.isEmpty)
        {
            return ""
        }
        var strResult = srcText
        strResult = strResult.replacingOccurrences(of: "&amp;", with: "&")
        strResult = strResult.replacingOccurrences(of: "&lt;", with: "<")
        strResult = strResult.replacingOccurrences(of: "&gt;", with: ">")
        strResult = strResult.replacingOccurrences(of: "&quot;", with: "\"")
        strResult = strResult.replacingOccurrences(of: "&#039;", with: "'")
        return strResult
    }
    
    public func getQuery(columnList: [DataColumn], dataRow: DataRow) -> String
    {
        var strRecult : String = ""
        var strData = ""
        
        //------------------------------------------------------------------------------
        // Add
        //------------------------------------------------------------------------------
        if(dataRow.State == DataRow.DATA_ROW_STATE_ADDED)
        {
            var strColumnNames = ""
            var strColumnValues = ""
            
            for clsColumn in columnList
            {
                if(clsColumn.KeyColumn == true || clsColumn.AutoIncrement == true
                    || clsColumn.UpdateColumn == true || clsColumn.Id != "")
                {
                    do {
                        let value = try dataRow.get(name: clsColumn.Id)
                        strData = value as? String ?? ""
                    } catch DataError.indexValeError {
                        strData = ""
                    } catch {
                        print("알수없는 오류발생")
                    }
                    strData = strData.replacingOccurrences(of: "'", with: "&#146;")
                    
                    
                    if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_ORACLE)
                    {
                        if(clsColumn.AutoIncrement == true)
                        {
                            strData = "SEQ_" + self.mStrTableName + ".NEXTVAL"
                        }
                        else
                        {
                            strData = self.convertOracleData(clsColumn: clsColumn, data: strData)
                        }
                    }
                    else if(self.mIntDataBaseType  == QueryMaker.DATABASE_TYPE_MSSQL)
                    {
                        strData = convertMSSQLData(clsColumn: clsColumn, data: strData);
                    }
                    else if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MYSQL  || self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MARIADB)
                    {
                        strData = convertMySQLData(clsColumn: clsColumn, data: strData)
                    }
                    else
                    {
                        strData = "'" + strData + "'"
                    }
                    
                    
                    if(self.mIntDataBaseType != QueryMaker.DATABASE_TYPE_ORACLE && clsColumn.AutoIncrement == true)
                    {
                        // MySQL/MariaDB, MySQL 의 경우 자동증가 컬럼은 입력시 뺀다.
                        //System.out.println("======================================");
                        //System.out.println(" *AutoIncrement Column, ColId:"+ clsColumn.getId());
                        //System.out.println("======================================");
                    }
                    else
                    {
                        strColumnNames   += clsColumn.Id + ","
                        strColumnValues  += QueryMaker.htmlDecode(srcText: strData) + ","
                    }
                }
                
            }
            
            strRecult.append("INSERT INTO " + self.mStrTableName + "(")
            
            let intIndex1 = strColumnNames.range(of: ",", options: .backwards)?.lowerBound
            strRecult = strColumnNames.substring(to: intIndex1!)
            
            strRecult.append(") VALUES(")
            
            let intIndex2 = strColumnValues.range(of: ",", options: .backwards)?.lowerBound
            strRecult = strColumnValues.substring(to: intIndex2!)
            strRecult.append(")")
            
        }
        
        
        
        //------------------------------------------------------------------------------
        // 수정
        //------------------------------------------------------------------------------
        if(dataRow.State == DataRow.DATA_ROW_STATE_MODIFIED)
        {
            var strColumnInfo = ""
            var strWhere = ""
            
            for clsColumn in columnList
            {
                if(clsColumn.KeyColumn == true || clsColumn.AutoIncrement == true
                    || clsColumn.UpdateColumn == true || clsColumn.Id != "")
                {
                    do {
                        let value = try dataRow.get(name: clsColumn.Id)
                        strData = value as? String ?? ""
                    } catch DataError.indexValeError {
                        strData = ""
                    } catch {
                        print("알수없는 오류발생")
                    }
                    strData = strData.replacingOccurrences(of: "'", with: "&#146;")
                    
                    if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_ORACLE)
                    {
                        strData = self.convertOracleData(clsColumn: clsColumn, data: strData)
                    }
                    else if(self.mIntDataBaseType  == QueryMaker.DATABASE_TYPE_MSSQL)
                    {
                        strData = convertMSSQLData(clsColumn: clsColumn, data: strData);
                    }
                    else if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MYSQL  || self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MARIADB)
                    {
                        strData = convertMySQLData(clsColumn: clsColumn, data: strData)
                    }
                    else
                    {
                        strData = "'" + strData + "'"
                    }
                    
                    strData = QueryMaker.htmlDecode(srcText: strData)
                    
                    if(clsColumn.KeyColumn)
                    {
                        strWhere += " AND " + clsColumn.Id + " = " + strData
                    }
                    else if(clsColumn.UpdateColumn == true || clsColumn.AutoIncrement == true)
                    {
                        strColumnInfo += clsColumn.Id + "=" + strData + ","
                    }
                }
            }
            
            
            strRecult.append("UPDATE " + self.mStrTableName + " SET ")
            
            let intIndex1 = strColumnInfo.range(of: ",", options: .backwards)?.lowerBound
            strRecult = strColumnInfo.substring(to: intIndex1!)
            
            strRecult.append(" WHERE 1=1 ")
            strRecult.append( strWhere)
        }
        
        //------------------------------------------------------------------------------
        // 삭제
        //------------------------------------------------------------------------------
        if(dataRow.State == DataRow.DATA_ROW_STATE_DELETED)
        {
            var strWhere = ""
            
            for clsColumn in columnList
            {
                if(clsColumn.KeyColumn == true || clsColumn.AutoIncrement == true
                    || clsColumn.UpdateColumn == true || clsColumn.Id != "")
                {
                    do {
                        let value = try dataRow.get(name: clsColumn.Id)
                        strData = value as? String ?? ""
                    } catch DataError.indexValeError {
                        strData = ""
                    } catch {
                        print("알수없는 오류발생")
                    }
                    strData = strData.replacingOccurrences(of: "'", with: "&#146;")
                    
                    if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_ORACLE)
                    {
                        strData = self.convertOracleData(clsColumn: clsColumn, data: strData)
                    }
                    else if(self.mIntDataBaseType  == QueryMaker.DATABASE_TYPE_MSSQL)
                    {
                        strData = convertMSSQLData(clsColumn: clsColumn, data: strData);
                    }
                    else if(self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MYSQL  || self.mIntDataBaseType == QueryMaker.DATABASE_TYPE_MARIADB)
                    {
                        strData = convertMySQLData(clsColumn: clsColumn, data: strData)
                    }
                    else
                    {
                        strData = "'" + strData + "'"
                    }
                    
                    strData = QueryMaker.htmlDecode(srcText: strData)
                    
                    if(clsColumn.KeyColumn)
                    {
                        strWhere += " AND " + clsColumn.Id + " = " + strData
                    }
                }
            }
            
            strRecult.append("DELETE FROM " + self.mStrTableName + " ")
            strRecult.append(" WHERE 1=1 ")
            strRecult.append( strWhere)
        }
        return strRecult
    }
    
    private func getFormatNumber(data: String, columnSize: String) -> String
    {
        if let dataToConvert = Double(data)
        {
            if(columnSize.isEmpty)
            {
                return String(dataToConvert)
            }
            else
            {
                let arrData = columnSize.split(separator: ",")
                if(arrData.count >= 1)
                {
                    return String(format: "%." + arrData[1] + "f", arrData)
                }
                else
                {
                    return String(dataToConvert)
                }
            }
        }
        return ""
        
    }
    
    
}

