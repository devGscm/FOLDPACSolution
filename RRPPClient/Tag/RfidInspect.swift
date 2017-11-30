//
//  RfidInspectController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class RfidInspect: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, ReaderResponseProtocol
{
	@IBOutlet weak var txtCount: UITextField!
	@IBOutlet weak var tvTagList: UITableView!
	
	var arrTagList			: Array<String> = Array<String>()
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
		self.initRfid()
		self.delegate = self as ReaderResponseProtocol
    }
	
	@IBAction func readerConnectClicked(_ sender: Any) {
		self.readerConnect()
	}
	
	@IBAction func readerDisConnectClicked(_ sender: Any) {
		self.readerDisConnect()
	}
	
	@IBAction func readerReadStartClicked(_ sender: Any) {
		//연결여부 확인후 알럿메세지
		if(self.readerIsConnected() == false)
		{
			let clsSliderDialog = SliderDialog()
			let objMe = self
			Dialog.show(container: self, viewController: clsSliderDialog, title: nil,
						message: NSLocalizedString("rfid_reader_not_connected", comment: "리더기에 연결되어있지않음"),
						okTitle: NSLocalizedString("common_confirm", comment: "확인"),
						okHandler: { (_) in
							objMe.readerConnect()
							},
						cancelTitle: NSLocalizedString("common_cancel", comment: "취소"),
						cancelHandler: nil)
			return
		}
		
		//실제불려지는 함수
		self.arrTagList.removeAll()
		DispatchQueue.main.async { self.tvTagList?.reloadData() }
		self.startRead()
	}
	
	@IBAction func readerReadEndClicked(_ sender: Any) {
		//연결여부 확인후 알럿메세지
		if(self.readerIsConnected() == false)
		{
			let clsSliderDialog = SliderDialog()
			let objMe = self
			Dialog.show(container: self, viewController: clsSliderDialog, title: nil,
						message: NSLocalizedString("rfid_reader_not_connected", comment: "리더기에 연결되어있지않음"),
						okTitle: NSLocalizedString("common_confirm", comment: "확인"),
						okHandler: { (_) in
							objMe.readerConnect()
			},
						cancelTitle: NSLocalizedString("common_cancel", comment: "취소"),
						cancelHandler: nil)
			return
		}
		
		//실제 불려지는 함수
		self.stopRead()
	}
	
	func didReadTagList(_ tagId: String) {
		if (self.arrTagList.contains(tagId) == false)
		{
			self.arrTagList.append(tagId)			
			let objMe = self
			DispatchQueue.main.async {
				self.txtCount.text = "\(objMe.arrTagList.count)"
				self.tvTagList?.reloadData()
			}
		}
	}
	
//	override public func swing_Response_TagList(_ value: String!)
//	{
//		var trimedData = value.trimmingCharacters(in: .whitespacesAndNewlines)
//		trimedData = trimedData.replacingOccurrences(of: ">T", with: "")
//		trimedData = trimedData.replacingOccurrences(of: ">J", with: "")
//		if(self.arrTagList.contains(trimedData) == false)
//		{
//			self.arrTagList.append(trimedData)
//		}
//
//		let objMe = self
//		DispatchQueue.main.async {
//			self.txtCount.text = "\(objMe.arrTagList.count)"
//			self.tvTagList?.reloadData()
//		}
//	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrTagList.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell : TagCell = tableView.dequeueReusableCell(withIdentifier: "tvcTempTag", for: indexPath) as! TagCell
		let clsTagInfo = self.arrTagList[indexPath.row]
		objCell.lblTag.text = clsTagInfo
		
		return objCell
	}
	
}





extension RfidInspect
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else
		{
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_rfid_inspect", comment: "RFID태그검수")
	}
}

