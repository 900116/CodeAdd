//
//  GHIDEEditor.h
//  CodeAdd
//
//  Created by YongCheHui on 15/12/14.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHIDEEditor : NSObject
+ (NSWindowController *)windowController;
+ (id)currentEditor;
+ (NSTextView *)textView;
+ (BOOL)textViewHasSelection;
@end
