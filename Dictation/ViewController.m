//
//  ViewController.m
//  Dictation
//
//  Created by Michael on 15/12/27.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import "ViewController.h"

#import "SliderViewController.h"
#import "MusicListViewController.h"
#import "RecoderViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "MusicCell.h"
#import "TFLargerHitButton.h"

#import "SNCircleProgressView.h"
#import "RBDMuteSwitch.h"

static NSString * const musicIdentifier = @"music";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,MusicCellDelegate,AVAudioPlayerDelegate,RBDMuteSwitchDelegate>

@property (nonatomic , strong) NSMutableArray *defaultArray;
@property (nonatomic , strong) NSMutableArray *userArray;
@property (nonatomic , strong) NSMutableArray *recentArray;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) AVAudioPlayer *audioPlayer;//播放器

@property (nonatomic , strong) NSIndexPath *currentIndexPath;

@property (nonatomic , strong) NSTimer *timer;                 //监控音频播放进度

@property (nonatomic , assign) NSInteger time;

@property (nonatomic , strong) MusicData *currentMusicData;

@property (nonatomic , assign) ViewType type;

@property (nonatomic , strong) NSIndexPath *indexPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserData) name:@"refreshUserData" object:nil];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH * 0.5 - 35, 30, 70, 20)];
    title.font = [UIFont systemFontOfSize:14.0];
    title.textColor = HexRGB(0x6E6E6E);
    title.text = @"天天听写";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(16, 24, 34, 34)];
    icon.layer.cornerRadius = 17.0;
    icon.clipsToBounds = YES;
    icon.image = [UIImage imageNamed:@"user_head"];
    [self.view addSubview:icon];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(62, 23, 50, 17)];
    userName.font = [UIFont systemFontOfSize:12.0];
    userName.textColor = HexRGB(0xF1639E);
    userName.text = [Utility userNameWithScore:[WMUserDefault intValueForKey:@"score"]];
//    userName.text = @"最近的录音";
    [self.view addSubview:userName];
    
    UIImageView *coin = [[UIImageView alloc] initWithFrame:CGRectMake(63, 42, 13, 13)];
//    coin.layer.cornerRadius = 17.0;
    coin.image = [UIImage imageNamed:@"icn_coin"];
    [self.view addSubview:coin];
    
    UILabel *coinNum = [[UILabel alloc] initWithFrame:CGRectMake(83, 38, 20, 22)];
    coinNum.font = [UIFont systemFontOfSize:16.0];
    coinNum.textColor = HexRGB(0x26D1F5);
    coinNum.text = [NSString stringWithFormat:@"%d",[WMUserDefault intValueForKey:@"score"]];
    //    userName.text = @"最近的录音";
    [self.view addSubview:coinNum];

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn addTarget:self action:@selector(goUserInfoView) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(12, 23, 112, 38);
    [self.view addSubview:leftBtn];
    
    TFLargerHitButton *listBtn = [TFLargerHitButton buttonWithType:UIButtonTypeCustom];
    listBtn.frame = CGRectMake(SCREENWIDTH - 45, 35, 23, 19);
    [listBtn setImage:[UIImage imageNamed:@"fa-align-justify"] forState:UIControlStateNormal];
    [listBtn addTarget:self action:@selector(goMusicListView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:listBtn];
    
    UILabel *tableName = [[UILabel alloc] initWithFrame:CGRectMake(34, 65, 65, 17)];
    tableName.font = [UIFont systemFontOfSize:12.0];
    tableName.textColor = HexRGB(0x9B9B9B);
    tableName.text = @"最近的录音";
    [self.view addSubview:tableName];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 84, SCREENWIDTH, SCREENHEIGHT - 220)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tag = TABLEVIEW_BEGIN_TAG * 40;
    [self.view addSubview:self.tableView];
    
    self.defaultArray = [NSMutableArray new];
    if ([WMUserDefault arrayForKey:@"DefaultData"]) {
        [self.defaultArray addObjectsFromArray:[WMUserDefault arrayForKey:@"DefaultData"]];
    }
    
    self.userArray = [NSMutableArray new];
    if ([WMUserDefault arrayForKey:@"UserData"]) {
        [self.userArray addObjectsFromArray:[WMUserDefault arrayForKey:@"UserData"]];
    }
    
    self.recentArray = [NSMutableArray new];
    if ([WMUserDefault arrayForKey:@"RecentData"]) {
        [self.recentArray addObjectsFromArray:[WMUserDefault arrayForKey:@"RecentData"]];
    }
    
    UIButton * addMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    
    addMusic.frame = CGRectMake(35, SCREENHEIGHT - 100, SCREENWIDTH - 70, 48);
    addMusic.layer.cornerRadius = 24;
    addMusic.backgroundColor = HexRGB(0xF1639E);
    [addMusic setTitle:@" 添加录音" forState:UIControlStateNormal];
    [addMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addMusic setImage:[UIImage imageNamed:@"icn_add"] forState:UIControlStateNormal];
    [addMusic addTarget:self action:@selector(setNewMusic) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addMusic];
    
//    if ([WMUserDefault intValueForKey:@"lead"] == 0) {
        [self addLeadView];
        [WMUserDefault setIntValue:1 forKey:@"lead"];
//    }
}

- (void)addLeadView
{
    UIView *BG = [[UIView alloc] initWithFrame:self.view.bounds];
    BG.tag = TABLEVIEW_BEGIN_TAG * 2;
    BG.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self.view addSubview:BG];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64)];
    scroll.tag = TABLEVIEW_BEGIN_TAG * 25;
    scroll.backgroundColor = [UIColor clearColor];
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.bounces = NO;
    [scroll setContentSize:CGSizeMake(SCREENWIDTH * 2, 0)];
    
    UIImageView *pageOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bootpage1"]];
    pageOne.center = CGPointMake(SCREENWIDTH * 0.5, SCREENHEIGHT * 0.5 - 128);
    [scroll addSubview:pageOne];
    
    UIButton * nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    nextBtn.frame = CGRectMake(SCREENWIDTH * 0.5 - 107, SCREENHEIGHT - 200, 215, 48);
    nextBtn.layer.cornerRadius = 4.0;
    nextBtn.backgroundColor = HexRGB(0x26D1F5);
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:nextBtn];
    
    UIImageView *pageTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bootpage2"]];
    pageTwo.center = CGPointMake(SCREENWIDTH * 1.5, SCREENHEIGHT * 0.5 - 128);
    [scroll addSubview:pageTwo];
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backBtn.frame = CGRectMake(SCREENWIDTH * 1.5 - 107, SCREENHEIGHT - 200, 215, 48);
    backBtn.layer.cornerRadius = 4.0;
    backBtn.backgroundColor = HexRGB(0x26D1F5);
    [backBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [backBtn setTitle:@"开始使用" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:backBtn];
    
    [BG addSubview:scroll];
}

- (void)nextPage
{
    UIView *view = [self.view viewWithTag:TABLEVIEW_BEGIN_TAG];
    
    UIScrollView *scroll = [view viewWithTag:TABLEVIEW_BEGIN_TAG * 25];
    
    [scroll setContentOffset:CGPointMake(SCREENWIDTH, 0) animated:YES];
}

- (void)popBack
{
    [[self.view viewWithTag:TABLEVIEW_BEGIN_TAG * 2] removeFromSuperview];
//    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)refreshUserData
{
    if ([WMUserDefault arrayForKey:@"UserData"]) {
        [self.userArray removeAllObjects];
        [self.userArray addObjectsFromArray:[WMUserDefault arrayForKey:@"UserData"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"disappear");
}

-(void)addMusic
{
    self.type = ViewTypeAdd;
    
    [self setNewMusic];
}

-(void)setNewMusic
{
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    bgView.tag = AddViewTypeWindow;
    [self.view addSubview:bgView];
    
    UIView *playBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 70, 266)];
    playBG.tag = AddViewTypeAddBG;
    playBG.center = CGPointMake(SCREENWIDTH * 0.5, SCREENHEIGHT * 0.5);
    playBG.backgroundColor = HexRGB(0x26D1F5);
    playBG.layer.cornerRadius = 4.0;
    playBG.clipsToBounds = YES;
    [bgView addSubview:playBG];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(23, 7, 100, 17)];
    title.font = [UIFont systemFontOfSize:12.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"文件名称";
    [playBG addSubview:title];
    
    NSDateFormatter *defaultMatter = nil;
    
    defaultMatter = [[NSDateFormatter alloc] init];
    [defaultMatter setDateFormat:@"MMdd_H点mm分"];
    
    NSDate *timeDate = [NSDate date];
    
    NSString *timeString = [defaultMatter stringFromDate:timeDate];

    UIView *textFieldBG = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(title.frame), CGRectGetMaxY(title.frame) + 6, CGRectGetWidth(playBG.frame) - 42, 37)];
    textFieldBG.layer.cornerRadius = 4.0;
    textFieldBG.backgroundColor = [UIColor whiteColor];
    [playBG addSubview:textFieldBG];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(title.frame) + 10, CGRectGetMaxY(title.frame) + 6, CGRectGetWidth(playBG.frame) - 52, 37)];
    textField.tag = AddViewTypeTextField;
    textField.layer.cornerRadius = 4.0;
    textField.textColor = HexRGB(0xF1639E);
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.text = [NSString stringWithFormat:@"%@_%ld",timeString,self.userArray.count + 1];
    if (self.type == ViewTypeEdit) {
        MusicData *data = nil;
        if (self.currentIndexPath.section == 1) {
            data = [self.defaultArray objectAtIndex:self.currentIndexPath.row];
        }else{
            data = [self.userArray objectAtIndex:self.currentIndexPath.row];
        }

        textField.text = data.musicName;
    }
    [playBG addSubview:textField];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(title.frame), CGRectGetMaxY(textField.frame) + 13, 100, 17)];
    typeLabel.font = [UIFont systemFontOfSize:12.0];
    typeLabel.textColor = [UIColor whiteColor];
    typeLabel.text = @"类型";
    [playBG addSubview:typeLabel];
    
    MusicData *data = nil;
    if (self.type == ViewTypeEdit) {
        if (self.currentIndexPath.section == 1) {
            data = [self.defaultArray objectAtIndex:self.currentIndexPath.row];
        }else{
            data = [self.userArray objectAtIndex:self.currentIndexPath.row];
        }
    }

    
    for (int i = 0; i < 3; i++) {
        CGFloat width = (CGRectGetWidth(textField.frame) - 2 * 6) / 3;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = AddViewTypeMusicType + i;
        btn.frame = CGRectMake(CGRectGetMinX(title.frame) + i * (width + 6), CGRectGetMaxY(typeLabel.frame) + 4, width, 37);
        btn.layer.cornerRadius = 4.0;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 1.0;
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        
        [btn addTarget:self action:@selector(clickMusicTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (i) {
            case 0:
                [btn setTitle:@"小学" forState:UIControlStateNormal];
                break;
            case 1:
                [btn setTitle:@"语文" forState:UIControlStateNormal];
                break;
            case 2:
                [btn setTitle:@"英语" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        if (data) {
            if ([data.musicTag indexOfObject:btn.titleLabel.text] != NSNotFound) {
                btn.selected = YES;
                btn.layer.borderColor = HexRGB(0x087D97).CGColor;
                btn.backgroundColor = HexRGB(0x1DAAC8);
            }
        }
        
        [playBG addSubview:btn];
    }

    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(CGRectGetWidth(playBG.frame) * 0.5 - 70, CGRectGetHeight(playBG.frame) - 70, 140, 38);
    addBtn.layer.cornerRadius = 19.0;
    addBtn.layer.borderWidth = 1.0;
    addBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [addBtn setTitle:@"新建录音" forState:UIControlStateNormal];
    if (self.type == ViewTypeEdit) {
        [addBtn setTitle:@"编辑完成" forState:UIControlStateNormal];
    }
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [addBtn addTarget:self action:@selector(goAddMusicView) forControlEvents:UIControlEventTouchUpInside];
    [playBG addSubview:addBtn];
    
    TFLargerHitButton *closeBtn = [[TFLargerHitButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(playBG.frame) - 44, 0, 34, 34)];
    [closeBtn setImage:[UIImage imageNamed:@"icn_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeSetNewMusicView) forControlEvents:UIControlEventTouchUpInside];
    [playBG addSubview:closeBtn];
}

- (void)clickMusicTypeBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        btn.layer.borderColor = HexRGB(0x087D97).CGColor;
        btn.backgroundColor = HexRGB(0x1DAAC8);
    }else{
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.backgroundColor = [UIColor clearColor];
    }
}

- (void)goAddMusicView
{
    UIView *bgView = [self.view viewWithTag:AddViewTypeWindow];
    UIView *playBG = [bgView viewWithTag:AddViewTypeAddBG];
    
    UITextField *textField = [playBG viewWithTag:AddViewTypeTextField];

    if (self.type == ViewTypeEdit) {
        MusicData *data = nil;
        if (self.currentIndexPath.section == 1) {
            data = [self.defaultArray objectAtIndex:self.currentIndexPath.row];
        }else{
            data = [self.userArray objectAtIndex:self.currentIndexPath.row];
        }
        
        data.musicName = textField.text;

        NSMutableArray *array = [NSMutableArray array];
        
        for (int i = 0; i < 3; i++) {
            UIButton *btn = [playBG viewWithTag:AddViewTypeMusicType + i];
            if (btn && [btn isKindOfClass:[UIButton class]] && btn.selected) {
                [array addObject:btn.titleLabel.text];
            }
        }
        
        if (array.count != 0) {
            [data.musicTag removeAllObjects];
            [data.musicTag addObjectsFromArray:array];
        }
        
        [WMUserDefault setArray:self.defaultArray forKey:@"DefaultData"];
        [WMUserDefault setArray:self.userArray forKey:@"UserData"];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self removeSetNewMusicView];

        return;
    }
    
    MusicData *musicData = [MusicData new];
    
    
    musicData.musicName = textField.text;
    musicData.indexName = textField.text;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [playBG viewWithTag:AddViewTypeMusicType + i];
        if (btn && [btn isKindOfClass:[UIButton class]] && btn.selected) {
            [array addObject:btn.titleLabel.text];
        }
    }
    musicData.musicTag = [NSMutableArray arrayWithArray:array];
    
    [self removeSetNewMusicView];
    
    RecoderViewController *recoderVC = [[RecoderViewController alloc] initWithMusicData:musicData];
    [[SliderViewController sharedSliderController].navigationController pushViewController:recoderVC animated:YES];
}

-(void)removeSetNewMusicView
{
    UIView *view = [self.view viewWithTag:AddViewTypeWindow];
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0;
    }                completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

-(void)goUserInfoView
{
    [[SliderViewController sharedSliderController] leftItemClick];
}

-(void)goMusicListView
{
    MusicListViewController *musicListVC = [[MusicListViewController alloc] initWithNibName:nil bundle:nil];
    [[SliderViewController sharedSliderController].navigationController pushViewController:musicListVC animated:YES];
    [SliderViewController sharedSliderController].navigationController.navigationBarHidden = NO;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.userArray.count;
    }else{
        return self.defaultArray.count;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;//此处的EditingStyle可等于任意UITableViewCellEditingStyle，该行代码只在iOS8.0以前版本有作用，也可以不实现。
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        if (indexPath.section == 1) {
            if (self.defaultArray.count > indexPath.row) {
                [self.defaultArray removeObjectAtIndex:indexPath.row];
                [WMUserDefault setArray:self.defaultArray forKey:@"DefaultData"];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }else{
            if (self.userArray.count > indexPath.row) {
                MusicData *musicData = [self.userArray objectAtIndex:indexPath.row];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",musicData.indexName]];
                BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
                if (bRet) {
                    //
                    NSError *err;
                    [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
                }
                
                [self.userArray removeObjectAtIndex:indexPath.row];
                [WMUserDefault setArray:self.userArray forKey:@"UserData"];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
        NSLog(@"点击删除");
    }];//此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    deleteRoWAction.backgroundColor = HexRGB(0x26D1F5);
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.currentIndexPath = indexPath;
        
        self.type = ViewTypeEdit;
        
        [self setNewMusic];
    }];
    editRowAction.backgroundColor = HexRGB(0x26D1F5);//可以定义RowAction的颜色
    return @[deleteRoWAction, editRowAction];//最后返回这俩个RowAction 的数组
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
        self.audioPlayer.volume = 0.5;
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
    return;
}

- (void)showPlayView
{
    self.time = 0;
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    bgView.tag = PlayViewTypeWindow;
    [self.view addSubview:bgView];
    
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
    
    SNCircleProgressView *progressView = [[SNCircleProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(playBG.frame) * 0.5 - 92, 86, 184, 184)];
    progressView.userInteractionEnabled = NO;
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
    
    UISlider *voice = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMidX(btnBG.frame) - 110, CGRectGetMinY(timeLabel.frame) + 70, 220, 20)];
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
    SNCircleProgressView *progress = [playBG viewWithTag:PlayViewTypeProgress];

    if (btn.selected) {
        [self startMusicPlay];
        
        statusLabel.text = [NSString stringWithFormat:@"正在播放 %@",self.currentMusicData.musicName];
        progress.progressColor = HexRGB(0xFD4270);

        playLabel.text = @"暂 停";
        playLabel.textColor = HexRGB(0xFD4270);
        
        playImageView.image = [UIImage imageNamed:@"icn_pause"];
        
        [btn setTitle:@"结束" forState:UIControlStateNormal];
        btn.backgroundColor = HexRGB(0xFD4270);
        
        playBtn.selected = btn.selected;
    }else{
        [self removePlayView];
    }
}

- (void)playProgress
{
    self.time ++;
    
    UIView *bgView = [self.view viewWithTag:PlayViewTypeWindow];
    UIView *playBG = [bgView viewWithTag:PlayViewTypePlayBG];
    SNCircleProgressView *progress = [playBG viewWithTag:PlayViewTypeProgress];

    UILabel *timeLabel = [playBG viewWithTag:PlayViewTypeTimeLabel];
    if (timeLabel && [timeLabel isKindOfClass:[UILabel class]]) {
        timeLabel.text = [NSString stringWithFormat:@"%@%ld:%@%ld",self.time/60 >= 10 ? @"" : @"0",self.time/60,self.time%60 >= 10 ? @"" : @"0",self.time%60];
    }
    
    progress.progressValue = self.time * 1.0 /self.audioPlayer.duration;
}

- (void)removePlayView
{
    [self stopMusicPlay];
    
    UIView *view = [self.view viewWithTag:PlayViewTypeWindow];
    
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
    self.audioPlayer.volume = slider.value;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"finish");
    [self stopMusicPlay];
    
    UIView *bgView = [self.view viewWithTag:PlayViewTypeWindow];
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

@end
