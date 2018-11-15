//
//  GameViewController.m
//  陈鼎星
//
//  Created by 陈鼎星 on 2018/11/9.
//  Copyright © 2018 Chen DingXing. All rights reserved.
//

#import "GameViewController.h"
#import "PureLayout/PureLayout.h"
#import "GameLogic/GameLogic.h"
#import "MyAttributedButton/MyAttributedButton.h"
#import "DTCoreText.h"

@interface GameViewController () <TelnetDelegate, GameLogicDelegate,UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *mapToolView;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UITextView *locationTextView;
@property (nonatomic, strong) UIView *textFieldView;
@property (nonatomic, strong) UITextField *commandField;
@property (nonatomic, strong) DTAttributedTextView *messageTextView;
@property (nonatomic, strong) UIView *directionView;
@property (nonatomic, strong) UIView *itemsView;
@property (nonatomic, strong) NSLayoutConstraint *textFieldViewHeightConstraint;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GameLogic shareInstance].delegate = self;
    self.messageTextView.delegate = self;
    self.messageTextView.userInteractionEnabled = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTextViewTap:)];
    [self.messageTextView addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeSize:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeSize:) name:UIKeyboardDidHideNotification object:nil];

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.mapToolView];//地图按钮栏
    [self.mapToolView addSubview:self.locationButton];//地名按钮
    [self.mapToolView addSubview:self.mapButton];//地图按钮

    for(int row = 0; row < 3; row++)
    {
        toolButtonView[row] = [[UIView alloc] init];
        [self.view addSubview:toolButtonView[row]];
        for(int col = 0; col < 6; col++)
        {
            toolButtons[row][col] = [[UIButton alloc] init];
            [[toolButtons[row][col] titleLabel]setFont:[UIFont systemFontOfSize: 12.0]];
            [toolButtons[row][col] setTitle:@"自定义按钮" forState:UIControlStateNormal];
            [toolButtons[row][col] setBackgroundColor:[UIColor darkGrayColor]];
            [toolButtonView[row] addSubview:toolButtons[row][col]];
        }
    }

    directionButtons = [[NSMutableArray alloc] init];
    itemsButtons = [[NSMutableArray alloc] init];

    [self.view addSubview:self.locationTextView];//地图信息栏
    [self.view addSubview:self.directionView];//方向按钮栏
    [self.view addSubview:self.itemsView];//方向按钮栏
    [self.view addSubview:self.messageTextView];//游戏消息栏
    [self.view addSubview:self.textFieldView];//游戏按钮栏
    self.commandField.delegate = self;
    [self.textFieldView addSubview:self.commandField];//命令输入栏
    [self.view setNeedsUpdateConstraints];

    [[GameLogic shareInstance] sendMessage:@"l"];
}

- (void) updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self.mapToolView autoPinToTopLayoutGuideOfViewController:self withInset:0];
        [self.mapToolView autoSetDimension:ALDimensionHeight toSize:40.0];
        [self.mapToolView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.mapToolView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.locationButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.mapToolView withOffset:5];
        [self.locationButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.mapToolView withOffset:5];
        [self.locationButton autoSetDimensionsToSize:CGSizeMake(80, 30)];

        [self.mapButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.mapToolView withOffset:5];
        [self.mapButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.mapToolView withOffset:90];
        [self.mapButton autoSetDimensionsToSize:CGSizeMake(50, 30)];

        [self.locationTextView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mapToolView];
        [self.locationTextView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.locationTextView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.locationTextView autoSetDimension:ALDimensionHeight toSize:100.0];

        [self.directionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.locationTextView];
        [self.directionView autoSetDimension:ALDimensionHeight toSize:34.0];
        [self.directionView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.directionView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        for(int row = 0; row < 3; row++)
        {
            if (row == 0) {
                [toolButtonView[row] autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view.superview withOffset:-20];
            } else {
                [toolButtonView[row] autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:toolButtonView[row-1]];
            }

            [toolButtonView[row] autoSetDimension:ALDimensionHeight toSize:61.0];
            [toolButtonView[row] autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [toolButtonView[row] autoPinEdgeToSuperviewEdge:ALEdgeRight];
            NSArray *buttonsFirstLine = @[toolButtons[row][0], toolButtons[row][1], toolButtons[row][2], toolButtons[row][3], toolButtons[row][4], toolButtons[row][5]];
            [buttonsFirstLine autoSetViewsDimension:ALDimensionHeight toSize:60.0];
            [buttonsFirstLine autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:1.0 insetSpacing:YES matchedSizes:YES];
        }

        [self.textFieldView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:toolButtonView[2]];
        self.textFieldViewHeightConstraint = [self.textFieldView autoSetDimension:ALDimensionHeight toSize:34.0];
        [self.textFieldView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.textFieldView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.itemsView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.directionView];
        [self.itemsView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.textFieldView];
        [self.itemsView autoSetDimension:ALDimensionWidth toSize:60.0];
        [self.itemsView autoPinEdgeToSuperviewEdge:ALEdgeLeft];

        [self.messageTextView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.directionView];
        [self.messageTextView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.textFieldView];
        [self.messageTextView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.itemsView];
        [self.messageTextView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.commandField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.textFieldView withOffset:2];
        [self.commandField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.commandField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [self.commandField autoSetDimension:ALDimensionHeight toSize:30];

        self.didSetupConstraints = YES;
    }

    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    //self.messageTextView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    //[self.client setup:self.hostEntry];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)confirmQuit
{
    [self.messageTextView resignFirstResponder];
    
    __weak GameViewController *weakSelf = self;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Terminate the session?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction* stopAction = [UIAlertAction actionWithTitle:@"Terminate" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action) {
                                                           [weakSelf.navigationController popViewControllerAnimated:YES];
                                                       }];
    
    [alert addAction:defaultAction];
    [alert addAction:stopAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)appendText:(NSAttributedString *)msg
{
    if (msg == nil)
        return;

    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *attrString = weakSelf.messageTextView.attributedString;
        NSMutableAttributedString *fullTextAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];

        [fullTextAttributed appendAttributedString:msg];

        weakSelf.messageTextView.attributedString = fullTextAttributed;
        //

        //[weakSelf.messageTextView insertText:msg];
        [weakSelf.messageTextView setNeedsDisplay];
        if (weakSelf.messageTextView.contentSize.height > weakSelf.messageTextView.bounds.size.height) {
            CGPoint bottomOffset = CGPointMake(0, weakSelf.messageTextView.contentSize.height - weakSelf.messageTextView.bounds.size.height);
            [weakSelf.messageTextView setContentOffset:bottomOffset animated:YES];
        }
    });

}

#pragma mark - UITextViewEvent

- (void)messageTextViewTap:(NSNotification *)notification
{
    [_commandField resignFirstResponder];
    self.textFieldViewHeightConstraint.constant = 34;
}

#pragma mark - UIKeyboardEvent

- (void)keyboardWillChangeSize:(NSNotification *)notification
{
    NSLog(@"%@", @"keyboardWillChangeSize");
//    NSDictionary *info = notification.userInfo;
//    CGRect r = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.textFieldViewHeightConstraint.constant = 135.0;
}

//组件初始化

- (UIView *)itemsView
{
    if (!_itemsView) {
        _itemsView = [UITextView newAutoLayoutView];
        _itemsView.userInteractionEnabled = true;
        _itemsView.backgroundColor = [UIColor blackColor];
    }
    return _itemsView;
}

- (DTAttributedTextView *)messageTextView
{
    if (!_messageTextView) {
        _messageTextView = [DTAttributedTextView newAutoLayoutView];
        _messageTextView.userInteractionEnabled = true;
        _messageTextView.scrollEnabled = true;
        //_messageTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 0);
        _messageTextView.backgroundColor = [UIColor blackColor];
    }
    return _messageTextView;
}

- (UIView *)mapToolView
{
    if (!_mapToolView) {
        _mapToolView = [UIView newAutoLayoutView];
        _mapToolView.backgroundColor = [UIColor blackColor];
    }
    return _mapToolView;
}

- (UIButton *)locationButton
{
    if (!_locationButton) {
        _locationButton = [UIButton newAutoLayoutView];
        [_locationButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [[_locationButton titleLabel] setFont:[UIFont systemFontOfSize: 12.0]];
        [_locationButton setBackgroundColor:[UIColor blackColor]];
        [_locationButton setTitle:@"地名" forState:UIControlStateNormal];
    }
    return _locationButton;
}

- (UIButton *)mapButton
{
    if (!_mapButton) {
        _mapButton = [UIButton newAutoLayoutView];
        [_mapButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [[_mapButton titleLabel] setFont:[UIFont systemFontOfSize: 12.0]];
        [_mapButton setBackgroundColor:[UIColor blackColor]];
        [_mapButton setTitle:@"地图" forState:UIControlStateNormal];
    }
    return _mapButton;
}

- (UITextView *)locationTextView
{
    if (!_locationTextView) {
        _locationTextView = [UITextView newAutoLayoutView];
        _locationTextView.backgroundColor = [UIColor blackColor];
    }
    return _locationTextView;
}

- (UIView *)textFieldView
{
    if (!_textFieldView) {
        _textFieldView = [UIView newAutoLayoutView];
        _textFieldView.backgroundColor = [UIColor grayColor];
    }
    return _textFieldView;
}

- (UITextField *)commandField
{
    if (!_commandField) {
        _commandField = [UITextField newAutoLayoutView];
        _commandField.backgroundColor = [UIColor whiteColor];
        [_commandField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_commandField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    }
    return _commandField;
}

- (UIView *)directionView
{
    if (!_directionView) {
        _directionView = [UIView newAutoLayoutView];
        _directionView.backgroundColor = [UIColor blackColor];
    }
    return _directionView;
}

- (void)walk:(UIButton *)sender {
    NSString *direction = sender.titleLabel.text;
    [[GameLogic shareInstance] sendMessage:direction];
}

#pragma mark - TelnetDelegate

- (void)didReceiveMessage:(NSAttributedString *)msg
{
    [self appendText:msg];
}

- (void)shouldEcho:(BOOL)echo
{
    //NSLog(@"%s %d", __func__, echo);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[GameLogic shareInstance] sendMessage:_commandField.text];
    [_commandField selectAll:self];
    return YES;
}

#pragma mark - GameLogicDelegate
- (void)showMessage:(NSAttributedString *)msg
{
    [self appendText:msg];
}

- (void)loginSuccessfully{

}

- (void)showLocation:(NSString *)locationName{
    [self.locationButton setTitle:locationName forState:UIControlStateNormal];
}

- (void)showLocationDescription:(NSAttributedString *)locationDescription{
    self.locationTextView.attributedText = locationDescription;
}

- (void)changeDirectionButtons:(NSArray *)directions{
    if ([directionButtons count] > 0) {
        for(int i = [directionButtons count] - 1; i >= 0; --i)
        {
            UIButton *button = directionButtons[i];
            [directionButtons removeObject:button];
            [button removeFromSuperview];
        }
    }

    for(int i = 0; i < [directions count]; i++)
    {
        UIButton *directionButton = [[UIButton alloc] init];
        [[directionButton titleLabel]setFont:[UIFont systemFontOfSize: 12.0]];
        [directionButton setBackgroundColor:[UIColor darkGrayColor]];
        [directionButton setTitle:directions[i] forState:UIControlStateNormal];
        [directionButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [directionButton setFrame:CGRectMake(2 + 52 * i, 2, 50, 30)];
        [directionButton addTarget:self action:@selector(walk:) forControlEvents:UIControlEventTouchUpInside];

        [self.directionView addSubview:directionButton];
        [directionButtons addObject:directionButton];
    }
    NSLog(@"button added~~~~~~~~~~~~~~~~~~~~~~~~");
}

- (void)changeItemsButtons:(NSArray *)items{
    if ([itemsButtons count] > 0) {
        for(int i = [itemsButtons count] - 1; i >= 0; --i)
        {
            MyAttributedButton *button = itemsButtons[i];
            [itemsButtons removeObject:button];
            [button removeFromSuperview];
        }
    }

    for(int i = 0; i < [items count]; i++)
    {
        NSAttributedString *attrTitle = [(NSDictionary *)items[i] objectForKey:@"name"];
        MyAttributedButton *itemButton = [[MyAttributedButton alloc] initWithFrame:CGRectMake(1, 1 + 61 * i, 60, 60) MyAttributedString:attrTitle];
        //[itemButton setTitle:@"测试" forState:UIControlStateNormal];
        [itemButton setBackgroundColor:[UIColor darkGrayColor]];

        [self.itemsView addSubview:itemButton];
        [itemsButtons addObject:itemButton];
    }
    NSLog(@"items added~~~~~~~~~~~~~~~~~~~~~~~~");
}

@end
