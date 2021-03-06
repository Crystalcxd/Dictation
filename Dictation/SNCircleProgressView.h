//
//  SNCircleProgressView.h
//  Dictation
//
//  Created by Michael on 16/1/5.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCircleProgressView : UIView

/**
 *  进度值0-1.0之间
 */
@property (nonatomic,assign)CGFloat progressValue;

/**
 *  边宽
 */
@property(nonatomic,assign) CGFloat progressStrokeWidth;

/**
 *  进度条颜色
 */
@property(nonatomic,strong)UIColor *progressColor;

/**
 *  进度条轨道颜色
 */
@property(nonatomic,strong)UIColor *progressTrackColor;

@end
