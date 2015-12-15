//
//  GHIDEEditor.m
//  CodeAdd
//
//  Created by YongCheHui on 15/12/14.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import "GHIDEEditor.h"
#import "IDEFoundation.h"

@implementation GHIDEEditor
+ (NSWindowController *)windowController {
    return [[NSApp keyWindow] windowController];
}

+ (id)currentEditor {
    if ([[self windowController]
         isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController =
        (IDEWorkspaceWindowController *)[self windowController];
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (NSTextView *)textView {
    if ([[self currentEditor]
         isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return [[self currentEditor] textView];
    }
    
    if ([[self currentEditor]
         isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        return [[self currentEditor] keyTextView];
    }
    
    return nil;
}

+ (BOOL)textViewHasSelection {
    return [[self textView] selectedRange].length > 0;
}

@end
