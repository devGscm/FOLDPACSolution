//
//  Constants.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 15..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import Foundation

class Constants
{
	static let DATE_SEARCH_DISTANCE = 7
	
	
	static let RFID_READER_TYPE_SWING_U					= 1	/**< RFID 리더기 : Swing U */
	static let RFID_READER_TYPE_AT288					= 2	/**< RFID 리더기 : AT288 */
	static let RFID_READER_TYPE_AJANTECH				= 3	/**< RFID 리더기 : AJANTECH */
	static let RFID_READER_TYPE_ARETE					= 4	/**< RFID 리더기 : ARETE */
	
	static let LANDSCAPE_SCREEN_ENABLED_KEY				= "landscapeScreenEnabled"		    /**< 화면 가로/세로 보기 키*/
	static let RFID_READER_TYPE_KEY					    = "rfidReaderType"			        /**< RFID 리더기 Type */
	static let RFID_READER_INFO_KEY						= "rfidReaderInfo"			       	/**< RFID 리더기 정보 */
	
	static let RFID_READER_ID_KEY						= "rfidReaderId"			        	/**< RFID 리더기 UUID */
	static let RFID_READER_NAME_KEY					    = "rfidReaderName"			    /**< RFID 리더기 명 */
	static let RFID_READER_MACADDR_KEY			        = "rfidReaderMacAddr"			 /**< RFID 리더기 MAC ADDRESS */
	
	static let IDENTIFICATION_SYSTEM_LIST_KEY			= "identificationSystemList"		/**< 식별체계*/
	static let BLUETOOTH_SELECTION_KEY					= "bluetoothSelection"		        /**< 블루투스 장치 선택 */
	static let RFID_BEEP_ENABLED_KEY					= "rfidBeepEnabled"				    /**< 비프음 */
	static let RFID_MASK_KEY							= "rfidMask"						/**< RFID 마스크 */
	static let BASE_BRANCH_KEY							= "baseBranch"					    /**< 거점 선택 */
	static let RFID_POWER_KEY							= "rfidPower"						/**< RFID 파워 */
    
	
	#if REDMOON
	static let WEB_SVC_URL 							    = "http://192.168.0.213:8080"	    /**< 서비스 URL-훈태 */
	#elseif ROY
	static let WEB_SVC_URL                              = "http://192.168.0.218:8080"       /**< 서비스 URL-현님 */
	#elseif YOMILE
	static let WEB_SVC_URL                              = "http://192.168.0.240:8080"       /**< 서비스 URL-용민 */
	#else
	static let WEB_SVC_URL 	    					    = "http://upis.moramcnt.com"	    /**< 서비스 URL     */
	#endif
	
	static let ROWS_PER_PAGE							= 20	/**< 기본 페이지 크기 */
	
	static let PROC_RESULT_SUCCESS									= "00"		/**< 처리결과 : 성공	**/
	static let PROC_RESULT_ERROR_NOT_EXIST_TAG						= "MK0110"	/**< 처리결과 : 존재하지 않는 EPC코드	**/
	
	static let PROC_RESULT_ERROR_ALREADY_MOUNTED					= "ZZ9995"	/**< 처리결과 : 이미 장착된 태그가 존재하여 처리할수 없습니다.**/
	static let PROC_RESULT_ERROR_NO_MATCH_BRANCH_CUST_INFO			= "ZZ9996"	/**< 처리결과 : 서버의 거점 및 고객사 정보와 일치 하지 않습니다.**/
	static let PROC_RESULT_ERROR_NO_REGISTERED_READERS				= "ZZ9997"	/**< 처리결과 : 등록된 리더기가 없습니다. 리더기 관리에서 단말기를 등록하여 주십시오.	**/
	static let PROC_RESULT_ERROR_TAG_ALREADY_PROCESSED				= "ZZ9998"	/**< 처리결과 : 이미 처리된 태그입니다.	**/
	static let PROC_RESULT_ERROR_UNABLE_TO_PROCESS_DUE_EXCEPTION	= "ZZ9999"	/**< 처리결과 : 예외로 인하여 처리할 수 없음.**/
	static let PROC_RESULT_ERROR_NEED_WORK_COMPLETE_FORCE			= "RS3000"	/**< 처리결과 : TAGID가 해당거점에 이미 입고처리가 되어져 있습니다. 그래도 입고처리하겠습니까?**/
	
	
	static let PROC_RESULT_ERROR_INSPECT_TAG_ISSUE					= "10"	/**< 처리결과 : 발급중인 태그라서 검수할수 없습니다.*/
	static let PROC_RESULT_ERROR_INSPECT_TAG_ENCODING_FAIL			= "20"	/**< 처리결과 : 인코딩이 실패난 태그라서  검수할수 없습니다.*/
	static let PROC_RESULT_ERROR_INSPECT_TAG_INSERT_SUCCESS			= "40"	/**< 처리결과 : 이미 파렛트에 삽입된 태그라서 검수할수 없습니다.*/
	static let PROC_RESULT_ERROR_INSPECT_TAG_INSERT_FAIL			= "41"	/**< 처리결과 : 파렛트에 삽입이 실패된 태그라서 검수할수 없습니다.*/
	static let PROC_RESULT_ERROR_INSPECT_TAG_DISCARD				= "80"	/**< 처리결과 : 폐기된 태그라서 검수할수 없습니다.*/
	static let PROC_RESULT_ERROR_INSPECT_TAG_ERROR_EXISTS			= "96"	/**< 처리결과 : 오류가 있는 태그가 존재합니다.**/
	static let PROC_RESULT_ERROR_INSPECT_UNKNOWN_EXCEPTION			= "97"	/**< 처리결과 : 알수없는 에러로 검수할수 없습니다.**/
	static let PROC_RESULT_ERROR_INSPECT_NOT_REGISTERED_DATA		= "99"	/**< 처리결과 : 서버에 등록되지 않은 EPC코드 입니다. */
	
	static let RFID_EPC_MODE_GRAI_96					= "33";	/**< EPC MODE - GRAI **/
	static let RFID_EPC_MODE_SGTIN_96				= "30";	/**< EPC MODE - SGTIN **/

	
    //=====================================================================================
    // 출고 구분
    //-------------------------------------------------------------------------------------
    static let SALE_TYPE_DELIVERY                             = "01";        /**< 출고  : 납품(지시서 O) */
    static let SALE_TYPE_MOVE                                 = "02";        /**< 출고  : 이동(지시서 O) */
    static let SALE_TYPE_RESALE                               = "05";        /**< 출고  : 출고(지시서 X) */
    static let SALE_TYPE_BARCODE                              = "10";        /**< 출고  : 출하(지시서 X/상품매핑O) */
    
    
	//=====================================================================================
	// 입고 구분
	//-------------------------------------------------------------------------------------
	static let RESALE_TYPE_DELIVERY					= "01"		/**< 입고 : 납품/판매(지시서 O) */
	static let RESALE_TYPE_MOVE						= "02"		/**< 입고  : 이동/이동(지시서 O) */
	static let RESALE_TYPE_RETURN					= "03"		/**< 입고  : 반납/구매(지시서 O) */
	static let RESALE_TYPE_GATHER					= "04"		/**< 입고  : 회수(지시서 X) */
	static let RESALE_TYPE_WAREHOUSING				= "05"		/**< 입고  : 입고(지시서 X) */
	//=====================================================================================
	
	
	//=====================================================================================
	// 작업 구분
	//-------------------------------------------------------------------------------------
	static let TRANSFER_TYPE_RETURN					= "01"		/**< 출하구분 : 반납 */
	static let TRANSFER_TYPE_SHIPMENT				= "02"		/**< 출하구분 : 출하 */
	//=====================================================================================
	
	
	
	//=====================================================================================
	// 작업 구분
	//-------------------------------------------------------------------------------------
	static let WORK_TYPE_SALE_IN					= "01"		/**< 작업구분 : 주문입고 */
	static let WORK_TYPE_SALE_OUT					= "02"		/**< 작업구분 : 주문출고 */
	static let WORK_TYPE_MOVE_IN					= "03"		/**< 작업구분 : 이동입고 */
	static let WORK_TYPE_MOVE_OUT					= "04"		/**< 작업구분 : 이동출고 */
	static let WORK_TYPE_RESALE_IN					= "05"		/**< 작업구분 : 구매입고 */
	static let WORK_TYPE_RESALE_OUT					= "06"		/**< 작업구분 : 구매출고(반납 : 미정인 항목) */
	
	//=====================================================================================
	
	//=====================================================================================
	// 출고-작업 처리 상태
	//-------------------------------------------------------------------------------------
	static let WORK_STATE_WORKING					= "01"		/**< 작업중	*/
	static let WORK_STATE_COMPLETE					= "02"		/**< 완료		*/
	static let WORK_STATE_COMPLETE_FORCE			= "03"		/**< (강제)완료 **/
	static let WORK_STATE_ONGOING					= "04"		/**< 처리진행	*/
	//=====================================================================================
	
	//=====================================================================================
	// 입고-작업 처리 상태
	//-------------------------------------------------------------------------------------
	static let RESALE_ORDER_STATE_START				= "01"		/**< 신규 **/
	static let RESALE_ORDER_STATE_WORK				= "02"		/**< 처리 **/
	static let RESALE_ORDER_STATE_CONFIRM			= "03"		/**< 승인 **/
	static let RESALE_ORDER_STATE_CANCEL			= "04"		/**< 취소 **/
	//=====================================================================================
	
	
	//=====================================================================================
	// 재고조사 상태
	//-------------------------------------------------------------------------------------
	static let STOCK_REVIEW_STATE_NEW				= "01"	/**< 신규 */
	static let STOCK_REVIEW_STATE_WORKING			= "02"	/**< 실사진행 */
	static let STOCK_REVIEW_STATE_COMPLETE			= "03"	/**< 실사완료 */
	static let STOCK_REVIEW_STATE_ADJUSTMENT		= "04"	/**< 재고조정 */
	static let STOCK_REVIEW_STATE_CANCEL			= "99"	/**< 취소 */
	
	//=====================================================================================
	
	//=====================================================================================
	// 이벤트 코드
	//-------------------------------------------------------------------------------------
	static let EVENT_CODE_IN						= "10"	/**< 이벤트 코드 : 입고 **/
	static let EVENT_CODE_MOUNT						= "40"	/**< 이벤트 코드 : 파렛트 장착 **/
	static let EVENT_CODE_CLEAN						= "60"	/**< 이벤트 코드 : 세척 **/
	static let EVENT_CODE_SELECT_STORE				= "80"	/**< 이밴트 코드 : 선별/보관 **/
	static let EVENT_CODE_OUT						= "90"	/**< 이벤트 코드 : 출고 **/
	static let EVENT_CODE_DESTORY					= "91"	/**< 이벤트 코드 : 파손폐기 **/
	static let EVENT_CODE_NOREAD					= "92"	/**< 이벤트 코드 : 미인식폐기 **/
	static let EVENT_CODE_DISPOSAL					= "93"	/**< 이벤트 코드 : 매각 **/
	//=====================================================================================
	
	//=====================================================================================
	// 사용자 언어
	//-------------------------------------------------------------------------------------
	static let USER_LANG_KR											= "KR"		/**< 한국어	*/
	static let USER_LANG_EN											= "EN"		/**< 영어		*/
	static let USER_LANG_CH											= "CH"		/**< 중국어	*/
    static let USER_LANG_JP                                         = "JP"      /**< 일본어    */
    
	//=====================================================================================
	
    //=====================================================================================
    // 고객사 구분
    //-------------------------------------------------------------------------------------
    static let  CUST_TYPE_ADM                                       = "ADM"    /**< 어드민회사       */
    static let  CUST_TYPE_EXP                                       = "EXP"    /**< 수출회사        */
    static let  CUST_TYPE_IMP                                       = "IMP"    /**< 수입회사        */
    static let  CUST_TYPE_ISS                                       = "ISS"    /**< 태그공급회사     */
    static let  CUST_TYPE_MGR                                       = "MGR"    /**< 관리회사        */
    static let  CUST_TYPE_PMK                                       = "PMK"    /**< 파렛트제작회사    */
    static let  CUST_TYPE_RDC                                       = "RDC"    /**< 물류회사        */
    static let  CUST_TYPE_SAL                                       = "SAL"    /**< 판매대행사       */
    static let  CUST_TYPE_TMK                                       = "TMK"    /**< 태그생산회사     */
    static let  CUST_TYPE_VIR                                       = "VIR"    /**< 가상고객사       */
    static let  CUST_TYPE_ETC                                       = "ETC"    /**< 기타회사        */
    //=====================================================================================
	
	static let RETURN_CODE_AUTHENTICATE_FAIL						= -1		/**< 응답코드:인증실패 **/
	static let RETURN_CODE_FAIL										= 0			/**< 응답코드:실패 **/
	static let RETURN_CODE_SUCCESS									= 1			/**< 응답코드:성공**/
	static let RETURN_CODE_LOADING									= 2			/**< 응답코드:로딩중 **/
	
	
	static let RETURN_CODE_NOT_ATTACH_UNIT							= 94		/**< 응답코드: 사용가능한 리더기정보 등록여부를 확인하여 주십시오. **/
	static let RETURN_CODE_ENTER_USER_ID							= 95		/**< 응답코드: 아이디를 입력하여 주십시오. **/
	static let RETURN_CODE_ENTER_PASSWORD							= 96		/**< 응답코드: 패스워드를 입력하여 주십시오. **/
	static let RETURN_CODE_VERIFY_LOGIN_INFO						= 97		/**< 응답코드: 로그인 정보를 다시 확인하여 주십시오. **/
	static let RETURN_CODE_DISABLED_USER							= 98		/**< 응답코드: 사용 중지된 사용자입니다. **/
	static let RETURN_CODE_NOT_RRPP_USER							= 99		/**< 응답코드: RRPP 사용자가 아님 **/
	static let RETURN_CODE_PK_VIOLATION								= 23000		/**< 응답코드:중복키 에러 **/
	
	
    
    //공통코드 구분자
    static let CODE_DETAIL_TYPE_SALE                                = "SALE"           /**< SALE_TYPE  */
    static let CODE_DETAIL_TYPE_RESALE                              = "RESALE"         /**< RESALE_TYPE  */

    
	//센서 태그 헤더 정보
	static let SWING_ABNORMAL_TAG_HEADER_INFO						= "301E"		/**< 이상 센서태그 헤더정보, #4번태그*/
	static let SWING_TAG_HEADER_INFO								= "3000"		/**< 센서태그 헤더정보 */
	static let SWING_BARCODE_HEADER_INFO							= "http:"		/**< 바코드 헤더정보*/
	static let SWING_BARCODE_QR_INFO								= "qc="			/**< 바코드 QR정보*/
	
	static let READING_LANGTH_BARCODE 								= 14			/**< 바코드타입:GTIN-14 */
	static let READING_LANGTH_QRCODE 								= 18			/**< 바코드타입:QR코드 	*/
	static let READING_LANGTH_RFIDTAG 								= 28			/**< 바코드타입:RFID태그 	*/
	
	static let INTENT_EXTRA_READING_TYPE 							= "ReadingType"	/**< 바코드타입:GTIN-14 */
	static let READING_TYPE_BARCODE 								= "BARCODE"		/**< 바코드타입:GTIN-14 */
	static let READING_TYPE_QRCODE 									= "QRCODE"			/**< 바코드타입:QR코드 	*/
	static let READING_TYPE_RFIDTAG 								= "RFIDTAG"		/**< 바코드타입:RFID태그 	*/
	
	//static let SWING_READER_MODE_RFID 								= 0				/**< 스윙리더기 : RFID 읽기모드 	*/
	//static let SWING_READER_MODE_TEMPERATURE						= 1				/**< 스윙리더기 : TEMPERATURE 읽기모드 	*/
	//static let SWING_READER_MODE_BCD 								= 2				/**< 스윙리더기 : BCD 읽기모드 	*/
	//static let SWING_READER_MODE_ENC 								= 3				/**< 스윙리더기 : ENC 읽기모드 	*/
	
	static let SWING_TAG_REPORT_MODE_NEW 							= 0				/**< 스윙리더기 : 태그리포트 [N] 	*/
	static let SWING_TAG_REPORT_MODE_ALL							= 1				/**< 스윙리더기 : 태그리포트 [A]	*/
	
    
    static let IDENTIFICATION_SYSTEM_GTIN14 						= 1		/**< 식별체계 : GTIN-14     	*/
    static let IDENTIFICATION_SYSTEM_AGQR							= 2		/**< 식별체계 : 농산물 QR코드     */
	
    static let DATA_ROW_STATE_UNCHANGED               				= 0     /**< 데이터상태 : 변경 없음 **/
    static let DATA_ROW_STATE_ADDED                    				= 1     /**< 데이터상태 : 삽입 **/
    static let DATA_ROW_STATE_MODIFIED                    			= 2     /**< 데이터상태 : 수정 **/
    static let DATA_ROW_STATE_DELETED                    			= 3     /**< 데이터상태 : 삭제 **/

    
	static let RELOAD_STATE_DEFAULT									= 0		/**< 리로드상태: 기본 **/
	static let RELOAD_STATE_TEMPORARY								= 1		/**< 리로드상태: 임시저장 **/
	static let RELOAD_STATE_COMPLETE								= 2		/**< 리로드상태: 완료저장 **/

    static let REMOVE_STATE_NORMAL                        			= 1		/**< 삭제상태: 기본 **/
    static let REMOVE_STATE_COMPLETE                    			= 2		/**< 삭제상태: 임시저장 **/

	static let AUTO_COMPLETED_AGGREMENT_YES							= "Y"	/**< 자동완료처리 : Y  **/
	static let AUTO_COMPLETED_AGGREMENT_NO							= "N"	/**< 자동완료처리 : N  **/
	
    static let INOUT_TYPE_INPUT                                     = "I"   /**< 구분:입고 선택    */
    static let INOUT_TYPE_OUTPUT                                    = "O"   /**< 구분:출고 선택    */
	
}
