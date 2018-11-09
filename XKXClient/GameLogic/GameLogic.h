//
//  GameLogic.h
//  陈鼎星
//
//  Created by 陈鼎星 on 2018/11/8.
//  Copyright © 2018 Chen DingXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnsiEscapeHelper.h"
#import "../TelnetClient.h"

@protocol GameLogicDelegate <NSObject>

- (void)showMessage:(NSAttributedString *)msg;
- (void)loginSuccessfully;

@end

@interface GameLogic : NSObject<TelnetDelegate>

@property (nonatomic, weak) id<GameLogicDelegate> delegate;

+(instancetype) shareInstance;
- (void)ConnectMudServer;
- (NSString *)getLocationName:(NSString *) msg;
- (void)logSentMessage:(NSString *)msg;
- (NSAttributedString *)filterMessage:(NSString *)msg;
- (void)loginWithUserNamePassword:(NSString *)inputUserName Password:(NSString *)inputPassword;
- (void)login;
- (void)sendMessage:(NSString *)msg;

@end
