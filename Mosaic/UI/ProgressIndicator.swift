//
//  ProgressIndicator.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 12. 1..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Foundation

public class ProgressIndicator: UIView
{
	public static let INDICATOR_COLOR_GRAY						= 1
	public static let INDICATOR_COLOR_WHITE						= 2
	
	var indicatorColor: Int
	var ucBackgroundColor: UIColor
	var strMessage: String
	var vwLoading = UIView()
	var vwContainer = UIView()
	
	var aivIndicator = UIActivityIndicatorView()
	
	public init(view : UIView, backgroundColor: UIColor, indicatorColor: Int, message : String)
	{
		self.indicatorColor = indicatorColor
		self.ucBackgroundColor = backgroundColor
		self.strMessage = message
		super.init(frame: CGRect(x: 0, y: 0, width: view.frame.maxX, height: view.frame.maxY))
		self.backgroundColor = getUIColorFromHex(rgbValue : 0x000000, alpha: 0.3)
		view.addSubview(self)
		
		vwContainer.center = view.center
		vwContainer.frame = CGRect(x: view.frame.midX - 150, y: view.frame.midY - 25 , width: 300, height: 50)
		initControl()
	}
	
	convenience init(view : UIView)
	{
		self.init(view: view, backgroundColor: UIColor.brown, indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "Loading..")
	}
	
	convenience init(view : UIView, messsage:String)
	{
		self.init(view: view, backgroundColor: UIColor.brown, indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: messsage)
	}
	
	required public init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	func initControl()
	{
		vwLoading.frame = vwContainer.bounds
		
		if(self.indicatorColor == ProgressIndicator.INDICATOR_COLOR_GRAY)
		{
			aivIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		}
		else
		{
			aivIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
		}
		
		aivIndicator.hidesWhenStopped = true
		aivIndicator.frame = CGRect(x: vwContainer.bounds.origin.x + 6, y: 0, width: 20, height: 50)
		
		
		let lblMessage = UILabel(frame:CGRect(x: vwContainer.bounds.origin.x + 30, y: 0, width: vwContainer.bounds.width - (vwContainer.bounds.origin.x + 35), height: 50))
		lblMessage.text = strMessage
		lblMessage.adjustsFontSizeToFitWidth = true
		lblMessage.textColor = UIColor.white
		
		vwLoading.layer.cornerRadius = 15
		vwLoading.backgroundColor = ucBackgroundColor
		vwLoading.alpha = 0.8
		vwLoading.addSubview(aivIndicator)
		vwLoading.addSubview(lblMessage)
		vwContainer.addSubview(vwLoading)
	}
	
	public func start()
	{
		if self.subviews.contains(vwContainer) == false
		{
			self.isHidden = false
			aivIndicator.startAnimating()
			self.addSubview(vwContainer)
		}
	}
	
	public func stop()
	{
		if self.subviews.contains(vwContainer) == true
		{
			aivIndicator.stopAnimating()
			vwContainer.removeFromSuperview()
			self.isHidden = true
		}
	}
	
	
	func getUIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor
	{
		let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
		let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
		let blue = CGFloat(rgbValue & 0xFF)/256.0
		return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
	}
}

