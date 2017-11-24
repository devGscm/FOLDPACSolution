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
	
	static let LANDSCAPE_SCREEN_ENABLED_KEY				= "landscapeScreenEnabled"		/**< 화면 가로/세로 보기 키*/
	static let RFID_READER_KEY							= "rfidReader"				/**< RFID 리더기 */
	static let IDENTIFICATION_SYSTEM_LIST_KEY			= "identificationSystemList"		/**< 식별체계*/
	static let BLUETOOTH_SELECTION_KEY					= "bluetoothSelection"		/**< 블루투스 장치 선택 */
	static let RFID_BEEP_ENABLED_KEY					= "rfidBeepEnabled"				/**< 비프음 */
	static let RFID_MASK_KEY							= "rfidMask"						/**< RFID 마스크 */
	static let BASE_BRANCH_KEY							= "baseBranch"					/**< 거점 선택 */
	static let RFID_POWER_KEY							= "rfidPower"						/**< RFID 파워 */
	
	//static let WEB_SVC_URL 								= "http://upis.moramcnt.com"	/**< 서비스 URL */
	static let WEB_SVC_URL 								= "http://192.168.0.213:8080"	/**< 서비스 URL  훈태*/
}
