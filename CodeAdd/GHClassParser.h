//
//  GHClassParser.h
//  CodeAdd
//
//  Created by YongCheHui on 15/12/15.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  类解析
 */
@interface GHClassParser : NSObject
/**
 *  init方法
 *
 *  @param strings 字符串
 *
 *  @return 对象
 */
-(instancetype)initWithStrings:(NSArray<NSString *> *)strings;
-(NSString *)descriptionStrs;
-(NSString *)codingStrs;
-(NSString *)copyingStrs;
@end
