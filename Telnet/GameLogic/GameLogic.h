//
//  GameLogic.h
//  Telnet
//
//  Created by 陈鼎星 on 2018/11/8.
//  Copyright © 2018 Bryan Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnsiEscapeHelper.h"

@interface GameLogic : NSObject

+(instancetype) shareInstance;
- (NSString *)getLocationName:(NSString *) msg;
- (void)logSentMessage:(NSString *)msg;
- (NSAttributedString *)filterMessage:(NSString *)msg;

@end
