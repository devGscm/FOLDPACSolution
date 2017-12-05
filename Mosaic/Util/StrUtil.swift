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
