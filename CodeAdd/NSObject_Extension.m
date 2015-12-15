//
//  NSObject_Extension.m
//  CodeAdd
//
//  Created by YongCheHui on 15/12/14.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//


#import "NSObject_Extension.h"
#import "CodeAdd.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[CodeAdd alloc] initWithBundle:plugin];
        });
    }
}
@end
