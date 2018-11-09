//
//  TelnetClient.m
//  陈鼎星
//
//  Created by 陈鼎星 on 9/11/2018.
//  Copyright © 2018 陈鼎星. All rights reserved.
//

#import "TelnetClient.h"
#import "libtelnet.h"

@interface TelnetClient ()
{
    telnet_t *telnet;
    NSString *hostName;
    int port;
}

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@end

NSMutableData *recBuf;
bool timerStarted;

@implementation TelnetClient

static const telnet_telopt_t telopts[] = {
    { TELNET_TELOPT_ECHO,		TELNET_WONT, TELNET_DO   },
    { TELNET_TELOPT_TTYPE,		TELNET_WILL, TELNET_DONT },
    { TELNET_TELOPT_COMPRESS2,	TELNET_WONT, TELNET_DO   },
    { TELNET_TELOPT_MSSP,		TELNET_WONT, TELNET_DO   },
    { -1, 0, 0 }
};

static void _send(id client, const char *buffer, size_t size) {
    NSData *data = [NSData dataWithBytes:buffer length:size];
    void (*myObjCSelectorPointer)(id, SEL, NSData *)  = (void (*)(id,SEL,NSData *))[client methodForSelector:@selector(flushData:)];
    myObjCSelectorPointer(client, @selector(flushData:), data);
}

- (void)startTimer:(id)telnetDelegate{
    timerStarted = true;
    //暂时是设置的300ms的延时处理，后续可以调整
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(action:) userInfo:telnetDelegate repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)action:(NSTimer *)sender{
    NSLog(@"NSTimer: -------------------------------------------------");

    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *msg = [[NSString alloc] initWithData:recBuf encoding:gbkEncoding];
    if (msg == nil)
    {
        timerStarted = false;
        return;
    }

    SEL sel = @selector(didReceiveMessage:);
    id telnetDelegate = sender.userInfo;
    void (*myObjCSelectorPointer)(id, SEL, NSString *)  = (void (*)(id,SEL,NSString *))[telnetDelegate methodForSelector:sel];
    myObjCSelectorPointer(telnetDelegate, sel, msg);

    //如果成功处理完成，清空缓存
    [recBuf resetBytesInRange:NSMakeRange(0, recBuf.length)];
    [recBuf setLength:0];
    
    timerStarted = false;
}

static void _display(id client, id telnetDelegate, const char *buffer, size_t size) {
    NSLog(@"_display: ***********************************************************************");
    //中文编码转换
    NSData* data = [NSData dataWithBytes:buffer length:size];
    if (recBuf == nil) {
        recBuf = [[NSMutableData alloc] initWithData:data];
    }
    else{
        [recBuf appendData:data];
    }

    //收到消息后不马上处理，而是打开一个timer延时处理，防止后面有断包没有收完
    if (!timerStarted) {
        void (*myObjCSelectorPointer)(id, SEL, id)  = (void (*)(id,SEL, id))[client methodForSelector:@selector(startTimer:)];
        myObjCSelectorPointer(client, @selector(startTimer:), telnetDelegate);
    }
}
static void _doEcho(id telnetDelegate, int echo) {
    BOOL doEcho;
    if (echo) {
        doEcho = YES;
    } else {
        doEcho = NO;
    }
    SEL sel = @selector(shouldEcho:);
    void (*myObjCSelectorPointer)(id, SEL, BOOL)  = (void (*)(id,SEL,BOOL))[telnetDelegate methodForSelector:sel];
    myObjCSelectorPointer(telnetDelegate, sel, doEcho);
}

static void _event_handler(telnet_t *telnet, telnet_event_t *ev,
                           void *user_data) {
    //printf("%s %d\n", __func__, ev->type);

    TelnetClient *client = (__bridge TelnetClient *)user_data;
    id<TelnetDelegate> telnetDelegate = client.delegate;
    
    switch (ev->type) {
            /* data received */
        case TELNET_EV_DATA:
            //printf("data：%.*s", (int)ev->data.size, ev->data.buffer);
            _display(client, telnetDelegate, ev->data.buffer, ev->data.size);
            break;
            /* data must be sent */
        case TELNET_EV_SEND:
        {
            _send(client, ev->data.buffer, ev->data.size);
        }
            break;
            /* request to enable remote feature (or receipt) */
        case TELNET_EV_WILL:
            /* we'll agree to turn off our echo if server wants us to stop */
            if (ev->neg.telopt == TELNET_TELOPT_ECHO)
                _doEcho(telnetDelegate, 0);
//                do_echo = 0;
            break;
            /* notification of disabling remote feature (or receipt) */
        case TELNET_EV_WONT:
            if (ev->neg.telopt == TELNET_TELOPT_ECHO)
                _doEcho(telnetDelegate, 1);
//                do_echo = 1;
            break;
            /* request to enable local feature (or receipt) */
        case TELNET_EV_DO:
            break;
            /* demand to disable local feature (or receipt) */
        case TELNET_EV_DONT:
            break;
            /* respond to TTYPE commands */
        case TELNET_EV_TTYPE:
            /* respond with our terminal type, if requested */
            if (ev->ttype.cmd == TELNET_TTYPE_SEND) {
                telnet_ttype_is(telnet, "dumb");
            }
            break;
            /* respond to particular subnegotiations */
        case TELNET_EV_SUBNEGOTIATION:
            break;
            /* error */
        case TELNET_EV_ERROR:
            fprintf(stderr, "ERROR: %s\n", ev->error.msg);
            //exit(1);
        default:
            /* ignore */
            break;
    }
}

- (void)writeMessage:(NSString *)msg
{
    const char *buffer = [msg UTF8String];
    size_t size = [msg length];
    static char crlf[] = { '\r', '\n' };
    int i;
    
    for (i = 0; i != size; ++i) {
        
        if (buffer[i] == '\r' || buffer[i] == '\n') {
            telnet_send(telnet, crlf, 2);
        } else {
            telnet_send(telnet, buffer + i, 1);
        }
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    //NSLog(@"%s", __func__);
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:aRunLoop forMode:mode];
    [self.outputStream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)scheduleInRunLoop
{
    //NSLog(@"%s", __func__);
    [self scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)openStreams
{
    //NSLog(@"%s %@ %@", __func__, self.inputStream, self.outputStream);
    [self.inputStream open];
    [self.outputStream open];
}

- (void)setup:(NSString *)hostName Port:(int)port
{
    CFHostRef host = CFHostCreateWithName(NULL, (__bridge CFStringRef _Nonnull)(hostName));
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToCFHost(NULL, host, port, &readStream, &writeStream);
    CFRelease(host);
    if (!(readStream && writeStream)) {
        //NSLog(@"Failed to create read&write stream");
        return ;
    } else {
        //NSLog(@"Successfully create read&write stream");
    }
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self scheduleInRunLoop];
    [self openStreams];
    
    telnet = telnet_init(telopts, _event_handler, 0, (__bridge void *)(self)/*&sock*/);
}

- (void)dealloc
{
    //NSLog(@"%s", __func__);
    
    [self.inputStream close];
    [self.outputStream close];
    
    telnet_free(telnet);
}

- (void)postNotification:(NSString *)notificationName withObject:(id)anObject
{
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:anObject];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    //NSLog(@"%s event<%lu> stream<%@>", __func__, (unsigned long)eventCode, aStream);
    
    if (aStream == self.outputStream) {
        switch (eventCode) {
            case NSStreamEventHasSpaceAvailable:
                //
                break;
                
            default:
                break;
        } 
    } else if (aStream == self.inputStream) {
        switch (eventCode) {
            case NSStreamEventHasBytesAvailable:
            {
                // read data
                uint8_t buf[512*1024];
                NSInteger len = 0;
                memset(buf, 0, 512*1024);
                len = [(NSInputStream *)aStream read:buf maxLength:512*1024];
                if(len > 0) {
                    telnet_recv(telnet, buf, len);
                } else {
                    //NSLog(@"no buffer! server disconnected");
                    [self.outputStream close];
                    break;
                }
                
            }
                break;
            case NSStreamEventEndEncountered:
            {
                // close
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)flushData:(NSData *)buffer
{
    if (!buffer) {
        //NSLog(@"Error: nil buffer");
        return;
    }
    
    NSUInteger writed = [self.outputStream write:[buffer bytes] maxLength:[buffer length]];
    //NSLog(@"%@ send out <%lu> %@", self, writed, buffer);
}

@end
