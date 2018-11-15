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

        if (![topString isEqualToString:@""]) {
            self.topLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2)];
            NSRange topRange = [cleanString rangeOfString:topString];
            self.topAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[myAttributedString attributedSubstringFromRange:topRange]];
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            //NSFont *font = [UIFont fontWithName:@"STXingkai" size:13];
            NSFont *font = [UIFont fontWithName:@"FZKangTi-S07S" size:12];
            //NSFont *font = [UIFont fontWithName:@"FZKaTong-M19S" size:12];
            NSDictionary *dic = @{NSFontAttributeName : font, NSParagraphStyleAttributeName:paragraphStyle};
            [self.topAttributedString addAttributes:dic range:NSMakeRange(0, [self.topAttributedString length])];
            self.topLabel.attributedString = self.topAttributedString;
            self.topLabel.backgroundColor = [UIColor clearColor];
            [self.topLabel sizeToFit];
            //[self.topLabel setBounds:CGRectMake(self.topLabel.bounds.origin.x + 6, self.topLabel.bounds.origin.y, self.topLabel.bounds.size.width, self.topLabel.bounds.size.height)];
            [self.topLabel setFrame:CGRectMake(frame.size.width / 2 - self.topLabel.frame.size.width / 2, frame.size.width / 2 - self.topLabel.frame.size.height, self.topLabel.frame.size.width, self.topLabel.frame.size.height)];
            [self addSubview:self.topLabel];
        }

        self.bottomLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, frame.size.width, frame.size.height / 2)];
        NSRange bottomRange = [cleanString rangeOfString:bottomString];
        self.bottomAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[myAttributedString attributedSubstringFromRange:bottomRange]];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSFont *font = [UIFont fontWithName:@"FZKaTong-M19S" size:14];
        NSDictionary *dic = @{NSFontAttributeName : font, NSParagraphStyleAttributeName:paragraphStyle,};
        [self.bottomAttributedString addAttributes:dic range:NSMakeRange(0, [self.bottomAttributedString length])];

        self.bottomLabel.attributedString = self.bottomAttributedString;
        self.bottomLabel.backgroundColor = [UIColor clearColor];
        //[self.bottomLabel sizeToFit];
        [self addSubview:self.bottomLabel];
    }
    return self;
}

@end
