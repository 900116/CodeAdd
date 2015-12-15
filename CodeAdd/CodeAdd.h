//
//  CodeAdd.h
//  CodeAdd
//
//  Created by YongCheHui on 15/12/14.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import <AppKit/AppKit.h>

@class CodeAdd;

static CodeAdd *sharedPlugin;

@interface CodeAdd : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end