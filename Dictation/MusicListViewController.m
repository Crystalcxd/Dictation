//
//  MusicListViewController.m
//  Dictation
//
//  Created by Michael on 15/12/30.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import "MusicListViewController.h"
#import "SliderViewController.h"

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>

#import "MusicCell.h"
#import "TFLargerHitButton.h"

#import "WMUserDefault.h"

#import "SNCircleProgressView.h"
#import "RBDMuteSwitch.h"

static NSString * const musicIdentifier = @"music";

@interface MusicListViewController ()<UITableViewDataSource,UITableViewDelegate,MusicCellDelegate,AVAudioPlayerDelegate,RBDMuteSwitchDelegate>

@property (nonatomic , strong) NSMutableArray *defaultArray;
@property (nonatomic , strong) NSMutableArray *userArray;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) AVAudioPlayer *audioPlayer;//播放器

@property (nonatomic , strong) NSIndexPath *currentIndexPath;

@property (nonatomic , strong) NSTimer *timer;                 //监控音频播放进度

@property (nonatomic , strong) MusicData *currentMusicData;

@property (nonatomic , assign) NSInteger time;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    title.text = @"我的录音库";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = HexRGB(0x9B9B9B);
    title.font = [UIFont systemFontOfSize:16.0];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    self.defaultArray = [NSMutableArray new];
    if ([WMUserDefault arrayForKey:@"DefaultData"]) {
        [self.defaultArray addObjectsFromArray:[WMUserDefault arrayForKey:@"DefaultData"]];
    }
    self.userArray = [NSMutableArray new];
    if ([WMUserDefault arrayForKey:@"UserData"]) {
        [self.userArray addObjectsFromArray:[WMUserDefault arrayForKey:@"UserData"]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SliderViewController sharedSliderController].navigationController.navigationBarHidden = YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.defaultArray.count;
    }else{
        return self.userArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicCell *cell = (MusicCell *)[tableView dequeueReusableCellWithIdentifier:musicIdentifier];
    if (cell == nil) {
        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:musicIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    if (indexPath.section == 1) {
        if (indexPath.row < self.defaultArray.count) {
            MusicData *musicData = [self.defaultArray objectAtIndex:indexPath.row];
            
            [cell configCellWith:musicData];
        }
    }else{
        if (indexPath.row < self.userArray.count) {
            MusicData *musicData = [self.userArray objectAtIndex:indexPath.row];
            
            [cell configCellWith:musicData];
        }
    }
    
    return cell;
}

#pragma mark - MusicCellDelegate

- (void)goPlayWithIndex:(NSIndexPath *)index
{
    self.currentIndexPath = index;
    
    if (self.currentIndexPath.section == 1) {
        MusicData *musicData = [self.defaultArray objectAtIndex:self.currentIndexPath.row];
        
        musicData.hasPlay = YES;

        self.currentMusicData = musicData;
        
        NSString *urlStr= [[NSBundle mainBundle]pathForResource:musicData.indexName ofType:@"mp3"];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        self.audioPlayer  =[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        self.audioPlayer.numberOfLoops=0;//设置为0不循环
        self.audioPlayer.volume = 1.0;
        self.audioPlayer.delegate=self;
        [self.audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            //            return nil;
        }
        
        [WMUserDefault setArray:self.defaultArray forKey:@"DefaultData"];
    }else{
        MusicData *musicData = [self.userArray objectAtIndex:self.currentIndexPath.row];
        
        musicData.hasPlay = YES;
        
        self.currentMusicData = musicData;
        
        NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",self.currentMusicData.indexName]];
        
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        self.audioPlayer  =[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        self.audioPlayer.numberOfLoops=0;//设置为0不循环
        self.audioPlayer.volume = 1.0;
        self.audioPlayer.delegate=self;
        [self.audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            //            return nil;
        }
        
        [WMUserDefault setArray:self.userArray forKey:@"UserData"];
    }

    [[RBDMuteSwitch sharedInstance] setDelegate:self];
    [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
    
    [self showPlayView];
}

- (void)showPlayView
{
    self.time = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIView *bgView = [[UIView alloc] initWithFrame:appDelegate.window.bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    bgView.tag = PlayViewTypeWindow;
    [appDelegate.window addSubview:bgView];
    
    UIView *playBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 35, SCREENHEIGHT < 508 ? SCREENHEIGHT - 20 : 508)];
    playBG.tag = PlayViewTypePlayBG;
    playBG.center = CGPointMake(SCREENWIDTH * 0.5, SCREENHEIGHT * 0.5);
    playBG.backgroundColor = [UIColor whiteColor];
    playBG.layer.cornerRadius = 4.0;
    playBG.clipsToBounds = YES;
    [bgView addSubview:playBG];
    
    TFLargerHitButton *closeBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(playBG.frame) - 44, 0, 34, 34)];
    [closeBtn setImage:[UIImage imageNamed:@"icn_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removePlayView) forControlEvents:UIControlEventTouchUpInside];
    [playBG addSubview:closeBtn];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, CGRectGetWidth(playBG.frame), 20)];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.font = [UIFont systemFontOfSize:14.0];
    statusLabel.textColor = HexRGB(0x6E6E6E);
    if (self.currentMusicData) {
        statusLabel.text = [NSString stringWithFormat:@"准备播放 %@",self.currentMusicData.musicName];
    }
    statusLabel.tag = PlayViewTypeStatusLabel;
    [playBG addSubview:statusLabel];
    
    SNCircleProgressView *progressView = [[SNCircleProgressView alloc]initWithFrame:CGRectMake(CGRectGetWidth(playBG.frame) * 0.5 - 92, 86, 184, 184)];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.tag = PlayViewTypeProgress;
    progressView.progressColor = HexRGB(0x26D1F5);
    progressView.progressStrokeWidth = 4.f;
    progressView.progressTrackColor = [UIColor whiteColor];
    
    [playBG addSubview:progressView];

    UIView *btnBG = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(playBG.frame) * 0.5 - 89, 90, 178, 178)];
    btnBG.layer.cornerRadius = 89;
    btnBG.clipsToBounds = YES;
    btnBG.backgroundColor = HexRGB(0xF5F5F5);
    btnBG.layer.borderWidth = 1.0;
    btnBG.layer.borderColor = HexRGB(0xD3D3D3).CGColor;
    [playBG addSubview:btnBG];
    
    UIImageView *playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(btnBG.frame) - 14, 153, 28, 33)];
    playImageView.tag = PlayViewTypePlayImageView;
    playImageView.image = [UIImage imageNamed:@"icn_play_big"];
    [playBG addSubview:playImageView];
    
    UILabel *playLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(btnBG.frame) - 25, CGRectGetMaxY(playImageView.frame) + 5, 50, 17)];
    playLabel.tag = PlayViewTypePlayLabel;
    playLabel.textAlignment = NSTextAlignmentCenter;
    playLabel.font = [UIFont systemFontOfSize:12.0];
    playLabel.textColor = HexRGB(0x26D1F5);
    playLabel.text = @"播 放";
    [playBG addSubview:playLabel];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = btnBG.frame;
    playBtn.tag = PlayViewTypePlayBtn;
    [playBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playBG addSubview:playBtn];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(btnBG.frame) - 25, CGRectGetMaxY(playBtn.frame) + 25, 50, 17)];
    timeLabel.tag = PlayViewTypeTimeLabel;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12.0];
    timeLabel.textColor = HexRGB(0x1C232B);
    timeLabel.text = @"00:00";
    [playBG addSubview:timeLabel];
    
    UISlider *voice = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMidX(btnBG.frame) - 110, CGRectGetMinY(timeLabel.frame) + 70, 220, 2)];
    voice.value = self.audioPlayer.volume;
    voice.minimumValueImage = [UIImage imageNamed:@"soundMIN"];
    voice.maximumValueImage = [UIImage imageNamed:@"soundMAX"];
    [voice addTarget:self action:@selector(changeSound:) forControlEvents:UIControlEventValueChanged];
    [playBG addSubview:voice];
    
    UIButton *playBtnTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtnTwo.tag = PlayViewTypePlayBtnTwo;
    playBtnTwo.frame = CGRectMake(CGRectGetMidX(btnBG.frame) - 70, CGRectGetHeight(playBG.frame) - 82, 140, 38);
    playBtnTwo.layer.cornerRadius = 19.0;
    playBtnTwo.backgroundColor = HexRGB(0x26D1F5);
    [playBtnTwo setTitle:@"播放" forState:UIControlStateNormal];
    [playBtnTwo setTitleColor:HexRGB(0xFCF9F0) forState:UIControlStateNormal];
    [playBtnTwo.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [playBtnTwo addTarget:self action:@selector(playMusicTwo:) forControlEvents:UIControlEventTouchUpInside];
    
    [playBG addSubview:playBtnTwo];
}

- (void)playMusic:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    UIView *playBG = [btn superview];
    
    btn.selected = !btn.selected;
    
    UILabel *statusLabel = [playBG viewWithTag:PlayViewTypeStatusLabel];
    UILabel *playLabel = [playBG viewWithTag:PlayViewTypePlayLabel];
    UIImageView *playImageView = [playBG viewWithTag:PlayViewTypePlayImageView];
    UIButton *playBtnTwo = [playBG viewWithTag:PlayViewTypePlayBtnTwo];
    SNCircleProgressView *progress = [playBG viewWithTag:PlayViewTypeProgress];

    if (btn.selected) {
        [self startMusicPlay];
        progress.progressColor = HexRGB(0xFD4270);

        statusLabel.text = [NSString stringWithFormat:@"正在播放 %@",self.currentMusicData.musicName];
        
        playLabel.text = @"暂 停";
        playLabel.textColor = HexRGB(0xFD4270);
        
        playImageView.image = [UIImage imageNamed:@"icn_pause"];
        
        [playBtnTwo setTitle:@"结束" forState:UIControlStateNormal];
        playBtnTwo.backgroundColor = HexRGB(0xFD4270);
        playBtnTwo.selected = btn.selected;
        
    }else{
        [self pauseMusicPlay];
        progress.progressColor = HexRGB(0x26D1F5);

        statusLabel.text = [NSString stringWithFormat:@"准备播放 %@",self.currentMusicData.musicName];
        
        playLabel.text = @"播 放";
        playLabel.textColor = HexRGB(0x26D1F5);
        
        playImageView.image = [UIImage imageNamed:@"icn_play_big"];
        
        [playBtnTwo setTitle:@"播放" forState:UIControlStateNormal];
        playBtnTwo.backgroundColor = HexRGB(0x26D1F5);
        playBtnTwo.selected = btn.selected;
    }
}

- (void)playMusicTwo:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    UIView *playBG = [btn superview];
    
    btn.selected = !btn.selected;
    
    UILabel *statusLabel = [playBG viewWithTag:PlayViewTypeStatusLabel];
    UILabel *playLabel = [playBG viewWithTag:PlayViewTypePlayLabel];
    UIImageView *playImageView = [playBG viewWithTag:PlayViewTypePlayImageView];
    UIButton *playBtn = [playBG viewWithTag:PlayViewTypePlayBtn];
    UILabel *timeLabel = [playBG viewWithTag:PlayViewTypeTimeLabel];
    
    if (btn.selected) {
        [self startMusicPlay];
        
        statusLabel.text = [NSString stringWithFormat:@"正在播放 %@",self.currentMusicData.musicName];
        
        playLabel.text = @"暂 停";
        playLabel.textColor = HexRGB(0xFD4270);
        
        playImageView.image = [UIImage imageNamed:@"icn_pause"];
        
        [btn setTitle:@"结束" forState:UIControlStateNormal];
        btn.backgroundColor = HexRGB(0xFD4270);
        
        playBtn.selected = btn.selected;
    }else{
        [self stopMusicPlay];
        
        statusLabel.text = [NSString stringWithFormat:@"准备播放 %@",self.currentMusicData.musicName];
        
        playLabel.text = @"播 放";
        playLabel.textColor = HexRGB(0x26D1F5);
        
        playImageView.image = [UIImage imageNamed:@"icn_play_big"];
        
        timeLabel.text = @"00:00";
        
        [btn setTitle:@"播放" forState:UIControlStateNormal];
        btn.backgroundColor = HexRGB(0x26D1F5);
        
        playBtn.selected = btn.selected;
    }
}

- (void)playProgress
{
    self.time ++;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIView *bgView = [appDelegate.window viewWithTag:PlayViewTypeWindow];
    UIView *playBG = [bgView viewWithTag:PlayViewTypePlayBG];
    SNCircleProgressView *progress = [playBG viewWithTag:PlayViewTypeProgress];

    UILabel *timeLabel = [playBG viewWithTag:PlayViewTypeTimeLabel];
    if (timeLabel && [timeLabel isKindOfClass:[UILabel class]]) {
        timeLabel.text = [NSString stringWithFormat:@"%@%d:%@%d",self.time/60 >= 10 ? @"" : @"0",self.time/60,self.time%60 >= 10 ? @"" : @"0",self.time%60];
    }
    
    progress.progressValue = self.time * 1.0 /self.audioPlayer.duration;
}

- (void)removePlayView
{
    [self stopMusicPlay];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIView *view = [appDelegate.window viewWithTag:PlayViewTypeWindow];
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0;
    }                completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
    
    [self.tableView reloadData];
}

- (void)startMusicPlay
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playProgress)userInfo:nil repeats:YES];
    [self.audioPlayer play];
}

- (void)pauseMusicPlay
{
    [self.audioPlayer pause];
    [self.timer invalidate];
}

- (void)stopMusicPlay
{
    self.audioPlayer.currentTime = 0;
    [self.audioPlayer stop];
    [self.timer invalidate];
}

- (void)changeSound:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSLog(@"%f",slider.value);
    self.audioPlayer.volume = slider.value;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"finish");
    [self stopMusicPlay];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIView *bgView = [appDelegate.window viewWithTag:PlayViewTypeWindow];
    UIView *playBG = [bgView viewWithTag:PlayViewTypePlayBG];
    
    UILabel *statusLabel = [playBG viewWithTag:PlayViewTypeStatusLabel];
    UILabel *playLabel = [playBG viewWithTag:PlayViewTypePlayLabel];
    UIImageView *playImageView = [playBG viewWithTag:PlayViewTypePlayImageView];
    UIButton *playBtn = [playBG viewWithTag:PlayViewTypePlayBtn];
    UILabel *timeLabel = [playBG viewWithTag:PlayViewTypeTimeLabel];
    UIButton *playBtnTwo = [playBG viewWithTag:PlayViewTypePlayBtnTwo];
    SNCircleProgressView *progress = [playBG viewWithTag:PlayViewTypeProgress];

    statusLabel.text = [NSString stringWithFormat:@"准备播放 %@",self.currentMusicData.musicName];
    
    playLabel.text = @"播 放";
    playLabel.textColor = HexRGB(0x26D1F5);
    
    playImageView.image = [UIImage imageNamed:@"icn_play_big"];
    
    timeLabel.text = @"00:00";

    self.time = 0;
    
    progress.progressValue = 0.0;
    progress.progressColor = HexRGB(0x26D1F5);

    [playBtnTwo setTitle:@"播放" forState:UIControlStateNormal];
    playBtnTwo.backgroundColor = HexRGB(0x26D1F5);
    
    playBtnTwo.selected = NO;
    playBtn.selected = NO;
}

- (void)isMuted:(BOOL)muted {
    if (muted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的手机处于静音状态，播放功能将无法正常使用" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        NSLog(@"Not Muted");
    }
    [[RBDMuteSwitch sharedInstance] setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
