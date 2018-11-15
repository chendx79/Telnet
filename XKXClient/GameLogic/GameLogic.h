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
- (void)showLocation:(NSString *)locationName;
- (void)showLocationDescription:(NSAttributedString *)locationDescription;
- (void)changeDirectionButtons:(NSArray *)directions;
- (void)changeItemsButtons:(NSArray *)items;

@end

@interface GameLogic : NSObject<TelnetDelegate>

@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, weak) id<GameLogicDelegate> delegate;

+(instancetype) shareInstance;
- (void)ConnectMudServer;
- (void)logSentMessage:(NSString *)msg;
- (NSAttributedString *)filterMessage:(NSString *)msg;
- (void)loginWithUserNamePassword:(NSString *)inputUserName Password:(NSString *)inputPassword;
- (void)login;
- (void)sendMessage:(NSString *)msg;

@end
