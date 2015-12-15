//
//  GHClassParser.m
//  CodeAdd
//
//  Created by YongCheHui on 15/12/15.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import "GHClassParser.h"
#import "NSString+GHBase.h"
#import "RegexKitLite.h"

@interface GHPropertyInfo:NSObject
{
    NSString *_name;
    NSString *_format;
    NSString *_decodeMethod;
    NSString *_encodeMethod;
}
-(instancetype)initWithString:(NSString *)propertyStr;
@property(nonatomic,copy) NSString *propertyName;
-(NSString *)descripHead;
-(NSString *)descripTail;
-(NSString *)decodeStr;
-(NSString *)encodeStr;
-(NSString *)copyStr;
@end

@implementation GHPropertyInfo
-(NSArray<NSString *>*)typeAndName:(NSString *)propertyStr
{
    propertyStr = [propertyStr substringFromIndex:9];
    propertyStr = [propertyStr stringByReplacingOccurrencesOfString:@";" withString:@""];
    //去掉IBOutlet
    propertyStr = [propertyStr stringByReplacingOccurrencesOfString:@"IBOutlet" withString:@""];
    NSInteger length = propertyStr.length+1;
    char c_str[length];
    [propertyStr getCString:c_str maxLength:length encoding:NSUTF8StringEncoding];
    BOOL begin = NO;
    NSMutableString *removeStr = [NSMutableString new];
    for (int i = 0; i < length; ++i) {
        char c = c_str[i];
        if (c == '(') {
            begin = YES;
        }
        if (begin) {
            [removeStr appendFormat:@"%c",c];
        }
        if (c == ')') {
            break;
        }
    }
    propertyStr = [propertyStr stringByReplacingOccurrencesOfString:removeStr withString:@""];
    //trim
    propertyStr = [propertyStr trim];
    
    NSArray *typeAndName = [propertyStr componentsSeparatedByString:@" "];
    NSMutableArray<NSString *>* removeOthers = [NSMutableArray new];
    for (NSString *str in typeAndName) {
        if (![str isEqualToString:@" "] && ![str isEqualToString:@""]) {
            if (![str isEqualToString:@"*"]) {
                [removeOthers addObject:str];
            }
        }
    }

    return removeOthers;
}

-(instancetype)initWithString:(NSString *)propertyStr
{
    self = [super init];
    if (self) {
        NSArray *typeAndName = [self typeAndName:propertyStr];
        _name = [[typeAndName[1] trim] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        NSString *type = [[typeAndName[0] trim] stringByReplacingOccurrencesOfString:@"*" withString:@""];

        if ([type isEqualToString:@"NSInteger"]) {
            _format = @"%ld";
            _decodeMethod = @"decodeIntegerForKey:";
            _encodeMethod = @"encodeInteger:";
        }
        else if ([type isEqualToString:@"NSTimeInterval"]) {
            _format = @"%lf";
            _decodeMethod = @"decodeDoubleForKey:";
            _encodeMethod = @"encodeDouble:";
        }
        else if([type isEqualToString:@"unsigned"])
        {
            _format = @"%u";
            _decodeMethod = @"decodeIntForKey:";
            _encodeMethod = @"encodeInt:";
        }
        else if([type isEqualToString:@"float"])
        {
            _format = @"%f";
            _decodeMethod = @"decodeDoubleForKey:";
            _encodeMethod = @"encodeDouble:";
        }
        else if([type isEqualToString:@"double"])
        {
            _format = @"%lf";
            _decodeMethod = @"decodeDoubleForKey:";
            _encodeMethod = @"encodeDouble:";
        }
        else if([type isEqualToString:@"BOOL"])
        {
            _format = @"%d";
            _decodeMethod = @"decodeBoolForKey:";
            _encodeMethod = @"encodeBool:";
            
        }
        else if([type isEqualToString:@"SEL"])
        {
            _format = @"%p";
        }
        else if([type rangeOfString:@"int"].location != NSNotFound)
        {
            NSMutableString *format = [NSMutableString stringWithString:@"%"];
            if ([type rangeOfString:@"unsigned"].location != NSNotFound) {
                [format appendString:@"u"];
            }
            if ([type rangeOfString:@"long"].location != NSNotFound) {
                [format appendString:@"l"];
            }
            if (format.length == 1) {
                [format appendString:@"d"];
            }
            _format = format;
            _decodeMethod = @"decodeIntegerForKey:";
            _encodeMethod = @"encodeInteger:";
        }
        else if([type rangeOfString:@"long"].location != NSNotFound)
        {
            NSMutableString *format = [NSMutableString stringWithString:@"%"];
            if ([type rangeOfString:@"unsigned"].location != NSNotFound) {
                [format appendString:@"u"];
            }
            [format appendString:@"l"];
            _decodeMethod = @"decodeIntegerForKey:";
            _encodeMethod = @"encodeInteger:";
            if ([type rangeOfString:@"double"].location != NSNotFound) {
                [format appendString:@"f"];
                _decodeMethod = @"decodeDoubleForKey:";
                _encodeMethod = @"encodeDouble:";
            }
            _format = format;
        }
        else
        {
            _format = @"%@";
            _decodeMethod = @"decodeObjectForKey:";
            _encodeMethod = @"encodeObject:";
        }
    }
    return self;
}


-(NSString *)descripHead
{
    return [NSString stringWithFormat:@"%@:%@",_name,_format];
}

-(NSString *)descripTail
{
    return [NSString stringWithFormat:@"self.%@",_name];
}

-(NSString *)decodeStr
{
    return [NSString stringWithFormat:@"\n\t\tself.%@ = [aDecoder %@@\"%@\"];",_name,_decodeMethod,_name];
}

-(NSString *)encodeStr
{
    return [NSString stringWithFormat:@"\n\t[aCoder %@_%@ forKey:@\"%@\"];",_encodeMethod,_name,_name];
}

-(NSString *)copyStr
{
    return [NSString stringWithFormat:@"\tobj.%@ = self.%@;\n",_name,_name];
}
@end

@implementation GHClassParser
{
    NSArray<NSString *>* _strings;
    NSMutableArray<GHPropertyInfo *> *_propertys;
}

-(instancetype)initWithStrings:(NSArray<NSString *> *)strings{
    self = [super init];
    if (self) {
        _strings = strings;
        _propertys = [NSMutableArray array];
        [self parserClassName];
    }
    return self;
}

-(void)parserClassName
{
    NSString *regex= @"@property.+;";
    for (NSString * str in _strings) {
        NSArray *propertyStrs = [str componentsMatchedByRegex:regex];
        for (NSString *propertyStr in propertyStrs) {
            [_propertys addObject:[[GHPropertyInfo alloc] initWithString:propertyStr]];
        }
    }
}

-(NSString *)codingStrs
{
    NSMutableString *decodeStr = [NSMutableString stringWithFormat:@"\n-(instancetype)initWithCoder:(NSCoder *)aDecoder\n{\n"];
    [decodeStr appendString:@"\tself = [super init];\n\tif(self){"];
    NSMutableString *encodeStr = [NSMutableString stringWithFormat:@"\n-(void)encodeWithCoder:(NSCoder *)aCoder\n{"];
    
    for (GHPropertyInfo *info in _propertys) {
        [decodeStr appendString:info.decodeStr];
        [encodeStr appendString:info.encodeStr];
    }
    
    [encodeStr appendFormat:@"\n}\n"];
    [decodeStr appendFormat:@"\n\t}\n\treturn self;\n}\n"];

    return [NSString stringWithFormat:@"%@\n%@",decodeStr,encodeStr];
}

-(NSString *)copyingStrs
{
    NSMutableString *copyHead = [NSMutableString stringWithFormat:@"\n-(id)copyWithZone:(NSZone *)zone\n{\n"];
    [copyHead appendString:@"\ttypeof(self) obj = [[[self class] allocWithZone:zone]init];\n"];
    for (GHPropertyInfo *info in _propertys) {
        [copyHead appendString:info.copyStr];
    }
    [copyHead appendFormat:@"return obj;\n}\n"];
    return copyHead;
}


-(NSString *)descriptionStrs
{
    NSMutableString *descrptionHead = [NSMutableString stringWithFormat:@"\n-(NSString *)description{\n\treturn [NSString stringWithFormat:@\"{"];
    NSMutableString *descrptionTail = [NSMutableString stringWithFormat:@""];
    for (GHPropertyInfo *info in _propertys) {
        [descrptionHead appendString:info.descripHead];
        [descrptionTail appendString:info.descripTail];
        if ([_propertys indexOfObject:info]!=_propertys.count-1) {
            [descrptionHead appendFormat:@","];
            [descrptionTail appendFormat:@","];
        }
    }
    [descrptionHead appendFormat:@"}\","];
    [descrptionTail appendFormat:@"];\n}\n"];
    return [NSString stringWithFormat:@"%@%@",descrptionHead,descrptionTail];
}
@end
