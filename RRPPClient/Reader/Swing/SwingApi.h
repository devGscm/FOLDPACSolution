//
//  DFBlunoManager.h
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "SwingDevice.h"

@protocol SwingDelegate <NSObject>
@required

/**
[""] *	@brief	Invoked whenever the central manager's state has been updated.
[""] *
[""] *	@param 	bleSupported 	Boolean
[""] */
-(void)bleDidUpdateState:(BOOL)bleSupported;

/**
[""] *	@brief	Invoked whenever the Device has been Discovered.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] */
-(void)didDiscoverDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the Device is ready to communicate.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] */
-(void)readyToCommunicate:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the Device has been disconnected.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] */
-(void)didDisconnectDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the data has been written to the BLE Device.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] */
-(void)didWriteData:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the data has been received from the BLE Device.
[""] *
[""] *	@param 	data 	Data
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] */
-(void)didReceiveData:(NSData*)data Device:(SwingDevice*)dev;


@optional

/**
[""] *	@brief	Invoked whenever the Device has been Discovered.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] */
-(void)didconnectedDevice:(SwingDevice*)dev;




@end

@interface SwingApi : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,weak) id<SwingDelegate> delegate;

/**
[""] *	@brief	Singleton
[""] *
[""] *	@return	Swing Device
[""] */
+ (id)sharedInstance;

/**
[""] *	@brief	Scan the Swing device
[""] *
[""] */
- (void)scan;
/**
[""] *	@brief	Stop scanning
[""] *
[""] */
- (void)stop;
/**
[""] *	@brief	Clear the list of the discovered device
[""] *
[""] */
- (void)clear;
/**
[""] *	@brief	Connect to device
[""] *
[""] *	@param 	dev 	Swing
[""] *
[""] */
- (void)connectToDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Disconnect from the device
[""] *
[""] *	@param 	dev 	SwingService
[""] *
[""] */
- (void)disconnectToDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Write the data to the device
[""] *
[""] *	@param 	data 	Daya
[""] *	@param 	dev 	SwingService
[""] *
[""] */
- (void)writeDataToDevice:(NSData*)data Device:(SwingDevice*)dev;

/**
[""] *	@brief	Write the data to the device
[""] *
[""] */
- (NSString *)writeDataToDevice:(NSString*)uuid;



@property (strong,nonatomic) CBCentralManager* centralManager;
@property (strong,nonatomic) CBPeripheralManager *peripheralManger;
@property (strong,nonatomic) NSMutableDictionary* dicBleDevices;
@property (strong,nonatomic) NSMutableDictionary* dicBlunoDevices;



@end
