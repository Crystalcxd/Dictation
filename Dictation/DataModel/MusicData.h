//
//  MusicData.h
//  Dictation
//
//  Created by Michael on 15/12/29.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface MusicData : NSObject

/** 列表名 */
@property (nonatomic , strong) NSString *musicName;
/** 数据库名 */
@property (nonatomic , strong) NSString *indexName;
@property (nonatomic , assign) NSInteger duration;
@property (nonatomic , strong) NSMutableArray *musicTag;

/** 是否播放过 */
@property (nonatomic , assign) BOOL hasPlay;
@end
