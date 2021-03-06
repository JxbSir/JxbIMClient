//
//  JxbIMLocationMessage.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbIMBaseMessage.h"

@interface JxbIMLocationMessage : JxbIMBaseMessage

/**
 *  纬度
 */
@property (nonatomic, assign) double latitude;

/**
 *  经度
 */
@property (nonatomic, assign) double longitude;
@end
