//
//  SwingProtocol.h
//  iManager
//
//  Created by jinugi011 on 2015. 7. 3..
//  Copyright (c) 2015년 nethom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwingApi.h"


typedef enum InventoryModeTypes
{
	INVENTORY_NORMAL, INVENTORY_WITHUSER, SEARCH_SINGLE, SEARCH_MULTI, SEARCH_WILDCARD
} InventoryMode;


#define STATE_NONE = 0;       // we're doing nothing
#define STATE_LISTEN = 1;     // now listening for incoming connections
#define STATE_CONNECTING = 2; // now initiating an outgoing connection
#define STATE_CONNECTED = 3;  // now connected to a remote device


#define CONTINUOUS_MODE = 0x63;
#define byte ALL_DEFAULT = 0x64;
#define POWER_ATTEN = 0x63;
#define ACCESS_PW = 0x63;


#define CONNECT_DEVICE_NAME1 @"c_key_device_name1"
#define CONNECT_DEVICE_UUID1 @"c_key_device_uuid1"

#define CONNECT_DEVICE_NAME2 @"c_key_device_name2"
#define CONNECT_DEVICE_UUID2 @"c_key_device_uuid2"

#define CONNECT_DEVICE_NAME3 @"c_key_device_name3"
#define CONNECT_DEVICE_UUID3 @"c_key_device_uuid3"



/**
[""] *	@brief	BLE Swing Reciver
[""] *
[""] *
[""] */

@protocol SwingProtocol <NSObject>
@required


-(BOOL)ReaderStatus;
-(void)ReciveData:(NSString *)result;


@optional

-(void)Swing_didDiscoverDevice:(SwingDevice*)dev;
-(void)Swing_didconnectedDevice:(SwingDevice*)dev;
-(void)Swing_readyToCommunicate:(SwingDevice*)dev;
-(void)Swing_didDisconnectDevice:(SwingDevice*)dev;

//Swing ResPonseData

-(void)Swing_Response_InventoryCmd_Stop:(NSString *)value;
-(void)Swing_Response_InventoryCmd_Start:(NSString *)value;
-(void)Swing_Response_InventoryCmd:(NSString *)value;
-(void)Swing_Response_TagList:(NSString *)value;
-(void)Swing_Response_ERROR:(NSString *)value;
-(void)Swing_Response_TagReport:(NSString *)value;
-(void)Swing_Response_continuous:(NSString *)value;
-(void)Swing_Response_buzzer:(NSString *)value;
-(void)Swing_Response_mode_trigger_alltag:(NSString *)value;
-(void)Swing_Response_power:(NSString *)value;
-(void)Swing_Response_session:(NSString *)value;
-(void)Swing_Response_threadhold:(NSString *)value;
-(void)Swing_Response_Unit:(NSString *)value;
-(void)Swing_Response_battery:(NSString *)value;
-(void)Swing_Response_InventoryMode:(NSString *)value;
-(void)Swing_Response_TagCount:(NSString *)value;
-(void)Swing_Response_MessageClear:(NSString *)value;
-(void)Swing_Response_MessageFIND:(NSString *)value;
-(void)Swing_Response_MenuEnable:(NSString *)value;
-(void)swing_clear_find;
-(void)Swing_Response_MaxEpcLength:(NSString *)value;
-(void)Swing_Response_FilterSize:(NSString *)value;
-(void)Swing_Response_Language:(NSString *)value;
-(void)Swing_Response_model:(NSString *)value;
@end


@interface SwingProtocol : NSObject<SwingDelegate>
{
	InventoryMode inventorymode;

}
@property(strong, nonatomic) SwingApi* swingapi;
@property(strong, nonatomic) SwingDevice* swingDev;
@property(strong, nonatomic) NSMutableArray* aryDevices; //device list
@property(nonatomic,weak) id<SwingProtocol> delegate;


@property(retain, nonatomic) NSArray* ErrorCode;
@property(retain, nonatomic) NSArray* ErrorDiscription;
@property(nonatomic) NSMutableData* byteData;



+(id)sharedInstace;
-(void)swing_scan;
-(BOOL)isSwingrederConnected;
//-(void)sync_update:(NSData* )buffer;

/**
 * Inventory Protocolss
 */
-(void)swing_readStart;
-(void)swing_readStop;
-(void)swing_getSyncTagList;
-(void)swing_clear_search_taget_list;
/**
 * Memory Access
 */
-(void)swing_readMemory:(int)bank:(int)offset:(int)wordLenght;
-(void)swing_writeMemory:(int)bank:(int)offset:(int)count:(NSString *)data;
-(void)swing_selectMemory:(int)bank:(int)offset:(int)count:(NSString *)data;
-(void)swing_lockMemory:(int)access:(int)kill:(int)epc:(int)tid:(int)user:(NSString *)access;



-(void)sendProtocol:(NSString *)value;
-(void)swing_setAllTagReport:(Boolean)on_all_tag_report;
-(void)swing_setContinuous:(Boolean)on_continuous;
-(void)swing_set_search_target:(NSString*)target_id;
-(void)swing_set_add_search_target:(NSInteger)idx:(NSString *)id_target;
-(void)swing_set_search_target_multi;


-(void)swing_set_inventory_mode:(NSInteger)mode;
-(void)swing_set_inventory_mode_find:(NSInteger)mode;
-(void)swing_clear_inventory;
-(void)swing_saveParam;
-(void)swing_setReadMode:(NSInteger)mode;

/**
 * Scanner Mode setting
 */
-(void)swing_setPower:(int)attenuation;
-(void)swing_setSession:(int)session;
-(void)swing_setEPCUserMode:(Boolean *)on_ecp_user;
-(BOOL)swing_setAccessPass:(NSString *)password;
-(void)swing_setMenuEnable:(BOOL)enable;
-(void)swing_setThreshold:(NSInteger)th;
-(void)swing_setBuzzer:(NSInteger)volume;
-(void)swing_setMaxepclength:(NSInteger)maxepclength;
-(void)swing_setFiltersize:(NSInteger)filtersize;
-(void)swing_setLanguage:(NSInteger)language;
-(void)swing_setModel:(NSString*)model;
-(void)swing_setUnit:(NSInteger)unit;
-(void)swing_clearAccessPass;
-(void)swing_setMenuEnable:(BOOL)enabled;
-(void)swing_saveParam;


/**
 * Scanner gettter
 */
-(void)swing_getpower;
-(void)swing_getsession;
-(void)swing_getBuzzerVolume;
-(void)swing_getEPCUserMode;
-(void)swing_getUserMemLength;
-(void)swing_getMenuEnable;
-(void)swing_getAllInformation;
-(void)swing_getAccessPass;
-(void)swing_getLanguage;
-(void)swing_testsend:(NSString*)value;




//UTIL
-(void)swing_error_find:(NSString *)code;

-(NSString *)getErrorCodeDiscription:(NSString *)Code;


@end
