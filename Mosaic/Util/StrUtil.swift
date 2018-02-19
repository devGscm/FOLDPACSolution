//
//  StrUtil.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 11. 25..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

public class StrUtil
{
	public static func replace(sourceText: String, findText: String, replaceText : String) -> String
	{
		return sourceText.replacingOccurrences(of: findText, with: replaceText,
                                               options: String.CompareOptions.literal, range: nil)
	}
    

    public static func indexOf(sourceText: String, findText: String) -> Int?
    {
        if let range = sourceText.range(of: findText)
        {
            return sourceText.distance(from: sourceText.startIndex, to: range.lowerBound)
        }
        return nil
    }
    
    public static func lastIndexRaw(sourceText: String, of str: String, before: Int = 0) -> String.Index?
    {
        guard sourceText.count > 0 else
        {
            return nil
        }
        guard (str.count + before) <= sourceText.count else
        {
            return nil
        }
        let startRange = sourceText.startIndex..<sourceText.index(sourceText.endIndex, offsetBy: -before)
        return sourceText.range(of: str, options: String.CompareOptions.backwards, range: startRange, locale: nil)?.lowerBound
    }
   
    public static func lastIndexOf(sourceText: String, of str: String, before: Int = 0) -> Int
    {
        guard let index = lastIndexRaw(sourceText: sourceText, of: str, before: before) else
        {
            return -1
        }
        return sourceText.distance(from: sourceText.startIndex, to: index)
    }
    
    public static func getLength(sourceText: String) -> Int
    {
		return sourceText.count
    }
    public static func substr(sourceText: String, startIndex: Int, length: Int) -> String
    {
        let start = sourceText.index(sourceText.startIndex, offsetBy: startIndex)
        let end = sourceText.index(sourceText.startIndex, offsetBy: startIndex + length)
        return String(sourceText[start..<end])
    }

    
    
    
    //=======================================
    //===== 문자열 자르기 메소드
    //=======================================
    public static func substring(strInputString: String, intIndexStart: Int, intIndexEnd: Int) -> String
    {
        var strResultData = String()
        var intStartIndex = 0
        
        intStartIndex = intIndexStart
        
        if(intStartIndex <= 0)
        {
            intStartIndex = 0                                                                                   //시작위치가 0보다 작으면 '0'
        }
        
        let indexStart = strInputString.index(strInputString.startIndex, offsetBy: intStartIndex)               //시작위치
        let indexEnd = strInputString.index(strInputString.startIndex, offsetBy: intIndexEnd)                   //종료위치
        
        
        if(intIndexEnd <= 0)
        {
            strResultData = String(strInputString[indexStart...])                                               //#1.시작위치'x' 부터 끝까지
        }
        else
        {
            strResultData = String(strInputString[indexStart...indexEnd])                                       //#2.시작위치 'x'부터 'x'까지
        }
        return strResultData
    }
    
    
    
}
