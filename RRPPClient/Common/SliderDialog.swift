//
//  SliderDialog.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 20..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation

import UIKit
class SliderDialog : UIViewController
{
	let mLblValue = UILabel()
	let mSldSlider = UISlider()
	
	var sliderValue: Int
	{
		get { return Int(self.mSldSlider.value) }
		set(intValue)
		{
			self.mLblValue.text = "\(intValue)"
			self.mSldSlider.value = Float(intValue)
		}
	}
	
	override func viewDidLoad()
	{
		mLblValue.frame = CGRect(x: 0, y: 0, width: 170, height: 30)
		mLblValue.text = "0"
		mLblValue.font = UIFont.systemFont(ofSize: 14)
		mLblValue.textAlignment = .center
		self.view.addSubview(mLblValue)
		
		self.mSldSlider.minimumValue = 0
		self.mSldSlider.maximumValue = 100
		self.mSldSlider.frame = CGRect(x: 0, y: 30, width: 170, height: 30)
		self.view.addSubview(self.mSldSlider)
		self.mSldSlider.addTarget(self, action: #selector(onSliderValueChanged), for: UIControlEvents.valueChanged)
		
		// 뷰 컨트롤러의 콘텐츠 사이즈 지정
		self.preferredContentSize = CGSize(width: self.mSldSlider.frame.width,
										   height: self.mLblValue.frame.height + self.mSldSlider.frame.height+10)
	}
	
	@IBAction func onSliderValueChanged(sender: UISlider)
	{
		let intValue = Int(sender.value)
		mLblValue.text = "\(intValue)"
	}
}
