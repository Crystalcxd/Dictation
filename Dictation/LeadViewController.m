//
//  LeadViewController.m
//  Dictation
//
//  Created by Michael on 16/1/5.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "LeadViewController.h"

#import "SliderViewController.h"

#import "Utility.h"

@interface LeadViewController ()

@end

@implementation LeadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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

    
    [self.view addSubview:scroll];
}

- (void)nextPage
{
    UIScrollView *scroll = [self.view viewWithTag:TABLEVIEW_BEGIN_TAG * 25];
    
    [scroll setContentOffset:CGPointMake(SCREENWIDTH, -20) animated:YES];
}

- (void)popBack
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
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
