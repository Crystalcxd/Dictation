//
//  MusicCell.h
//  Dictation
//
//  Created by Michael on 15/12/29.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MusicData.h"

@protocol MusicCellDelegate;

@interface MusicCell : UITableViewCell

@property (nonatomic, assign) id<MusicCellDelegate>delegate;
@property (nonatomic, assign) NSIndexPath *indexPath;

- (void)configCellWith:(id)objc;

@end

@protocol MusicCellDelegate <NSObject>
@optional

- (void)goPlayWithIndex:(NSIndexPath *)index;

@end
