//
//  dataColumn.swift
//  mfw
//
//  Created by MORAMCNT on 2017. 11. 10..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public class DataColumn : NSObject, NSCopying
{
    public static let DELIM_COLUMN_SIZE      = ","
    
    private var mStrId: String               = ""
    private var mStrType: String             = ""
    private var mStrSize: String             = ""
    private var mBoolKeyColumn: Bool         = true
    private var mBoolUpdateColumn: Bool      = false
    private var mBoolAutoIncrement: Bool     = false
    private var mBoolCanXlsExport: Bool      = true
    private var mStrTitle: String            = ""
    
    public override init()
    {
        super.init()
    }
    
    
    public init(id: String)
    {
        self.mStrId = id
        super.init()
    }
    
	public init(id: String, type: String, size : String, keyColumn: Bool, updateColumn: Bool, autoIncrement: Bool, canXlsExport: Bool, title: String)
    {
        self.mStrId                  = id
        self.mStrType                = type
        self.mStrSize                = size
        self.mBoolKeyColumn          = keyColumn
        self.mBoolUpdateColumn       = updateColumn
        self.mBoolAutoIncrement      = autoIncrement
        self.mBoolCanXlsExport       = canXlsExport
        self.mStrTitle               = title
    }
    
    public init(id: String, type: String, size : String, keyColumn: String, updateColumn: String, autoIncrement: String, canXlsExport: String, title: String)
    {
        self.mStrId                  = id
        self.mStrType                = type
        self.mStrSize                = size
        
        self.mBoolKeyColumn = false
        if(keyColumn.lowercased() == "true"){
            self.mBoolKeyColumn = true
        }
        
        self.mBoolUpdateColumn = false
        if(updateColumn.lowercased() == "true"){
            self.mBoolUpdateColumn = true
        }
        
        self.mBoolAutoIncrement = false
        if(autoIncrement.lowercased() == "true"){
            self.mBoolAutoIncrement = true
        }
        
        self.mBoolCanXlsExport = false
        if(canXlsExport.lowercased() == "true"){
            self.mBoolCanXlsExport = true
        }
        
        self.mStrTitle               = title
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = DataColumn()
        return copy
        
        //TODO:: 깊은복사
        //        DataColumn drRow = (DataColumn)super.clone();
        //        return drRow;
    }
    
    public var Id: String {
        set { self.mStrId = newValue }
        get {return mStrId }
    }
    
    public var ColType: String {
        set { self.mStrType = newValue }
        get {return mStrType }
    }
    
    public var Size: String {
        set { self.mStrSize = newValue }
        get {return mStrSize }
    }
    
    public var KeyColumn: Bool {
        set { self.mBoolKeyColumn = newValue }
        get {return mBoolKeyColumn }
    }
    
    public var UpdateColumn: Bool {
        set { self.mBoolUpdateColumn = newValue }
        get {return mBoolUpdateColumn }
    }
    
    public var AutoIncrement: Bool {
        set { self.mBoolAutoIncrement = newValue }
        get {return mBoolAutoIncrement }
    }
    
    public var CanXlsExport: Bool {
        set { self.mBoolCanXlsExport = newValue }
        get {return mBoolCanXlsExport }
    }
    
    public var Title: String {
        set { self.mStrTitle = newValue }
        get {return mStrTitle }
    }
    
    public func toXmlString() -> String
    {
        var resultValue = "<col"
        resultValue.append(" id='" + self.Id + "'")
        resultValue.append(" type='" + self.ColType + "'")
        resultValue.append(" size='" + self.Size + "'")
        resultValue.append(" keyColumn='" + self.KeyColumn.description + "'")
        resultValue.append(" updateColumn='" + self.UpdateColumn.description + "'")
        resultValue.append(" autoIncrement='" + self.AutoIncrement.description + "'")
        resultValue.append(" canXlsExport='" + self.CanXlsExport.description + "'")
        resultValue.append(" title='" + self.Title + "'")
        resultValue.append("/>")
    return resultValue
    }
    
    public func close() -> Void
    {
        mStrId              = ""
        mStrType            = ""
        mStrSize            = ""
        mBoolUpdateColumn    = false
        mBoolKeyColumn        = true
        mBoolAutoIncrement    = false
        mBoolCanXlsExport    = true
        mStrTitle            = ""
    }
}
