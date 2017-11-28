//
//  DFBlunoDevice.h
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwingDevice : NSObject
{
@public
    BOOL _bReadyToWrite;
}

@property(strong, nonatomic) NSString* identifier;//<-UUID
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* macaddress;
@property(assign, nonatomic, readonly) BOOL bReadyToWrite;

@end
