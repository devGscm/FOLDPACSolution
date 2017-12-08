//
//  ItemInfo.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 6..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


public class ItemInfo : NSObject
{
    
    var mIntRowState        = -1;
    var mBoolChecked    	= false		/**< 체크 여부             */
    var mStrEpcCode			= ""        /**< EPC 코드            */
    var mStrEpcUrn			= ""        /**< EPC URN        */
    var mStrAssetEpc        = ""        /**< 자산 EPC코드(유형)    */
    var mStrAssetName		= ""        /**< 자산 EPC명(유형)    */
    var mStrSerialNo        = ""        /**< 시리얼번호            */
    var mStrProdCode        = ""        /**< 상품코드            */
    var mStrProdName        = ""        /**< 상품명            */
    var mStrProdReadCnt		= ""        /**< 인식수량            */
    var mStrSaleItemSeq		= ""        /**< DB에 등록된 상품 SEQ    */
    var mIntReadCount		= 0        /**< 조회수             */
    var mStrReadTime		= ""        /**< 조회시간            */
    var mStrResult			= ""        /**< 처리결과            */
    
    
    
    /**
     * 체크여부를 리턴한다.
     * @return
     */
    public func getChecked() -> Bool    { return mBoolChecked        }
    
    /**
     * Epc 코드를 리턴한다.
     * @return
     */
    public func getEpcCode() -> String        { return mStrEpcCode        }
    
    /**
     * Epc Urn를 리턴한다.
     * @return
     */
    public func getEpcUrn() -> String        { return mStrEpcUrn        }
    
    /**
     * 자산 EPC 코드를 리턴한다.
     * @return
     */
    public func getAssetEpc() -> String        { return mStrAssetEpc        }
    
    /**
     * 자산 EPC명을 리턴한다.
     * @return
     */
    public func getAssetName() -> String   { return mStrAssetName        }
    
    /**
     * 시리얼번호를 리턴한다.
     * @return
     */
    public func getSerialNo() -> String        { return mStrSerialNo       }
    
    /**
     * 상품코드를 리턴한다.
     * @return
     */
    public func getProdCode() -> String        { return mStrProdCode       }
    
    /**
     * 상품명을 리턴한다.
     * @return
     */
    public func getProdName() -> String        { return mStrProdName       }
    
    /**
     * 상품명을 리턴한다.
     * @return
     */
    public func getProdReadCnt() -> String        { return mStrProdReadCnt       }
    
    /**
     * 상품등록,시퀀스(SEQ)
     * @return
     */
    public func getSaleItemSeq() -> String       { return mStrSaleItemSeq      }
    
    
    /**
     * 조회수를 리턴한다.
     * @return
     */
    public func getReadCount() -> Int        { return mIntReadCount       }
    
    /**
     * 조회시간을 리턴한다.
     * @return
     */
    public func getReadTime() -> String       { return mStrReadTime       }
    
    /**
     * 처리결과를 리턴한다.
     * @return
     */
    public func getResult() -> String        { return mStrResult        }
    
    
    public func getRowState() -> Int		{ return mIntRowState    }
    
    /**
     * 체크여부를 설정한다.
     * @param checked
     */
    public func setChecked(checked: Bool)    { self.mBoolChecked        = checked;    }
    
    /**
     * Epc 코드를 설정한다.
     * @param epcCode Epc 코드
     */
    public func setEpcCode(epcCode: String)        { self.mStrEpcCode        = epcCode    }
    
    /**
     * Epc Urn을 설정한다.
     * @param epcUrn Epc Urn
     */
    public func setEpcUrn(epcUrn: String)        { self.mStrEpcUrn        = epcUrn    }
    
    /**
     * 자산 EPC 코드를 설정한다.
     * @param assetEpc 자산 EPC 코드
     */
    public func setAssetEpc(assetEpc: String)    { self.mStrAssetEpc        = assetEpc    }
    
    /**
     * 자산 EPC명을 설정한다.
     * @param assetName 자산 EPC명
     */
    public func setAssetName(assetName: String)    { self.mStrAssetName    = assetName    }
    
    /**
     * 시리얼번호를 설정한다.
     * @param serialNo 시리얼번호
     */
    public func setSerialNo(serialNo: String)    { self.mStrSerialNo        = serialNo    }
    
    /**
     * 상품코드를 설정한다.
     * @param prodCode
     */
    public func setProdCode(prodCode: String)    { self.mStrProdCode        = prodCode    }
    
    /**
     * 상품명을 설정한다.
     * @param prodName
     */
    public func setProdName(prodName: String)    { self.mStrProdName        = prodName    }
    
    /**
     * 인식수량을 설정한다.
     * @param prodReadCnt
     */
    public func setProdReadCnt(prodReadCnt: String)    { self.mStrProdReadCnt        = prodReadCnt    }
    
    /**
     * 상품SEQ 설정한다.
     * @param saleItemSeq
     */
    public func setSaleItemSeq(saleItemSeq: String)    { self.mStrSaleItemSeq        = saleItemSeq    }
    
    
    /**
     * 조회수를 설정한다.
     * @param readCount 조회수
     */
    public func setReadCount(readCount: Int)        { self.mIntReadCount    = readCount    }
    
    /**
     * 조회시간를 설정한다.
     * @param readTime 조회시간
     */
    public func setReadTime(readTime: String)    { self.mStrReadTime        = readTime    }
    
    /**
     * 처리결과를 설정한다.
     * @param result    처리결과
     */
    public func setResult(result: String)        { self.mStrResult        = result    }
    
    
    public func setRowState(rowState: Int)        { self.mIntRowState        = rowState    }

}
