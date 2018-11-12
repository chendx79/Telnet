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

@interface GameViewController () <TelnetDelegate, GameLogicDelegate,UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *mapToolView;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UITextView *locationTextView;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UITextField *commandField;
@property (nonatomic, strong) UITextView *messageTextView;
//@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* toolButtons;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GameLogic shareInstance].delegate = self;
    self.messageTextView.delegate = self;
    
    //[self.messageTextView setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeSize:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeSize:) name:UIKeyboardDidHideNotification object:nil];

    [self.view addSubview:self.mapToolView];//地图按钮栏
    [self.mapToolView addSubview:self.locationButton];//地名按钮
    [self.mapToolView addSubview:self.mapButton];//地图按钮

    [self.view addSubview:self.locationTextView];//地图信息栏
    [self.view addSubview:self.messageTextView];//游戏消息栏
    [self.view addSubview:self.toolView];//游戏按钮栏
    self.commandField.delegate = self;
    [self.toolView addSubview:self.commandField];//命令输入栏
    [self.view setNeedsUpdateConstraints];
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

        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.toolView autoSetDimension:ALDimensionHeight toSize:330.0];
        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.messageTextView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.locationTextView];
        [self.messageTextView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.toolView];
        [self.messageTextView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.messageTextView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.commandField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toolView withOffset:50];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)appendText:(NSAttributedString *)msg
{
    if (msg == nil)
        return;

    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{


        NSMutableAttributedString *fullTextAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:weakSelf.messageTextView.attributedText];

        [fullTextAttributed appendAttributedString:msg];

        weakSelf.messageTextView.attributedText = fullTextAttributed;
        //

        //[weakSelf.messageTextView insertText:msg];
        [weakSelf.messageTextView setNeedsDisplay];
        
        NSRange visibleRange = NSMakeRange(weakSelf.messageTextView.text.length-2, 1);
        [weakSelf.messageTextView scrollRangeToVisible:visibleRange];
    });

}

#pragma mark - UIKeyboardEvent

- (void)keyboardWillChangeSize:(NSNotification *)notification
{
    return;
    //NSLog(@"%s", __func__);
    NSDictionary *info = notification.userInfo;
    
    CGRect r = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"keyboard %@", NSStringFromCGRect(r));
    
    CGRect oriBound = self.messageTextView.bounds;
    [self.messageTextView setBounds:CGRectMake(0, 0, oriBound.size.width, oriBound.size.height-r.size.height)];
    [self.messageTextView setCenter:CGPointMake(self.messageTextView.bounds.size.width/2.0, self.messageTextView.bounds.size.height/2.0)];
    [self.messageTextView setNeedsLayout];
}

- (void)keyboardDidChangeSize:(NSNotification *)notification
{
    return;
    //NSLog(@"%s", __func__);
    
    [self.messageTextView setBounds:self.view.bounds];
    [self.messageTextView setCenter:self.view.center];
}

- (UITextView *)messageTextView
{
    if (!_messageTextView) {
        _messageTextView = [UITextView newAutoLayoutView];
        _messageTextView.userInteractionEnabled = true;
        _messageTextView.scrollEnabled = true;
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
        [_locationButton setBackgroundColor:[UIColor darkGrayColor]];
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
        [_mapButton setBackgroundColor:[UIColor darkGrayColor]];
        [_mapButton setTitle:@"地图" forState:UIControlStateNormal];
    }
    return _mapButton;
}

- (UITextView *)locationTextView
{
    if (!_locationTextView) {
        _locationTextView = [UITextView newAutoLayoutView];
        _locationTextView.backgroundColor = [UIColor darkGrayColor];
    }
    return _locationTextView;
}

- (UIView *)toolView
{
    if (!_toolView) {
        _toolView = [UIView newAutoLayoutView];
        _toolView.backgroundColor = [UIColor grayColor];
    }
    return _toolView;
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

@end
