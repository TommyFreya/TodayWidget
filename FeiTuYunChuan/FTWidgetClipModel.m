//
//  FTWidgetClipModel.m
//  MyWidget
//
//  Created by HMT on 14/10/29.
//  Copyright (c) 2014年 MTH. All rights reserved.
//

#import "FTWidgetClipModel.h" 

@implementation FTWidgetClipModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.userName = [aDecoder decodeObjectForKey:@"UserName"];
        self.content = [aDecoder decodeObjectForKey:@"Content"];
        self.clipTime = [aDecoder decodeObjectForKey:@"ClipTime"];
        self.isTure = [aDecoder decodeObjectForKey:@"IsTure"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_userName forKey:@"UserName"];
    [aCoder encodeObject:_content forKey:@"Content"];
    [aCoder encodeObject:_clipTime forKey:@"ClipTime"];
    [aCoder encodeObject:_isTure forKey:@"IsTure"];
}


@end
