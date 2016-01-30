//
//  WHC_MenuCell.h
//  Dictation
//
//  Created by Michael on 16/1/5.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHC_MenuCellDelegate;

@interface WHC_MenuCell : UITableViewCell

@property (nonatomic,assign)   CGFloat                 menuViewWidth;                //菜单总宽度
@property (nonatomic,retain)   NSArray               * menuItemTitles;               //每个菜单的标题
@property (nonatomic,retain)   NSArray               * menuItemTitleColors;          //每个菜单的文字颜色
@property (nonatomic,retain)   NSArray               * menuItemBackImages;           //每个菜单的背景图片
@property (nonatomic,retain)   NSArray               * menuItemNormalImages;         //每个菜单正常的图片
@property (nonatomic,retain)   NSArray               * menuItemSelectedImages;       //每个菜单选中的图片
@property (nonatomic,retain)   NSArray               * menuItemBackColors;           //每个菜单的背景颜色
@property (nonatomic,retain)   NSArray               * menuItemWidths;               //每个菜单的宽度
@property (nonatomic,strong)   UIView                * ContentView;                  //自定义内容view
@property (nonatomic,assign)   CGFloat                 fontSize;                     //字体大小
@property (nonatomic,assign)   NSInteger               index;                        //cell下标
@property (nonatomic,assign)   id<WHC_MenuCellDelegate>delegate;                     //cell代理

//单击菜单项
- (void)clickMenuItem:(UIButton*)sender;

//关闭菜单
- (BOOL)closeCellWithAnimation:(BOOL)b;

//关闭批量菜单
- (BOOL)closeCellWithTableView:(UITableView*)tableView index:(NSInteger)index animation:(BOOL)b;

//开始或者正在拉开菜单
- (void)startScrollviewCell:(BOOL)state x:(CGFloat)moveX;

//结束拉开菜单
- (void)didEndScrollViewCell:(BOOL)state;
@end

@protocol WHC_MenuCellDelegate <NSObject>

- (BOOL)WHC_MenuCell:(WHC_MenuCell*)whcCell didPullCell:(NSInteger)index;            //拉动tableView的回调

@end
