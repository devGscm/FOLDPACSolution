//
//  ViewController.swift
//  RRPPClient
//
//  Created by MORAMCNT on 2017. 11. 7..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit
import Mosaic

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //#########################################
        // 1. Login 호출
        //#########################################
        let dataClient = Mosaic.DataClient(url: Constants.WEB_SVC_URL)
        dataClient.loginService(userId : "rp11", passwd : "1111", mobileId : "01053567314",
                              loginCompletionHandler:
                              { (login, error) in
                                if let error = error {
                                    //에러처리
                                    print(error)
                                    return
                                }
                                guard let login = login else {
                                    print("에러 데이터가 없음")
                                    return
                                }
                                // 성공
                                if let returnCode = login.returnCode , returnCode > 0
                                {
                                    if let userInfo = login.encryptId
                                    {
                                        print("userInfo: \(userInfo)")
                                    }

                                }
                                else
                                {
                                    print("인증오류")
                                }

                            })
        
        //########################################
        // 2.selectRawData 호출
        //#########################################
        dataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
        dataClient.UserData = "redis.selectBranchList"
        dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
        dataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
        dataClient.addServiceParam(paramName: "custType", value: "MGR")
        dataClient.selectRawData(dataCompletionHandler:
            { (responseData, error) in
                if let error = error {
                    // 에러처리
                    print(error)
                    return
                }
                guard let responseData = responseData else {
                    print("에러 데이터가 없음")
                    return
                }
                // 성공
                if let returnCode = responseData.returnCode , returnCode > 0
                {
                    if let returnMessage = responseData.returnMessage
                    {
                        print("return RawMessage : \(returnMessage)")
                    }
                }
                else
                {
                    print("json 오류")
                }

        })
        
        //#########################################
        ////3. selectData 호출
        //#########################################
        dataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
        dataClient.UserData = "redis.selectBranchList"
        dataClient.removeServiceParam()
        dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
        dataClient.addServiceParam(paramName: "parentCustId", value: "170627000205")
        dataClient.addServiceParam(paramName: "custType", value: "MGR")
        dataClient.selectData(dataCompletionHandler:
            { (data, error) in
                if let error = error {
                    // 에러처리
                    print(error)
                    return
                }
                guard let dataTable = data else {
                    print("에러 데이터가 없음")
                    return
                }

                print("####결과값 처리")
                let dataColumns = dataTable.getDataColumns()
                let dataRows = dataTable.getDataRows()
                for dataRow in dataRows
                {
                    for dataColumn in dataColumns
                    {
                        print(" dataColumn Id:" + dataColumn.Id + " Value:" + dataRow.get(name: dataColumn.Id, defaultValue: 0).debugDescription)
                    }
                }
        })
        
        
        //#########################################
        ////3. excute 호출
        //#########################################
        dataClient.UserInfo = "xxOxOsU93/PvK/NN7DZmZw=="
        dataClient.ExecuteUrl = "redisService:executeClientConfigData"
        dataClient.removeServiceParam()
        dataClient.addServiceParam(paramName: "corpId", value: "logisallcm")
        //dataClient.addServiceParam(paramName: "userId", value: "rp11")
        dataClient.addServiceParam(paramName: "userId", value: "rp11")
        dataClient.addServiceParam(paramName: "unitId", value: "ksck")
        dataClient.addServiceParam(paramName: "branchId", value: "161004000074")
        dataClient.addServiceParam(paramName: "branchCustId", value: "161004000114")
        
        dataClient.executeData(dataCompletionHandler:
            { (data, error) in
                if let error = error {
                    // 에러처리
                    print(error)
                    return
                }
                guard let dataTable = data else {
                    print("에러 데이터가 없음")
                    return
                }
                
                print("####결과값 처리")
                let dataColumns = dataTable.getDataColumns()
                let dataRows = dataTable.getDataRows()
                for dataRow in dataRows
                {
                    for dataColumn in dataColumns
                    {
                        print(" dataColumn Id:" + dataColumn.Id + " Value:" + dataRow.get(name: dataColumn.Id, defaultValue: 0).debugDescription)
                    }
                }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

