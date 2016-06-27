//
//  JxbQmttCode.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/25.
//  Copyright © 2016年 Peter. All rights reserved.
//

typedef NS_ENUM (NSUInteger, JxbConnectionCode) {
    JxbConnectionAccepted,
    JxbConnectionRefusedUnacceptableProtocolVersion,
    JxbConnectionRefusedIdentiferRejected,
    JxbConnectionRefusedServerUnavailable,
    JxbConnectionRefusedBadUserNameOrPassword,
    JxbConnectionRefusedNotAuthorized
};
