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
	var lblMessage : UILabel?
	
	var aivIndicator = UIActivityIndicatorView()

	var onCancelHandler : ((ProgressIndicator) -> Void)
	
	public convenience init(view : UIView, backgroundColor: UIColor, indicatorColor: Int, message : String)
	{
		self.init(view: view, backgroundColor: backgroundColor, indicatorColor: indicatorColor, message: message, cancelable: false, cancelHandler: { (_) in })
	}

	
	public init(view : UIView, backgroundColor: UIColor, indicatorColor: Int, message : String, cancelable: Bool, cancelHandler: @escaping (ProgressIndicator) -> Void)
	{
		self.indicatorColor = indicatorColor
		self.ucBackgroundColor = backgroundColor
		self.strMessage = message
		self.onCancelHandler = cancelHandler
		
		super.init(frame: CGRect(x: 0, y: 0, width: view.frame.maxX, height: view.frame.maxY))
		self.backgroundColor = getUIColorFromHex(rgbValue : 0x000000, alpha: 0.3)
		view.addSubview(self)
		
		vwContainer.center = view.center
		vwContainer.frame = CGRect(x: view.frame.midX - 150, y: view.frame.midY - 25 , width: 300, height: 50)
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
		
		lblMessage = UILabel(frame:CGRect(x: vwContainer.bounds.origin.x + 30, y: 0, width: vwContainer.bounds.width - (vwContainer.bounds.origin.x + 35), height: 50))
		lblMessage?.text = strMessage
		lblMessage?.adjustsFontSizeToFitWidth = true
		lblMessage?.textColor = UIColor.white
		
		vwLoading.layer.cornerRadius = 15
		vwLoading.backgroundColor = ucBackgroundColor
		vwLoading.alpha = 0.8
		vwLoading.addSubview(aivIndicator)
		vwLoading.addSubview(lblMessage!)
		vwContainer.addSubview(vwLoading)

		if(cancelable == true)
		{
			let tgrRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLoadingClicked))
			vwLoading.addGestureRecognizer(tgrRecognizer)
		}
		
		self.isHidden = true
	}
	
	@objc func onLoadingClicked(sender: UITapGestureRecognizer)
	{
		print("onLoadingClicked")
		self.hide()
		onCancelHandler(self)
	}
	
	public convenience init(view : UIView)
	{
		self.init(view: view, backgroundColor: UIColor.gray, indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "Loading..", cancelable: false, cancelHandler: { (_) in })
	}
	
	convenience init(view : UIView, messsage:String)
	{
		self.init(view: view, backgroundColor: UIColor.brown, indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: messsage, cancelable: false, cancelHandler: { (_) in })
	}
	
	required public init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	

	
	public func show(message : String)
	{
        DispatchQueue.main.async
        {
            self.lblMessage?.text = message
            self.show()
        }
	}
	
	public func show()
	{
        DispatchQueue.main.async
        {
            if self.subviews.contains(self.vwContainer) == false
            {
                self.isHidden = false
                self.aivIndicator.startAnimating()
                self.addSubview(self.vwContainer)
            }
        }
	}
	
	public func hide()
	{
        DispatchQueue.main.async
        {
            if self.subviews.contains(self.vwContainer) == true
            {
                self.aivIndicator.stopAnimating()
                self.vwContainer.removeFromSuperview()
                
                //self.isHidden = true
                // 트랜지션 효과
                UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.isHidden = true
                }, completion: nil)
            }
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

