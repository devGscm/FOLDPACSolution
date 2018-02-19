//
//  UIImage.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 12. 11..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import UIKit

public enum ImageFormat
{
	case png
	case jpeg(CGFloat)
}

extension UIImage
{
	public func base64(format: ImageFormat) -> String?
	{
		var imageData: Data?
		switch format
		{
			case .png: imageData = UIImagePNGRepresentation(self)
			case .jpeg(let compression): imageData = UIImageJPEGRepresentation(self, compression)
		}
		return imageData?.base64EncodedString()
	}
}

