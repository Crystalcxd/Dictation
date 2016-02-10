//
//  RecoderViewController.m
//  Dictation
//
//  Created by Michael on 15/12/30.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import "RecoderViewController.h"
#import "SliderViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "Utility.h"
#import "WMUserDefault.h"

@interface RecoderViewController ()<AVAudioRecorderDelegate>

@property (nonatomic , strong) MusicData *musicData;

@property (nonatomic , strong) AVAudioRecorder *audioRecorder;//音频录音机

@property (nonatomic , assign) NSInteger time;

@property (nonatomic , strong) NSTimer *timer;                 //监控音频播放进度

@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) UIView *recoderBG;
@property (nonatomic , strong) UIImageView *microphone;
@property (nonatomic , strong) UILabel *timeLabel;
@property (nonatomic , strong) UIImageView *tipImageView;
@property (nonatomic , strong) UILabel *tipLabel;
@property (nonatomic , strong) UIButton *finishBtn;
@property (nonatomic , strong) UIButton *startBtn;
@end

@implementation RecoderViewController

- (instancetype)initWithMusicData:(MusicData *)musicData
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.musicData = musicData;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAudioSession];

    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
//            return nil;
        }
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, SCREENWIDTH, 20)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = HexRGB(0xF1639E);
    self.titleLabel.text = [NSString stringWithFormat:@"%@ 准备录音",self.musicData.musicName];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.titleLabel];
    
    self.recoderBG = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 92, 146, 184, 184)];
    self.recoderBG.layer.cornerRadius = 92;
    self.recoderBG.backgroundColor = HexRGB(0xFDFDFD);
    self.recoderBG.layer.borderColor = HexRGB(0xEAEAE9).CGColor;
    self.recoderBG.layer.borderWidth = 1.0;
    [self.view addSubview:self.recoderBG];
    
    self.microphone = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 9, 207, 18, 31)];
    self.microphone.image = [UIImage imageNamed:@"icn_microphone"];
    [self.view addSubview:self.microphone];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 25, 246, 50, 20)];
    self.timeLabel.font = [UIFont systemFontOfSize:14.0];
    self.timeLabel.textColor = HexRGB(0x6E6E6E);
    self.timeLabel.text = @"00:00";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timeLabel];
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.frame = self.recoderBG.frame;
    [self.startBtn addTarget:self action:@selector(startRecoder:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
    
    self.tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 20, 319, 40, 46)];
    self.tipImageView.image = [UIImage imageNamed:@"icn_hand"];
    [self.view addSubview:self.tipImageView];
    
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 70, 375, 140, 22)];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont systemFontOfSize:16.0];
    self.tipLabel.textColor = HexRGB(0x9B9B9B);
    self.tipLabel.text = @"点击开始录音";
    [self.view addSubview:self.tipLabel];
    
    self.finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 96, 410, 192, 38)];
    self.finishBtn.layer.cornerRadius = 19.0;
    self.finishBtn.backgroundColor = HexRGB(0xF1639E);
    [self.finishBtn setTitle:@"结束录音" forState:UIControlStateNormal];
    [self.finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.finishBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.finishBtn addTarget:self action:@selector(finishRecoder:) forControlEvents:UIControlEventTouchUpInside];
    self.finishBtn.hidden = YES;
    [self.view addSubview:self.finishBtn];
}

- (void)startRecoder:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.selected) {
        return;
    }
    
    btn.selected = !btn.selected;
    
    self.finishBtn.hidden = NO;
    
    self.tipImageView.hidden = YES;
    self.tipLabel.hidden = YES;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ 录音中...",self.musicData.musicName];
    
    self.timeLabel.textColor = HexRGB(0xF1639E);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audioPowerChange)userInfo:nil repeats:YES];
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
}

- (void)finishRecoder:(id)sender
{
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
    
    NSMutableArray *array = [NSMutableArray array];
    
    if ([WMUserDefault arrayForKey:@"UserData"]) {
        [array addObjectsFromArray:[WMUserDefault arrayForKey:@"UserData"]];
    }
    
    self.musicData.duration = self.time + 1;
    
    if (self.musicData.duration >= 10) {
        NSInteger score = [WMUserDefault intValueForKey:@"score"];
        if (self.musicData.duration < 50) {
            score = score + 1;
        }else{
            score = score + 5;
        }
        
        [WMUserDefault setIntValue:score forKey:@"score"];
    }
    
    [array insertObject:self.musicData atIndex:0];
    
    [WMUserDefault setArray:array forKey:@"UserData"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshUserData" object:nil];
    
    [self performSelector:@selector(popBack) withObject:nil afterDelay:0.5];
}

- (void)popBack
{
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",self.musicData.indexName]];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

-(void)audioPowerChange{
    self.time ++;
    self.timeLabel.text = [NSString stringWithFormat:@"%@%d:%@%d",self.time/60 >= 10 ? @"" : @"0",self.time/60,self.time%60 >= 10 ? @"" : @"0",self.time%60];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
