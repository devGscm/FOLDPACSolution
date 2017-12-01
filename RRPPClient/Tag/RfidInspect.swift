//
//  RfidInspectController.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 28..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class RfidInspect: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, ReaderResponseDelegate
{
	@IBOutlet weak var txtCount: UITextField!
	@IBOutlet weak var tvTagList: UITableView!
	
	var arrTagList			: Array<String> = Array<String>()
	
    override func viewDidLoad()
    {
		print("###############################")
		print("##### viewDidLoad() ######")
		print("###############################")
		super.viewDidLoad()
		
		// 오른쪽 토클메뉴 강제로 띄위기
		//navigationDrawerController?.toggleRightView()
		
		//TODO:: 전역객체에서 등록된 리더기정보를 가져온다.
		let devId  = "D32F0010-8DB8-856F-A8DF-85B3D00CF26A"
		self.initRfid(.SWING, id:  devId, delegateReder:  self as ReaderResponseDelegate )
		//self.initRfid(.AT288, id:  devId, delegateReder:  self as ReaderResponseDelegate )
    }
	
	
	
	@IBAction func readerConnectClicked(_ sender: Any) {
		self.readerConnect()
	}
	
	@IBAction func readerDisConnectClicked(_ sender: Any) {
		self.readerDisConnect()
	}
	
	@IBAction func readerReadStartClicked(_ sender: Any) {
		//연결여부 확인후 알럿메세지
		if(self.isConnected() == false)
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
		if(self.isConnected() == false)
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
	
	func viewDidRelease()
	{
		print("=========================================")
		print("*RfidInspect.viewDidRelease()")
		print("=========================================")
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

