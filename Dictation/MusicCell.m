//
//  MusicCell.m
//  Dictation
//
//  Created by Michael on 15/12/29.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import "MusicCell.h"

#import "Utility.h"

@interface MusicCell ()

@property (nonatomic , strong) UILabel *musicName;
@property (nonatomic , strong) UILabel *musicTime;
@property (nonatomic , strong) UILabel *musicTag;
@property (nonatomic , strong) UIButton *button;

@end

@implementation MusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.musicName = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, SCREENWIDTH - 18 - 70 - 35, 20)];
        self.musicName.textColor = HexRGB(0xF1639E);
        self.musicName.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.musicName];
        
        self.musicTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.musicName.frame), CGRectGetMaxY(self.musicName.frame) + 2, 50, 14)];
        self.musicTime.textColor = HexRGB(0x9B9B9B);
        self.musicTime.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.musicTime];
        
        self.musicTag = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.musicTime.frame), CGRectGetMinY(self.musicTime.frame), SCREENWIDTH - 18 - 70 - CGRectGetMaxX(self.musicTime.frame), 14)];
        self.musicTag.textColor = HexRGB(0x9B9B9B);
        self.musicTag.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.musicTag];
        
        self.button=[[ UIButton alloc ] initWithFrame : CGRectMake ( SCREENWIDTH - 18 - 70 , 0 , 70 , 57 )];
        //加文字
        [self.button setTitle : @"播放" forState: UIControlStateNormal ];
        [self.button setTitleColor :HexRGB(0x26D1F5) forState : UIControlStateNormal ];
        //加图片
        [self.button setImage :[ UIImage imageNamed : @"icn_play" ] forState : UIControlStateNormal ];
        //加边框
//        self.button. layer . borderColor =[ UIColor redColor ]. CGColor;
//        self.button. layer . borderWidth = 0.5 ;
        
        //改变图文位置 左右并排
        self.button. titleEdgeInsets = UIEdgeInsetsMake ( 0 , -self.button. imageView . frame . size . width , 0 , self.button. imageView . frame . size . width );
        self.button. imageEdgeInsets = UIEdgeInsetsMake ( 0 , self.button. titleLabel . frame . size . width + 15 , 0 , 0 );
        
        [self.button addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.button];
    }
    
    return self;
}

- (void)play:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(goPlayWithIndex:)]) {
        [self.delegate goPlayWithIndex:self.indexPath];
    }
}

- (void)configCellWith:(id)objc
{
    if ([objc isKindOfClass:[MusicData class]]) {
        MusicData *musicData = (MusicData *)objc;
        
        self.musicName.text = musicData.musicName;
        
        self.musicName.textColor = HexRGB(0xF1639E);
        if (musicData.hasPlay) {
            self.musicName.textColor = HexRGB(0x9B9B9B);
        }
        
        self.musicTime.text = [self timeStringFrom:musicData.duration];
        self.musicTag.text = [self tagStringFromArray:musicData.musicTag];
    }
}

- (NSString *)timeStringFrom:(NSInteger)time
{
    NSString *str = @"";
    
    str = [NSString stringWithFormat:@"%ld'%ld''",time/60,time%60];
    
    return str;
}

- (NSString *)tagStringFromArray:(NSArray *)array
{
    NSString *str = @"";
    
    NSInteger count = array.count;
    for ( int i = 0; i < count; i++) {
        NSString *string = [array objectAtIndex:i];
        if (i == 0) {
            str = [NSString stringWithFormat:@"%@%@",str,string];
        }else{
            str = [NSString stringWithFormat:@"%@ %@",str,string];
        }
    }
    
    return str;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
