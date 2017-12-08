#import "SwingApi.h"

#define kSwingServiceID @"FFF0" //ff10
#define kSwing_read_Service @"FFF1"
#define kSwing_write_service @"FFF2"

#define kSwing_current_device @"c_device"

typedef enum
{
    SCAN_S_NOT_LOADED,
    SCAN_S_DISAPPEARED,
    SCAN_S_WILL_DISAPPEAR,
    SCAN_S_APPEARED_IDLE,
    SCAN_S_APPEARED_SCANNING

} SCAN_State;

@interface SwingApi ()
{
    BOOL _bSupported;
}


@end

@implementation SwingApi

#pragma mark- Functions

+ (id)sharedInstance
{
	static SwingApi* this	= nil;
    
	if (!this)
    {
		this = [[SwingApi alloc] init];
        this.dicBleDevices = [[NSMutableDictionary alloc] init];
        this.dicBlunoDevices = [[NSMutableDictionary alloc] init];
        this->_bSupported = NO;
        this.centralManager = [[CBCentralManager alloc]initWithDelegate:this queue:nil];
    }
    
	return this;
}

- (void)configureSensorTag:(CBPeripheral*)peripheral
{
    NSLog(@"##[SwingApi] -> configureSensorTag :: readyToCommunicate 호출");
    CBUUID *sUUID = [CBUUID UUIDWithString:kSwingServiceID];
    CBUUID *cUUID = [CBUUID UUIDWithString:kSwing_read_Service];
    
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
    NSString* key = [peripheral.identifier UUIDString];
    SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
    blunoDev->_bReadyToWrite = YES;
    
    if ([((NSObject*)_delegate) respondsToSelector:@selector(readyToCommunicate:)])
    {
        [_delegate readyToCommunicate:blunoDev];
    }
}

- (void)deConfigureSensorTag:(CBPeripheral*)peripheral
{
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kSwingServiceID];
    CBUUID *cUUID = [CBUUID UUIDWithString:kSwing_read_Service];
    
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    
}

- (void)scan
{
    [self.centralManager stopScan];
    [self clear];
    //[self.centralManager init];
    //[self.dicBleDevices removeAllObjects];
    //[self.dicBlunoDevices removeAllObjects];
    if (_bSupported)
    {
        //[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kSwingServiceID]] options:nil];
        //[self.peripheralManger];
        //NSArray *services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:kSwingServiceID], [CBUUID UUIDWithString:kSwingDataCharactieristicIDCH1], [CBUUID UUIDWithString:kSwingDataCharactieristicIDCH2],[CBUUID UUIDWithString:kSwingDataCharactieristicIDCH3],nil];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    

}

- (void)stop
{
    [self.centralManager stopScan];
}

- (void)clear
{
    [self.dicBleDevices removeAllObjects];
    [self.dicBlunoDevices removeAllObjects];
    
     //NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
}

- (void)connectToDevice:(SwingDevice*)dev
{
    BLEDevice* bleDev = [self.dicBleDevices objectForKey:dev.identifier];
    [bleDev.centralManager connectPeripheral:bleDev.peripheral options:nil];
}

- (void)disconnectToDevice:(SwingDevice*)dev
{
    BLEDevice* bleDev = [self.dicBleDevices objectForKey:dev.identifier];
    [self deConfigureSensorTag:bleDev.peripheral];
    [bleDev.centralManager cancelPeripheralConnection:bleDev.peripheral];
}


- (void)writeDataToDevice:(NSData*)data Device:(SwingDevice*)dev
{
    if (!_bSupported || data == nil)
    {
        NSLog(@"!BLE Not Support");
        return;
    }
    else if(!dev.bReadyToWrite)
    {
        NSLog(@"!NO Paring Mode");
        return;
    }
    
    BLEDevice* bleDev = [self.dicBleDevices objectForKey:dev.identifier];
    [BLEUtility writeCharacteristic:bleDev.peripheral sUUID:kSwingServiceID cUUID:kSwing_write_service data:data];
    
    
}




#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        _bSupported = NO;
        NSArray* aryDeviceKeys = [self.dicBlunoDevices allKeys];
        for (NSString* strKey in aryDeviceKeys)
        {
            SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:strKey];
            blunoDev->_bReadyToWrite = NO;
        }
        
    }
    else
    {
        _bSupported = YES;
        NSArray* aryDeviceKeys = [self.dicBlunoDevices allKeys];
        for (NSString* strKey in aryDeviceKeys)
        {
            SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:strKey];
            blunoDev->_bReadyToWrite = YES;
            NSLog(@"name = %@",blunoDev.name );
        }
    }
    
    if ([((NSObject*)_delegate) respondsToSelector:@selector(bleDidUpdateState:)])
    {
        [_delegate bleDidUpdateState:_bSupported];
    }
    
}

/**
[""] *	@brief	Discover Swing Device Override function is Ioss
[""] *
[""] *	@param 	dev 	peripheral
[""] *	@param 	dev 	advertisementData
[""] *	@param 	dev 	RSSI
[""] *
[""] */

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString* key = [peripheral.identifier UUIDString];
    BLEDevice* dev = [self.dicBleDevices objectForKey:key];
    
    if (dev !=nil )
    {
        if ([dev.peripheral isEqual:peripheral])
        {
            dev.peripheral = peripheral;
            if ([((NSObject*)_delegate) respondsToSelector:@selector(didDiscoverDevice:)])
            {
                SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
                [_delegate didDiscoverDevice:blunoDev];
            }
        }
    }
    else
    {
        BLEDevice* bleDev = [[BLEDevice alloc] init];
        bleDev.peripheral = peripheral;
        bleDev.centralManager = self.centralManager;
        [self.dicBleDevices setObject:bleDev forKey:key];
        SwingDevice* blunoDev = [[SwingDevice alloc] init];
        blunoDev.identifier = key;
        blunoDev.name = peripheral.name;
        blunoDev.macaddress = [self writeDataToDevice:key];
        [self.dicBlunoDevices setObject:blunoDev forKey:key];

        if ([((NSObject*)_delegate) respondsToSelector:@selector(didDiscoverDevice:)])
        {
            [_delegate didDiscoverDevice:blunoDev];
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    if(peripheral.state == CBPeripheralStateConnected)
    {
 	    NSString* key = [peripheral.identifier UUIDString];
        SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
   		blunoDev->_bReadyToWrite = YES;

       //[[NSUserDefaults standardUserDefaults]setObject:blunoDev forKey:kSwing_current_device];
        
        NSLog(@"[1]connect device %@", [blunoDev macaddress]);
        
        if ([((NSObject*)_delegate) respondsToSelector:@selector(didconnectedDevice:)])
        {
            [_delegate didconnectedDevice:blunoDev];
        }

    }
    
}




-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"didFailToConnectPeripheral!!");
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    NSString* key = [peripheral.identifier UUIDString];
    SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
    blunoDev->_bReadyToWrite = NO;
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didDisconnectDevice:)])
    {
        [_delegate didDisconnectDevice:blunoDev];
    }
}

#pragma  mark - CBPeripheral delegate (Override Functions)

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *s in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:s];
        
    }
    
    //for (CBService *aService in peripheral.services){
     //   if ([aService.UUID isEqual:[CBUUID UUIDWithString:kSwingServiceID]]) {
        //    [peripheral discoverCharacteristics:nil forService:aService];
     //   }
    //}
}

/**
[""] *	@brief	읽기 쓰기 가능한 서비스 검색
[""] *
[""] */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kSwingServiceID]])
    {
        [self configureSensorTag:peripheral];

//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//        }
    }

}


/**
[""] *	@brief	페어링 안된 상태에서 비콘 메세지 케치를 위한 오버라이드 함수
[""] *
[""] *	@param 	dev 	peripheral 디바이스 정보
[""] *	@param 	dev 	advertisementData 비콘 i,a 메시지
[""] *	@param 	dev 	RSSI 신호 세기
[""] *
[""] */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"did update Notificaiton Status Characteristic");

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kSwingServiceID]])
       {
           NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
           //NSLog(@"Value %@",value);

           NSData *data = characteristic.value;
           NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          // NSLog(@"Data ====== %@", stringFromData);
       }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"##[SwingApi] -> peripheral :: didReceiveData 호출");
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didReceiveData:Device:)])
    {
        NSString* key = [peripheral.identifier UUIDString];
        SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
        [_delegate didReceiveData:characteristic.value Device:blunoDev];
        
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didWriteData:)])
    {
        NSString* key = [peripheral.identifier UUIDString];
        SwingDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
        [_delegate didWriteData:blunoDev];
    }
}

//modify profile 
-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{

}


- (NSString *)writeDataToDevice:(NSString*)uuid
{
	NSMutableString *macAddress  = [[NSMutableString alloc]init];

    
    NSArray *result = [uuid componentsSeparatedByString:@"-"];
    
    
    if(result.count >= 4)
    {
        NSLog(@"Address = %@",[result objectAtIndex:4]);
        macAddress = [result objectAtIndex:4];// [NSMutableString stringWithString:[result objectAtIndex:4]);
        NSLog(@"Address = %@",macAddress);
        
    }
    
    //[macAddress insertString:@" " atIndex:1];
    
	return macAddress;
}

//-(void)centralManager:(CBCentralManager *)central didco
/*-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSString* key = [peripheral.identifier UUIDString];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSLog(@"@peripheral connect device= %@",peripheral.name);
    BLEDevice* bleDev = [[BLEDevice alloc] init];
    bleDev.peripheral = peripheral;
    bleDev.centralManager = self.centralManager;
    [self.dicBleDevices setObject:bleDev forKey:key];
    SwingDevice* blunoDev = [[SwingDevice alloc] init];
    blunoDev.identifier = key;
    blunoDev.name = peripheral.name;
    [self.dicBlunoDevices setObject:blunoDev forKey:key];
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didconnecteODevice:)])
    {
        [_delegate didconnectedDevice:blunoDev];
    }
}*/



@end
