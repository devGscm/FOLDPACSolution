//
//  ClientConfig.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 6..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


import UIKit
import Material
import Mosaic

//class ClientConfig : UITableViewController, DataProtocol
class ClientConfig : BaseTableViewController, DataProtocol
{
    var mLstRfidType:Array<ReaderType> = Array<ReaderType>()
    var mLstIdentificationSystem:Array<IdentificationSystemDialog.IdentificationSystem> = Array<IdentificationSystemDialog.IdentificationSystem>()
    
    @IBOutlet weak var btnBranch: UIButton!
    @IBOutlet weak var swRfidBeep: UISwitch!                    //RFID 효과음
    @IBOutlet weak var btnRfidType: UIButton!
    @IBOutlet weak var btnRfidReader: UIButton!
    @IBOutlet weak var btnRfidMask: UIButton!                    //RFID 마스크
    @IBOutlet weak var btnRfidPower: UIButton!
    @IBOutlet weak var btnIdentificationSystem: UIButton! //상품식별체계
    
	lazy var mClsLeftController: LeftViewController = {
		return UIStoryboard.viewController(identifier: "LeftViewController") as! LeftViewController
	}()
	
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
		super.initController()
		prepareToolbar()
		
        initViewControl()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()         //키보드 숨기기
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
		super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    
    func initViewControl()
    {
       
        // 거점선택
		let strBranchName = AppContext.sharedManager.getUserInfo().getBranchName()
		if(strBranchName.isEmpty == false)
		{
			self.btnBranch.setTitle(strBranchName, for: .normal)
		}
        //let strBranch = UserDefaults.standard.string(forKey: Constants.BASE_BRANCH_KEY) ?? "Selection"
        //print("@@@@@@ Branch : \(strBranch)")
        //self.btnBranch.setTitle(strBranch, for: .normal)
        
		
		
        //상품식별체계
        mLstIdentificationSystem.append(IdentificationSystemDialog.IdentificationSystem(IdentificationSystemType: 1, IdentificationSystemName: NSLocalizedString("identification_system_itf14", comment: "ITF-14 바코드")))
        mLstIdentificationSystem.append(IdentificationSystemDialog.IdentificationSystem(IdentificationSystemType: 2, IdentificationSystemName: NSLocalizedString("identification_system_agqr", comment: "농산물 QR코드")))
        
        let intIdentificationSystem = UserDefaults.standard.integer(forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
		for strtIdentificationSystem in mLstIdentificationSystem
		{
			if(strtIdentificationSystem.IdentificationSystemType == intIdentificationSystem)
			{
				let strIdentificationSystemName = strtIdentificationSystem.IdentificationSystemName
				self.btnIdentificationSystem.setTitle(strIdentificationSystemName, for: .normal)
				break
			}
		}
		
		
        
        //효과음
        self.swRfidBeep.isOn = UserDefaults.standard.bool(forKey: Constants.RFID_BEEP_ENABLED_KEY)
        
        //RFID 장치 타입
        mLstRfidType.append(.SWING)
        mLstRfidType.append(.AT288)
        let readerType = ReaderType(rawValue: UserDefaults.standard.integer(forKey: Constants.RFID_READER_TYPE_KEY))
        self.btnRfidType.setTitle(readerType?.description ?? NSLocalizedString("button_selection", comment: "선택"), for: .normal)
        
        // RFID 장치 정보
        // UserDefaults 구조체 정보를 넣기 위해서는 클래스 Array로 선언해야 저장가능하다.
        if let rederInfoList = UserDefaults.standard.data(forKey: Constants.RFID_READER_INFO_KEY)
        {
            if let rederInfoList = NSKeyedUnarchiver.unarchiveObject(with: rederInfoList) as? [ReaderDevInfo]
            {
                for rederInfo in rederInfoList
                {
                    //self.btnRfidReader.setTitle(rederInfo.name, for: .normal)
                    self.btnRfidReader.setTitle(rederInfo.macAddr, for: .normal)
                    //반드시 한건만 있기 때문에 나감
                    break
                }
            }
        }
        
        // RFID 마스크
        let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
        //print("@@@@@@ RFID MASK:\(strRfidMask)")
        self.btnRfidMask.setTitle(strRfidMask, for: .normal)
        
        // RFID Power
        let strRfidPower = UserDefaults.standard.string(forKey: Constants.RFID_POWER_KEY) ?? "0"
        self.btnRfidPower.setTitle(strRfidPower, for: .normal)
        //print("@@@@@@ RFID POWER:\(strRfidPower)")
    }
    
    func recvData( returnData : ReturnData)
    {
        // 거점 선택
        if(returnData.returnType == "branchSearch")
        {
            if(returnData.returnRawData != nil)
            {
                let clsDataRow = returnData.returnRawData as! DataRow
                let strBranchId = clsDataRow.getString(name:"branchId") ?? ""
                let strBranchName = clsDataRow.getString(name:"branchName") ?? ""
                let strBranchCustId = clsDataRow.getString(name:"branchCustId") ?? ""
                let strBranchCustType = clsDataRow.getString(name:"branchCustType") ?? ""
                let strBranchCustName = clsDataRow.getString(name:"branchCustName") ?? ""
                let strInAgreeYn = clsDataRow.getString(name:"inAgreeYn") ?? ""
                
                let clsUserInfo = AppContext.sharedManager.getUserInfo()
                clsUserInfo.setBranchId(branchId: strBranchId)
                clsUserInfo.setBranchName(branchName: strBranchName)
                clsUserInfo.setBranchCustId(branchCustId: strBranchCustId)
                clsUserInfo.setBranchCustType(branchCustType: strBranchCustType)
                clsUserInfo.setBranchCustName(branchCustName: strBranchCustName)
                clsUserInfo.setInAgreeYn(inAgreeYn: strInAgreeYn)
				
				
				//사용자가 선택된 거점 정보를 서버에 전달
				//해당 단말기ID 대한 거점정보를 업데이트
				if(strBranchId.isEmpty == false && strBranchCustId.isEmpty == false)
				{
					let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
					clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
					clsDataClient.ExecuteUrl = "redisService:executeClientConfigData"
					clsDataClient.removeServiceParam()
					clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
					clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
					clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
					clsDataClient.addServiceParam(paramName: "branchId", value: strBranchId)
					clsDataClient.addServiceParam(paramName: "branchCustId", value:strBranchCustId )
					
					clsDataClient.executeData(dataCompletionHandler: { (data, error) in
						if let error = error {
							self.showSnackbar(message: error.localizedDescription)
							return
						}
						guard let clsResultDataTable = data else {
							print("에러 데이터가 없음")
							return
						}
						
						let clsResultDataRows = clsResultDataTable.getDataRows()
						if(clsResultDataRows.count > 0)
						{
							let clsDataRow = clsResultDataRows[0]
							let strResultCode = clsDataRow.getString(name: "resultCode")
							print(" -strResultCode:\(strResultCode!)")
							if(Constants.PROC_RESULT_SUCCESS != strResultCode)
							{
								self.showSnackbar(message: NSLocalizedString("common_error_occur_modification_try_again", comment: "수정 중 에러가 발생하였습니다. 잠시후 다시 시도하여 주십시오."))
							}
						}
					})
				}
				
                
                
                print("@@@@@@@@@@@@@ strBranchID:\(strBranchId)" )
                //UserDefaults.standard.setValue(strBranchId, forKey: Constants.BASE_BRANCH_KEY)
                //UserDefaults.standard.synchronize()
                self.btnBranch.setTitle(strBranchName, for: .normal)
				
				// 옵져버 전달 : 왼쪽메뉴 재생성
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doMakeLeftMenu"), object: nil)
				
            }
        }
    }
    
    // Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "segBranchSearch")
        {
            if let clsBranchSearchDialog = segue.destination as? BranchSearchDialog
            {
                clsBranchSearchDialog.ptcDataHandler = self
            }
        }
    }
    
    // 거점선택
    @IBAction func onBranchClicked(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "segBranchSearch", sender: self)
    }
    
    /*
     @IBAction func onBranchClicked(_ sender: Any)
     {
     //clsBranchSearchDialog.contentWidth = self.view.frame.width * 1.2
     clsBranchSearchDialog.contentHeight = self.view.frame.height
     
     let acDialog = UIAlertController(title:nil, message:"거점 선택", preferredStyle: .alert)
     acDialog.setValue(clsBranchSearchDialog, forKeyPath: "contentViewController")
     let aaOkAction = UIAlertAction(title: "OK", style: .default) { (_) in
     
     }
     acDialog.addAction(aaOkAction)
     
     var height:NSLayoutConstraint = NSLayoutConstraint(item: acDialog.view,
     attribute: NSLayoutAttribute.height,
     relatedBy: NSLayoutRelation.equal,
     toItem: nil,
     attribute: NSLayoutAttribute.notAnAttribute,
     multiplier: 1,
     constant: self.view.frame.height * 0.9
     )
     acDialog.view.addConstraint(height)
     
     self.present(acDialog, animated: true)
     }
     */
    
    //상품식별체계
    @IBAction func onIdentificationSystemClicked(_ sender: UIButton)
	{
        let clsIdentificationSystemDialog = IdentificationSystemDialog()
        clsIdentificationSystemDialog.loadData(lstIdentificationSystem: mLstIdentificationSystem)
        
        let acDialog = UIAlertController(title: NSLocalizedString("preference_identification_system", comment: "상품식별체계"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsIdentificationSystemDialog, forKeyPath: "contentViewController")
        
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
        })
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            let intIdentificationSystemType = clsIdentificationSystemDialog.selectedRow.IdentificationSystemType
            let strIdentificationSystemName = clsIdentificationSystemDialog.selectedRow.IdentificationSystemName
            UserDefaults.standard.setValue(intIdentificationSystemType, forKey: Constants.IDENTIFICATION_SYSTEM_LIST_KEY)
            UserDefaults.standard.synchronize()
            self.btnIdentificationSystem.setTitle(strIdentificationSystemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    //RFID 리더기 (type)
    @IBAction func onRfidTypeClicked(_ sender: Any) {
        let clsReaderDialog = RfidTypeDialog()
        clsReaderDialog.loadData(lstRfidReader: mLstRfidType)
        
        let acDialog = UIAlertController(title: NSLocalizedString("preference_rfid_reader", comment: "RFID 리더기"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsReaderDialog, forKeyPath: "contentViewController")
        
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
        })
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            let readerType = clsReaderDialog.selectedRow
            UserDefaults.standard.setValue(readerType.rawValue, forKey: Constants.RFID_READER_TYPE_KEY)
            UserDefaults.standard.synchronize()
            self.btnRfidType.setTitle(readerType.description, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    // 블루투스 장치선택
    @IBAction func onRfidReaderClicked(_ sender: Any)
    {
        let clsReaderDialog = RfidReaderDialog()
        let acDialog = UIAlertController(title: NSLocalizedString("preference_rfid_reader", comment: "RFID 리더기"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsReaderDialog, forKeyPath: "contentViewController")
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
        })
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            if let rederInfo = clsReaderDialog.selectedRow
            {
                var rederInfos = [ReaderDevInfo]()
                rederInfos.append(rederInfo)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: rederInfos)
                UserDefaults.standard.set(encodedData, forKey: Constants.RFID_READER_INFO_KEY)
                UserDefaults.standard.synchronize()
                self.btnRfidReader.setTitle(rederInfo.macAddr, for: .normal)
            }
            clsReaderDialog.discoverStop()
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    // RFID 효과음
    @IBAction func onRfidBeepChanged(_ sender: UISwitch)
    {
        let boolBeepEnabled = sender.isOn
        UserDefaults.standard.set(boolBeepEnabled, forKey: Constants.RFID_BEEP_ENABLED_KEY)
        UserDefaults.standard.synchronize()
    }
    
    
    // RFID 마스크
    @IBAction func onRfidMaskClicked(_ sender: Any)
    {
        let acDialog = UIAlertController(title: NSLocalizedString("preference_rfid_mask", comment: "RFID 마스크"), message: nil, preferredStyle: .alert)
        acDialog.addTextField() {
            //$0.text = self.btnRfidMask.titleLabel?.text;
            let strRfidMask = UserDefaults.standard.string(forKey: Constants.RFID_MASK_KEY) ?? "3312"
            $0.text = strRfidMask
        }
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
        })
        acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            let strValue = acDialog.textFields?[0].text
            UserDefaults.standard.setValue(strValue, forKey: Constants.RFID_MASK_KEY)
            UserDefaults.standard.synchronize()
            self.btnRfidMask.setTitle(strValue, for: .normal)
        })
        self.present(acDialog, animated: false, completion: nil)
    }
    
    //RFID Power
    @IBAction func onRfidPowerClicked(_ sender: Any)
    {
        let clsSliderDialog = SliderDialog()
        let intRfidPower = Int(self.btnRfidPower.titleLabel?.text ?? "0")!
        //print("@@@@@intRfidPower = \(intRfidPower)")
        clsSliderDialog.sliderValue = intRfidPower
        Dialog.show(container: self, viewController: clsSliderDialog, title: nil,
                    message: NSLocalizedString("preference_rfid_power", comment: "RFID Power"),
                    okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                    okHandler: { (_) in
                        let intValue = Int(clsSliderDialog.sliderValue)
                        UserDefaults.standard.setValue(intValue, forKey: Constants.RFID_POWER_KEY)
                        UserDefaults.standard.synchronize()
                        self.btnRfidPower.setTitle("\(intValue)", for: .normal)
                        print(">>> sliderValue = \(intValue)")
        },
                    cancelTitle: NSLocalizedString("common_cancel", comment: "취소"),
                    cancelHandler: nil)
    }
}

extension ClientConfig
{
    fileprivate func prepareToolbar()
    {
        guard let tc = toolbarController else {
            return
        }
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        tc.toolbar.detail = NSLocalizedString("title_client_config", comment: "자산등록")
    }
}

