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
		return sourceText.replacingOccurrences(of: findText, with: replaceText, options: String.CompareOptions.literal, range: nil)
	}
}
