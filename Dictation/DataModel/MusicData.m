//
//  MusicData.m
//  Dictation
//
//  Created by Michael on 15/12/29.
//  Copyright © 2015年 Michael. All rights reserved.
//

#import "MusicData.h"

@implementation MusicData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.musicName forKey:@"musicName"];
    [aCoder encodeObject:self.indexName forKey:@"indexName"];
    [aCoder encodeObject:self.musicTag forKey:@"musicTag"];
    [aCoder encodeInteger:self.duration forKey:@"duration"];
    [aCoder encodeBool:self.hasPlay forKey:@"hasPlay"];
};

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.duration = [aDecoder decodeIntegerForKey:@"duration"];
        self.musicName = [aDecoder decodeObjectForKey:@"musicName"];
        self.indexName = [aDecoder decodeObjectForKey:@"indexName"];
        self.musicTag = [aDecoder decodeObjectForKey:@"musicTag"];
        self.hasPlay = [aDecoder decodeBoolForKey:@"hasPlay"];
    }
    
    return self;
}

@end
