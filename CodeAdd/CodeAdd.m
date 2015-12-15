//
//  CodeAdd.m
//  CodeAdd
//
//  Created by YongCheHui on 15/12/14.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import "CodeAdd.h"
#import <Cocoa/Cocoa.h>
#import "GHIDEEditor.h"
#import "GHClassParser.h"

@interface CodeAdd()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation CodeAdd

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Code Add" action:nil keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [[menuItem submenu] addItem:actionMenuItem];
        [self createSubMenu:actionMenuItem];
    }
}

-(void)createSubMenu:(NSMenuItem *)rootMenuItem
{
    NSMenu *menu = [[NSMenu alloc]initWithTitle:@"Code Add"];
    
    NSMenuItem *codeAddDescripion = [[NSMenuItem alloc]initWithTitle:@"Code Add Description" action:@selector(menuTouch:) keyEquivalent:@""];
    [codeAddDescripion setTarget:self];
    [menu addItem:codeAddDescripion];
    
    NSMenuItem *codeAddCoding = [[NSMenuItem alloc]initWithTitle:@"Code Add Coding" action:@selector(menuTouch:) keyEquivalent:@""];
    [codeAddCoding setTarget:self];
    [menu addItem:codeAddCoding];
    
    NSMenuItem *codeAddCopying = [[NSMenuItem alloc]initWithTitle:@"Code Add Copying" action:@selector(menuTouch:) keyEquivalent:@""];
    [codeAddCopying setTarget:self];
    [menu addItem:codeAddCopying];
    
    [rootMenuItem setSubmenu:menu];
}

-(void)menuTouch:(NSMenuItem *)item
{
    NSTextView * textView = [GHIDEEditor textView];
    if (textView.selectedRanges.count == 0) {
        return;
    }
    NSString *all = textView.string;
    NSMutableArray<NSString *> *strs = [NSMutableArray new];
    for (NSValue *value in textView.selectedRanges) {
        NSRange range = [value rangeValue];
        [strs addObject:[all substringWithRange:range]];
    }
    GHClassParser *parser = [[GHClassParser alloc]initWithStrings:strs];
    NSString *copyStr = nil;
    if ([item.title isEqualToString:@"Code Add Description"]) {
        copyStr = [parser descriptionStrs];
    }
    else if ([item.title isEqualToString:@"Code Add Coding"]) {
        copyStr = [parser codingStrs];
    }
    else if ([item.title isEqualToString:@"Code Add Copying"]) {
        copyStr = [parser copyingStrs];
    }
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pb setString:copyStr forType:NSStringPboardType];
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
