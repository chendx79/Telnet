//
//  GameLogic.h
//  Telnet
//
//  Created by 陈鼎星 on 2018/11/8.
//  Copyright © 2018 Bryan Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnsiEscapeHelper.h"
#import "../TelnetClient.h"

@protocol GameLogicDelegate <NSObject>

- (void)showMessage:(NSAttributedString *)msg;

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

@end
