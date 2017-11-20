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
	let lblValue = UILabel()
	let sldSlider = UISlider()
	
	var sliderValue: Int
	{
		get { return Int(self.sldSlider.value) }
		set(intValue)
		{
			self.lblValue.text = "\(intValue)"
			self.sldSlider.value = Float(intValue)
		}
	}
	
	override func viewDidLoad()
	{
		lblValue.frame = CGRect(x: 0, y: 0, width: 170, height: 30)
		lblValue.text = "0"
		lblValue.font = UIFont.systemFont(ofSize: 14)
		lblValue.textAlignment = .center
		self.view.addSubview(lblValue)
		
		self.sldSlider.minimumValue = 0
		self.sldSlider.maximumValue = 100
		self.sldSlider.frame = CGRect(x: 0, y: 30, width: 170, height: 30)
		self.view.addSubview(self.sldSlider)
		self.sldSlider.addTarget(self, action: #selector(onSliderValueChanged), for: UIControlEvents.valueChanged)
		
		// 뷰 컨트롤러의 콘텐츠 사이즈 지정
		self.preferredContentSize = CGSize(width: self.sldSlider.frame.width,
										   height: self.lblValue.frame.height + self.sldSlider.frame.height+10)
	}
	
	@IBAction func onSliderValueChanged(sender: UISlider)
	{
		let intValue = Int(sender.value)
		lblValue.text = "\(intValue)"
	}
}
