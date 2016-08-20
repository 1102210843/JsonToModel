//
//  SYSourceListCell.m
//  JsonToModel
//
//  Created by 孙宇 on 16/8/1.
//  Copyright © 2016年 孙宇. All rights reserved.
//

#import "SYSourceListCell.h"

@implementation SYSourceListCell

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]){
        
        self.checkImageView = [[NSImageView alloc]initWithFrame:CGRectMake(50, 10, 20, 20)];
        [self.checkImageView setImage:[NSImage imageNamed:@"check"]];
        [self addSubview:self.checkImageView];
        
    }
    return self;
}

@end
