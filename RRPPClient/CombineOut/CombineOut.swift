//
//  CombineOut.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 13..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic
import BarcodeScanner

class CombineOut: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
    @IBOutlet weak var lblUserName: UILabel!            //작업자
    @IBOutlet weak var lblBranchInfo: UILabel!          //거점
    @IBOutlet weak var lblReaderName: UILabel!          //리더명
    @IBOutlet weak var btnRfidReader: UIButton!         //연결
    
    @IBOutlet weak var btnSelectWorkType: UIButton!     //구분
    @IBOutlet weak var btnSaleWorkId: UIButton!         //송장선택
    @IBOutlet weak var btnBarcodeSearch: UIButton!      //바코드
    
    @IBOutlet weak var tfVehName: UITextField!          //차량번호
    
    @IBOutlet weak var lblOrderCustName: UILabel!       //입고처
    @IBOutlet weak var lblDeliBranchName: UILabel!      //출고처

    @IBOutlet weak var lblAssetEpcName: UILabel!        //유형
    @IBOutlet weak var lblAssignCount: UILabel!         //출고예정
    
    @IBOutlet weak var lblProcCount: UILabel!           //처리량
    @IBOutlet weak var lblRemainCount: UILabel!         //미처리량
    @IBOutlet weak var tvCombineOut: UITableView!       //테이블뷰
    
    
    var mBoolWorkListSelected = false                    /**< 송장-선택 했는지 여부 */
    var mBoolNewTagInfoExist = false                    /**< 신규태그 - 신규태그가 있는지 여부 -전송용 */
    
    var clsIndicator : ProgressIndicator?
    var clsDataClient : DataClient!
    var clsBarcodeScanner: BarcodeScannerController?
    
    var strTitle = ""
    var mStrSaleWorkId = String()                        //송장번호
    var mStrProdAssetEpc = String()                      //유형
    var mIntProcCount = Int()                            //처리량
    var mIntWorkAssignCount = Int()                      //출고량
    
    var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
    var tfCurControl : UITextField!
    var dpPicker : UIDatePicker!
    var arcSaleType : Array<ListViewDialog.ListViewItem> = Array<ListViewDialog.ListViewItem>()
    var mStrSaleType : String?
    
    //=======================================
    //=====  setTitle()
    //=======================================
    func setTitle(title: String)
    {
        self.strTitle = title
    }

    
    //=======================================
    //=====  viewDidLoad()
    //=======================================
    override func viewDidLoad()
    {
        print("=========================================")
        print("*CombineOut.viewDidLoad()")
        print("=========================================")
        super.viewDidLoad()
        initBarcodeScanner()
        
        //다른 화면 터치시 키보드 숨기기
        self.hideKeyboardWhenTappedAround()
    }
    
    //=======================================
    //=====  didReceiveMemoryWarning()
    //=======================================
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //=======================================
    //===== viewWillAppear()
    //=======================================
    override func viewWillAppear(_ animated: Bool)
    {
        print("=========================================")
        print("*CombineOut.viewWillAppear()")
        print("=========================================")
        super.viewWillAppear(animated)
        //super.initController()
        
        prepareToolbar()        //툴바 타이틀 설정
        initViewControl()       //뷰 컨트롤 초기화
        initSelectWorkType()
        
        //RFID를 처리할 델리게이트 지정
        self.initRfid(self as ReaderResponseDelegate )
    }
    
    
    //=======================================
    //===== viewDidDisappear()
    //=======================================
    override func viewDidDisappear(_ animated: Bool)
    {
        print("=========================================")
        print("*CombineOut.viewDidDisappear()")
        print("=========================================")
        
        self.mBoolNewTagInfoExist = false
        self.mBoolWorkListSelected = false
        self.strTitle  = ""
        self.mStrSaleWorkId = ""
        self.mStrProdAssetEpc = ""
        self.mIntProcCount = 0
        self.mIntWorkAssignCount = 0
        self.mStrSaleType = ""
        
        arrAssetRows.removeAll()
        arrTagRows.removeAll()
        
        clsIndicator = nil
        clsDataClient = nil
        
        super.destoryRfid()
        super.viewDidDisappear(animated)
    }
    
    
    //=======================================
    //===== initViewControl()
    //=======================================
    func initViewControl()
    {
        clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
                                         indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
        
        lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()                                 //작업자
        lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()                             //거점
        //lblReaderName.text = UserDefaults.standard.string(forKey: Constants.RFID_READER_NAME_KEY)             //리더기명
        lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()                          //리더기명
        
        btnSaleWorkId.setTitle(NSLocalizedString("sale_work_id_selection", comment: "송장선택"), for: .normal)
        btnBarcodeSearch.setTitle(NSLocalizedString("common_barcode_search", comment: "바코드"), for: .normal)
        
        //공통코드 조회
        initCommonCodeList(userLang: AppContext.sharedManager.getUserInfo().getUserLang())
        self.mStrSaleType = ""
        
    }
    
    
    
    
    //=======================================
    //===== '구분' 셀렉트박스
    //=======================================
    @IBAction func onSelectWorkType(_ sender: UIButton) {
        let clsDialog = ListViewDialog()
        clsDialog.contentHeight = 150
        clsDialog.loadData(data: arcSaleType, selectedItem: mStrSaleType!)
        
        let acDialog = UIAlertController(title: NSLocalizedString("sale_type_name", comment: "구분"), message:nil, preferredStyle: .alert)
        acDialog.setValue(clsDialog, forKeyPath: "contentViewController")
        
        let aaOkAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
            self.mStrSaleType = clsDialog.selectedRow.itemCode
            let strItemName = clsDialog.selectedRow.itemName
           
            
            self.btnSelectWorkType.setTitle(strItemName, for: .normal)
        }
        acDialog.addAction(aaOkAction)
        self.present(acDialog, animated: true)
    }
    
    //=======================================
    //===== '구분' 셀렉트박스 0번으로 선택
    //=======================================
    func initSelectWorkType()
    {
        //구분을 0번째 아이템으로 설정.
        if(arcSaleType.count > 0)
        {
            btnSelectWorkType.setTitle(arcSaleType[0].itemName, for: .normal)
            mStrSaleType = arcSaleType[0].itemCode
        }
    }
    
    
    //=======================================
    //===== 공통코드 정보를 읽어온다.
    //=======================================
    func initCommonCodeList(userLang : String)
    {
        //arcSaleType.append(ListViewDialog.ListViewItem(itemCode: "", itemName: NSLocalizedString("common_select_all", comment: "전체")))
        let strCustType = AppContext.sharedManager.getUserInfo().getCustType()
        
        var ctUserCustType = LocalData.CustType.PMK
        if(strCustType == Constants.CUST_TYPE_PMK) { ctUserCustType = .PMK }
        else if(strCustType == Constants.CUST_TYPE_RDC) { ctUserCustType = .RDC }
        else if(strCustType == Constants.CUST_TYPE_EXP) { ctUserCustType = .EXP }
        else if(strCustType == Constants.CUST_TYPE_IMP) { ctUserCustType = .IMP }
        
        let arrSaleType: Array<CodeInfo> = LocalData.shared.getSaleTypeCodeDetail(fieldValue:"SALE_TYPE", saleResale: .Sale, custType: ctUserCustType, initCodeName:nil)
        
        for clsInfo in arrSaleType
        {
            var strCommName = ""
            if(Constants.USER_LANG_CH == userLang)
            {
                strCommName = clsInfo.commNameCh
            }
            else if(Constants.USER_LANG_EN == userLang)
            {
                strCommName = clsInfo.commNameEn
            }
            else
            {
                strCommName = clsInfo.commNameKr
            }
            arcSaleType.append(ListViewDialog.ListViewItem(itemCode: clsInfo.commCode, itemName: strCommName))
        }
    }
    
    
    
    //=======================================
    //===== initDataClient()
    //=======================================
    func initDataClient()
    {
        clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectWorkCombineInOutCancelList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
    }
    
 
    
    
    
    
    //=======================================
    //===== 테이블뷰
    //=======================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.arrAssetRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableView.rowHeight = 65                    //셀 크기 조정
        //tableView.allowsSelection = false           //셀 선택안되게 막음
        
        let objCell:CombineOutCell = tableView.dequeueReusableCell(withIdentifier: "tvcCombineOut", for: indexPath) as! CombineOutCell
        
        let clsTagInfo = arrAssetRows[indexPath.row]
        
        objCell.lblAssetEpcName.text = clsTagInfo.getAssetName()
        objCell.lblAssignCnt.text = String(clsTagInfo.getWorkAssignCount())
        objCell.lblProcCnt.text = String(clsTagInfo.getProcCount())
        objCell.lblRemainCnt.text = String(clsTagInfo.getRemainCount())
        
        objCell.btnSelection.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        objCell.btnSelection.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
        objCell.btnSelection.tag = indexPath.row
        objCell.btnSelection.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
        return objCell
    }
    
    //=======================================
    //===== RFID 태그 목록 보기
    //=======================================
    @objc func onTagListClicked(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "segTagDetailList", sender: self)
    }

    
    

    //=======================================
    //===== 'Prepare' - Segue처리
    //=======================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
        if(segue.identifier == "segCombineOutWorkList")
        {
            if let clsDialog = segue.destination as? CombineOutWorkList
            {
                clsDialog.ptcDataHandler = self
                clsDialog.strWorkType = mStrSaleType!     //구분
            }
        }
        else if(segue.identifier == "segOutSignDialog")
        {
            if let clsDialog = segue.destination as? OutSignDialog
            {
//                let clsDataRow : DataRow = DataRow()
//                clsDataRow.addRow(name: "remark", value: "")
//                clsDialog.loadData(dataRow: clsDataRow)
                clsDialog.ptcDataHandler = self
            }
        }
        else if(segue.identifier == "segTagDetailList")
        {
            if let clsDialog = segue.destination as? TagDetailList
            {
                if let btnDetail = sender as? UIButton
                {
                    let clsTagInfo = arrAssetRows[btnDetail.tag]
                    
                    // 해당 자산코드만 필터링하여 배열을 재생성하여 전달
                    let arrData = arrTagRows.filter({ (clsData) -> Bool in
                        if(clsData.getAssetEpc() == clsTagInfo.getAssetEpc())
                        {
                            return true
                        }
                        return false
                    })
                    clsDialog.loadData(arcTagInfo : arrData)
                }
            }
        }
    }
    
    
    
    //=======================================
    //===== 씬(Scene)데이터 수신
    //=======================================
    func recvData(returnData: ReturnData)
    {
        if(returnData.returnType == "CombineOutWorkList")
        {
            if(returnData.returnRawData != nil)
            {
                let clsDataRow  = returnData.returnRawData as! DataRow
                if(mStrSaleWorkId != clsDataRow.getString(name: "saleWorkId") ?? "")
                {
                    //화면정보 초기화
                    clearTagData(true)
                    
                    let clsDataRow = returnData.returnRawData as! DataRow
                    
                    //팝업에서 넘어온 데이터를 넣는다.
                    mStrSaleWorkId          = clsDataRow.getString(name: "saleWorkId") ?? ""
                    let strOrderCustName    = clsDataRow.getString(name: "orderCustName") ?? ""
                    let strDeliBranchName   = clsDataRow.getString(name: "deliBranchName") ?? ""
                    mIntWorkAssignCount     = clsDataRow.getInt(name: "workAssignCnt") ?? 0
                    mIntProcCount           = clsDataRow.getInt(name: "procCnt") ?? 0
                    let strVehName          = clsDataRow.getString(name: "vehName") ?? ""
                    mStrProdAssetEpc        = clsDataRow.getString(name: "prodAssetEpc") ?? ""
                    let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                    let intRemainCnt        = clsDataRow.getInt(name: "remainCnt") ?? 0

                    //화면에 정보표시
                    btnSaleWorkId.setTitle(mStrSaleWorkId, for: .normal)
                    lblOrderCustName.text   = strOrderCustName
                    lblDeliBranchName.text  = strDeliBranchName
                    lblAssignCount.text     = String(mIntWorkAssignCount)
                    lblProcCount.text       = String(mIntProcCount)
                    tfVehName.text          = strVehName
                    lblAssetEpcName.text    = strProdAssetEpcName
                    lblRemainCount.text     = String(intRemainCnt)
                    
                    //선택된 '송장정보' 내용조회
                    doSearchWorkListDetail()
                    
                    //선택된 '송장정보'에 대한 태그리스트
                    doSearchTagList()
                    
                    //송장 선택 여부
                    mBoolWorkListSelected = true
                }
            }
        }
        else if(returnData.returnType == "outSignDialog")
        {
            if(returnData.returnRawData != nil)
            {
                let clsDataRow      = returnData.returnRawData as! DataRow
                let strRemark       = clsDataRow.getString(name: "remark") ?? ""
                let strSignData     = clsDataRow.getString(name: "signData") ?? ""
                let strVehName      = tfVehName?.text ?? ""

                print("=================================")
                print("=========[ 완료전송 데이터 ] ========")
                print("=================================")
                
                //DB서버로 전송
                sendData(Constants.WORK_STATE_COMPLETE, mStrSaleWorkId, strVehName, "", strRemark, strSignData);
            }
        }
        
        
    }

    
    //=======================================
    //===== doSearchWorkListDetail
    //=======================================
    func doSearchWorkListDetail()
    {
        print("===============================")
        print("===doSearchWorkListDetail: \(doSearchWorkListDetail)")
        print("===============================")
            
        clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectCombineOutWorkListDetail"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: mStrSaleWorkId)
        
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error
            {
                //에러처리
                DispatchQueue.main.async { self.tvCombineOut?.hideIndicator() }
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsDataTable = data else
            {
                DispatchQueue.main.async { self.tvCombineOut?.hideIndicator() }
                print("에러 데이터가 없음")
                return
            }
            
            //DB에서 리스트 조회값 받음
            for clsDataRow in clsDataTable.getDataRows()
            {
                //let strSaleWorkId       = clsDataRow.getString(name: "saleWorkId") ?? ""
                let strProcCnt          = clsDataRow.getString(name: "procCnt") ?? ""
                let strWorkAssignCnt    = clsDataRow.getString(name: "workAssignCnt") ?? ""
                let strRemainCnt        = clsDataRow.getString(name: "remainCnt") ?? ""
                let strProdAssetEpc     = clsDataRow.getString(name: "prodAssetEpc") ?? ""
                let strProdAssetEpcName = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                                    
                //그리드용 자료구조에 넣기
                let clsTagInfo = RfidUtil.TagInfo()
                clsTagInfo.setProcCount(Int(strProcCnt)!)
                clsTagInfo.setWorkAssignCount(Int(strWorkAssignCnt)!)
                clsTagInfo.setRemainCount(Int(strRemainCnt)!)
                clsTagInfo.setAssetEpc(strProdAssetEpc)
                clsTagInfo.setAssetName(strProdAssetEpcName)
                
                print("===============================")
                print("===strProdAssetEpc: \(strProdAssetEpc)")
                print("===============================")
                
                //그리드 리스트에 추가
                self.arrAssetRows.append(clsTagInfo)
            }
            DispatchQueue.main.async
            {
                self.tvCombineOut?.reloadData()
                self.tvCombineOut?.hideIndicator()
            }
        })
    }
    
    
    //=======================================
    //===== RFID 태그데이터
    //=======================================
    func getRfidData(clsTagInfo : RfidUtil.TagInfo)
    {
        if(mBoolWorkListSelected == true)
        {
            let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
            let strSerialNo = clsTagInfo.getSerialNo()
            let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"    // 회사EPC코드 + 자산EPC코드

            var boolFindAbnormal            = false;
            var boolFindInvalidAssetEpc     = false;
            var boolFindAssetTypeOverlap    = false;
            
            
            //태그정보 리스트에 저장
            clsTagInfo.setAssetEpc(strAssetEpc)
            if(clsTagInfo.getAssetEpc().isEmpty == false)
            {
                let strAssetName = super.getAssetName(assetEpc: strAssetEpc)
                clsTagInfo.setAssetName(strAssetName)
                print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
            }
            clsTagInfo.setNewTag(true)
            clsTagInfo.setReadCount(1)
            clsTagInfo.setReadTime(strCurReadTime)
            
            //시스템에 등록된 AssetEpc 와 AssetEpc 비교
            for clsAssetInfo in super.getAssetList()
            {
                if(clsAssetInfo.assetEpc == strAssetEpc)
                {
                    boolFindInvalidAssetEpc = false;
                    break;
                }
                else
                {
                    //자산코드 없음
                    boolFindInvalidAssetEpc = true;
                }
            }
            
            //시스템에 동일한 자산코드가 있을때만 진행
            if(boolFindInvalidAssetEpc == false)
            {
                //납품(지시서O) 처리경우, '송장조회' 리스트에 없으면  리더기로 읽지 않음. //'이동'은 처리함.
                if(mStrSaleType == Constants.SALE_TYPE_DELIVERY)
                {
                    for clsTagInfo in arrAssetRows
                    {
                        //같은 자산유형이 있다면 자산유형별로 조회수 증가
                        if(clsTagInfo.getAssetEpc() == strAssetEpc)
                        {
                            boolFindAbnormal = false;
                            break;
                        }
                        else
                        {
                            boolFindAbnormal = true;
                        }
                    }
                }
                
                //중복 시리얼 확인 - 전달용 태그 리스트
                for clsTagInfo in arrTagRows
                {
                    // 같은 시리얼번호가 있는지 체크
                    if(clsTagInfo.getSerialNo() == strSerialNo)
                    {
                        print(" 동일한 시리얼번호 존재")
                        boolFindAbnormal = true;                //같은것이 있으므로 이상여부를 true로 설정
                        break;
                    }
                }
                
                //중복 자산 확인 - 그리드 리스트에 내용 갱신
                for clsTagInfo in arrAssetRows
                {
                    //print("========== [1]처리량 증가/미처리량 감소 ==============")
                    //let strCheckAssetEpc  = clsTagInfo.getAssetEpc()
                    //print("===strAssetEpc: \(strAssetEpc) :: \(strCheckAssetEpc) ")
                    //print("================================================")
                    
                    //같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
                    if(strAssetEpc == clsTagInfo.getAssetEpc())
                    {
                        boolFindAssetTypeOverlap = true;
                        
                        if(boolFindAbnormal == false)
                        {
                            clsTagInfo.setReadCount((clsTagInfo.getReadCount() + 1))        //증복된것이 있다면 조회수를 업데이트한다.
                        }
                        break;
                    }
                }
                
                //이상이 없다면 삽입한다.
                if(boolFindAbnormal == false)
                {
                    //신규태그 입력 체크
                    self.mBoolNewTagInfoExist = true
                    
                    //전송용 리스트에 추가
                    arrTagRows.append(clsTagInfo)
                    
                    //그리드 리스트에 추가
                    if(boolFindAssetTypeOverlap == false)
                    {
                        arrAssetRows.append(clsTagInfo)
                    }
                    
                    //입력창 내용 갱신(처리량증가/미처리량감소)
                    var intRemainCount: Int = Int(lblRemainCount?.text ?? "0")! // 미처리량
                    if intRemainCount > 0
                    {
                        intRemainCount = intRemainCount - 1
                        lblRemainCount.text = String(intRemainCount)
                    }
                    
                    self.mIntProcCount = Int(lblProcCount?.text ?? "0")! + 1 // 처리량
                    lblProcCount?.text = String(mIntProcCount)
                    
                    //5)그리드 리스에 내용 갱신
                    for clsTagInfo in arrAssetRows
                    {
                        // 같은 자산타입(Asset_type)이면 처리량증가,미처리량감소
                        if(strAssetEpc == clsTagInfo.getAssetEpc())
                        {
                            clsTagInfo.setProcCount((clsTagInfo.getProcCount() + 1)) // 처리량 증가
                            clsTagInfo.setRemainCount((clsTagInfo.getRemainCount() - 1)) // 미처리량 감소
                        }
                    }
                }
            }
            DispatchQueue.main.async { self.tvCombineOut?.reloadData() }
        }
    }
    
    
    
    
    //=======================================
    //===== 화면 및 데이터 리스트 클리어
    //=======================================
    func clearTagData(_ clearScreen: Bool )
    {
        mBoolNewTagInfoExist = false
        arrTagRows.removeAll()
        arrAssetRows.removeAll()
        
        DispatchQueue.main.async
        {
            self.tvCombineOut?.reloadData()      //테이블뷰 클리어
        }
        
        if(clearScreen == true)
        {
            DispatchQueue.main.async
            {
                self.mStrSaleWorkId = ""
                self.mStrProdAssetEpc = ""
                self.mIntProcCount = 0
                self.mIntWorkAssignCount = 0
               
                self.tfVehName.text = ""            //차량번호
                self.lblOrderCustName.text = ""     //입고처
                self.lblDeliBranchName.text = ""    //배송거점
                self.lblAssetEpcName.text = ""      //유형
                self.lblAssignCount.text = ""       //출고예정
                self.lblProcCount.text = ""         //처리량
                self.lblRemainCount.text = ""       //미처리량
                
                self.btnSaleWorkId.setTitle(NSLocalizedString("sale_work_id_selection", comment: "송장선택"), for: .normal)
                self.btnBarcodeSearch.setTitle(NSLocalizedString("common_barcode_search", comment: "바코드"), for: .normal)
            }
        }
        
        //RFID리더기 초기화
        super.clearInventory()
    }
    
    
    
    
    //=======================================
    //===== '송장선택'버튼
    //=======================================
    @IBAction func onSaleWorkIdClicked(_ sender: Any)
    {
        self.performSegue(withIdentifier: "segCombineOutWorkList", sender: self)
    }
    
    
    
//=========================== [리더기 관련 이벤트및 처리 시작] ================================
  
    //=======================================
    //===== 리더기 연결 클릭이벤트
    //=======================================
    @IBAction func onRfidReaderClicked(_ sender: UIButton)
    {
        print("====[onRfidReaderClicked]====")
        if(sender.isSelected == false)
        {
            showSnackbar(message: NSLocalizedString("rfid_connecting_reader", comment: "RFID 리더기에 연결하는 중 입니다."))
            super.readerConnect()
        }
        else
        {
            super.readerDisConnect()
        }
    }
    
    //리더기에서 읽어드린 태그에 대한 이벤트 발생처리
    func didReadTagid(_ tagid: String)
    {
        print("====[didReadTagid]====")
        let clsTagInfo = RfidUtil.parse(strData: tagid)
        getRfidData(clsTagInfo: clsTagInfo)
    }
    
    //리더기 연결성공
    func didReaderConnected()
    {
        print("====[didReaderConnected]====")
        showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
        changeBtnRfidReader(true)
    }
    
    //리더기 연결종로
    func didReaderDisConnected()
    {
        print("====[didReaderDisConnected]====")
        showSnackbar(message: NSLocalizedString("rfid_connection_terminated", comment: "연결이 종료되었습니다."))
        changeBtnRfidReader(false)
    }
    
    //리더기 연결 타임오바
    func didRederConnectTimeOver()
    {
        print("====[didRederConnectTimeOver]====")
        showSnackbar(message: NSLocalizedString("rfid_not_connect_reader", comment: "RFID 리더기에 연결할수 없습니다."))
        changeBtnRfidReader(false)
    }
    
    //리더기 연결 여부에 따른 버튼에대한 상태값 변경
    func changeBtnRfidReader(_ isConnected : Bool)
    {
        print("====[changeBtnRfidReader]====")
        if(isConnected )
        {
            self.btnRfidReader.isSelected = true
            self.btnRfidReader.backgroundColor = Color.orange.base
            self.btnRfidReader.tintColor = Color.orange.base
            self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_close", comment: "종료"), for: .normal)
        }
        else
        {
            self.btnRfidReader.isSelected = false
            self.btnRfidReader.backgroundColor = Color.blue.base
            self.btnRfidReader.tintColor = Color.white
            self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_connect", comment: "연결"), for: .normal)
        }
    }
//리더기 관련 이벤트및 처리 끝

    
//============================ [바코드 관련 이벤트및 처리 시작] ======================================
    
    //=======================================
    //===== initBarcodeScanner
    //=======================================
    func initBarcodeScanner()
    {
        BarcodeScanner.Title.text = NSLocalizedString("common_barcode_search", comment: "바코드")
        BarcodeScanner.CloseButton.text = NSLocalizedString("common_close", comment: "닫기")
        BarcodeScanner.SettingsButton.text = "설정"
        BarcodeScanner.Info.text = NSLocalizedString("msg_default_status", comment: "바코드를 사각형 안으로 넣어주세요.")
        BarcodeScanner.Info.notFoundText = NSLocalizedString("common_no_data_for_barcode", comment: "해당 바코드에 해당하는 데이터가 없습니다.")
        
        BarcodeScanner.Info.loadingText = NSLocalizedString("common_progressbar_loading", comment: "로딩 중 입니다.")
        //        BarcodeScanner.Info.settingsText = NSLocalizedString("In order to scan barcodes you have to allow camera under your settings.", comment: "")
        
        //        // Fonts
        //        BarcodeScanner.Title.font = UIFont.boldSystemFont(ofSize: 17)
        //        BarcodeScanner.CloseButton.font = UIFont.boldSystemFont(ofSize: 17)
        //        BarcodeScanner.SettingsButton.font = UIFont.boldSystemFont(ofSize: 17)
        //        BarcodeScanner.Info.font = UIFont.boldSystemFont(ofSize: 14)
        //        BarcodeScanner.Info.loadingFont = UIFont.boldSystemFont(ofSize: 16)
        //
        //        // Colors
        //        BarcodeScanner.Title.color = UIColor.black
        //        BarcodeScanner.CloseButton.color = UIColor.black
        //        BarcodeScanner.SettingsButton.color = UIColor.white
        //        BarcodeScanner.Info.textColor = UIColor.black
        //        BarcodeScanner.Info.tint = UIColor.black
        //        BarcodeScanner.Info.loadingTint = UIColor.black
        //        BarcodeScanner.Info.notFoundTint = UIColor.red
        //
        
        clsBarcodeScanner = BarcodeScannerController()
        clsBarcodeScanner?.codeDelegate = self
        clsBarcodeScanner?.errorDelegate = self
        clsBarcodeScanner?.dismissalDelegate = self
    }
    
   
    //=======================================
    //===== '바코드' 버튼
    //=======================================
    @IBAction func onBarcodeSearchClicked(_ sender: UIButton)
    {
        // 모달로 띄운다.
        clsBarcodeScanner?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(clsBarcodeScanner!, animated: true, completion: nil)
    }
    
    func doSearchBarcode(barcode: String)
    {
        let clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectSaleInWorkList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleType", value: mStrSaleType!)
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: barcode)
        
        //clsDataClient.addServiceParam(paramName: "resaleType", value: self.strWorkType)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                print(error)
                return
            }
            guard let clsDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            if(clsDataTable.getDataRows().count == 0)
            {
                super.showSnackbar(message: NSLocalizedString("common_no_data_for_barcode", comment: "해당 바코드에 해당하는 데이터가 없습니다."))
                return
            }
            
            self.clearTagData(true)
            
            let clsDataRow              = clsDataTable.getDataRows()[0]
            
            let strOrderCustName        = clsDataRow.getString(name: "orderCustName") ?? ""         //송장번호
            let strDeliBranchName       = clsDataRow.getString(name: "deliBranchName") ?? ""        //주문회사
            self.mIntWorkAssignCount    = clsDataRow.getInt(name: "workAssignCnt") ?? 0             //배송거점명
            self.mIntProcCount          = clsDataRow.getInt(name: "procCnt") ?? 0                   //처리량
            let strVehName              = clsDataRow.getString(name: "vehName") ?? ""               //차량번호
            self.mStrProdAssetEpc       = clsDataRow.getString(name: "prodAssetEpc") ?? ""          //유형
            let strProdAssetEpcName     = clsDataRow.getString(name: "prodAssetEpcName") ?? ""      //유형명
            
            var intRemainCnt            = self.mIntWorkAssignCount - self.mIntProcCount             //미처리량
            if(intRemainCnt < 0)
            {
                intRemainCnt = 0                                                                    //미처리량 0이하는 0
            }
            
            self.lblOrderCustName.text  = strOrderCustName
            self.lblDeliBranchName.text = strDeliBranchName
            self.btnSaleWorkId.setTitle(self.mStrSaleWorkId, for: .normal)                          //송장번호
            self.lblAssignCount.text    = String(self.mIntWorkAssignCount)                          //출고지시수량
            self.lblProcCount.text      = String(self.mIntProcCount)                                //처리수량
            self.tfVehName.text         = strVehName                                                //차량명
            self.lblAssetEpcName.text   = strProdAssetEpcName                                       //유형명
            self.lblRemainCount.text    = String(intRemainCnt)                                      //미처리량
            
            //조회 및 그리드 리스트에 표시
            self.doSearchWorkListDetail()        //선택된 '송장정보' 내용 조회
            self.doSearchTagList()                //선택된 '송장정보'에 대한 태그리스트
            
            self.mBoolWorkListSelected = true    //송장 선택 여부
        })
    }
//------------------------------------------------------------------------
// 바코드 관련 이벤트및 처리 끝
//========================================================================
    
    
    
    
    
    //======================================
    //===== '초기화'버튼
    //======================================
    @IBAction func onClearAllClicked(_ sender: UIButton)
    {
        Dialog.show(container: self, viewController: nil,
            title: NSLocalizedString("common_delete", comment: "삭제"),
            message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
            okTitle: NSLocalizedString("common_confirm", comment: "확인"),
            okHandler: { (_) in
                
                if(self.mStrSaleWorkId.isEmpty == false)
                {
                    self.doReloadTagList()      //초기화
                }
                else
                {
                    self.clearTagData(true)
                    super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
                }
            },
            cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
    }
    
    
    //======================================
    //===== '작업초기화'버튼
    //======================================
    @IBAction func onWorkInitClick(_ sender: UIButton)
    {
        if(mStrSaleWorkId.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_select_sale_work_id", comment: "조회된 송장번호가 없습니다."))
            return
        }
        
        Dialog.show(container: self, viewController: nil,
                    title: NSLocalizedString("common_task_init", comment: "작업초기화"),
                    message: NSLocalizedString("common_confirm_work_Init", comment: "현재 작업을 초기화 하시겠습니까 ?"),
                    okTitle: NSLocalizedString("common_confirm", comment: "확인"),
                    okHandler: { (_) in
                        self.sendWorkInitData(saleWorkId: self.mStrSaleWorkId)
        },
                    cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
    }
    

    //======================================
    //===== '임시저장'버튼
    //======================================
    @IBAction func onTempSaveClick(_ sender: UIButton)
    {
        if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
            return
        }
        
        if(self.mStrSaleWorkId.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_enter_your_work_id", comment: "송장번호를 입력하여 주십시오."))
            return
        }
        
        if(self.mBoolNewTagInfoExist == false)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
            return
        }
        
        // 납품(지서서O) 입고 처리
        if(self.mStrSaleType == Constants.SALE_TYPE_DELIVERY)
        {
            if(self.mIntProcCount > self.mIntWorkAssignCount)
            {
                //처리수량이 예정수량보다 큽니다.(입고불가)
                Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_can_not_processed_because_completed_assigned_quantity", comment: "할당한 수량을 완료하였기 때문에 처리할수 없습니다."))
                return
            }
        }
        
        let strVehName = self.tfVehName?.text ?? ""

        //DB로 데이터 전송 처리
        sendData(Constants.WORK_STATE_WORKING, mStrSaleWorkId, strVehName, "", "", "")
        
    }
    
    

    //======================================
    //===== '완료전송'버튼
    //======================================
    @IBAction func onSendClicked(_ sender: UIButton)
    {
        //리더기 장치ID 필수
        if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
            return
        }
        
        //차량번호 필수
        let strVehName = tfVehName?.text ?? ""
        if(strVehName.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("msg_enter_vehicle_number", comment: "차량번호를 입력하여 주십시오."))
            return
        }
        
        //송장번호 필수
        let strSaleWorkId = btnSaleWorkId.titleLabel?.text
        if(strSaleWorkId?.isEmpty == true)
        {
            Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_enter_your_work_id", comment: "송장번호를 입력하여 주십시오."))
            return
        }
        
        //납품(지시서O) 처리
        if(self.mStrSaleType == Constants.SALE_TYPE_DELIVERY)
        {
            if(self.mIntProcCount > self.mIntWorkAssignCount)
            {
                //완료전송을 하기 위해서는 출고예정과 처리량이 동일해야 합니다.
                Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("sale_same_processing_qty_work_assing_qty", comment: "완료전송을 하기 위해서는 출고예정과 처리량이 동일해야 합니다."))
                return
            }
        }
        self.performSegue(withIdentifier: "segOutSignDialog", sender: self)
    }
    
    
    
    
    
    //======================================
    //===== 초기화 버튼 처리, 태그 리스트 재조회
    //======================================
    func doReloadTagList()
    {
        let clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "inOutService:selectSaleOutWorkList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.mStrSaleWorkId)
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "pageNo", value: 1)
        clsDataClient.addServiceParam(paramName: "rowsPerPage", value: 300)
        
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                print(error)
                return
            }
            guard let clsDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            
            // 2) DB에서 리스트 조회값 받음
            for clsDataRow in clsDataTable.getDataRows()
            {
                let strOrderCustName            = clsDataRow.getString(name: "orderCustName") ?? ""
                let strDeliBranchName           = clsDataRow.getString(name: "deliBranchName") ?? ""
                self.mIntWorkAssignCount        = clsDataRow.getInt(name: "workAssignCnt") ?? 0
                self.mIntProcCount              = clsDataRow.getInt(name: "procCnt") ?? 0               //처리량
                self.mStrProdAssetEpc           = clsDataRow.getString(name: "prodAssetEpc") ?? ""      //유형
                let strProdAssetEpcName         = clsDataRow.getString(name: "prodAssetEpcName") ?? ""  //유형명
                var intRemainCnt                = self.mIntWorkAssignCount - self.mIntProcCount         //미처리량
                if(intRemainCnt < 0)
                {
                    intRemainCnt = 0            //미처리량 0이하는 0
                }
                
                //1)화면에 표시
                DispatchQueue.main.async
                {
                    self.lblOrderCustName.text = strOrderCustName
                    self.lblDeliBranchName.text = strDeliBranchName
                    self.btnSaleWorkId.setTitle(self.mStrSaleWorkId, for: .normal)      //송장번호
                    self.lblAssignCount.text = String(self.mIntWorkAssignCount)         //출고지시수량
                    self.lblProcCount.text = String(self.mIntProcCount)                 //처리수량
                    self.lblAssetEpcName.text = strProdAssetEpcName                     //유형명
                    self.lblRemainCount.text = String(intRemainCnt)                     //미처리량
                }
                //2)태그데이터 초기화
                self.clearTagData(false)


                //3)조회 및 그리드 리스트에 표시
                self.doSearchWorkListDetail()        //선택된 '송장정보' 내용 조회
                self.doSearchTagList()               //선택된 '송장정보'에 대한 태그리스트
                

                self.mBoolWorkListSelected = true    //송장 선택 여부
                super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
            }
        })
    }
    
    
    

    //======================================
    //===== 송장조회(번호)에 대한 상세 태그리스트
    //======================================
    func doSearchTagList()
    {
        let clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.SelectUrl = "supplyService:selectSaleOutTagList"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userLang", value: AppContext.sharedManager.getUserInfo().getUserLang())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: self.mStrSaleWorkId)
        clsDataClient.selectData(dataCompletionHandler: {(data, error) in
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                print(error)
                return
            }
            guard let clsDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            
            //2)DB에서 리스트 조회값 받음
            for clsDataRow in clsDataTable.getDataRows()
            {
                let strEpcCode              = clsDataRow.getString(name: "epcCode") ?? ""
                let strEpcUrn               = clsDataRow.getString(name: "epcUrn") ?? ""
                let strUtcTraceDate         = clsDataRow.getString(name: "utcTraceDate") ?? ""
                let strProdAssetEpcName     = clsDataRow.getString(name: "prodAssetEpcName") ?? ""
                
                let clsTagInfo = RfidUtil.TagInfo()
                clsTagInfo.setEpcCode(strEpcCode)
                clsTagInfo.setAssetName(strProdAssetEpcName)
                
                if(strEpcUrn.isEmpty == false)
                {
                    clsTagInfo.setEpcUrn(strEpcUrn)
                    let arsEpcUrn = strEpcUrn.split(".")
                    if( arsEpcUrn.count == 4)
                    {
                        let strCorpEpc  = arsEpcUrn[1]
                        let strAssetEpc = arsEpcUrn[2]
                        let strSerialNo = arsEpcUrn[3]
                        
                        let strNewAssetEpc = "\(strCorpEpc)\(strAssetEpc)"
                        
                        print("=============================================")
                        print("strCorpEpc:\(strCorpEpc)")
                        print("strNewAssetEpc:\(strNewAssetEpc)")
                        print("strSerialNo:\(strSerialNo)")
                        print("=============================================")
                        
                        clsTagInfo.setAssetEpc(strNewAssetEpc)
                        clsTagInfo.setSerialNo(strSerialNo)
                    }
                }
                
                if(strUtcTraceDate.isEmpty == false)
                {
                    let strLocaleTraceDate = DateUtil.utcToLocale(utcDate: strUtcTraceDate, dateFormat: "yyyyMMddHHmmss")
                    clsTagInfo.setReadTime(strLocaleTraceDate)
                }
                
                self.arrTagRows.append(clsTagInfo)
            }
            
        })
        
    }
    

    //=======================================
    //===== 작업초기화 데이터를 전송한다
    //======================================
    func sendWorkInitData(saleWorkId: String)
    {
        clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
        let clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.ExecuteUrl = "inOutService:executeOutCancelData"
        clsDataClient.removeServiceParam()
        clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
        clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
        clsDataClient.addServiceParam(paramName: "saleWorkId", value: saleWorkId)
        clsDataClient.executeData(dataCompletionHandler: { (data, error) in
            self.clsIndicator?.hide()
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                return
            }
            guard let clsResultDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            
            //print("===='작업초기화' 결과값 처리")
            let clsResultDataRows = clsResultDataTable.getDataRows()
            if(clsResultDataRows.count > 0)
            {
                let clsDataRow = clsResultDataRows[0]
                let strResultCode = clsDataRow.getString(name: "resultCode")
                
                print(" -strResultCode:\(strResultCode!)")
                if(Constants.PROC_RESULT_SUCCESS == strResultCode)
                {
                    DispatchQueue.main.async
                    {
                        //초기화 처리
                        self.doReloadTagList()
                    }
                }
                else
                {
                    let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
                    self.showSnackbar(message: strMsg)
                }
            }
            
        })
    }
    
    
    
    //=======================================
    //===== DB로 데이터 전송처리
    //======================================
    func sendData(_ workState: String,_ saleWorkId: String,_ vehName: String,_ workerName: String,_ remark: String,_ signData: String)
    {
        clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
        
        let clsDataClient = DataClient(container: self, url: Constants.WEB_SVC_URL)
        clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
        clsDataClient.ExecuteUrl = "inOutService:executeOutData"
        clsDataClient.removeServiceParam()
        
        clsDataClient.addServiceParam(paramName: "workState",       value: workState)
        clsDataClient.addServiceParam(paramName: "corpId",          value: AppContext.sharedManager.getUserInfo().getCorpId())
        clsDataClient.addServiceParam(paramName: "userId",          value: AppContext.sharedManager.getUserInfo().getUserId())
        clsDataClient.addServiceParam(paramName: "saleWorkId",      value: saleWorkId)
        clsDataClient.addServiceParam(paramName: "vehName",         value: vehName)
        clsDataClient.addServiceParam(paramName: "branchId",        value: AppContext.sharedManager.getUserInfo().getBranchId())
        clsDataClient.addServiceParam(paramName: "unitId",          value: AppContext.sharedManager.getUserInfo().getUnitId())
        clsDataClient.addServiceParam(paramName: "barcodeId",       value: "")      //바코드ID
        clsDataClient.addServiceParam(paramName: "itemCode",        value: "")      //제품코드
        clsDataClient.addServiceParam(paramName: "prodCnt",         value: "")      //제품개수
                
        //완료전송 및(강제)완료전송, 처리진행인경우
        if(Constants.WORK_STATE_COMPLETE == workState)
        {
            let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
            let strWorkDateTime = DateUtil.localeToUtc(localeDate: strCurReadTime, dateFormat: "yyyyMMddHHmmss")
            clsDataClient.addServiceParam(paramName: "workDateTime",    value: strWorkDateTime)
            clsDataClient.addServiceParam(paramName: "workerName",      value: workerName)
            clsDataClient.addServiceParam(paramName: "remark",          value: remark)
            
            if(signData.isEmpty == false)
            {
                clsDataClient.addServiceParam(paramName: "signData",    value: signData)        // 사인데이터
            }
        }
        
        let clsDataTable : DataTable = DataTable()
        clsDataTable.Id = "WORK_OUT"
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        clsDataTable.addDataColumn(dataColumn: DataColumn(id: "traceDateTime", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
        
        for clsInfo in self.arrTagRows
        {
            if(clsInfo.getNewTag() == true)
            {
                let strTraceDate = DateUtil.localeToUtc(localeDate: clsInfo.getReadTime(), dateFormat: "yyyyMMddHHmmss")
                let clsDataRow : DataRow = DataRow()
                clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
                clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
                clsDataRow.addRow(name:"traceDateTime", value: strTraceDate)
                clsDataTable.addDataRow(dataRow: clsDataRow)
            }
        }
        clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
            self.clsIndicator?.hide()
            if let error = error {
                // 에러처리
                super.showSnackbar(message: error.localizedDescription)
                print(error)
                return
            }
            guard let clsResultDataTable = data else {
                print("에러 데이터가 없음")
                return
            }
            
            //print("####결과값 처리")
            let clsResultDataRows = clsResultDataTable.getDataRows()
            if(clsResultDataRows.count > 0)
            {
                let clsDataRow = clsResultDataRows[0]
                let strResultCode = clsDataRow.getString(name: "resultCode")
                
                print(" -strResultCode:\(strResultCode!)")
                if(Constants.PROC_RESULT_SUCCESS == strResultCode)
                {
                    let strSvrProcCount = clsDataRow.getString(name: "procCount")
                    let strSvrWorkState = clsDataRow.getString(name: "workState")
                    print("-서버로부터 받은 처리갯수: \(strSvrProcCount ?? "")")
                    print("-서버로부터 받은 작업처리상태: \(strSvrWorkState ?? "")")
                    
                    DispatchQueue.main.async
                    {
                        //전송 성공인 경우
                        for clsInfo in self.arrTagRows
                        {
                            clsInfo.setNewTag(false)    // 태그상태 NEW -> OLD로 변경
                        }
                        self.mBoolNewTagInfoExist = false
                        
                        //현재 작업상태가 완료전송인경우
                        if(Constants.WORK_STATE_COMPLETE == strSvrWorkState)
                        {
                            //송장정보관련 UI객체를 초기화한다.
                            self.clearTagData(true)
                        }
                        let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
                        self.showSnackbar(message: strMsg)
                    }
                }
                else
                {
                    let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
                    self.showSnackbar(message: strMsg)
                }
            }
        })
    }
    
    
    
}



extension CombineOut: BarcodeScannerCodeDelegate
{
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode barcode: String, type: String)
    {
        print("================================")
        print(" - Barcode Data: \(barcode)")
        print(" - Symbology Type: \(type)")
        print("================================")
        
        controller.dismiss(animated: true, completion: nil)
        if(barcode.isEmpty == false)
        {
            if(mStrSaleWorkId.isEmpty == false)
            {
                if(mStrSaleWorkId != barcode)
                {
                    doSearchBarcode(barcode: barcode)
                }
            }
            else
            {
                doSearchBarcode(barcode: barcode)
            }
        }
    }
}

extension CombineOut: BarcodeScannerErrorDelegate
{
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error)
    {
        print(error)
    }
}

extension CombineOut: BarcodeScannerDismissalDelegate
{
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


//=======================================
//===== 툴바 타이틀
//======================================
extension CombineOut
{
    fileprivate func prepareToolbar()
    {
        guard let tc = toolbarController else {
            return
        }
        tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
        tc.toolbar.detail = NSLocalizedString("title_work_out_delivery", comment: "출고")
    }
}


