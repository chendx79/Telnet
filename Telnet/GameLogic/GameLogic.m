//
//  GameLogic.m
//  Telnet
//
//  Created by 陈鼎星 on 2018/11/8.
//  Copyright © 2018 Bryan Yuan. All rights reserved.
//

#import "GameLogic.h"

@interface GameLogic()
{
    bool askingUserName;
    bool askingPassword;
    bool justSend;
    bool justMove;
    bool justLook;
    NSAttributedString* locationName;
    NSAttributedString* map;
    NSAttributedString* locationDescription;
}

@end

ANSIEscapeHelper *ansiEscapeHelper;

@implementation GameLogic

static GameLogic* _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        //处理AnsiEscapeString
        ansiEscapeHelper = [[ANSIEscapeHelper alloc] init];
        // set colors & font to use to ansiEscapeHelper
        NSDictionary *colorPrefDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:SGRCodeFgBlack], kANSIColorPrefKey_FgBlack,
                                           [NSNumber numberWithInt:SGRCodeFgWhite], kANSIColorPrefKey_FgWhite,
                                           [NSNumber numberWithInt:SGRCodeFgRed], kANSIColorPrefKey_FgRed,
                                           [NSNumber numberWithInt:SGRCodeFgGreen], kANSIColorPrefKey_FgGreen,
                                           [NSNumber numberWithInt:SGRCodeFgYellow], kANSIColorPrefKey_FgYellow,
                                           [NSNumber numberWithInt:SGRCodeFgBlue], kANSIColorPrefKey_FgBlue,
                                           [NSNumber numberWithInt:SGRCodeFgMagenta], kANSIColorPrefKey_FgMagenta,
                                           [NSNumber numberWithInt:SGRCodeFgCyan], kANSIColorPrefKey_FgCyan,
                                           [NSNumber numberWithInt:SGRCodeBgBlack], kANSIColorPrefKey_BgBlack,
                                           [NSNumber numberWithInt:SGRCodeBgWhite], kANSIColorPrefKey_BgWhite,
                                           [NSNumber numberWithInt:SGRCodeBgRed], kANSIColorPrefKey_BgRed,
                                           [NSNumber numberWithInt:SGRCodeBgGreen], kANSIColorPrefKey_BgGreen,
                                           [NSNumber numberWithInt:SGRCodeBgYellow], kANSIColorPrefKey_BgYellow,
                                           [NSNumber numberWithInt:SGRCodeBgBlue], kANSIColorPrefKey_BgBlue,
                                           [NSNumber numberWithInt:SGRCodeBgMagenta], kANSIColorPrefKey_BgMagenta,
                                           [NSNumber numberWithInt:SGRCodeBgCyan], kANSIColorPrefKey_BgCyan,
                                           nil];
        NSUInteger iColorPrefDefaultsKey;
        NSData *colorData;
        NSString *thisPrefName;
        for (iColorPrefDefaultsKey = 0; iColorPrefDefaultsKey < [[colorPrefDefaults allKeys] count]; iColorPrefDefaultsKey++)
        {
            thisPrefName = [[colorPrefDefaults allKeys] objectAtIndex:iColorPrefDefaultsKey];
            colorData = [[NSUserDefaults standardUserDefaults] dataForKey:thisPrefName];
            if (colorData != nil)
            {
                UIColor *thisColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
                [[ansiEscapeHelper ansiColors] setObject:thisColor forKey:[colorPrefDefaults objectForKey:thisPrefName]];
            }
        }
    }) ;

    return _instance ;
}

//^[\u4e00-\u9fa5]* - $

- (NSString *)getLocationName:(NSString *) msg{
    NSString *result;
    NSArray *lines = [msg componentsSeparatedByString:@"\r\n"];
    for (int line = 0; line < [lines count]; line = line + 1) {
        NSString *lineString = [lines objectAtIndex:line];
        NSRange range = [lineString rangeOfString:@"^[\u4e00-\u9fa5]* - $" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            NSRange nameRange = [lineString rangeOfString:@"^[\u4e00-\u9fa5]*" options:NSRegularExpressionSearch];
            result = [lineString substringWithRange:nameRange];
            NSLog(@"%@", result);
            break;
        }
    }
    return result;
}

- (void)logSentMessage:(NSString *)msg{
    if ([msg isEqualToString:@"l"]) {
        justLook = true;
    }
    if ([[NSArray arrayWithObjects: @"e", @"s", @"w", @"n", @"ne", @"nw", @"se", @"sw", nil] containsObject:msg]) {
        justMove = true;
    }
}

//此ID档案已存在，请输入密码：

- (NSAttributedString *)filterMessage:(NSString *)msg{
    NSString * cleanMsg;
    NSAttributedString *attrStr = [ansiEscapeHelper attributedStringWithANSIEscapedString:msg cleanString:&cleanMsg];
    //NSLog(@"Got %lu string [%@]", [cleanMsg length], cleanMsg);
    if (justLook) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        NSLog(@"地点名字:[\n%@\n]", [self getLocationName:cleanMsg]);
        justLook = false;
    }
    if (justMove) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        justMove = false;
    }
    return attrStr;
}

@end
