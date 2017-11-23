//
//  dataRow.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 9..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public enum  DataError: Error {
    case indexRowError(reason: String)
    case indexValeError(reason: String)
}

public class DataRow : NSObject, NSCopying
{
    public static let DATA_ROW_STATE_UNCHANGED : Int      = 0;    /**< 데이터 상태 : 변화업음 **/
    public static let DATA_ROW_STATE_ADDED : Int          = 1;    /**< 데이터 상태  : 추가됨 **/
    public static let DATA_ROW_STATE_MODIFIED : Int       = 2;    /**< 데이터 상태  : 변경됨 **/
    public static let DATA_ROW_STATE_DELETED : Int        = 3;    /**< 데이터  : 삭제됨 **/
    
    public static let DELIM_DATASET_RECORD                = "ζ"; // zeta = "ST"
    public static let DELIM_DATASET_RECORD_LINE_FEED      = "η"; // zeta = "TEST"

    
    private var mIntId : Int?
    private var mIntState : Int = DataRow.DATA_ROW_STATE_UNCHANGED
    private var mIntRowKeyNo : Int = 0
    
    private var mVecDataRowName : [String]
    private var mVecDataRowValue : [Any]
    
    override init()
    {
        mIntId = 0
        self.mIntState       = DataRow.DATA_ROW_STATE_UNCHANGED
        self.mIntRowKeyNo    = 0
        self.mVecDataRowName    = [String]()
        self.mVecDataRowValue    = [Any]()
        
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = DataRow()
        return copy
        
        //TODO:: 깊은복사
        //DataRow drRow = (DataRow)super.clone();
        //drRow.mVecDataRowName    = (Vector)this.mVecDataRowName.clone();
        //drRow.mVecDataRowValue    = (Vector)this.mVecDataRowValue.clone();
        
    }
    
    public var DataRowNames: [String] {
        set { self.mVecDataRowName = newValue }
        get {return mVecDataRowName }
    }
    
    public var State: Int {
        set { self.mIntState = newValue }
        get {return mIntState }
    }
    
    public var Id: Int? {
        set { self.mIntId = newValue }
        get {return mIntId }
    }
    
    public var RowKeyNo: Int {
        set { self.mIntRowKeyNo = newValue }
        get {return mIntRowKeyNo }
    }
    
    /**
     *    해당 DataRow에 데이터를 추가한다.
     */
    public func addRow(value : Any) -> Void
    {
        self.mVecDataRowValue.append(value)
    }
    
    /**
     *    해당 컬럼에 컬럼명과 데이터를 추가한다.
     */
    public func addRow(name: String, value: Any) -> Void
    {
        self.mVecDataRowName.append(name)
        self.mVecDataRowValue.append(value)
    }
    
    /**
     *    해당 컬럼에 컬럼명과 데이터를 제거한다.
     */
    public func removeRow(name: String) throws -> Void
    {
        guard let intIndex = self.mVecDataRowName.index(of:name) else
        {
            throw DataError.indexValeError(reason: String(format: "setColumn(), 해당 데이터 %@가 없습니다", name))            
        }
        
        self.mVecDataRowName.remove(at: intIndex)
        self.mVecDataRowValue.remove(at: intIndex)
    }
    
    /**
     *    해당 인덱스의 컬럼 데이터를 설정한다.
     */
    public func setRow( index: Int, value : Any) throws -> Void
    {
        let isIndexValid = self.mVecDataRowValue.indices.contains(index)
        if(!isIndexValid)
        {
            throw DataError.indexValeError(reason: "해당 인덱스가 존재하지 않습니다.")
        }
        self.mVecDataRowValue[index] = value
    }
    
    /**
     * 해당 인덱스의 컬럼 정수 데이터를 설정한다.
     * @param intIndex
     * @param intValue
     * @throws Exception
     */
    public func setRow(index: Int, value: Int) throws -> Void
    {
        let isIndexValid = self.mVecDataRowValue.indices.contains(index)
        if(!isIndexValid)
        {
            throw DataError.indexValeError(reason: "해당 인덱스가 존재하지 않습니다.")            
        }
        let strValue = String(value)
        self.mVecDataRowValue[index] = strValue
    }
    
    
    public func setRow(name: String, value: String) throws -> Void
    {
        guard let intIndex = self.mVecDataRowName.index(of:name) else
        {
            throw DataError.indexValeError(reason: String(format: "setColumn(), 해당 데이터 %@가 없습니다", name))
        }
        self.mVecDataRowValue[intIndex] = value
    }
    
    /**
     * Record의 해당 필드의 String Type 데이터가 srcData와 일치할 경우 modifiedData로 변환한다.
     *
     * @param strName
     * @param strFindName
     * @param modifiedData
     * @throws Exception
     */
    public func setRow(name: String, findName: String, modifiedData: String) -> Void
    {
        if let value : String = self.getString(name: name), value == findName
        {
            do
            {
                try self.setRow(name:value, value: modifiedData)
            } catch DataError.indexValeError(let reason) {
                print("알수없는 오류발생:" + reason)
            } catch {
                print("알수없는 오류발생")
            }
        }
    }
    
    
    /**
     * Record의 해당 필드의 String Type 데이터가 srcData와 일치할 경우 modifiedData로 변환한다.
     */
    public func setRow( name: String, srcData: Int, modifiedData: Int) -> Void
    {
        if let value : Int = self.getInt(name: name), value == srcData
        {
            do
            {
                try self.setRow(index:value, value: modifiedData)
            } catch DataError.indexValeError(let reason) {
                print("알수없는 오류발생:" + reason)
            } catch {
                print("알수없는 오류발생")
            }
        }
    }
    
    
    /**
     *    이름으로 Column data 얻기...대소문자 구분안함
     */
    public func get(name : String, defaultValue: Any) -> Any?
    {
        do {
            let value = try get(name: name)
            return value
            
        } catch DataError.indexValeError {
            return defaultValue
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    public func getString(name : String, defaultValue: String) -> String?
    {
        do {
            let value = try get(name: name)
            return value as? String ?? ""
            
        } catch DataError.indexValeError {
            return defaultValue
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    
    /**
     *    이름으로 Column data 얻기...대소문자 구분안함
     */
    public func get(name: String) throws -> Any?
    {
        let strName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let intIndex = self.mVecDataRowName.index(of:strName) else        {
            throw DataError.indexValeError(reason: String(format: "setColumn(), 해당 데이터 %@가 없습니다", name))
        }
        return self.mVecDataRowValue[intIndex]
    }
    
    /**
     *    해당 Column의 데이터를 얻는다. (0-base)
     */
    public func get(index: Int) throws -> Any
    {
        let isIndexValid = self.mVecDataRowValue.indices.contains(index)
        if(!isIndexValid)
        {
            throw DataError.indexValeError(reason: "해당 인덱스가 존재하지 않습니다.")
        }
        return self.mVecDataRowValue[index];
    }
    
    /**
     *    이름으로 Column data 얻기...대소문자 구분안함
     */
    public func getString(name: String) -> String?
    {
        do {
            let value = try get(name: name)			
			return value as? String ?? ""
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    /**
     *    이름으로 Column data 얻기...대소문자 구분안함
     */
    public func getIntValue(index: Int)  -> Int?
    {
        do {
			let value  = try Int(self.get(index: index) as! String)
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    /**
     *    이름으로 Column data 얻기...대소문자 구분안함
     */
//    public func getIntValue(name: String) -> Int?
//    {
//        do {
//            let value = try Int(self.get(name: name) as! String)
//            return value
//        } catch DataError.indexValeError {
//            return nil
//        } catch {
//            print("알수없는 오류발생")
//        }
//        return nil
//    }
	
    public func getInt(name: String) -> Int?
    {
        do {
            let value = try Int(self.get(name: name) as! String)
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    
    public func getInt(name: String, defaultValue: Int) -> Int?
    {
        return self.getInt(name: name)
    }
    
    public func getLong(name: String) -> Int64?
    {
        do {
            let value =  try Long(self.get(name: name) as! String)
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    public func getDouble(name: String) -> Double?
    {
        do {
            let value = try Double(self.get(name: name) as! String)
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    public func getFloat(name: String) -> Float?
    {
        do {
            let value = try  try Float(self.get(name: name) as! String)
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    public func getBoolean(name: String) -> Bool?
    {
        do {
            let value = try self.get(name: name) as? Bool
            return value
        } catch DataError.indexValeError {
            return nil
        } catch {
            print("알수없는 오류발생")
        }
        return nil
    }
    
    
    /**
     *    해당 인덱스의 컬럼명을 변경한다.
     */
    public func setName(index: Int, name: String) throws -> Void
    {
        let isIndexValid = self.mVecDataRowName.indices.contains(index)
        if(!isIndexValid)
        {
            throw DataError.indexValeError(reason: "해당 인덱스가 존재하지 않습니다.")
        }
        self.mVecDataRowName[index] = name
    }
    
    
    
    /**
     *    해당 Column의 이름을 얻는다. (0-base)
     */
    public func getName(index: Int, name: String) throws -> String
    {
        let isIndexValid = self.mVecDataRowName.indices.contains(index)
        if(!isIndexValid)
        {
            throw DataError.indexValeError(reason: "해당 인덱스가 존재하지 않습니다.")
        }
        return self.mVecDataRowName[index]
    }
    
    
    public func hasName(name: String) -> Bool
    {
        guard let index = self.mVecDataRowName.index(of:name) else
        {
            return false
        }
        return (index > -1 )
    }
    
    
    /**
     * Column의 모든 데이터를 보여준다.
     */
    public func printAllRowNames() -> Void
    {
        var index = 0
        for (name) in self.mVecDataRowName.enumerated() {
            print("index: \(index): name: \(name)")
            index += 1
        }
    }
    
    public func size() -> Int
    {
        return self.mVecDataRowValue.count
    }
    
    public func capitalizingFirstLetter(source: String) -> String {
        return source.prefix(1).uppercased() + source.dropFirst().lowercased()
    }
    
    public func underscoreToCamel(source: String) -> String
    {
        let strArray = source.components(separatedBy: "_")
        var bIsFirst = true
        var strReturn = ""
        for strData in strArray
        {
            if(bIsFirst)
            {
                strReturn.append(strData.lowercased())
                bIsFirst = false
            }
            else
            {
                strReturn.append(capitalizingFirstLetter(source: strData))
            }
        }
        return strReturn
    }
    
    public func toMap() -> [String: Any]
    {
       // self.characters.split{$0 == " "}.map(String.init).map{$0.capitalizedString}.joinWithSeparator(" ")
        var map = [String: Any]()
        for index in 0...self.mVecDataRowName.count
        {
            let newName = underscoreToCamel(source: self.mVecDataRowName[index])
            map[newName] = self.mVecDataRowValue[index]
            
        }
        return map
    }
    
    
    
    public func toXmlString() -> String
    {
        var resultValue = "<row>"
        for value in self.mVecDataRowValue
        {
            resultValue.append(value as? String ?? "")
            resultValue.append(DataRow.DELIM_DATASET_RECORD)
        }
        resultValue.append("</row>")
        return resultValue
    }
    
    /**
     * 저장(삽입, 수정, 삭제)시에 바뀐Row를 리턴한다.
     * @return
     */
    
    
    
    public func getChangedRow() -> String
    {
        var resultValue = "<row id='"
		
		//value as? String ?? ""
        resultValue.append(String(describing:self.Id))
        resultValue.append("' state='")
        resultValue.append(String(self.State))
        resultValue.append("' rowKeyNo='" )
        resultValue.append(String(self.RowKeyNo))
        resultValue.append( "'>" )
        
        for index in 0...self.mVecDataRowName.count
        {
            let name = self.mVecDataRowName[index]
            let value = self.mVecDataRowValue[index]
            resultValue.append("<" + name + ">")
            resultValue.append(value as? String ?? "")
            resultValue.append("</" + name + ">")
        }
        resultValue.append("</row>")
        return resultValue
    }
    
    public func getChangedRow(dataHandlerType: Int) -> String
    {
        //var resultValue = "<row id='"
        //resultValue.append(self.Id + "' state='" + self.State + "' rowKeyNo='" + self.RowKeyNo + "'>")
        var resultValue = "<row id='"
        resultValue.append(String(describing:self.Id) )
        resultValue.append("' state='")
        resultValue.append(String(self.State))
        resultValue.append("' rowKeyNo='" )
        resultValue.append(String(self.RowKeyNo))
        resultValue.append( "'>" )
        
        if(dataHandlerType == 1)
        {
            for index in 0...self.mVecDataRowName.count
            {
                let name = self.mVecDataRowName[index]
                let value = self.mVecDataRowValue[index]
                resultValue.append("<" + name + ">")
                resultValue.append(value as? String ?? "")
                resultValue.append("</" + name + ">")
            }
        }
        else
        {
            for value in self.mVecDataRowValue
            {
                resultValue.append(value as? String ?? "")
                resultValue.append(DataRow.DELIM_DATASET_RECORD)
            }
        }
        resultValue.append("</row>")
        return resultValue
    }
    
    public func close() -> Void
    {
        self.mVecDataRowName.removeAll()
        self.mVecDataRowValue.removeAll()
    }
}

