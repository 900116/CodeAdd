//
//  NSString+GHBase.m
//  CodeAdd
//
//  Created by YongCheHui on 15/12/15.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import "NSString+GHBase.h"

@implementation NSString (GHBase)
-(NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
@end
