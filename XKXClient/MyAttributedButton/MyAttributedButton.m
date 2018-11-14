//
//  MyAttributedButton.m
//  XKXClient
//
//  Created by 陈鼎星 on 2018/11/14.
//  Copyright © 2018 Bryan Yuan. All rights reserved.
//

#import "MyAttributedButton.h"
#import "DTCoreText.h"
#import "AnsiEscapeHelper.h"

@interface MyAttributedButton()
@property (nonatomic, strong) NSMutableAttributedString *topAttributedString;
@property (nonatomic, strong) NSMutableAttributedString *bottomAttributedString;
@property (nonatomic, strong) DTAttributedLabel *topLabel;
@property (nonatomic, strong) DTAttributedLabel *bottomLabel;
@end

@implementation MyAttributedButton

- (void)drawRect:(CGRect)rect {
    
}

- (instancetype)initWithFrame:(CGRect)frame MyAttributedString:(NSAttributedString *) myAttributedString{

    self = [super initWithFrame:frame];
    if (self != nil) {
        _myAttributedString = myAttributedString;
        NSString *cleanString = myAttributedString.string;
        NSArray *nameArray = [cleanString componentsSeparatedByString:@" "];

        NSString *topString = @"";
        NSString *bottomString = @"";
        if ([nameArray count] == 1) {
            bottomString = nameArray[0];
        } else if ([nameArray count] == 2){
            topString = nameArray[0];
            bottomString = nameArray[1];
        } else {
            @throw [NSException exceptionWithName:@"wrong item name" reason:cleanString userInfo:nil];
        }
        self.topLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2)];
        self.bottomLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, frame.size.width, frame.size.height / 2)];

        if (![topString isEqualToString:@""]) {
            NSRange topRange = [cleanString rangeOfString:topString];
            self.topAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[myAttributedString attributedSubstringFromRange:topRange]];
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:paragraphStyle};
            [self.topAttributedString addAttributes:dic range:NSMakeRange(0, [self.topAttributedString length])];
            self.topLabel.attributedString = self.topAttributedString;
            self.topLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.topLabel];
        }

        NSRange bottomRange = [cleanString rangeOfString:bottomString];
        self.bottomAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[myAttributedString attributedSubstringFromRange:bottomRange]];

        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:paragraphStyle,};
        [self.bottomAttributedString addAttributes:dic range:NSMakeRange(0, [self.bottomAttributedString length])];

        self.bottomLabel.attributedString = self.bottomAttributedString;
        self.bottomLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bottomLabel];
    }
    return self;
}

@end
