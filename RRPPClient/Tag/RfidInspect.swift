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
	
    //var arrTagList		: Array<String> = Array<String>()
	@IBOutlet weak var swRederMode: UISwitch!
	var arrTagList     : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()

    override func viewWillAppear(_ animated: Bool)
    {
		self.initRfid(self as ReaderResponseDelegate )
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
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
			Dialog.show(container: self, title: nil, message: NSLocalizedString("rfid_reader_not_connected", comment: "리더기에 연결되어있지않음"))
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
			Dialog.show(container: self, title: nil, message: NSLocalizedString("rfid_reader_not_connected", comment: "리더기에 연결되어있지않음"))
			return
		}
		
		//실제 불려지는 함수
		self.stopRead()
	}
	
	@IBAction func readerModeChanged(_ sender: Any) {
		if(self.isConnected() == false)
		{
			Dialog.show(container: self, title: nil, message: NSLocalizedString("rfid_reader_not_connected", comment: "리더기에 연결되어있지않음"))
			return
		}
		
		if(self.swRederMode.isOn == true)
		{
			//실제 불려지는 함수
			self.setRederMode(.BARCODE)
		}
		else
		{
			//실제 불려지는 함수
			self.setRederMode(.RFID)
		}	
	}
	
	///////////////////////////////////////////////////////////
	/// ReaderResponseDelegate에서 받는 이벤트 구현 시작
	//////////////////////////////////////////////////////////
	
	/// 테그 데이터 반환
	/// - Parameter tagId:
	func didReadTagid(_ tagid: String) {
        //[1]입력태그: T30003312D58E3D8100C00002BF52
        //[2]변환태그: 30003312D58E3D8100C00002BF52
        //[3]strTagIdParse: 3312D58E3D8100C00002BF52
        //let strTagidParse = StrUtil.substring(strInputString: tagid, intIndexStart: 4, intIndexEnd: 0)
        let clsTagInfo = RfidUtil.parse(strData: tagid)
		
        arrTagList.append(clsTagInfo)
        let objMe = self
        DispatchQueue.main.async {
            self.txtCount.text = "\(objMe.arrTagList.count)"
            self.tvTagList?.reloadData()
        }
	}
	
	///바코드 반환 (구현 안해도 됨.)
	func didReadBarcode(_ barcode: String)
	{
		//let clsTagInfo = RfidUtil.parse(strData: tagid)
		
		let clsTagInfo = RfidUtil.TagInfo()
		clsTagInfo.setEpcUrn(strEpcUrn: "XXX" + barcode)
		
		arrTagList.append(clsTagInfo)
		let objMe = self
		DispatchQueue.main.async {
			self.txtCount.text = "\(objMe.arrTagList.count)"
			self.tvTagList?.reloadData()
		}
		
	}
	
	
	
	func didReaderScanList(id: String, name: String, macAddr: String) {
		print("Bluetooth에서 스캔한 리더기 리스트:  id:\(id), name:\(name), macAddr:\(macAddr)")
	}
	
	///////////////////////////////////////////////////////////
	/// ReaderResponseDelegate에서 받는 이벤트 구현 종료
	//////////////////////////////////////////////////////////
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrTagList.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell : TagCell = tableView.dequeueReusableCell(withIdentifier: "tvcTempTag", for: indexPath) as! TagCell
		let clsTagInfo = self.arrTagList[indexPath.row]
        
		objCell.lblTag.text = clsTagInfo.getEpcUrn()
		
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

