//
//  OutMemoDialog.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 12. 12..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Material
import Mosaic


class OutMemoDialog: BaseViewController
{
    var ptcDataHandler : DataProtocol?

    //@IBOutlet weak var tfRemark: UITextField!

    @IBOutlet weak var tfMemo: UITextField!
    
    override func viewDidLoad()
    {
        print("##[OutMemoDialog]->viewDidLoad()")
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("##[OutMemoDialog]->viewWillAppear()")
        super.viewWillAppear(animated)
        super.initController()
    }
    
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.releaseController()
        super.viewDidDisappear(animated)
    }
    
    //=======================================
    //===== '닫기(X)'버튼
    //=======================================
    @IBAction func onCloseClicked(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }

    //=======================================
    //===== '확인(X)'버튼
    //=======================================
    @IBAction func onConfirmClicked(_ sender: Any)
    {
        let clsDataRow : DataRow = DataRow()
        clsDataRow.addRow(name: "remark", value: tfMemo.text ?? "")
        let strtData = ReturnData(returnType: "outMemoDialog", returnCode: nil, returnMesage: nil, returnRawData: clsDataRow)
        ptcDataHandler?.recvData(returnData: strtData)
        self.dismiss(animated: true, completion: nil)
    }
    
    func didStart()
    {
        print("Started Drawing")
    }
    
    // didFinish() is called rigth after the last touch of a gesture is registered in the view.
    // Can be used to enabe scrolling in a scroll view if it has previous been disabled.
    func didFinish()
    {
        print("Finished Drawing")
    }
}

