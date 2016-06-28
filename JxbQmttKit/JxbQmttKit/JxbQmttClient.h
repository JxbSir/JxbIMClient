//
//  JxbQmttClient.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/25.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JxbQmttCode.h"


#define JxbIMNewMessageNotification     @"JxbIMNewMessageNotification"


@class JxbIMBaseMessage,JxbIMTextMessage,JxbIMImageMessage,JxbIMCustomMessage,JxbIMNotifyMessage,JxbIMSystemMessage,JxbIMLocationMessage,JxbIMInputingMessage;


@protocol JxbQmttDelegate <NSObject>
@optional
- (void)receiveMessage:(JxbIMBaseMessage * __nonnull)message;
@end

@interface JxbQmttClient : NSObject


@property (nonatomic, weak, nullable) id<JxbQmttDelegate> delegate;


/**
 *  单例模式
 *
 *  @return
 */
+ (instancetype __nonnull)sharedInstance;

/**
 *  连接IM服务器
 *
 *  @param host         主机地址
 *  @param clentId      客户端id，可以用userid，代表一个用户
 *  @param successBlock 连接成功回调
 *  @param failureBlock 连接失败回调
 */
- (void)connect:(NSString * __nonnull)host clentId:(NSString* __nonnull)clentId successBlock:(void(^ __nullable)(void))successBlock failureBlock:(void(^ __nullable)(JxbConnectionCode statusCode))failureBlock;

/**
 *  断开服务器
 */
- (void)disconnect;

/**
 *  订阅Topic
 *
 *  @param topics 一个topic的数组(NSString)
 */
- (void)subscribe:(NSArray * __nonnull)topics;

/**
 *  取消订阅Topic
 *
 *  @param topics 同订阅
 */
- (void)unsubscribe:(NSArray * __nonnull)topics;

/**
 *  读取本地历史记录
 *
 *  @param topic         topic，若nil，则读取全部
 *  @param completeBlock 读取记录回调，返回的是相应MsgType的JxbIM[*]Message数组
 */
- (void)loadAllMsg:(NSString * __nullable)topic completeBlock:(void(^ __nonnull)( NSArray * _Nullable messages ))completeBlock;

/**
 *  发送文本消息
 *
 *  @param message 消息结构
 */
- (void)sendTextMessage:(JxbIMTextMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送图片信息
 *
 *  @param message 消息结构
 */
- (void)sendImageMessage:(JxbIMImageMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送位置信息
 *
 *  @param message 消息结构
 */
- (void)sendLocationMessage:(JxbIMLocationMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送通知信息
 *
 *  @param message 消息结构
 */
- (void)sendNotifyMessage:(JxbIMNotifyMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送正在输入信息
 *
 *  @param message 消息结构
 */
//- (void)sendInputingMessage:(JxbIMInputingMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送系统信息
 *
 *  @param message 消息结构
 */
//- (void)sendSystemMessage:(JxbIMSystemMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

/**
 *  发送自定义信息
 *
 *  @param message 消息结构
 */
//- (void)sendCustomMessage:(JxbIMCustomMessage* __nonnull)message completeBlcok:(void(^ __nullable)(bool bSuccess))completeBlcok;

@end
