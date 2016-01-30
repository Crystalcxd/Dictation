//
//  NSIndexPath+Key.m
//  WeMedia
//
//  Created by Kyle on 14-3-26.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#import "NSIndexPath+WMKey.h"

@implementation NSIndexPath(WMKey)

- (NSString *)WMKey
{
    return [NSString stringWithFormat:@"WMKey:Secion:%d,Row:%d",self.section,self.row];
}

@end
