//
//  LeftViewController.m
//  Dictation
//
//  Created by Michael on 16/1/4.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "LeftViewController.h"
#import "LeadViewController.h"
#import "SliderViewController.h"

#import "Utility.h"
#import "WMUserDefault.h"

#import <MessageUI/MessageUI.h>

@interface LeftViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HexRGB(0xFCF9F0);
    
    CGFloat width = [[SliderViewController sharedSliderController] LeftSContentOffset];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_head"]];
    imageview.center = CGPointMake(width * 0.5, 78);
    [self.view addSubview:imageview];
    
    UILabel *coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageview.frame) - 25, 129, 38, 17)];
    coinLabel.textColor = HexRGB(0x6E6E6E);
    coinLabel.font = [UIFont systemFontOfSize:12.0];
    coinLabel.text = @"听写币";
    [self.view addSubview:coinLabel];
    
    UIImageView *coin = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(coinLabel.frame) + 47, 127, 18, 18)];
    //    coin.layer.cornerRadius = 17.0;
    coin.image = [UIImage imageNamed:@"icn_coin"];
    [self.view addSubview:coin];

    UILabel *coinNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(coin.frame) + 25, 125, 17, 22)];
    coinNum.font = [UIFont systemFontOfSize:16.0];
    coinNum.textColor = HexRGB(0x26D1F5);
    coinNum.text = [NSString stringWithFormat:@"%d",[WMUserDefault intValueForKey:@"score"]];
    coinNum.tag = TABLEVIEW_BEGIN_TAG * 60;
    [self.view addSubview:coinNum];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(imageview.frame) - 70, 156, 140, 17)];
    userName.textAlignment = NSTextAlignmentCenter;
    userName.textColor = HexRGB(0x6E6E6E);
    userName.font = [UIFont systemFontOfSize:12.0];
    userName.text = [NSString stringWithFormat:@"称号：%@",[Utility userNameWithScore:[WMUserDefault intValueForKey:@"score"]]];
    userName.tag = TABLEVIEW_BEGIN_TAG * 50;
    [self.view addSubview:userName];

    for (int i = 0; i < 2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 234 + i * 55, [[SliderViewController sharedSliderController] LeftSContentOffset], 55);
        
        btn.tag = TABLEVIEW_BEGIN_TAG + i;
        
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame), CGRectGetWidth(btn.frame), 0.7)];
        line.backgroundColor = HexRGB(0xCCCCCC);
        [self.view addSubview:line];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(19, CGRectGetMinY(btn.frame), 140, 55)];
        title.textColor = HexRGB(0x26D1F5);
        title.font = [UIFont systemFontOfSize:16.0];
        if (i == 0) {
            title.text = @"使用说明";
        }else{
            title.text = @"改进建议";
        }
        [self.view addSubview:title];
    }
}

- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == TABLEVIEW_BEGIN_TAG) {
        [self goLeadView];
    }else{
        [self sendMail];
    }
}

- (void)goLeadView
{
    LeadViewController *leadVC = [[LeadViewController alloc] initWithNibName:nil bundle:nil];
    [[SliderViewController sharedSliderController].navigationController pushViewController:leadVC animated:YES];
}

- (void)sendMail
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:[NSArray arrayWithObject:@"910028867@qq.com"]];
    mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
    
    mailComposer.mailComposeDelegate = self; // Set the delegate
    
    [self presentViewController:mailComposer animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"Cancel the email", nil);
//            [self shareResult:msg];
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"Save the email successfully", nil);
//            [self shareResult:msg];
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"Email has been sent", nil);
//            [self shareCountServe];
//            [self shareResult:msg];
            break;
        case MFMailComposeResultFailed:
            msg = NSLocalizedString(@"Failed to send email", nil);
//            [self shareResult:msg];
            break;
        default:
            break;
    }
    
    NSLog(@"%@",msg);
    
//    NSLog(@"%ld",(long)[ShareData defaultShareData].shareType);
//    NSLog(@"%ld",(long)[ShareData defaultShareData].shareObjectType);
    [self dismissViewControllerAnimated:YES completion:^(){
        
    }];
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
