//
//  GroupController.h
//  Velocity
//
//  Created by Mike Wille on 9/15/04.
//  Copyright 2004 Nerdo Latchkey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GroupTreeNode;
@class AppController;

@interface GroupController : NSObject {

	// The nodes currently being dragged around...
    NSArray *draggedNodes;
	
	// The group tree
	GroupTreeNode *groups;
	
	// this holds the 16 x 16 small icon used in the tree view)
	NSDictionary *fileIconsSmall;
	// this holds the 64 x 64 large icon (used in thumb display)
	NSDictionary *fileIconsLarge;
	
	IBOutlet NSOutlineView *groupOutlineView;
	IBOutlet AppController *appController;
	
	// The list of groups and their info... each entry in the array is an UploadGroup object...
	NSMutableArray *groupsArray;
	// the currently selected group.
	int curGroup;
}

- (void)addGroup:(id)sender;
- (void)deleteSelections:(id)sender;
- (void)outlineViewAction:(id)sender;

- (NSArray *)draggedNodes;
- (NSArray *)selectedNodes;

- (BOOL)allowOnDropOnGroup;
- (BOOL)allowOnDropOnLeaf;
- (BOOL)allowBetweenDrop;

@end
