//
//  DateUtil.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 11. 25..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


public class DateUtil
{
	public static func utcToLocale(utcDate : String, dateFormat: String) -> String
	{
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = dateFormat
		dfFormat.timeZone = TimeZone(abbreviation: "UTC")
		let dtUtcDate = dfFormat.date(from: utcDate)
		
		dfFormat.timeZone = TimeZone.current
		dfFormat.dateFormat = dateFormat
		return dfFormat.string(from: dtUtcDate!)
	}
	
	public static func localeToUtc(localeDate: String, dateFormat: String) -> String
	{
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = dateFormat
		dfFormat.timeZone = TimeZone.current
		let dtLocaleDate = dfFormat.date(from: localeDate)
		
		dfFormat.timeZone = TimeZone(abbreviation: "UTC")
		dfFormat.dateFormat = dateFormat
		return dfFormat.string(from: dtLocaleDate!)
	}
	
	public static func getConvertFormatDate(date: String, srcFormat : String, dstFormat : String) -> String
	{
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = srcFormat
		let dtDate = dfFormat.date(from: date)
		dfFormat.dateFormat = dstFormat
		return dfFormat.string(from: dtDate!)
	}
	
	public static func getFormatDate(date: String, dateFormat: String) -> Date
	{
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = dateFormat
		return dfFormat.date(from: date)!
	}
	
}

