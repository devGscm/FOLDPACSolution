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
[""] *
[""] *	@return	void
[""] */
-(void)bleDidUpdateState:(BOOL)bleSupported;

/**
[""] *	@brief	Invoked whenever the Device has been Discovered.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
[""] */
-(void)didDiscoverDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the Device is ready to communicate.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
[""] */
-(void)readyToCommunicate:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the Device has been disconnected.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
[""] */
-(void)didDisconnectDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the data has been written to the BLE Device.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
[""] */
-(void)didWriteData:(SwingDevice*)dev;

/**
[""] *	@brief	Invoked whenever the data has been received from the BLE Device.
[""] *
[""] *	@param 	data 	Data
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
[""] */
-(void)didReceiveData:(NSData*)data Device:(SwingDevice*)dev;


@optional

/**
[""] *	@brief	Invoked whenever the Device has been Discovered.
[""] *
[""] *	@param 	dev 	DFBlunoDevice
[""] *
[""] *	@return	void
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
[""] *	@return	void
[""] */
- (void)scan;
/**
[""] *	@brief	Stop scanning
[""] *
[""] *	@return	void
[""] */
- (void)stop;
/**
[""] *	@brief	Clear the list of the discovered device
[""] *
[""] *	@return	void
[""] */
- (void)clear;
/**
[""] *	@brief	Connect to device
[""] *
[""] *	@param 	dev 	Swing
[""] *
[""] *	@return	void
[""] */
- (void)connectToDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Disconnect from the device
[""] *
[""] *	@param 	dev 	SwingService
[""] *
[""] *	@return	void
[""] */
- (void)disconnectToDevice:(SwingDevice*)dev;

/**
[""] *	@brief	Write the data to the device
[""] *
[""] *	@param 	data 	Daya
[""] *	@param 	dev 	SwingService
[""] *
[""] *	@return	void
[""] */
- (void)writeDataToDevice:(NSData*)data Device:(SwingDevice*)dev;

/**
[""] *	@brief	Write the data to the device
[""] *
[""] *	@param 	data 	Daya
[""] *	@param 	dev 	SwingService
[""] *
[""] *	@return	void
[""] */
- (NSString *)writeDataToDevice:(NSString*)uuid;



@property (strong,nonatomic) CBCentralManager* centralManager;
@property (strong,nonatomic) CBPeripheralManager *peripheralManger;
@property (strong,nonatomic) NSMutableDictionary* dicBleDevices;
@property (strong,nonatomic) NSMutableDictionary* dicBlunoDevices;



@end
