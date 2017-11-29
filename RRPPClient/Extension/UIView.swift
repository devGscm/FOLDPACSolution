//
//  UIView.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UIView
{

	@IBInspectable var borderColor:UIColor?
	{
		set
		{
			layer.borderColor = newValue!.cgColor
		}
		get
		{
			if let color = layer.borderColor
			{
				return UIColor(cgColor: color)
			}
			else
			{
				return nil
			}
		}
	}
	@IBInspectable var borderWidth:CGFloat
	{
		set
		{
			layer.borderWidth = newValue
		}
		get
		{
			return layer.borderWidth
		}
	}
	
	@IBInspectable var cornerRadius:CGFloat
	{
		set
		{
			layer.cornerRadius = newValue
			clipsToBounds = newValue > 0
		}
		get
		{
			return layer.cornerRadius
		}
	}
	

	
	@IBInspectable var shadowColor : UIColor?
	{
		set
		{
			layer.shadowColor = newValue!.cgColor
		}
		get
		{
			if let color = layer.shadowColor
			{
				return UIColor(cgColor: color)
			}
			else
			{
				return nil
			}
		}
	}
	
	@IBInspectable var shadowOpacity:Float
	{
		set {
			layer.shadowOpacity = newValue
		}
		get {
			return layer.shadowOpacity
		}
	}
	
	@IBInspectable var shadowOffset: CGSize
	{
		set
		{
			layer.shadowOffset = newValue
		}
		get
		{
			return layer.shadowOffset
		}
	}
	
	@IBInspectable var shadowRadius:CGFloat
	{
		set
		{
			layer.shadowRadius = newValue
		}
		get
		{
			return layer.shadowRadius
		}
	}
	
	// 예: View.roundCorners([.topLeft, .bottomLeft], radius: 10)
	func roundCorners(corners: UIRectCorner, radius: CGFloat)
	{
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		self.layer.mask = mask
	}
	
	
	
}
