//
//  SwingProtocol.m
//  iManager
//
//  Created by jinugi011 on 2015. 7. 3..
//  Copyright (c) 2015년 nethom. All rights reserved.
//

#import "SwingProtocol.h"
@implementation SwingProtocol


//num InventoryMode _param_inventory_mode = INVENTORY_NORMAL;



#pragma Swing_API_For_bluetooth

+(id)sharedInstace
{
    
    static SwingProtocol* this = nil;
    
    if(!this)
    {
        this = [[SwingProtocol alloc] init];
        this.swingapi = [SwingApi sharedInstance];
        this.swingapi.delegate = this;

     
        if(this.aryDevices == NULL)
        {
            this.aryDevices = [[NSMutableArray alloc]init]; //device list in
            
            NSLog(@"aryDevice is null");
        }else{
            NSLog(@"aryDevices is not null");
        }
        
        
    }
    
    
    //self._inventory= INVENTORY_NORMAL;
    // = INVENTORY_NORMAL;
    
    return this;
}
- (id) init
{
    if ( self = [super init] )
    {
       //_byteData = (Byte*)malloc(256);
        _byteData = [[NSMutableData alloc] init];
    }
    return self;
}
-(BOOL)ReaderStatus
{
    //return [self.blunoManager.delegate];
    return false;
}


#pragma mark- SwingDelegate

-(void)bleDidUpdateState:(BOOL)bleSupported
{
    if(bleSupported)
    {
        [self.swingapi scan];
    }
}

-(void)didDiscoverDevice:(SwingDevice*)dev
{
    BOOL bRepeat = NO;
    if([dev name] == nil){
         NSLog(@"Device nil !!!");
        return;
    }
    
    for (SwingDevice* bleDevice in self.aryDevices)
    {
        if ([bleDevice isEqual:dev])
        {
            bRepeat = YES;
            break;
        }    }
    if (!bRepeat)
    {
        [self.aryDevices addObject:dev];
        //if([[dev name] isEqualToString:@"SwingU"]){
        
    }

    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_didDiscoverDevice:)])
    {
       [_delegate Swing_didDiscoverDevice:dev];
    }

}
/**
 * connedted swing reader ready
 **/
-(void)readyToCommunicate:(SwingDevice*)dev
{
    NSLog(@"Ready to Communication");
	//통신 준비 완료
    self.swingDev = dev;
    self.swingDev->_bReadyToWrite = YES;

    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_readyToCommunicate:)])
    {
      [_delegate Swing_readyToCommunicate:dev];
    }
    
}

-(void)didDisconnectDevice:(SwingDevice*)dev
{
    //self.swingDev->_bReadyToWrite = NO;
   if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_didDisconnectDevice:)])
   {
	   [_delegate Swing_didDisconnectDevice:dev];
   }
}

-(void)didWriteData:(SwingDevice*)dev
{
   NSLog(@"data is sended to swing device complate");
}


-(void)sendProtocol:(NSString *)value
{
    NSString* strTemp = value;
    
    if([strTemp length] > 20) //커멘드가 20바이트가 넘을 경우
    {
        int start = 0;
        //NSData *senddata = [[NSData alloc]init];
        
        for (int i=1; i< [strTemp length]; i++) {
            
            if(i % 20 == 0)
            {
                NSRange split;
                split.location = start;
                split.length = 20;
            
                NSString *sendstring = [strTemp substringWithRange:split];
                
                NSLog(@"send = %@",sendstring);
                
                NSData* data = [sendstring dataUsingEncoding:NSUTF8StringEncoding];
                [self.swingapi writeDataToDevice:data Device:self.swingDev];
                start = i;
            }
        }
        
        NSString *sendstring = [strTemp substringFromIndex:start];
        
        NSLog(@"send = %@",sendstring);
        
        
        NSData* data = [sendstring dataUsingEncoding:NSUTF8StringEncoding];
        [self.swingapi writeDataToDevice:data Device:self.swingDev];
        
    }else{
        NSData* data = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
         NSLog(@"send = %@",strTemp);
        [self.swingapi writeDataToDevice:data Device:self.swingDev];
    }
    
}

-(BOOL)swing_getParingstatus
{
	return false;
}


-(void)didReceiveData:(NSData*)data Device:(SwingDevice*)dev
{

	NSUInteger len = [data length];
    //Byte *byteData = (Byte*)malloc(len);
    
    //memcpy(_byteData + [_byteData length], [data bytes], len);
    const char* temp = (const char*)[data bytes];
    if(temp[len-1] == 0x00){ // end of packet
        //NSData *extractData = [data subdataWithRange:NSMakeRange(0, len-1)];
        NSMutableData* copydata = [[NSMutableData alloc] initWithData:data];
        [_byteData appendData:copydata];

        NSLog(@"##[SwingProtocol] -> didReceiveData :: parseSwing 호출");
        [self parseSwing:_byteData];
        
        //_byteData = [NSMutableData init];
        _byteData.init;
    }else if(temp[len-1] == 0x01){
        NSData *extractData = [data subdataWithRange:NSMakeRange(0, len-1)];
        NSMutableData* copydata = [[NSMutableData alloc] initWithData:extractData];
        [_byteData appendData:copydata];
    }else{
        NSLog(@"unkonwn data = %@",data);
    }
}



//==================================
//==== 스윙리더기 데이터 버퍼
//==================================
-(void)parseSwing:(NSData*)buffer
{
        const char* result = (const char*)[buffer bytes];
        unsigned char cmd = result[1];
        NSString *tempresult = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
        NSLog(@"== 입력 커맨드: %c || 수신 데이터: %@",cmd,tempresult);


    
    if(result[0]== '>'){
        switch (cmd) {
                
            case 'a':
            case 'A':
                if(result[2] == '3') { //MESSAGE_STOP
                    
                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryCmd_Stop:)])
                    {
                        [_delegate Swing_Response_InventoryCmd_Stop:tempresult];
                    }
                    
                }
                if(result[2] == 'f') { //MESSAGE_START
                    
                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryCmd_Start:)])
                    {
                        [_delegate Swing_Response_InventoryCmd_Start:tempresult];
                    }
                    
                }
                else if (result[2] == '7') {//MESSAGE_FOUND
                    
                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryCmd:)])
                    {
                        [_delegate Swing_Response_InventoryCmd:tempresult];
                    }
                    
                }
                else if (result[2] == '4') {//MESSAGE_SEARCH_FINISH
                    
                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryCmd:)])
                    {
                        [_delegate Swing_Response_InventoryCmd:tempresult];
                    }
                    
                }
                else if (result[2] == ' '&& result[3] == '0') {//MESSAGE_MENU_ENABLE
                    
                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_MenuEnable:)])
                    {
                        [_delegate Swing_Response_MenuEnable:tempresult];
                    }
                }
//                else {
//                    if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryCmd:)])
//                    {
//                        [_delegate Swing_Response_InventoryCmd:tempresult];
//                    }
//                }
                break;
            case 'E':
//                if ([((NSObject*)_delegate) respondsToSelector:@selector(swing_error_find:)])
//                {
//                    
//            		[self swing_error_find:tempresult];
//                }
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_ERROR:)])
                {
                    [_delegate Swing_Response_ERROR:tempresult];
                }
    	        break;

/* 태그 모드 */
            case 'T':	// 'T', tag report mode
            	if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_TagList:)])
   				{
                 	[_delegate Swing_Response_TagList:tempresult];
                   
        		}
                break;
                
/* QR코드,바코드 모드 */
            case 'J':	//barcode mode
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_TagList:)])
   				{
                    NSLog(@"##[SwingProtocol] -> SwingProtocol :: Swing_Response_TagList 호출");
                    
        			[_delegate Swing_Response_TagList:tempresult];
        		}
                break;
            case 'R':	// 'R', tag memory report mode
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_TagReport:)])
   				{
        			[_delegate Swing_Response_TagReport:tempresult];
        		}
    		    break;
            case 'c':	// 'c', get continuous mode
                //Log.d("dsm362", String.format("continuous mode = %s", new String(data, 0, datalength)));
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_continuous:)])
   				{
        			[_delegate Swing_Response_continuous:tempresult];
        		}
                break;
            case 's':	// 's', get buzzer volume
                if(result[2] == 't') break;
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_buzzer:)])
   				{
        			[_delegate Swing_Response_buzzer:tempresult];
        		}
    		    break;
            case 'b':	// 'b', get report mode, 0: trigger, 1: all tag
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_mode_trigger_alltag:)])
   				{
        			[_delegate Swing_Response_mode_trigger_alltag:tempresult];
        		}
    		    break;
            case 'p':	// 'p', get power, 0, 1, 2 mode
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_power:)])
   				{

        			[_delegate Swing_Response_power:tempresult];
        		}
                break;
            case 'k': // 'k' trhead hold for reading
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_threadhold:)])
   				{
        			[_delegate Swing_Response_threadhold:tempresult];
        		}
                break;
            case 'u': //'u' write unit
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_Unit:)])
   				{
        			[_delegate Swing_Response_Unit:tempresult];
        		}
    		    break;
            case 'v': //battery
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_battery:)])
   				{
        			[_delegate Swing_Response_battery:tempresult];
        		}
    	        break;
            case 'm':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_InventoryMode:)])
   				{
        			[_delegate Swing_Response_InventoryMode:tempresult];
        		}
    			
                break;
            case 'n':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_TagCount:)])
   				{
        			[_delegate Swing_Response_TagCount:tempresult];
        		}
                break;
            case 'f':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_MessageClear:)])
   				{
        			[_delegate Swing_Response_MessageClear:tempresult];
        		}
            case 'G':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_MessageFIND:)])
   				{
        			[_delegate Swing_Response_MessageFIND:tempresult];
        		}
                break;
//            case '2':
//                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_MessageFIND:)])
//                {
//                    [_delegate Swing_Response_MessageFIND:tempresult];
//                }
//                break;
                
            case '2': // max epc length
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_MaxEpcLength:)])
                {
                    [_delegate Swing_Response_MaxEpcLength:tempresult];
                }
                break;
//            case '': // max count (filter size)
//                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_FilterSize:)])
//                {
//                    [_delegate Swing_Response_FilterSize:tempresult];
//                }
//                break;
            case '1': // language 0:english, 1:chinese
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_Language:)])
                {
                    [_delegate Swing_Response_Language:tempresult];
                }
                break;
            case '8':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_model:)])
                {
                    [_delegate Swing_Response_model:tempresult];
                }
                break;
            case '4':
                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_session:)])
                {
                    [_delegate Swing_Response_session:tempresult];
                }
                break;
            case 'q':
                
                NSLog(@"== Swing power off!!!!!!!");
                break;
            default:
//                if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_TagList:)])
//   				{
//        			[_delegate Swing_Response_TagList:tempresult];
//                }
                NSLog(@" case unparsed msg!!!!!!! ");
                break;
        }
    }else{
        NSLog(@" > unparsed msg!!!!!!!");
    }
    
}

-(NSData *) parseStringToData:(NSString *) str
{
	if ([str length] % 3 != 0)
	{
		// raise an exception, because the string's length should be a multiple of 3.
	}

	NSMutableData *result = [NSMutableData dataWithLength:[str length] / 3];
	unsigned char *buffer = [result mutableBytes];

	for (NSUInteger i = 0; i < [result length]; i++)
	{
		NSString *byteString = [str substringWithRange:NSMakeRange(i * 3, 3)];
		buffer[i] = [byteString intValue];
	}
	return result;
}

- (BOOL)isSwingrederConnected
{
    if(_swingDev != NULL)
    {
        if(_swingDev->_bReadyToWrite == YES)
        {
            return YES;
        }
        return NO;
    }
    return NO;
}

/**
**/

-(void)swing_error_find:(NSString *)code
{
    
    NSLog(@"code = %@",code);
    
    
	if ([((NSObject*)_delegate) respondsToSelector:@selector(Swing_Response_ERROR:)])
	{
		[_delegate Swing_Response_ERROR:code];
	}
}



#pragma mark- Swing Protocol Send List

-(void)swing_set_inventory_mode:(int)mode
{
   // if(_param_inventory_mode == mode) return;

    NSString *cmd = [[NSString alloc]initWithFormat:@">x m %d\r",mode];  //String.format(">x m %d\r", mode.ordinal());
    [self sendProtocol:cmd];
}

-(void)swing_set_inventory_mode_find:(int)mode
{
    // if(_param_inventory_mode == mode) return;
    
    NSString *cmd = [[NSString alloc]initWithFormat:@">x l %d\r",mode];  //String.format(">x m %d\r", mode.ordinal());
    [self sendProtocol:cmd];
}


-(void)swing_readStart
{
	 NSString *cmd = [[NSString alloc]initWithFormat:@">f\r"];  //String.format(">x m %d\r", mode.ordinal());
	 [self sendProtocol:cmd];
}

-(void)swing_readStop
{
	NSString *cmd = [[NSString alloc]initWithFormat:@"3"];  //String.format(">x m %d\r", mode.ordinal());
		 [self sendProtocol:cmd];
}

-(void)swing_clear_inventory
{
	 NSString *cmd = [[NSString alloc]initWithFormat:@">c\r"];  //String.format(">x m %d\r", mode.ordinal());
	 [self sendProtocol:cmd];
}



-(void)swing_readMemory:(int)bank:(int)offset:(int)wordLenght
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">r %02d %02d %02d\r", bank, offset, wordLenght];  //String.format(">x m %d\r", mode.ordinal());
	[self sendProtocol:cmd];
}


-(void)swing_getSyncTagList
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">y t\r"];  //String.format(">x m %d\r", mode.ordinal());
    NSLog(@"tagList send = %@",cmd);
	[self sendProtocol:cmd];
}

-(void)swing_clear_search_taget_list
{
    NSLog(@"Find clear");
    [self swing_clear_find];
}

-(void)swing_writeMemory:(int)bank:(int)offset:(int)count:(NSString *)data
{
   NSString *cmd = [[NSString alloc]initWithFormat:@">w %02d %02d %02d %@ \r", bank, offset, count, data];
    
    NSLog(@"write send = %@",cmd);
    
	[self sendProtocol:cmd];
}

-(void)swing_selectMemory:(int)bank:(int)offset:(int)count:(NSString *)data
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">s %02d %02d %02d %@ \r", bank, offset, count, data];
    
    NSLog(@"select send = %@",cmd);
    
    [self sendProtocol:cmd];
}

-(void)swing_lockMemory:(int)access:(int)kill:(int)epc:(int)tid:(int)user:(NSString *)accesspassword
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">l %d %d %d %d %d %@\r", access, kill, epc, tid, user, accesspassword];
    
    NSLog(@"select send = %@",cmd);
    
    [self sendProtocol:cmd];
}

-(void)swing_setAllTagReport:(Boolean)on_all_tag_report
{
    
	
    if(on_all_tag_report)
	{
	    NSString *cmd = [[NSString alloc]initWithFormat:@">x b 1\r\n"];
        [self sendProtocol:cmd];
	}else{
	    NSString *cmd = [[NSString alloc]initWithFormat:@">x b 0\r\n"];
        [self sendProtocol:cmd];
	}
	
}

-(void)swing_setPower:(int)attenuation
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">x p %d\r",attenuation];
	[self sendProtocol:cmd];
}


-(void)swing_setSession:(int)session
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">x 4 %d\r",session];
    [self sendProtocol:cmd];
}

-(void)swing_setContinuous:(Boolean)on_continuous
{
	//NSString *param = @"";
	if(on_continuous)
	{
	  NSString *cmd = [[NSString alloc]initWithFormat:@">x c 1\r\n"];
        [self sendProtocol:cmd];
	}else{
	    NSString *cmd = [[NSString alloc]initWithFormat:@">x c 0\r\n"];
        [self sendProtocol:cmd];
	}
	
}

-(void)swing_setContinuous
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y c "];
    [self sendProtocol:cmdString];
}


-(void)swing_setMenuEnable:(BOOL)enable
{
    NSString *param = @"";
	if(enable)
	{
		param = @"1\r";
	}else{
		param = @"0\r";
	}

	NSString *cmd = [[NSString alloc]initWithFormat:@">x a %@\r",param];
	[self sendProtocol:cmd];
}

-(void)swing_setThreshold:(NSInteger)th
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">x k %ld\r",(long)th];
	[self sendProtocol:cmd];
}

-(void)swing_setUnit:(NSInteger)unit
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">x u %ld\r",unit];
	[self sendProtocol:cmd];
}

-(void)swing_setBuzzer:(NSInteger)volume
{
	NSString *cmd = [[NSString alloc]initWithFormat:@">x s %ld\r",volume];
	[self sendProtocol:cmd];
}

-(void)swing_setMaxepclength:(NSInteger)maxepclength
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">m %ld\r",maxepclength];
    [self sendProtocol:cmd];
}

-(void)swing_setFiltersize:(NSInteger)filtersize
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">t %ld\r",filtersize];
    [self sendProtocol:cmd];
}

-(void)swing_setLanguage:(NSInteger)language
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">x 1 %ld\r",language];
    [self sendProtocol:cmd];
    //NSLog(@"command" + cmd);
}

-(void)swing_setModel:(NSString*)model
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">x 8 %@\r",model];
    [self sendProtocol:cmd];
//    NSLog(@"command" + cmd);
}

-(void)swing_set_search_target:(NSString*)target_id
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">x l 001 %@\r",target_id];
	[self sendProtocol:cmdString];
}

-(void)swing_set_add_search_target:(NSInteger)idx:(NSString *)id_target
{
    NSString *cmdString = [[NSString alloc]initWithFormat:@">x l %03ld %@\r",(long)idx,id_target];
    [self sendProtocol:cmdString];
}


-(void)swing_set_search_target_multi
{
    NSString *cmdString = [[NSString alloc]initWithFormat:@">x l 999\r"];
    [self sendProtocol:cmdString];
}




-(void)swing_clear_find
{
    NSLog(@"clear finish");
    NSString *cmd = [[NSString alloc]initWithFormat:@">x l c\r"];  //String.format(">x m %d\r", mode.ordinal());
    [self sendProtocol:cmd];
}

-(void)swing_setEPCUserMode:(Boolean *)on_ecp_user
{
	NSString *param = @"";
	if(on_ecp_user)
	{
		param = @"1\r";
	}else{
		param = @"0\r";
	}
	NSString *cmd = [[NSString alloc]initWithFormat:@">x y %@",param];
	[self sendProtocol:cmd];
}

-(void)swing_saveParam
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">x a\r"];
	[self sendProtocol:cmdString];
}

-(void)swing_setReadMode:(NSInteger)mode
{
    NSString *cmd = [[NSString alloc]initWithFormat:@">x 6 %ld\r",(long)mode];
    [self sendProtocol:cmd];
}

////
/**
 * Swing get Protocol for reader status
 *
 */

-(void)swing_getMenuEnable
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y a \r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getLanguage
{
    NSString *cmdString = [[NSString alloc]initWithFormat:@">y 1 \r\n"];
    [self sendProtocol:cmdString];
}

-(void)swing_getAllInformation
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">i \r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getpower
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y p \r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getsession
{
    NSString *cmdString = [[NSString alloc]initWithFormat:@">y 4 \r\n"];
    [self sendProtocol:cmdString];
}

-(void)swing_getBuzzerVolume
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y s \r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getEPCUserMode
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y y r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getUserMemLength
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">y 7 r\n"];
	[self sendProtocol:cmdString];
}

-(void)swing_getAccessPass
{
	NSString *cmdString = [[NSString alloc]initWithFormat:@">>y w\r"];
	[self sendProtocol:cmdString];
}



-(void)swing_testsend:(NSString*)value
{
    [self sendProtocol:value];
}

-(NSString *)getErrorCodeDiscription:(NSString *)Code
{


	NSArray  *ErrorDiscription = [NSArray arrayWithObjects:@"Memory access success", @"Invalid protocol", @"Invalid parameter", @"Unknown command",@"Operation failed",@"Handle mismatch", @"CRC error", @"No tag reply", @"Invalid password", @"Zero kill password",
	    @"Tag lost", @"Command format error", @"Read count invalid", @"Out of retries", @"Operation failed",
	    @"General error", @"No memory", @"Memory locked", @"Insufficient power", @"Unkown error", /* etc */nil ];


	NSString *result = @"Unkown error";

	NSRange replaceRange = [Code rangeOfString:@"E00000"];
	if (replaceRange.location != NSNotFound) {

		return  [ErrorDiscription objectAtIndex:0];

	}

	replaceRange = [Code rangeOfString:@"E00001"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:1];
	}

	replaceRange = [Code rangeOfString:@"E00002"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:2];
	}

	replaceRange = [Code rangeOfString:@"E00003"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:3];
	}


	replaceRange = [Code rangeOfString:@"E00004"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:4];
	}

	replaceRange = [Code rangeOfString:@"E10001"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:5];
	}

	replaceRange = [Code rangeOfString:@"E10002"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:6];
	}

	replaceRange = [Code rangeOfString:@"E10003"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:7];
	}

	replaceRange = [Code rangeOfString:@"E10004"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:8];
	}

	replaceRange = [Code rangeOfString:@"E10005"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:9];
	}

	replaceRange = [Code rangeOfString:@"E10006"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:10];
	}

	replaceRange = [Code rangeOfString:@"E10007"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:11];
	}

	replaceRange = [Code rangeOfString:@"E10008"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:12];
	}
	replaceRange = [Code rangeOfString:@"E10009"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:13];
	}
	replaceRange = [Code rangeOfString:@"E1FFFF"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:14];
	}

	replaceRange = [Code rangeOfString:@"E20000"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:15];
	}

	replaceRange = [Code rangeOfString:@"E20003"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:16];
	}

	replaceRange = [Code rangeOfString:@"E20004"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:17];
	}

	replaceRange = [Code rangeOfString:@"E2000B"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:18];
	}

	replaceRange = [Code rangeOfString:@"E2000F"];
	if (replaceRange.location != NSNotFound) {
		return  [ErrorDiscription objectAtIndex:19];
	}

	return result;

}

-(bool) contains: (NSString*)str containsCharator:(NSString *)character{
    NSUInteger range = [str rangeOfString:character].location;
    if(range != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}


@end
