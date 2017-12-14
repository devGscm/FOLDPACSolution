//
//  RfidUtil.swift
//   RRPPClient
//
//  Created by 현병훈 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation
import Mosaic

public class RfidUtil
{
    
    /**
     * 태그정보를 정의한 클래스
     * @author 모람씨앤티
     * @version 1.0
     */
    public class TagInfo
    {
        var mEnuEncoding: Encodings?            /**< 인코딩 종류             */
        var mStrEpcUrn: String?                 /**< EPC URN              */
        var mStrEpcCode: String?                /**< EPC 코드              */
        var mStrCorpEpc: String?                /**< 기업EPC코드            */
        var mStrAssetEpc: String?               /**< 자산EPC코드            */
        
        var mStrItem: String?                   /**< 상품                  */
        var mStrSerialNo: String?               /**< 시리얼번호(제조업체 + 제조년 + 제조월 + 순차번호 로 구성) */
        var mStrLocation: String?               /**< 위치                  */
        var mStrProdCode: String?               /**< 상품코드               */
        var mStrProdName: String?               /**< 상품명                */
        var mStrProdReadCnt: String?            /**< 인식수량               */
        var mStrCustEpc: String?                /**< 고객사EPC             */
        var mStrYymm: String?                   /**< 발행연월               */
        var mStrSeqNo: String?                  /**< 발행순번               */
        var mStrAssetName: String?              /**< 자산EPC명             */
        var mBoolNewTag : Bool?
        var mIntReadCount = 0                   /**< 조회수                */
        var mStrReadTime : String?
		var mIsChecked : Bool
		var mStrResult : String
		
        
        init()
        {
            mEnuEncoding        = nil
            mStrEpcUrn          = nil
            mStrEpcCode         = nil
            mStrCorpEpc         = nil
            mStrAssetEpc        = nil
            mStrItem            = nil
            mStrSerialNo        = nil
            mStrLocation        = nil
            mStrProdCode        = nil
            mStrProdName        = nil
            mStrProdReadCnt     = nil
            mStrCustEpc         = nil
            mStrYymm            = nil
            mStrSeqNo           = nil
            mStrAssetName       = nil
            mBoolNewTag         = false
            mIntReadCount       = 0
            mStrReadTime        = nil
			mIsChecked			= false
			mStrResult				= ""
        }
        
        /**
         * 인코딩 종류를 리턴한다.
         * @return
         */
        public func getEncoding() -> Encodings                  { return mEnuEncoding ?? Encodings.GRAI_96            }
        
        /**
         * EPC URN를 리턴한다.
         * @return
         */
        public func getEpcUrn() -> String                       { return mStrEpcUrn ?? ""            }
        
        /**
         * EPC 코드를 리턴한다.
         * @return
         */
        public func getEpcCode() -> String                      { return mStrEpcCode ?? ""            }
        
        /**
         * 기업EPC코드를 리턴한다.
         * @return
         */
        public func getCorpEpc() -> String                      { return mStrCorpEpc ?? ""            }
        
        /**
         * 자산EPC코드를 리턴한다.
         * @return
         */
        public func getAssetEpc() -> String                     { return mStrAssetEpc ?? ""            }
        
        
        /**
         * 상품을 리턴한다.
         * @return
         */
        public func getItem() -> String                         { return mStrItem ?? ""            }
        
        /**
         * 시리얼번호를 리턴한다.
         * @return
         */
        public func getSerialNo() -> String                     { return mStrSerialNo ?? ""            }
        
        /**
         * 위치를 리턴한다.
         * @return
         */
        public func getLocation() -> String                     { return mStrLocation ?? ""            }
        
        /**
         * 상품코드를 리턴한다.
         * @return
         */
        public func getProdCode() -> String                     { return mStrProdCode ?? ""        }
        
        /**
         * 상품명을 리턴한다.
         * @return
         */
        public func getProdName() -> String                     { return mStrProdName ?? ""        }
        
        /**
         * 상품명을 리턴한다.
         * @return
         */
        public func getProdReadCnt() -> String                  { return mStrProdReadCnt ?? ""        }
        
        /**
         * 고객사EPC를 리턴한다.
         * @return
         */
        public func getCustEpc() -> String                      { return mStrCustEpc ?? ""            }
        
        /**
         * 발행연월을 리턴한다.
         * @return
         */
        public func getYymm() -> String                         { return mStrYymm ?? ""                }
        
        /**
         * 발행순번을 리턴한다.
         * @return
         */
        public func getSeqNo() -> String                        { return mStrSeqNo ?? ""                }
        
        
        
        // 자산명을 리턴한다.
        public func getAssetName() -> String                    { return mStrAssetName ?? "" }
        public func getNewTag() -> Bool                         { return mBoolNewTag ?? false }
        public func getReadCount() -> Int                       { return mIntReadCount     }
        public func getReadTime() -> String                     { return mStrReadTime ?? "" }
		
		public func getChecked() -> Bool 						{return mIsChecked}
		
		public func getResult() -> String 						{return mStrResult}
        
        /**
         * 인코딩 종류를 설정한다.
         * @param enuEncoding 인코딩 종류
         */
        public func setEncoding(enuEncoding: Encodings)         { self.mEnuEncoding = enuEncoding        }
        
        /**
         * EPC URN를 설정한다.
         * @param strEpcUrn EPC URN
         */
        public func setEpcUrn(strEpcUrn: String)                { self.mStrEpcUrn   = strEpcUrn        }
        
        /**
         * EPC 코드를 설정한다.
         * @param strEpcCode EPC 코드
         */
        public func setEpcCode( strEpcCode: String)             { self.mStrEpcCode  = strEpcCode        }
        
        /**
         * 기업EPC코드를 설정한다.
         * @param strCorpEpc 기업EPC코드
         */
        public func setCorpEpc( strCorpEpc: String)             { self.mStrCorpEpc  = strCorpEpc        }
        
        /**
         * 자산EPC코드를 설정한다.
         * @param strAssetEpc 자산EPC코드
         */
        public func setAssetEpc( assetEpc: String)           { self.mStrAssetEpc = assetEpc        }
        
        
        /**
         * 상품을 설정한다.
         * @param strItem 상품
         */
        public func setItem( strItem: String)                   { self.mStrItem     = strItem            }
        
        /**
         * 시리얼번호를 설정한다.
         * @param strSerialNo 시리얼번호
         */
        public func setSerialNo( strSerialNo: String)           { self.mStrSerialNo = strSerialNo        }
        
        /**
         * 위치를 설정한다.
         * @param strLocation 위치
         */
        public func setLocation( strLocation: String)           { self.mStrLocation = strLocation        }
        
        /**
         * 상품코드를 설정한다.
         * @param strProdCode
         */
        public func setProdCode( strProdCode: String)           { self.mStrProdCode = strProdCode    }
        
        /**
         * 상품명을 설정한다.
         * @param strProdName
         */
        public func setProdName( strProdName: String)           { self.mStrProdName = strProdName    }
        
        /**
         * 인식수량을 설정한다.
         * @param strProdReadCnt
         */
        public func setProdReadCnt( strProdReadCnt: String)     { self.mStrProdReadCnt = strProdReadCnt    }
        
        /**
         * 고객사EPC를 설정한다.
         * @param strCustEpc 고객사EPC
         */
        public func setCustEpc(strCustEpc: String)              { self.mStrCustEpc  = strCustEpc        }
        
        /**
         * 발행연월를 설정한다.
         * @param strYymm 발행연월
         */
        public func setYymm(strYymm: String)                    { self.mStrYymm     = strYymm            }
        
        /**
         * 발행순번을 설정한다.
         * @param strSeqNo 발행순번
         */
        public func setSeqNo(strSeqNo: String)                  { self.mStrSeqNo = strSeqNo }
        public func setAssetName( assetName: String)            { self.mStrAssetName = assetName }
        public func setNewTag(newTag: Bool)                     { self.mBoolNewTag = newTag }
        public func setReadCount(readCount: Int)                { self.mIntReadCount = readCount }
        public func setReadTime(readTime: String)               { self.mStrReadTime = readTime }
		
		public func setChecked(_ checked: Bool)						{self.mIsChecked = checked	}
		
		public func setResult(_ result: String)						{self.mStrResult = result }
    }

    
    public enum Encodings
    {
        case GID_96, SGTIN_96, SSCC_96, SGLN_96, GRAI_96, GIAI_96, DoD_96, Raw
    }
    
    public static func checkHeader(strData: String) -> Encodings
    {
        //let strData = "3312D58E3D8100C000027505"                                        //테스트 입력값(Hex): 3312D58E3D8100C000027505
        
        var strHeaderBinary = String()
        
        //문자열 잘르기
        let idxStartIndex = strData.index(strData.startIndex, offsetBy:0)
        let idxEndIndex = strData.index(strData.startIndex, offsetBy:1)
        let strSubStringHeader = strData[idxStartIndex...idxEndIndex]                   //변경값(Hex): 33
        
        //String to Hex 변환
        let intHeaderHex = Int(strSubStringHeader, radix: 16)                           //변경값(Dec): 51
        
        //Hex to Binary 변환
        strHeaderBinary = String(intHeaderHex!, radix: 2)                               //변경값(Binary): 110011
        
        //헤더값 8자리 맞춤
        if(strHeaderBinary.count < 8)
        {
            let intShortBinaryCnt = 8 - strHeaderBinary.count
            var strZeroPaddings = String()
            for _ in 1...intShortBinaryCnt
            {
                strZeroPaddings += "0"
            }
            strHeaderBinary = strZeroPaddings + strHeaderBinary                         //변경값(Binary): 00110011
        }
        
        //바이너리 변환
        //for strHeaderSingleChar in strSubStringHeader
        //{
        //    let intBinary = Int(String(strHeaderSingleChar)) ?? 0
        //    let strBinary = String(intBinary, radix:2)
        //    let strBinaryAddSize = "00" + strBinary
        //    strHeaderBinary.append(strBinaryAddSize)                        //헤더값: 00110011
        //    print("\(strHeaderBinary)")
        //}
        
        if(strHeaderBinary == "00101111"){
            return Encodings.DoD_96
        }
        else if (strHeaderBinary == "00110000"){
            return Encodings.SGTIN_96
        }
        else if (strHeaderBinary == "00110001"){
            return Encodings.SSCC_96
        }
        else if (strHeaderBinary == "00110010"){
            return Encodings.SGLN_96
        }
        else if (strHeaderBinary == "00110011"){
            return Encodings.GRAI_96                                       //헤더값 '33'입력시 -> 'GRAI_96' 리턴
        }
        else if (strHeaderBinary == "00110100"){
            return Encodings.GIAI_96
        }
        else if (strHeaderBinary == "00110101"){
            return Encodings.GID_96
        }
        return Encodings.Raw
    }
    
    
    
    /**
     * 태그 종류별 스위칭
     * @param strData 입력값
     * @return
     */
    public static func parse(strData: String) -> TagInfo
    {
        let strInputData = strData.replacingOccurrences(of: " ", with: "")
        let enuEncoding: Encodings = checkHeader(strData: strInputData)
        
        //print("==== [RfidUtil]=>parse: \(enuEncoding) :: \(strInputData) ====\n")
        //print("===================================================\n")
        
        switch(enuEncoding)
        {
        case .GID_96:
            return RfidUtil.parseGid96(enuEncoding: RfidUtil.Encodings.GID_96, strData: strInputData)
            
        case .SGTIN_96:
            return RfidUtil.parseSgtin96(enuEncoding: RfidUtil.Encodings.SGTIN_96, strData: strInputData)
            
        case .SSCC_96:
            return RfidUtil.parseSscc96(enuEncoding: RfidUtil.Encodings.SSCC_96, strData: strInputData)
            
        case .SGLN_96:
            return RfidUtil.parseSgln96(enuEncoding: RfidUtil.Encodings.SGLN_96, strData: strInputData)
            
        case .GRAI_96:
            return RfidUtil.parseGrai96(enuEncoding: RfidUtil.Encodings.GRAI_96, strData: strInputData)
            
        case .GIAI_96:
            return RfidUtil.parseGiai96(enuEncoding: RfidUtil.Encodings.GIAI_96, strData: strInputData)
            
        case .DoD_96:
            return RfidUtil.parseDod96(enuEncoding: RfidUtil.Encodings.DoD_96, strData: strInputData)
            
        case .Raw:
            return RfidUtil.parseRaw(enuEncoding: RfidUtil.Encodings.Raw, strData: strInputData)

        }
    }
    
    
    
    
    
    /**
     * 48길이로 채운다.
     * @param input 입력값
     * @return
     */
    public static func fillLength48(strInput: String) -> String
    {
        //let strInput: String = "00C000027505"                                         //테스트 입력값(Hex): 00C000027505
        var strInputToBinary = String()
        
        //String to Hex 변환
        let intInputToHex = Int(strInput, radix: 16)                                    //변경값(DEC): 824633881861
        //print("\(intInputToHex ?? 0)")
        
        //Hex to Binary 변환
        strInputToBinary = String(intInputToHex!, radix: 2)                             //변경값(Binary): 1100000000000000000000100111010100000101
        
        //print("\(strInputToBinary)")
        //print("\(strInputToBinary.count)")
        
        //입력값 48자리 맞춤
        if(strInputToBinary.count < 48)
        {
            let intShortBinaryCnt = 48 - strInputToBinary.count
            var strZeroPaddings = String()
            for _ in 1...intShortBinaryCnt
            {
                strZeroPaddings += "0"
            }
            //print("48보다 작음: \(intShortBinaryCnt)")
            //print("변경전:\(strInputToBinary)")
            
            strInputToBinary = strZeroPaddings + strInputToBinary
            
            //print("변경후:\(strInputToBinary)")
        }
        return strInputToBinary;
    }
    
    
    /**
     * parseGid96으로 변환한다.
     */
    public static func parseGid96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "gid:"
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 36), radix: 2)!) + "."
            + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 36, intIndexEnd: 59), radix: 2)!) + "."
            + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 60, intIndexEnd: 95), radix: 2)!)
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        return clsTagInfo
    }
    
    
    
    /**
     * Sgtin96으로 변환한다.
     */
    public static func parseSgtin96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "sgtin:"
        var strCorpEpc = String()
        var strItem = String()
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 10), radix: 2)!) + "."
        
        //Partition 변환
        let intPartition: Int? = Int(StrUtil.substring(strInputString: bitString, intIndexStart: 11, intIndexEnd: 13), radix: 2)
        
        //print("==== [RfidUtil]=>parseSgtin96:\(intPartition!) ====\n")
        //print("===================================================\n")
        
        switch(intPartition!)
        {
        case 0:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 53), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 54, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 1:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 51), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 51, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 2:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 48), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 48, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 3:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 44), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 44, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 4:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 40), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 41, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 5:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 37), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 38, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 6:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 34), radix: 2)!)
            strItem = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 34, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strItem, intCount: 13 - strItem.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            break;
            
        default:
            break;
        }
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setCorpEpc(strCorpEpc: strCorpEpc)
        clsTagInfo.setItem(strItem: strItem)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    /**
     * Sscc96으로 변환한다.
     */
    public static func parseSscc96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "sscc:"
        var strCorpEpc = String()
        var strSerialNo = String()
        
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 10), radix: 2)!) + "."
        
        //Partition 변환
        let intPartition: Int? = Int(StrUtil.substring(strInputString: bitString, intIndexStart: 11, intIndexEnd: 13), radix: 2)
        
        switch(intPartition!)
        {
        case 0:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 53), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 54, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 1:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 50), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 51, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 2:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 48), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 48, intIndexEnd: 72), radix: 2)!)
            
            
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 3:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 43), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 44, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 4:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 41), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 41, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 5:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 37), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 38, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        case 6:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 33), radix: 2)!)
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 33, intIndexEnd: 71), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strSerialNo, intCount: 17 - strSerialNo.count - strCorpEpc.count)
            break;
            
        default:
            break;
        }
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setCorpEpc(strCorpEpc: strCorpEpc)
        clsTagInfo.setSerialNo(strSerialNo: strSerialNo)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    /**
     * Sgln96으로 변환한다.
     */
    public static func parseSgln96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "sgln:"
        var strCorpEpc = String()
        var strLocation = String()
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 10), radix: 2)!) + "."
        
        //Partition 변환
        let intPartition: Int? = Int(StrUtil.substring(strInputString: bitString, intIndexStart: 11, intIndexEnd: 13), radix: 2)
        
        switch(intPartition!)
        {
        case 0:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 53), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 54, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 1:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 50), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 51, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 2:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 47), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 48, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 3:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 40), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 41, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 4:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 40), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 41, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 5:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 37), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 38, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        case 6:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 33), radix: 2)!)
            strLocation = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 34, intIndexEnd: 54), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strLocation, intCount: 12 - strLocation.count - strCorpEpc.count) + "."
                + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 55, intIndexEnd: 95), radix: 2)!)
            break;
            
        default:
            break;
        }
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setCorpEpc(strCorpEpc: strCorpEpc)
        clsTagInfo.setLocation(strLocation: strLocation)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    /**
     * Grai96으로 변환한다.
     */
    public static func parseGrai96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        //print("[2]=>parseGrai96: \(strData)")
        
        //let enuEncoding = RfidUtil.Encodings.GRAI_96                                        //테스트 입력값: GRAI_96
        //let strData = "3312D58E3D8100C000027505"                                            //테스트 입력값: 3312D58E3D8100C000027505
        
        var strEpcUrn = "grai:"
        var strCorpEpc = String()
        var strAssetEpc = String()
        let strCustEpc = String()
        let strIssueYear = String()
        var strSerialNo = String()
        let strIssueSeq = String()
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))               //결과: 3312D58E3D81
                        + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))            //결과: 00C000027505
                        //결과: 001100110001001011010101100011100011110110000001000000001100000000000000000000100111010100000101
        
        //Partition 변환
        let subStrBitString = StrUtil.substring(strInputString: bitString, intIndexStart: 11, intIndexEnd: 13)                                   //결과: 100
        let intPartition: Int? = Int(subStrBitString, radix: 2)                                                                                 //결과: 4
        
        switch(intPartition!)
        {
        case 0:
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 53), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 54, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        case 1:
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 51), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 51, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        case 2:
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 48), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 48, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        case 3:
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 44), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 44, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        case 4:
            //RRPP용
            strSerialNo = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 58, intIndexEnd: 95), radix: 2)!)               //결과: 161029
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 40), radix: 2)!)                //결과: 95100027
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 41, intIndexEnd: 57), radix: 2)!)               //결과: 1027
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count)
                + "." + strSerialNo                                                                                                             //결과: grai:95100027.1027.161029
            break;
            
        case 5:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 37), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 38, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        case 6:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 34), radix: 2)!)
            strAssetEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 34, intIndexEnd: 57), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + addPaddingZeros(strInputString: strAssetEpc, intCount: 12 - strAssetEpc.count - strCorpEpc.count) + "." + strSerialNo
            break;
            
        default:
            break;
        }
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setCorpEpc(strCorpEpc: strCorpEpc)
        clsTagInfo.setAssetEpc(assetEpc: strAssetEpc)
        clsTagInfo.setSerialNo(strSerialNo: strSerialNo)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        clsTagInfo.setCustEpc(strCustEpc: strCustEpc)
        clsTagInfo.setYymm(strYymm: strIssueYear)
        clsTagInfo.setSeqNo(strSeqNo: strIssueSeq)
        
        return clsTagInfo
    }
    
    
    
    /**
     * parseGiai96으로 변환한다.
     */
    public static func parseGiai96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "giai:"
        var strCorpEpc = String()
        var strAssetRef = String()
        
        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 10), radix: 2)!) + "."
        
        //Partition 변환
        let intPartition: Int? = Int(StrUtil.substring(strInputString: bitString, intIndexStart: 11, intIndexEnd: 13), radix: 2)
        
        
        switch(intPartition!)
        {
        case 0:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 53), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 54, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 1:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 50), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 51, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 2:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 48), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 48, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 3:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 43), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 44, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 4:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 40), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 40, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 5:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 37), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 38, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        case 6:
            strCorpEpc = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 14, intIndexEnd: 33), radix: 2)!)
            strAssetRef = String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 34, intIndexEnd: 95), radix: 2)!)
            strEpcUrn += strCorpEpc + "." + strAssetRef
            break;
            
        default:
            break;
        }
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setCorpEpc(strCorpEpc: strCorpEpc)
        clsTagInfo.setAssetEpc(assetEpc: strAssetRef)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    
    
    /**
     * parseDod96으로 변환한다.
     */
    public static func parseDod96(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        var strEpcUrn = "usdod:"

        //바이너리 변환
        let bitString = self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 0, intIndexEnd: 11))
            + self.fillLength48(strInput: StrUtil.substring(strInputString: strData, intIndexStart: 12, intIndexEnd: 23))
        
        //EPC-URN 조합
        strEpcUrn += String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 8, intIndexEnd: 11), radix: 2)!) + "."
            + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 12, intIndexEnd: 59), radix: 2)!) + "."
            + String(Int(StrUtil.substring(strInputString: bitString, intIndexStart: 60, intIndexEnd: 95), radix: 2)!) + "."
        
        //소문자 변환
        strEpcUrn = strEpcUrn.lowercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    
    /**
     * Raw으로 변환한다.
     */
    public static func parseRaw(enuEncoding: Encodings, strData: String) -> TagInfo
    {
        //대문자 변환
        let strEpcUrn =  String(strData.count * 4) + ".x" + strData.uppercased()
        
        //태그정보에 저장
        let clsTagInfo = TagInfo()
        clsTagInfo.setEpcCode(strEpcCode: strData)
        clsTagInfo.setEncoding(enuEncoding: enuEncoding)
        clsTagInfo.setEpcUrn(strEpcUrn: strEpcUrn)
        
        return clsTagInfo
    }
    
    
    //=======================================
    //===== 문자열에 0 채우기
    //=======================================
    public static func addPaddingZeros(strInputString: String, intCount: Int) -> String
    {
        var strInputData = strInputString
        
        for _ in 0..<intCount
        {
            strInputData = "0" + strInputData
        }
        return strInputData
    }
    
}

