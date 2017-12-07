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
	static let RFID_READER_TYPE_KEY					= "rfidReaderType"			        /**< RFID 리더기 Type */
	static let RFID_READER_INFO_KEY						= "rfidReaderInfo"			       	/**< RFID 리더기 정보 */
	
	static let RFID_READER_ID_KEY						= "rfidReaderId"			        	/**< RFID 리더기 UUID */
	static let RFID_READER_NAME_KEY					= "rfidReaderName"			    /**< RFID 리더기 명 */
	static let RFID_READER_MACADDR_KEY			= "rfidReaderMacAddr"			 /**< RFID 리더기 MAC ADDRESS */
	
	static let IDENTIFICATION_SYSTEM_LIST_KEY			= "identificationSystemList"		/**< 식별체계*/
	static let BLUETOOTH_SELECTION_KEY					= "bluetoothSelection"		        /**< 블루투스 장치 선택 */
	static let RFID_BEEP_ENABLED_KEY					= "rfidBeepEnabled"				    /**< 비프음 */
	static let RFID_MASK_KEY							= "rfidMask"						/**< RFID 마스크 */
	static let BASE_BRANCH_KEY							= "baseBranch"					    /**< 거점 선택 */
	static let RFID_POWER_KEY							= "rfidPower"						/**< RFID 파워 */

    
	
	static let WEB_SVC_URL 								= "http://upis.moramcnt.com"	    /**< 서비스 URL */
	//static let WEB_SVC_URL 							= "http://192.168.0.213:8080"	    /**< 서비스 URL  훈태*/
	
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
	//=====================================================================================
    
    
    static let IDENTIFICATION_SYSTEM_GTIN14 						= "1"	/**< 식별체계 : GTIN-14     	*/
    static let IDENTIFICATION_SYSTEM_AGQR							= "2"	/**< 식별체계 : 농산물 QR코드     */
	
    static let DATA_ROW_STATE_UNCHANGED               				= 0     /**< 데이터상태 : 변경 없음 **/
    static let DATA_ROW_STATE_ADDED                    				= 1     /**< 데이터상태 : 삽입 **/
    static let DATA_ROW_STATE_MODIFIED                    			= 2     /**< 데이터상태 : 수정 **/
    static let DATA_ROW_STATE_DELETED                    			= 3     /**< 데이터상태 : 삭제 **/

    
	static let RELOAD_STATE_DEFAULT									= 0		/**< 리로드상태: 기본 **/
	static let RELOAD_STATE_TEMPORARY								= 1		/**< 리로드상태: 임시저장 **/
	static let RELOAD_STATE_COMPLETE								= 2		/**< 리로드상태: 완료저장 **/

    static let REMOVE_STATE_NORMAL                        			= 1		/**< 삭제상태: 기본 **/
    static let REMOVE_STATE_COMPLETE                    			= 2		/**< 삭제상태: 임시저장 **/

	
}
