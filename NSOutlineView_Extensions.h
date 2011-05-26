//
//  NSOutlineView_Extensions.h
//
//  Copyright (c) 2001-2002, Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSOutlineView (DonerExtensions)

- (NSArray*)allSelectedItems;
- (void)selectItems:(NSArray*)items byExtendingSelection:(BOOL)extend;

@end

// This is the class used for the group outline view...
@interface DragToOutlineView : NSOutlineView {
}

@end

// This is the class used for the file browser...
@interface DragFromOutlineView : NSOutlineView {
}

@end