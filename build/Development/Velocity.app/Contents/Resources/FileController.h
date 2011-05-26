//
//  FileController.h
//  Velocity
//
//  Created by Mike Wille on 9/15/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileSystemItem;
@class AppController;

@interface FileController : NSObject {
	// The nodes currently being dragged around...
    NSArray *draggedNodes;
	
	// The root node of the view..
	FileSystemItem *root;
	NSString *rootPath;
	
	IBOutlet NSOutlineView *fileOutlineView;
	IBOutlet AppController *appController;
}

// Datasource...

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id) item;
- (id)outlineView:(NSOutlineView *)outlineView
			child:(int)index
			ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView
			objectValueForTableColumn:(NSTableColumn *)tableColumn
			byItem:(id)item;

// Dragging...
- (void)outlineViewAction:(id)sender;

- (NSArray *)draggedNodes;
- (NSArray *)selectedNodes;

- (BOOL)allowOnDropOnGroup;
- (BOOL)allowOnDropOnLeaf;
- (BOOL)allowBetweenDrop;

- (void)changeRoot:(NSString *)path;

@end
